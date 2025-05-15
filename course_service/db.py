import os

from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session

DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
Base = declarative_base()


class CourseResponse(BaseModel):
    course: int
    free: bool

class SentenceResponse(BaseModel):
    course: int
    seq: int
    french: str
    english: str

class CourseModel(Base):
    __tablename__ = "courses"
    course = Column(Integer, primary_key=True)
    free = Column(Boolean)

class SentenceModel(Base):
    __tablename__ = "contents"
    course = Column(Integer, primary_key=True)
    seq = Column(Integer, primary_key=True)
    french = Column(String)
    english = Column(String)

def get_db():
    db = SessionLocal()
    try: yield db
    finally: db.close()
