import os

from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String, Numeric
from decimal import Decimal
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
Base = declarative_base()


class CourseResponse(BaseModel):
    course_id: int
    price: Decimal

class SentenceResponse(BaseModel):
    course_id: int
    seq: int
    french: str
    english: str

class CourseModel(Base):
    __tablename__ = "courses"
    course_id = Column(Integer, primary_key=True)
    price = Column(Numeric(10, 2))

class SentenceModel(Base):
    __tablename__ = "contents"
    course_id = Column(Integer, primary_key=True)
    seq = Column(Integer, primary_key=True)
    french = Column(String)
    english = Column(String)

class QuizModel(Base):
    __tablename__ = "quizzes"
    quiz_id = Column(Integer, primary_key=True)
    title = Column(String, nullable=False)
    description = Column(String)
    tag = Column(String)
    icon = Column(String)
    bg_color = Column(String)
    icon_color = Column(String)
    content_json = Column(String, nullable=False)

class QuizListResponse(BaseModel):
    quiz_id: int
    title: str
    description: str | None = None
    tag: str | None = None
    icon: str | None = None
    bg_color: str | None = None
    icon_color: str | None = None

class QuizDetailResponse(QuizListResponse):
    content_json: str

def get_db():
    db = SessionLocal()
    try: yield db
    finally: db.close()
