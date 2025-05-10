FROM python:3.10-slim

WORKDIR /app

# COPY ../commons/requirements.txt common.requirements.txt
# RUN pip install --no-cache-dir -r common.requirements.txt

COPY requirements.txt requirements.txt
RUN [ -f requirements.txt ] && pip install --no-cache-dir -r requirements.txt || echo "No local requirements.txt"

COPY . .

CMD ["sh", "-c","uvicorn main:app --host 0.0.0.0 --port $SERVICE_PORT"]