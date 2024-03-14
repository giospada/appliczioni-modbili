from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime


class Position(BaseModel):
    long: float
    lat: float

class Attributes(BaseModel):
    level: str
    price: int
    sport: str

class UserBase(BaseModel):
    username: str

class UserCreate(UserBase):
    password: str

class UserInDB(UserBase):
    id: int

    class Config:
        orm_mode = True

class ActivityBase(BaseModel):
    description: str
    time: datetime
    position: Position
    attributes: Attributes
    numberOfPeople: int


class ActivityCreate(ActivityBase):
    pass

class Activity(ActivityBase):
    id: int
    participants: List[UserInDB] = []
    creator: str

    class Config:
        orm_mode = True

class ActivityRegistration(BaseModel):
    username: str
    activityId: int

class FeedbackBase(BaseModel):
    username: Optional[str] = None
    activity_id: int 
    rating: int
    comment: Optional[str] = None

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

class Message(BaseModel):
    message:str