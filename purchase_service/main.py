import os
import uuid
import json
from typing import Optional

from fastapi import FastAPI, HTTPException, Depends
from fastapi.responses import HTMLResponse
from aiokafka import AIOKafkaProducer
from sqlalchemy import func
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


@app.post("/api/orders/create", response_model=OrderResponse)
def create_order(req: OrderRequest, db: Session = Depends(get_db)):
    order_id = str(uuid.uuid4())
    order = OrderModel(
        order_id=order_id,
        user_id=req.user_id,
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
      <form action="/orders/{order_id}/callback" method="post">
        <button type="submit">confirm</button>
      </form>
    </body></html>
    """
    return HTMLResponse(html)

@app.post("/api/orders/{order_id}/callback")
async def payment_callback(order_id: str, db: Session = Depends(get_db)):
    order = db.query(OrderModel).filter(OrderModel.order_id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    if order.status != "PENDING":
        raise HTTPException(status_code=400, detail="Order not in PENDING status")
    order.status = "PAID"
    db.commit()

    producer = await get_producer()
    event = {
        "user_id": order.user_id,
        "course_ids": [order.course_id],
        "order_id": order.order_id,
        "purchased_at": order.created_at.isoformat()
    }
    await producer.send_and_wait(KAFKA_TOPIC_PURCHASE, json.dumps(event).encode("utf-8"))
    return {"message": "Payment successful"}

@app.get("/api/orders/{order_id}", response_model=OrderStatus)
def get_order_status(order_id: str, db: Session = Depends(get_db)):
    order = db.query(OrderModel).filter(OrderModel.order_id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return OrderStatus(order_id=order.order_id, status=order.status)

@app.post("/api/orders/{order_id}/refund")
async def refund_order(order_id: str, db: Session = Depends(get_db)):
    order = db.query(OrderModel).filter(OrderModel.order_id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    if order.status != "PAID":
        raise HTTPException(status_code=400, detail="Order not in PAID status")
    order.status = "REFUNDED"
    db.commit()

    producer = await get_producer()
    event = {
        "user_id": order.user_id,
        "course_ids": [order.course_id],
        "order_id": order.order_id,
        "refunded_at": func.now().isoformat()
    }
    await producer.send_and_wait(KAFKA_TOPIC_REFUND, json.dumps(event).encode("utf-8"))
    return {"message": "Refund processed"}
