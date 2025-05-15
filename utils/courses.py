import os
import redis

class EntitlementsCache:
    def __init__(self):
        self.pool = redis.ConnectionPool(
            host=os.getenv("REDIS_HOST"),
            port=int(os.getenv("REDIS_PORT")),
            password=os.getenv("REDIS_PASSWORD", None),
            db=int(os.getenv("REDIS_DB", 0)),
            decode_responses=True,
            socket_connect_timeout=3,
            health_check_interval=30
        )
        self.redis = redis.Redis(connection_pool=self.pool)
        if not self._test_connection():
            raise ConnectionError("Redis connection failed")

    def _test_connection(self):
        try:
            return self.redis.ping()
        except redis.exceptions.RedisError:
            return False

    def add_courses(self, user_id: int, course_ids: list[str]) -> int:
        return self.redis.sadd(f"user:{user_id}:courses", *course_ids)

    def get_courses(self, user_id: int) -> set[str]:
        return self.redis.smembers(f"user:{user_id}:courses")

    def is_course_authorized(self, user_id: int, course_id: str) -> bool:
        return self.redis.sismember(f"user:{user_id}:courses", course_id)

    def remove_course(self, user_id: int, course_id: str) -> int:
        return self.redis.srem(f"user:{user_id}:courses", course_id)
