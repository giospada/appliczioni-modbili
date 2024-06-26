from typing import Optional
from sqlalchemy.orm import Session
import models, schemas, auth
from fastapi import HTTPException, status
from datetime import datetime, timedelta
import math

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

def delete_activity(db: Session, activity_id: int,username:str):
    activity = db.query(models.Activity).filter(models.Activity.id == activity_id).first()
    if activity is None:
        raise Exception("Activity not found")
    if activity.creator != username:
        raise Exception("User not authorized to delete activity")

    db.add(models.DeletedActivity(
        activity_id=activity.id,
        last_update=datetime.now(),
    ))
    db.delete(activity)

    db.commit()

def leave_activity(db: Session, activity_id: int, username: str):
    activity = db.query(models.Activity).filter(models.Activity.id == activity_id).first()
    if activity is None:
        raise Exception("Activity not found")
    user = db.query(models.User).filter(models.User.username == username).first()
    if user is None:
        raise Exception("User not found")
    if user not in activity.participants:
        raise Exception("User not in activity")
    activity.participants.remove(user)
    activity.last_update = datetime.now()
    db.commit()

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
            last_update=datetime.now(),
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
    db_activity.last_update = datetime.now()
    db.commit()
    return {"message": "Registration successful"}

def post_feedback(db: Session, feedback: schemas.FeedbackBase):
    db_feedback = models.Feedback(**feedback.model_dump())
    db.add(db_feedback)
    db.commit()
    db.refresh(db_feedback)
    return {"message": "Feedback submitted successfully"}


def get_activity_by_id(db: Session, activity_id: int):
    # get also partecipants
    return db.query(models.Activity).filter(models.Activity.id == activity_id).first()


def get_activities(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Activity).offset(skip).limit(limit).all()

def km_distance(long1: float, lat1: float, long2: float, lat2: float):
    # This is a simplified implementation of the Haversine formula
    # which calculates the distance between two points on the Earth's surface
    # given their longitudes and latitudes.
    # It is not perfectly accurate, but it is good enough for this example.
    # A real implementation would use a geospatial library or database extension.
    p = 0.017453292519943295
    a = 0.5 - math.cos((lat2 - lat1) * p)/2 + math.cos(lat1 * p) * math.cos(lat2 * p) * (1 - math.cos((long2 - long1) * p)) / 2
    return 12742 * math.asin(math.sqrt(a))

def search_activities(db: Session, date:Optional[datetime]):
    db_activities = db.query(models.Activity)
    if date:
        db_activities= db_activities.filter(models.Activity.last_update > date)
        
    activities= db_activities.all()

    return activities;

def get_deleted_activities(db: Session, date:Optional[datetime])->list[int]:
    db_activities = db.query(models.DeletedActivity)
    if date:
        db_activities= db_activities.filter(models.Activity.last_update > date)
    return [dele.activity_id for dele in db_activities.all()]

def get_activity_feedback(db: Session, username: str):
    db_user = get_user_by_username(db, username=username)
    if db_user:
        return db.query(models.Feedback).filter(models.Feedback.username == username).all()
    else:
        raise HTTPException(status_code=404, detail="User not found")


def get_user_activities(db: Session, username: str):
    db_user = get_user_by_username(db, username=username)
    if db_user:
        return db_user.activities
    else:
        raise HTTPException(status_code=404, detail="User not found")

