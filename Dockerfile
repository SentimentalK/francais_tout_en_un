FROM python:3.10-slim

ARG SERVICE_DIR
WORKDIR /app

COPY requirements.txt common.requirements.txt
RUN pip install --no-cache-dir -r common.requirements.txt

COPY ./$SERVICE_DIR/requirements.txt* ./
RUN if [ -f requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi

COPY ./$SERVICE_DIR/ ./

CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port $SERVICE_PORT"]