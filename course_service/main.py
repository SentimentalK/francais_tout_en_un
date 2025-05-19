import os
from typing import List
from functools import wraps

from fastapi import FastAPI, HTTPException, Depends
from fastapi.responses import StreamingResponse
from decimal import Decimal
from sqlalchemy.orm import Session
from db import CourseModel, CourseResponse, SentenceModel, SentenceResponse, get_db

from utils.courses import EntitlementsCache
from utils.tokens import TokenAuthority
from utils.logs import setup_logging
setup_logging()
import logging
logger = logging.getLogger(__name__)

AUDIO_DIR = os.getenv("AUDIO_DIR", "./src")
redis_cache = EntitlementsCache()
app = FastAPI(title="Course Content Service")

def check_course_cache():
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            user_id = kwargs.get("user_id")
            course_id = kwargs.get("course_id")
            db = kwargs.get("db")
            if db is None:
                raise HTTPException(status_code=500, detail="Server configuration error: Auth decorator requires 'db' session.")
            try:
                course_price_info = db.query(CourseModel.price).filter(CourseModel.course_id == course_id).first()
            except Exception as e:
                logger.error(f"Database error fetching price for course {course_id} in decorator: {e}", exc_info=True)
            is_free = False
            if course_price_info and course_price_info.price == Decimal("0.00"):
                is_free = True
            if not is_free and not redis_cache.is_course_authorized(user_id, str(course_id)):
                raise HTTPException(status_code=403, detail="Course did not purchase.")
            return func(*args, **kwargs)
        return wrapper
    return decorator

@app.get("/api/courses/", response_model=List[CourseResponse])
def list_courses(db: Session = Depends(get_db)):
    try: 
        return db.query(CourseModel).order_by(CourseModel.course_id).all()
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/courses/{course_id}/sentences", response_model=List[SentenceResponse])
@check_course_cache()
def get_sentences(
        course_id: int, 
        db: Session = Depends(get_db),
        user_id :str = Depends(TokenAuthority.get_optional_user_id)
    ):
    try: 
        sentences = db.query(SentenceModel).filter(SentenceModel.course_id == course_id).order_by(SentenceModel.seq).all()
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))
    if not sentences:
        raise HTTPException(status_code=404, detail="Course not found or no sentences available")
    return sentences 

@app.get("/api/courses/{course_id}/audio")
@check_course_cache()
def get_audio(
        course_id: int,
        db: Session = Depends(get_db),
        user_id :str = Depends(TokenAuthority.get_optional_user_id)
    ):
    filename = f"{course_id}.mp3"
    file_path = os.path.join(AUDIO_DIR, filename)
    if not os.path.isfile(file_path):
        raise HTTPException(status_code=404, detail="Audio file not found")
    def iterfile():
        with open(file_path, mode="rb") as f:
            for chunk in iter(lambda: f.read(1024 * 16), b""):
                yield chunk
    return StreamingResponse(iterfile(), media_type="audio/mpeg")
