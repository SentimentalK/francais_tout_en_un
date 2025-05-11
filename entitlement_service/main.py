import os
import asyncio
import json
from typing import List

from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from aiokafka import AIOKafkaConsumer

from db import Entitlement, EntitlementOut, CheckEntitlement, get_db, SessionLocal


kafka_bootstrap = os.getenv("KAFKA_BOOTSTRAP")
purchase_topic = os.getenv("KAFKA_TOPIC_PURCHASE", "course.purchased")
refund_topic = os.getenv("KAFKA_TOPIC_REFUND", "course.refunded")

app = FastAPI(title="Entitlement Service")

@app.get("/entitlements/{user_id}", response_model=List[EntitlementOut])
def list_entitlements(user_id: str, db: Session = Depends(get_db)):
    ents = db.query(Entitlement).filter(Entitlement.user_id == user_id).all()
    return [EntitlementOut(course_id=e.course_id, order_id=e.order_id) for e in ents]

@app.get("/entitlements/{user_id}/course/{course_id}", response_model=CheckEntitlement)
def check_entitlement(user_id: str, course_id: int, db: Session = Depends(get_db)):
    ent = db.query(Entitlement).filter(
        Entitlement.user_id == user_id,
        Entitlement.course_id == course_id
    ).first()
    return CheckEntitlement(has_access=bool(ent))

async def consume_events():
    consumer = AIOKafkaConsumer(
        purchase_topic, refund_topic,
        loop=asyncio.get_event_loop(),
        bootstrap_servers=kafka_bootstrap,
        group_id="entitlement-service-group",
        auto_offset_reset="earliest"
    )
    await consumer.start()
    try:
        async for msg in consumer:
            topic = msg.topic
            payload = json.loads(msg.value.decode("utf-8"))
            user_id = payload.get("user_id")
            order_id = payload.get("order_id")
            course_ids = payload.get("course_ids") or [payload.get("course_id")]
            db = SessionLocal()
            try:
                if topic == purchase_topic:
                    for cid in course_ids:
                        exists = db.query(Entitlement).filter(
                            Entitlement.user_id == user_id,
                            Entitlement.course_id == cid
                        ).first()
                        if not exists:
                            ent = Entitlement(user_id=user_id, course_id=cid, order_id=order_id)
                            db.add(ent)
                    db.commit()
                elif topic == refund_topic:
                    for cid in course_ids:
                        ent = db.query(Entitlement).filter(
                            Entitlement.user_id == user_id,
                            Entitlement.course_id == cid
                        ).first()
                        if ent:
                            db.delete(ent)
                    db.commit()
            finally:
                db.close()
    finally:
        await consumer.stop()


@app.on_event("startup")
async def startup_event():
    asyncio.create_task(consume_events())