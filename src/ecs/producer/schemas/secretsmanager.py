from pydantic import BaseModel
from typing import Optional, Dict, Any

class SecretCreateRequest(BaseModel):
    secret_value: Dict[str, Any]
    description: Optional[str] = None

class SecretCreateResponse(BaseModel):
    message: str
    secret_name: str
    version_id: str
    arn: str

class SecretGetResponse(BaseModel):
    secret_name: str
    secret_value: Dict[str, Any]
    version_id: str
    created_date: str
    description: Optional[str] = None 