import os
import jwt
import uuid
import time
from fastapi import Header, HTTPException, status
from typing import Optional


JWT_SECRET = os.getenv("JWT_SECRET", "xinghan")
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_SECONDS = os.getenv("ACCESS_TOKEN_EXPIRE_SECONDS", 900)


class TokenAuthority:
    
    @staticmethod
    def create_access_token(user_id: uuid.UUID) -> str:
        now = int(time.time())
        payload = {
            'sub': str(user_id),
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
            raise HTTPException(status_code=401, detail=f"Invalid token {token}")
        
    @staticmethod
    def get_optional_user_id(authorization: Optional[str] = Header(None)) -> Optional[str]:
        if not authorization:
            return None
        token = authorization.split(" ")[1]
        try:
            payload = TokenAuthority.verify_token(token)
            return payload['sub']
        except (jwt.ExpiredSignatureError, jwt.InvalidTokenError, jwt.DecodeError) as e:
            return None
        except Exception as e:
            return None

    @staticmethod
    def get_user_id(authorization: Optional[str] = Header(None)) -> str:
        
        user_id = TokenAuthority.get_optional_user_id(authorization=authorization)
        
        if user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Missing or invalid Authorization header, or token is invalid/expired."
            )
        return user_id