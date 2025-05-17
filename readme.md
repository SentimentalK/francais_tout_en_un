# Français Tout-en-Un

**Français Tout-en-Un** is a modern web application designed to facilitate learning the French language. Built on a distributed microservices architecture, it delivers a seamless and performant user experience.

## Tech Stack
- **Backend**: Python (FastAPI + Uvicorn), SQLAlchemy
- **Database**: PostgreSQL, Redis
- **Messaging**: Kafka
- **Containerization**: Docker
- **Frontend**: React
- **Authentication**: JWT
- **API Gateway**: Nginx

## Requirements
To run the application locally, ensure you have the following tools installed:
- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Installation and Setup

**Run the Application**:
   
```
docker-compose down && docker-compose up --build
```

**Access the Application**:
```
http://localhost
```

## Development
**Restart & build single microservice**:
```
docker-compose up -d --no-deps --build --force-recreate <service_name>
```
**Start the React frontend in development mode:**
```
yarn dev
```

## High-Level Interaction Diagram
```mermaid
---
config:
  theme: redux
  layout: dagre
---
flowchart TD
    FE["Front End"] -- API Requests / User Actions --> NG["Nginx"]
    NG -- POST /api/user/login --> AS["Authentication Service"]
    AS -- JWT Token / Login Response --> NG
    NG -- GET /api/entitlements --> ES["Entitlement Service"]
    ES -- Entitlement Data --> NG
    NG -- GET /api/courses/{id} --> CS["Course Service"]
    CS -- Course Content / 403 --> NG
    NG -- POST /api/purchase --> PS["Purchase Service"]
    PS -- Purchase Confirmation --> NG
    NG -- HTTP/S Responses --> FE
    %% Internal Communications
    ES -- cache user course access --> Redis["Redis"]
    CS -- verify access --> Redis
    PS -- emit purchase/refund event --> MQ["Message Queue"]
    MQ -- deliver events --> ES
    ES -- update cached course access --> Redis
```