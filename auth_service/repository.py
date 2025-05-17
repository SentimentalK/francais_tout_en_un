# Implementation of the Repository Pattern that Martin Fowler describes in his book 
# "Patterns of Enterprise Application Architecture" as
#   "a mediator between the domain and data mapping layers, 
#    providing a collection-like interface for accessing domain objects. 
#    The Repository acts like an in-memory collection of domain objects, 
#    allowing client code to construct queries declaratively and interact 
#    with domain objects as if they were all in memory, regardless of the 
#    underlying data store."


import uuid
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from orm import UserModel

class UserRepo:

    def __init__(self, db: Session):
        self.db = db

    def get_by_username(self, username: str) -> UserModel | None:
        return self.db.query(UserModel).filter(UserModel.username == username).first()

    def get_by_email(self, email: str) -> UserModel | None:
        return self.db.query(UserModel).filter(UserModel.email == email).first()

    def get_by_id(self, user_id: uuid.UUID) -> UserModel | None:
        return self.db.query(UserModel).get(user_id)

    def create(self, username: str, email: str, password_hash: str) -> UserModel:
        db_user = UserModel(username=username, email=email, password_hash=password_hash)
        try:
            self.db.add(db_user)
            self.db.commit()
            self.db.refresh(db_user)
            return db_user
        except IntegrityError:
            self.db.rollback()
            raise
        except Exception:
            self.db.rollback()
            raise