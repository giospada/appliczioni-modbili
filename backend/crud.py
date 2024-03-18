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

def search_activities(db: Session, sport: Optional[str] = None, level: Optional[str] = None, price: Optional[int] = None, long: Optional[float] = None, lat: Optional[float] = None, radius: Optional[int] = None):
    # For simplicity, this example does not implement actual geolocation-based searching.
    # A real implementation would require geospatial queries which SQLite does not support natively.
    # You might use PostGIS with PostgreSQL for a production scenario.
    db_activities = db.query(models.Activity)
    if sport:
        db_activities = db_activities.filter(models.Activity.sport == sport)
    if level:
        db_activities = db_activities.filter(models.Activity.level == level)
    if price:
        db_activities = db_activities.filter(models.Activity.price == price)
    if long and lat and radius:
        db_activities = db_activities.filter(km_distance(long, lat, models.Activity.long, models.Activity.lat) <= radius)
    
    return db_activities.all()



def get_user_activities(db: Session, username: str):
    db_user = get_user_by_username(db, username=username)
    if db_user:
        return db_user.activities
    else:
        raise HTTPException(status_code=404, detail="User not found")

