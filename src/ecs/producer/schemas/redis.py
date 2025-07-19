from pydantic import BaseModel


class RedisSetRequest(BaseModel):
    key: str
    value: str
    ttl: int = None


class RedisSetResponse(BaseModel):
    message: str
    key: str
    value: str
    ttl: int = None
