import os
import uuid
import json
from datetime import datetime
from typing import Optional
from utils.jwt_gate import TokenAuthority
from typing import List

from utils.log_handler import setup_logging
setup_logging()
import logging
logger = logging.getLogger(__name__)

from fastapi import FastAPI, HTTPException, Depends
from fastapi.responses import HTMLResponse
from aiokafka import AIOKafkaProducer
from sqlalchemy.orm import Session
from db import OrderModel, OrderRequest, OrderResponse, OrderStatus, get_db

KAFKA_BOOTSTRAP = os.getenv("KAFKA_BOOTSTRAP")
KAFKA_TOPIC_PURCHASE = os.getenv("KAFKA_TOPIC_PURCHASE", "course.purchased")
KAFKA_TOPIC_REFUND = os.getenv("KAFKA_TOPIC_REFUND", "course.refunded")

producer: Optional[AIOKafkaProducer] = None
async def get_producer() -> AIOKafkaProducer:
    global producer
    if producer is None:
        producer = AIOKafkaProducer(bootstrap_servers=KAFKA_BOOTSTRAP)
        await producer.start()
    return producer

app = FastAPI(title="Order Service")

@app.post("/api/purchase/create", response_model=OrderResponse)
def create_order(
        req: OrderRequest, 
        db: Session = Depends(get_db),
        user_id :str = Depends(TokenAuthority.get_user_id)
    ):
    order_id = str(uuid.uuid4())
    order = OrderModel(
        order_id=order_id,
        user_id=user_id,
        course_ids=req.course_ids,
        amount=req.amount,
        status="PENDING"
    )
    db.add(order)
    db.commit()
    db.refresh(order)
    payment_url = f"/pay/{order_id}"
    return OrderResponse(order_id=order_id, payment_url=payment_url)

@app.get("/api/pay/{order_id}", response_class=HTMLResponse)
def pay_page(order_id: str):
    html = f"""
    <html><body>
      <h3>payment simulation</h3>
      <p>Order ID: {order_id}</p>
      <form action="/api/purchase/{order_id}/callback" method="post">
        <button type="submit">confirm</button>
      </form>
    </body></html>
    """
    return HTMLResponse(html)

@app.post("/api/purchase/{order_id}/callback")
async def payment_callback(
    order_id: str, 
    db: Session = Depends(get_db),
    user_id :str = Depends(TokenAuthority.get_user_id)
):
    order = db.query(OrderModel).filter(OrderModel.order_id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    if order.status not in ["PENDING","FAILED"]:
        raise HTTPException(status_code=400, detail="Order not in PENDING status")

    producer = await get_producer()
    event = {
        "user_id": user_id,
        "course_ids": order.course_ids,
        "order_id": order_id,
        "purchased_at": order.created_at.isoformat()
    }
    try:
        logger.info(f"event: {event}")
        await producer.send_and_wait(KAFKA_TOPIC_PURCHASE, json.dumps(event).encode("utf-8"))
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

@app.get("/api/purchase", response_model=List[OrderStatus])
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
        await producer.send_and_wait(KAFKA_TOPIC_REFUND, json.dumps(event).encode("utf-8"))
    except Exception as e:
        logging.error(f"Kafka send failed: {e}")
        raise HTTPException(status_code=500, detail="Payment event send failed, please try again later.")
    order.status = "REFUNDED"
    order.refunded_at = datetime.now()
    db.commit()
    return {"message": "Refund processed"}

