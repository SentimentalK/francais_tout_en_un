import uuid
from sqlalchemy.orm import Session
from fastapi import FastAPI, Depends, HTTPException, status

from orm import get_db
from repository import UserRepo
from service import AuthService
from utils.tokens import TokenAuthority
from schemas import RegisterRequest, LoginRequest, TokenResponse, UserResponse


app = FastAPI(
    title="User Auth Service",
    description="User authentication with FastAPI and Repository Pattern.",
    version="1.0.0"
)

def user_repo(db: Session = Depends(get_db)) -> UserRepo:
    return UserRepo(db=db)

def auth_service(user_repo: UserRepo = Depends(user_repo)) -> AuthService:
    return AuthService(user_repo=user_repo)

@app.post('/api/user/register', response_model=TokenResponse)
def register(
        req: RegisterRequest, 
        service: AuthService = Depends(auth_service)
    ):
    try:
        access_token = service.register(
            username=req.username,
            email=req.email,
            password=req.password
        )
        return TokenResponse(access_token=access_token, token_type="bearer")
    except HTTPException:
        raise

@app.post('/api/user/login', response_model=TokenResponse)
def login(
        req: LoginRequest, 
        service: AuthService = Depends(auth_service)
    ):
    try:
        access_token = service.login(username=req.username, password=req.password)
        return TokenResponse(access_token=access_token, token_type="bearer")
    except HTTPException:
        raise
    except Exception:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Login failed unexpectedly.")

@app.get('/api/user/info', response_model=UserResponse)
def user_info(
        user_id :str = Depends(TokenAuthority.get_user_id),
        service: AuthService = Depends(auth_service)
    ):
    try:
        user = service.get_user_info(user_id=uuid.UUID(user_id))
    except HTTPException:
        raise
    except Exception:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Retrive user_info failed unexpectedly.")
    return UserResponse(
        id=user.id,
        username=user.username,
        email=user.email,
        created_at=user.created_at.strftime("%Y-%m-%d %H:%M:%S")
    )
