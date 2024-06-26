from datetime import datetime
from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List,Optional
import  crud, models, schemas, database, auth
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime

models.Base.metadata.create_all(bind=database.engine)

app = FastAPI()

origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

@app.post("/signup", response_model=schemas.Token)
def signup(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = crud.create_user(db=db, user=user)
    access_token = auth.create_access_token(
        data={"sub": user.username}
    )
    return {"access_token": access_token, "token_type": "bearer"}


@app.post("/login", response_model=schemas.Token)
def login(user: schemas.UserCreate, db: Session = Depends(get_db)):
    user = crud.authenticate_user(db, user.username, user.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token = auth.create_access_token(
        data={"sub": user.username}
    )
    return {"access_token": access_token, "token_type": "bearer"}

@app.post("/token", response_model=schemas.Token)
def token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    return login(schemas.UserCreate(username= form_data.username,password=form_data.password) ,db)


@app.post("/activities", response_model=schemas.Activity)
def create_activity(activity: schemas.ActivityCreate, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    token_data = auth.verify_token(token, credentials_exception)
    return crud.create_activity(db=db, activity=activity, username=token_data.username).toActivityBase()


@app.get("/activities_delete", response_model=List[int])
def get_deleted_activities(db: Session = Depends(get_db), date: Optional[datetime] = None):
    return crud.get_deleted_activities(db,date)


@app.get("/activities/search", response_model=List[int])
def search_for_activities(
        last_update: Optional[datetime] = None,
        db: Session = Depends(get_db)):
    activities = crud.search_activities(db, last_update)
    return [activity.id for activity in activities]

@app.post("/activities/register", response_model=schemas.Message)
def register_activity(registration: schemas.ActivityRegistration, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    token_data = auth.verify_token(token, credentials_exception)
    return crud.register_for_activity(db=db, username=token_data.username, activity_id=registration.activityId)

@app.get("/activities/history", response_model=List[str])
def get_activity_history(username: str, db: Session = Depends(get_db)):
    activities = crud.get_user_activities(db, username)
    return [activity.id for activity in activities]

@app.get("/activities/{activity_id}", response_model=schemas.Activity)
def get_activity(activity_id: int, db: Session = Depends(get_db)):
    activity = crud.get_activity_by_id(db, activity_id)
    if activity is None:
        raise HTTPException(status_code=404, detail="Activity not found")
    return activity.toActivityBase()

@app.post("/feedback", response_model=schemas.Message)
def submit_feedback(feedback: schemas.FeedbackBase, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    token_data = auth.verify_token(token, credentials_exception)
    feedback.username = token_data.username
    try:
        return crud.post_feedback(db=db, feedback=feedback)
    except Exception as e:
        print(e)
        raise HTTPException(status_code=404, detail="Activity not found")

@app.get("/feedback", response_model=list[schemas.FeedbackBase])
def get_feedbacks(db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    token_data = auth.verify_token(token, credentials_exception)
    return crud.get_activity_feedback(db, token_data.username)

@app.delete("/activity/{activity_id}")
async def delete_activity(activity_id: int, db: Session = Depends(get_db),token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    token_data = auth.verify_token(token, credentials_exception)
    return crud.delete_activity(db, activity_id,token_data.username)

@app.post("/activity/{activity_id}/leave")
async def leave_activity(activity_id: int, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    token_data = auth.verify_token(token, credentials_exception)
    return crud.leave_activity(db,activity_id, token_data.username)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
#
