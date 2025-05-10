import os
import uuid
import time
import json
from typing import Optional


from pydantic import BaseModel
from sqlalchemy import create_engine, Column, String, Integer, Float, DateTime, func
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# Configuration
database_url = os.getenv("DATABASE_URL")

# SQLAlchemy setup
engine = create_engine(database_url, echo=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
Base = declarative_base()


class OrderModel(Base):
    __tablename__ = "orders"
    order_id = Column(String, primary_key=True, index=True)
    user_id = Column(String, nullable=False, index=True)
    course_id = Column(Integer, nullable=False, index=True)
    amount = Column(Float, nullable=False)
    status = Column(String, nullable=False, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

Base.metadata.create_all(bind=engine)

class OrderRequest(BaseModel):
    user_id: str
    course_id: int
    amount: float

class OrderResponse(BaseModel):
    order_id: str
    payment_url: str

class OrderStatus(BaseModel):
    order_id: str
    status: str

def get_db():
    db = SessionLocal()
    try: yield db
    finally: db.close()
