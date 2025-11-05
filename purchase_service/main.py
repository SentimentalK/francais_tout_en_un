import os
import uuid
import json
import requests
from typing import List
from typing import Optional
from datetime import datetime
from requests.exceptions import RequestException

import redis.asyncio as redis
from redis.asyncio.connection import ConnectionPool

from utils.tokens import TokenAuthority
from utils.logs import setup_logging
setup_logging()
import logging
logger = logging.getLogger(__name__)

from fastapi import FastAPI, HTTPException, Depends
from fastapi.responses import HTMLResponse
from aiokafka import AIOKafkaProducer
from sqlalchemy.orm import Session
from db import OrderModel, OrderRequest, OrderResponse, OrderStatus, PaymentCallbackPayload, get_db

KAFKA_BOOTSTRAP = os.getenv("KAFKA_BOOTSTRAP")
KAFKA_TOPIC_PURCHASE = os.getenv("KAFKA_TOPIC_PURCHASE", "course.purchased")
KAFKA_TOPIC_REFUND = os.getenv("KAFKA_TOPIC_REFUND", "course.refunded")
COURSE_SERVICE_URL = os.getenv("COURSE_SERVICE_URL", "http://course_service:8001/api/courses/")

REDIS_HOST = os.getenv("REDIS_HOST", "redis")
REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))
REDIS_STREAM_PURCHASE = KAFKA_TOPIC_PURCHASE
REDIS_STREAM_REFUND = KAFKA_TOPIC_REFUND

MESSAGING_BACKEND = os.getenv("MESSAGING_BACKEND", "kafka")

producer: Optional[AIOKafkaProducer] = None
async def get_producer() -> AIOKafkaProducer:
    global producer
    if producer is None:
        producer = AIOKafkaProducer(bootstrap_servers=KAFKA_BOOTSTRAP)
        await producer.start()
    return producer

redis_pool: Optional[ConnectionPool] = None
async def get_redis_connection() -> redis.Redis:
    global redis_pool
    if redis_pool is None:
        logger.info(f"Initializing Redis connection pool for {REDIS_HOST}:{REDIS_PORT}")
        redis_pool = redis.ConnectionPool(host=REDIS_HOST, port=REDIS_PORT, db=0, decode_responses=True)
    return redis.Redis(connection_pool=redis_pool)

app = FastAPI(title="Order Service")

@app.post("/api/purchase/create", response_model=OrderResponse)
def create_order(
        req: OrderRequest, 
        db: Session = Depends(get_db),
        user_id :str = Depends(TokenAuthority.get_user_id)
    ):

    try:
        response = requests.get(COURSE_SERVICE_URL, timeout=5)
        response.raise_for_status() 
        courses_data = response.json()
        total = sum(float(c["price"]) for c in courses_data if c["course_id"] in req.course_ids)
    except RequestException as e:
        logger.error(f"Error fetching course data from {COURSE_SERVICE_URL}: {e}")
        raise HTTPException(status_code=503, detail=f"Course service unavailable: {e}")
    except json.JSONDecodeError as e:
        logger.error(f"Error decoding JSON from course service: {e}")
        raise HTTPException(status_code=500, detail="Invalid response from course service.")

    order_id = uuid.uuid4()
    order = OrderModel(
        order_id=order_id,
        user_id=uuid.UUID(user_id),
        course_ids=req.course_ids,
        amount=round(total,2),
        status="PENDING"
    )
    db.add(order)
    db.commit()
    db.refresh(order)
    payment_url = f"/purchase/{order_id}"
    return OrderResponse(order_id=order_id, payment_url=payment_url, amount=total)

@app.post("/api/purchase/{order_id}/callback")
async def payment_callback(
    order_id: str, 
    payload: PaymentCallbackPayload,
    db: Session = Depends(get_db),
    user_id :str = Depends(TokenAuthority.get_user_id)
):
    order = db.query(OrderModel).filter(
        OrderModel.order_id == order_id,
        OrderModel.user_id == user_id
        ).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    if order.status not in ["PENDING","FAILED"]:
        if order.status == "PAID" and payload.outcome == "success":
            return {"message": "Already Paid."}
        raise HTTPException(status_code=400, detail="Order not in PENDING status")

    if payload.outcome != "success":
        order.status = "FAILED"
        db.commit()
        return {"message": "Payment failed as simulated."}
    
    producer = await get_producer()
    event = {
        "user_id": user_id,
        "course_ids": order.course_ids,
        "order_id": order_id,
        "purchased_at": order.created_at.isoformat()
    }
    try:
        if MESSAGING_BACKEND == "kafka":
            logger.info(f"event: {event}")
            await producer.send_and_wait(KAFKA_TOPIC_PURCHASE, json.dumps(event).encode("utf-8"))
        elif MESSAGING_BACKEND == "redis":
            logger.info(f"Sending event to Redis Stream: {REDIS_STREAM_PURCHASE}")
            r = await get_redis_connection()
            # Redis Streams (xadd) requires a flat dict of strings.
            # We must serialize the list of course_ids.
            redis_event = {
                "user_id": event["user_id"],
                "order_id": event["order_id"],
                "purchased_at": event["purchased_at"],
                "course_ids": json.dumps(event["course_ids"])
            }
            await r.xadd(REDIS_STREAM_PURCHASE, redis_event)
            await r.close()
    except Exception as e:
        logging.error(f"Kafka send failed: {e}")
        order.status = "FAILED"
        db.commit()
        raise HTTPException(status_code=500, detail="Payment event send failed, please try again later.")
    order.status = "PAID"
    db.commit()
    return {"message": "Payment successful"}

@app.get("/api/purchase/{order_id}", response_model=OrderStatus)
def get_order_status(order_id: str, db: Session = Depends(get_db)):
    order = db.query(OrderModel).filter(OrderModel.order_id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return OrderStatus(
            order_id=order.order_id,
            status=order.status,
            amount=order.amount,
            currency=order.currency,
            payment_gateway=order.payment_gateway,
            gateway_txn_id=order.gateway_txn_id,
            created_at=order.created_at.isoformat(),
            updated_at=order.updated_at.isoformat(),
            refunded_at=order.refunded_at.isoformat() if order.refunded_at else None
        )

@app.get("/api/purchase/", response_model=List[OrderStatus])
def list_entitlements(
        user_id :str = Depends(TokenAuthority.get_user_id),
        db: Session = Depends(get_db)
    ):
    ords = db.query(OrderModel).filter(OrderModel.user_id == user_id).all()
    return [OrderStatus(
            order_id=e.order_id,
            status=e.status,
            amount=e.amount,
            currency=e.currency,
            payment_gateway=e.payment_gateway,
            gateway_txn_id=e.gateway_txn_id,
            created_at=e.created_at.isoformat(),
            updated_at=e.updated_at.isoformat(),
            refunded_at=e.refunded_at.isoformat() if e.refunded_at else None
        ) for e in ords]

@app.post("/api/purchase/{order_id}/refund")
async def refund_order(
    order_id: str, 
    db: Session = Depends(get_db),
    user_id :str = Depends(TokenAuthority.get_user_id)
):
    order = db.query(OrderModel).filter(OrderModel.order_id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    if order.status != "PAID":
        raise HTTPException(status_code=400, detail="Order not in PAID status")

    producer = await get_producer()
    event = {
        "user_id": user_id,
        "course_ids": order.course_ids,
        "order_id": order_id
    }
    try:
        if MESSAGING_BACKEND == "kafka":
            await producer.send_and_wait(KAFKA_TOPIC_REFUND, json.dumps(event).encode("utf-8"))
        elif MESSAGING_BACKEND == "redis":
            logger.info(f"Sending event to Redis Stream: {REDIS_STREAM_REFUND}")
            r = await get_redis_connection()
            redis_event = {
                "user_id": event["user_id"],
                "order_id": event["order_id"],
                "course_ids": json.dumps(event["course_ids"])
            }
            await r.xadd(REDIS_STREAM_REFUND, redis_event)
            await r.close()
    except Exception as e:
        logging.error(f"Kafka send failed: {e}")
        raise HTTPException(status_code=500, detail="Payment event send failed, please try again later.")
    order.status = "REFUNDED"
    order.refunded_at = datetime.now()
    db.commit()
    return {"message": "Refund processed"}

