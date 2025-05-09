import os
import jwt
import time
import bcrypt

from fastapi import FastAPI, Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from db import (
    UserModel,
    RegisterRequest,
    LoginRequest,
    TokenResponse,
    User,
    get_db,
    create_user,
    get_user_by_username,
)


JWT_SECRET = os.getenv("JWT_SECRET", "xinghan")
JWT_ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_SECONDS = 900  # 15 minutes

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/user/login")
app = FastAPI()


class TokenService:
    @staticmethod
    def create_access_token(user_id: int) -> str:
        now = int(time.time())
        payload = {
            'sub': user_id,
            'iat': now,
            'exp': now + ACCESS_TOKEN_EXPIRE_SECONDS
        }
        return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)

    @staticmethod
    def verify_token(token: str) -> dict:
        try:
            payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
            return payload
        except jwt.ExpiredSignatureError:
            raise HTTPException(status_code=401, detail="Token has expired")
        except jwt.InvalidTokenError:
            raise HTTPException(status_code=401, detail="Invalid token")


class AuthService:
    def __init__(self, db: Session):
        self.db = db

    def register(self, username: str, email: str, password: str) -> str:
        if get_user_by_username(self.db, username):
            raise HTTPException(status_code=400, detail="Username already registered")
        hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()
        user = create_user(self.db, username, email, hashed)
        return TokenService.create_access_token(user.id)

    def login(self, username: str, password: str) -> str:
        user = get_user_by_username(self.db, username)
        if not user or not bcrypt.checkpw(password.encode(), user.password_hash.encode()):
            raise HTTPException(status_code=401, detail="Incorrect username or password")
        return TokenService.create_access_token(user.id)

    def get_current_user(self, token: str) -> User:
        data = TokenService.verify_token(token)
        user = self.db.query(UserModel).get(data.get('sub'))
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        return User(id=user.id, username=user.username, email=user.email, created_at=str(user.created_at))


@app.post('/api/user/register', response_model=TokenResponse)
def register(req: RegisterRequest, db: Session = Depends(get_db)):
    token = AuthService(db).register(req.username, req.email, req.password)
    return TokenResponse(access_token=token)

@app.post('/api/user/login', response_model=TokenResponse)
def login(req: LoginRequest, db: Session = Depends(get_db)):
    token = AuthService(db).login(req.username, req.password)
    return TokenResponse(access_token=token)

@app.get('/me', response_model=User)
def read_me(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    return AuthService(db).get_current_user(token)
