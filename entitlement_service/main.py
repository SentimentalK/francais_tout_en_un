import os
import asyncio
import json
from typing import List

from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from aiokafka import AIOKafkaConsumer
from utils.tokens import TokenAuthority
from utils.courses import EntitlementsCache

import redis.asyncio as redis
from redis.asyncio.connection import ConnectionPool
from redis.exceptions import ResponseError

from utils.logs import setup_logging
setup_logging()
import logging
logger = logging.getLogger(__name__)

from db import Entitlement, EntitlementOut, CheckEntitlement, get_db, SessionLocal


kafka_bootstrap = os.getenv("KAFKA_BOOTSTRAP")
purchase_topic = os.getenv("KAFKA_TOPIC_PURCHASE", "course.purchased")
refund_topic = os.getenv("KAFKA_TOPIC_REFUND", "course.refunded")

REDIS_HOST = os.getenv("REDIS_HOST", "redis")
REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))
REDIS_STREAM_PURCHASE = purchase_topic
REDIS_STREAM_REFUND = refund_topic

MESSAGING_BACKEND = os.getenv("MESSAGING_BACKEND", "kafka")
CONSUMER_GROUP_NAME = "entitlement-service-group"

redis_pool: ConnectionPool = None
async def get_redis_connection() -> redis.Redis:
    global redis_pool
    if redis_pool is None:
        logger.info(f"Initializing Redis connection pool for {REDIS_HOST}:{REDIS_PORT}")
        redis_pool = redis.ConnectionPool(host=REDIS_HOST, port=REDIS_PORT, db=0)
    return redis.Redis(connection_pool=redis_pool)

redis_cache = EntitlementsCache()
semaphore = asyncio.Semaphore(10)
app = FastAPI(title="Entitlement Service")

@app.get("/api/entitlements/", response_model=List[EntitlementOut])
def list_entitlements(
        user_id :str = Depends(TokenAuthority.get_user_id),
        db: Session = Depends(get_db)
    ):
    ents = db.query(Entitlement).filter(Entitlement.user_id == user_id).all()
    course_ids = [e.course_id for e in ents]
    if course_ids:
        redis_cache.add_courses(user_id, course_ids)
    return [EntitlementOut(course_id=e.course_id, order_id=e.order_id) for e in ents]

@app.get("/api/entitlements/{course_id}", response_model=CheckEntitlement)
def check_entitlement(
    course_id: int, 
    db: Session = Depends(get_db),
    user_id :str = Depends(TokenAuthority.get_user_id)
):
    ent = db.query(Entitlement).filter(
        Entitlement.user_id == user_id,
        Entitlement.course_id == course_id
    ).first()
    return CheckEntitlement(has_access=bool(ent))


async def handle_kafka_event(msg):
    async with semaphore:
        topic = msg.topic
        payload = json.loads(msg.value.decode("utf-8"))
        user_id = payload.get("user_id")
        order_id = payload.get("order_id")
        # Kafka payload sends 'course_ids' as a list
        course_ids = payload.get("course_ids") or [payload.get("course_id")] 
        
        await process_event_logic(topic, user_id, order_id, course_ids)


async def consume_kafka_events():
    logger.info(f"Starting KAFKA consumer for topics: {purchase_topic}, {refund_topic}")
    consumer = AIOKafkaConsumer(
        purchase_topic, refund_topic,
        loop=asyncio.get_event_loop(),
        bootstrap_servers=kafka_bootstrap,
        group_id=CONSUMER_GROUP_NAME,
        auto_offset_reset="earliest"
    )
    await consumer.start()
    tasks = set()
    try:
        async for msg in consumer:
            task = asyncio.create_task(handle_kafka_event(msg))
            tasks.add(task)
            tasks = {t for t in tasks if not t.done()}
    finally:
        await consumer.stop()
        if tasks:
            await asyncio.gather(*tasks)

async def handle_redis_event(stream: str, msg_id: str, data: dict, redis_client: redis.Redis):
    async with semaphore:
        payload = {k.decode('utf-8'): v.decode('utf-8') for k, v in data.items()}
        
        topic = stream
        user_id = payload.get("user_id")
        order_id = payload.get("order_id")

        # CRITICAL DIFFERENCE:
        # The producer serialized 'course_ids' as a JSON string.
        # We must de-serialize it here.
        course_ids_str = payload.get("course_ids")
        if course_ids_str:
            course_ids = json.loads(course_ids_str)
        else:
            course_ids = [payload.get("course_id")] # Fallback

        await process_event_logic(topic, user_id, order_id, course_ids)
        
        # Acknowledge the message in the stream
        await redis_client.xack(stream, CONSUMER_GROUP_NAME, msg_id)


async def consume_redis_events():
    logger.info(f"Starting REDIS STREAM consumer for streams: {REDIS_STREAM_PURCHASE}, {REDIS_STREAM_REFUND}")
    r = await get_redis_connection()
    streams_to_read = {REDIS_STREAM_PURCHASE: '>', REDIS_STREAM_REFUND: '>'}
    
    # Ensure consumer groups exist (safe to run multiple times)
    try:
        await r.xgroup_create(REDIS_STREAM_PURCHASE, CONSUMER_GROUP_NAME, id='0', mkstream=True)
    except ResponseError:
        pass
    try:
        await r.xgroup_create(REDIS_STREAM_REFUND, CONSUMER_GROUP_NAME, id='0', mkstream=True)
    except ResponseError:
        pass

    tasks = set()
    try:
        while True:
            response = await r.xreadgroup(
                groupname=CONSUMER_GROUP_NAME,
                consumername=f"consumer-{os.getpid()}",
                streams=streams_to_read,
                count=10,
                block=5000 # Wait 5 seconds
            )

            if not response:
                continue

            for stream, messages in response:
                stream_name = stream.decode('utf-8')
                for msg_id, data in messages:
                    msg_id_str = msg_id.decode('utf-8')
                    task = asyncio.create_task(handle_redis_event(stream_name, msg_id_str, data, r))
                    tasks.add(task)
                    tasks = {t for t in tasks if not t.done()}
    finally:
        await r.close()
        if tasks:
            await asyncio.gather(*tasks)

async def process_event_logic(topic: str, user_id: str, order_id: str, course_ids: List[int]):
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
                    logger.info(f"Granting access: user {user_id} to course {cid}")
                    redis_cache.add_courses(user_id, [cid])
            db.commit()
        elif topic == refund_topic:
            for cid in course_ids:
                ent = db.query(Entitlement).filter(
                    Entitlement.user_id == user_id,
                    Entitlement.course_id == cid
                ).first()
                if ent:
                    db.delete(ent)
                    logger.info(f"Revoking access: user {user_id} from course {cid}")
                    redis_cache.remove_course(user_id, cid)
            db.commit()
    except Exception as e:
        logger.error(f"Error processing event (topic: {topic}, order: {order_id}): {e}")
        db.rollback()
    finally:
        db.close()

@app.on_event("startup")
async def startup_event():
    if MESSAGING_BACKEND == "redis":
        asyncio.create_task(consume_redis_events())
    elif MESSAGING_BACKEND == "kafka":
        asyncio.create_task(consume_kafka_events())