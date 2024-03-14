from sqlalchemy import Boolean, Column, Float, Integer, String, DateTime, ForeignKey, Table
from sqlalchemy.orm import relationship
from database import Base
from datetime import datetime
import schemas

association_table = Table('association', Base.metadata,
    Column('user_id', ForeignKey('users.id'), primary_key=True),
    Column('activity_id', ForeignKey('activities.id'), primary_key=True)
)

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    hashed_password = Column(String)

class Activity(Base):
    __tablename__ = "activities"

    id = Column(Integer, primary_key=True, index=True)
    description = Column(String, index=True)
    level = Column(String)
    price = Column(Integer)
    sport = Column(String)
    time = Column(DateTime, default=datetime.utcnow)
    long = Column(Float)
    lat = Column(Float)
    number_of_people = Column(Integer)
    creator = Column(Integer, ForeignKey('users.username'))
    participants = relationship(
        "User",
        secondary=association_table,
        back_populates="activities"
    )

    def toActivityBase(self):
        return schemas.Activity(
            id=self.id,
            description=self.description,
            time=self.time,
            creator=self.creator,
            position=schemas.Position(lat=self.lat, long=self.long),
            attributes=schemas.Attributes(level=self.level, price=self.price, sport=self.sport),
            numberOfPeople=self.number_of_people
        )

User.activities = relationship(
    "Activity",
    secondary=association_table,
    back_populates="participants"
)

class Feedback(Base):
    __tablename__ = "feedback"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, ForeignKey('users.username'))
    activity_id = Column(Integer, ForeignKey('activities.id'))
    rating = Column(Integer)
    comment = Column(String)

