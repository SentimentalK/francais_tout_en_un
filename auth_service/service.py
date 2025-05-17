import uuid
import bcrypt
from fastapi import HTTPException, status
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from orm import UserModel
from repository import UserRepo
from utils.tokens import TokenAuthority


class AuthService:
    def __init__(self, user_repo: UserRepo):
        self.user_repo = user_repo

    @staticmethod
    def hash_password(password: str) -> str:
        pwd_bytes = password.encode('utf-8')
        salt = bcrypt.gensalt()
        hashed_password = bcrypt.hashpw(pwd_bytes, salt)
        return hashed_password.decode('utf-8')
    
    @staticmethod
    def verify_password(plain_password: str, hashed_password: str) -> bool:
        plain_password_bytes = plain_password.encode('utf-8')
        hashed_password_bytes = hashed_password.encode('utf-8')
        return bcrypt.checkpw(plain_password_bytes, hashed_password_bytes)

    def register(self, username: str, email: str, password: str) -> str:
        if self.user_repo.get_by_username(username):
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Username already registered")
        if self.user_repo.get_by_email(email):
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered")

        hashed_password = self.hash_password(password)
        try:
            user_model = self.user_repo.create(
                username=username, email=email, password_hash=hashed_password
            )
        except IntegrityError:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Username or email already exists."
            )
        except SQLAlchemyError:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="A database error occurred during registration."
            )
        except Exception:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="An internal error occurred during registration."
            )
        return TokenAuthority.create_access_token(user_id=user_model.id)

    def login(self, username: str, password: str) -> str:
        user_model = self.user_repo.get_by_username(username)
        if not user_model or not self.verify_password(password, user_model.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect username or password",
                headers={"WWW-Authenticate": "Bearer"},
            )
        return TokenAuthority.create_access_token(user_id=user_model.id)

    def get_user_info(self, user_id: uuid.UUID) -> UserModel:
        db_user_model = self.user_repo.get_by_id(user_id)
        if db_user_model is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found based on token")
        return db_user_model
        
