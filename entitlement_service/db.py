import os
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

database_url = os.getenv("DATABASE_URL")

engine = create_engine(database_url, echo=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
Base = declarative_base()

class Entitlement(Base):
    __tablename__ = "entitlements"
    user_id = Column(String, primary_key=True, index=True)
    course_id = Column(Integer, primary_key=True, index=True)
    order_id = Column(String, nullable=False)

class EntitlementOut(BaseModel):
    course_id: int
    order_id: str

class CheckEntitlement(BaseModel):
    has_access: bool

def get_db():
    db = SessionLocal()
    try: yield db
    finally: db.close()

Base.metadata.create_all(bind=engine)