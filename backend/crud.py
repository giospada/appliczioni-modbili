from sqlalchemy.orm import Session
import models, schemas, auth
from fastapi import HTTPException, status
from datetime import datetime, timedelta

def get_user_by_username(db: Session, username: str):
    return db.query(models.User).filter(models.User.username == username).first()

def create_user(db: Session, user: schemas.UserCreate):
    db_user = get_user_by_username(db, username=user.username)
    if db_user:
        raise HTTPException(status_code=400, detail="Username already registered")
    hashed_password = auth.get_password_hash(user.password)
    db_user = models.User(username=user.username, hashed_password=hashed_password)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def authenticate_user(db: Session, username: str, password: str):
    user = get_user_by_username(db, username)
    if not user:
        return False
    if not auth.verify_password(password, user.hashed_password):
        return False
    return user

def create_activity(db: Session, activity: schemas.ActivityCreate, username: str):
    db_user = get_user_by_username(db, username=username)
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    db_activity = models.Activity(
            description=activity.description,
            time=activity.time,
            long=activity.position.long,
            lat=activity.position.lat,
            level=activity.attributes.level,
            price=activity.attributes.price,
            sport=activity.attributes.sport,
            number_of_people=activity.numberOfPeople ,
            creator=username,
            participants=[db_user])
    db.add(db_activity)
    db.commit()
    db.refresh(db_activity)
    return db_activity

def register_for_activity(db: Session, username: str, activity_id: int):
    db_user = get_user_by_username(db, username)
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    db_activity = db.query(models.Activity).filter(models.Activity.id == activity_id).first()
    if not db_activity:
        raise HTTPException(status_code=404, detail="Activity not found")
    if db_user in db_activity.participants:
        raise HTTPException(status_code=400, detail="User already registered for this activity")
    db_activity.participants.append(db_user)
    db.commit()
    return {"message": "Registration successful"}

def post_feedback(db: Session, feedback: schemas.FeedbackBase):
    db_feedback = models.Feedback(**feedback.model_dump())
    db.add(db_feedback)
    db.commit()
    db.refresh(db_feedback)
    return {"message": "Feedback submitted successfully"}


def get_activity_by_id(db: Session, activity_id: int):
    return db.query(models.Activity).filter(models.Activity.id == activity_id).first()

def get_activities(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Activity).offset(skip).limit(limit).all()

def search_activities(db: Session, sport: str, level: str, price: int, long: float, lat: float, radius: int):
    # For simplicity, this example does not implement actual geolocation-based searching.
    # A real implementation would require geospatial queries which SQLite does not support natively.
    # You might use PostGIS with PostgreSQL for a production scenario.
    return db.query(models.Activity).filter(
        models.Activity.sport == sport,
        models.Activity.level == level,
        models.Activity.price <= price
    ).all()

def get_user_activities(db: Session, username: str):
    db_user = get_user_by_username(db, username=username)
    if db_user:
        return db_user.activities
    else:
        raise HTTPException(status_code=404, detail="User not found")

