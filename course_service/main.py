import os
from typing import List

from fastapi import FastAPI, HTTPException, Depends
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
from db import CourseModel, CourseResponse, SentenceModel, SentenceResponse, get_db

AUDIO_DIR = os.getenv("AUDIO_DIR", "./src")
app = FastAPI(title="Course Content Service")

@app.get("/api/courses/", response_model=List[CourseResponse])
def list_courses(db: Session = Depends(get_db)):
    try: 
        return db.query(CourseModel).order_by(CourseModel.lesson).all()
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/courses/{lesson}/sentences", response_model=List[SentenceResponse])
def get_sentences(lesson: int, db: Session = Depends(get_db)):
    try: 
        sentences = db.query(SentenceModel).filter(SentenceModel.lesson == lesson).order_by(SentenceModel.seq).all()
    except Exception as e: 
        raise HTTPException(status_code=500, detail=str(e))
    if not sentences:
        raise HTTPException(status_code=404, detail="Lesson not found or no sentences available")
    return sentences 

@app.get("/api/courses/{lesson}/audio")
def get_audio(lesson: int):
    filename = f"{lesson}.mp3"
    file_path = os.path.join(AUDIO_DIR, filename)
    if not os.path.isfile(file_path):
        raise HTTPException(status_code=404, detail="Audio file not found")
    def iterfile():
        with open(file_path, mode="rb") as f:
            for chunk in iter(lambda: f.read(1024 * 16), b""):
                yield chunk
    return StreamingResponse(iterfile(), media_type="audio/mpeg")
