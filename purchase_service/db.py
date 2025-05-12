import os
from typing import List


from pydantic import BaseModel
from sqlalchemy.dialects.postgresql import ARRAY
from sqlalchemy import create_engine, Column, String, Integer, Numeric, DateTime, func
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

database_url = os.getenv("DATABASE_URL")

engine = create_engine(database_url, echo=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
Base = declarative_base()


class OrderModel(Base):
    __tablename__ = "orders"
    order_id = Column(String, primary_key=True)
    user_id = Column(String, nullable=False, index=True)
    course_ids = Column(ARRAY(Integer), nullable=False)
    amount = Column(Numeric(10, 2), nullable=False)
    currency = Column(String(3), default='USD')
    status = Column(String(20), nullable=False, index=True)
    payment_gateway = Column(String(50))
    gateway_txn_id = Column(String(100))
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    refunded_at = Column(DateTime)
    refund_reason = Column(String)

Base.metadata.create_all(bind=engine)

class OrderRequest(BaseModel):
    course_ids: List[int]
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
