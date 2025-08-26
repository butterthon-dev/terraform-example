import json
import os
# from datetime import datetime

import boto3
# import redis
from fastapi import FastAPI, HTTPException

# from schemas.redis import RedisSetRequest, RedisSetResponse
from schemas.secretsmanager import SecretCreateRequest, SecretCreateResponse, SecretGetResponse

app = FastAPI()

# # Redisクライアントの初期化
# redis_client = redis.Redis(
#     host=os.environ.get("REDIS_HOST", "localhost"),
#     port=int(os.environ.get("REDIS_PORT", 6379)),
#     db=int(os.environ.get("REDIS_DB", 0)),
#     decode_responses=True
# )

# SecretManagerクライアントの初期化
secretsmanager_client = boto3.client("secretsmanager")

# SecretManagerの設定
SECRET_NAME = "env/wms/logiless"

@app.get("/healthz")
async def healthz():
    return {"message": "Healthy"}


@app.post("/push-message")
async def push_message(payload: dict):
    sqs_client = boto3.client("sqs")
    sqs_client.send_message(
        QueueUrl=os.environ["SQS_QUEUE_URL"],
        MessageBody=json.dumps(payload),
        # MessageGroupId="producer",  # メッセージを個別のグループに整理するためのID( FIFOキューに限る )
    )
    return {"message": "Message pushed."}


# @app.post("/redis/set", response_model=RedisSetResponse)
# async def set_redis_value(request: RedisSetRequest):
#     """
#     Redisに値を格納するエンドポイント

#     Args:
#         request: リクエストボディ（key, value, ttl）
#     """
#     try:
#         if request.ttl:
#             redis_client.setex(request.key, request.ttl, request.value)
#         else:
#             redis_client.set(request.key, request.value)

#         return RedisSetResponse(
#             message="Value stored successfully",
#             key=request.key,
#             value=request.value,
#             ttl=request.ttl
#         )
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=f"Redis error: {str(e)}")


# @app.get("/redis/get/{key}")
# async def get_redis_value(key: str):
#     """
#     Redisから値を取り出すエンドポイント
    
#     Args:
#         key: 取得するキー名
#     """
#     try:
#         value = redis_client.get(key)

#         if value is None:
#             raise HTTPException(status_code=404, detail=f"Key '{key}' not found")

#         # TTLも取得
#         ttl = redis_client.ttl(key)

#         return {
#             "key": key,
#             "value": value,
#             "ttl": ttl if ttl > 0 else None
#         }
#     except HTTPException:
#         raise
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=f"Redis error: {str(e)}")


# @app.delete("/redis/delete/{key}")
# async def delete_redis_value(key: str):
#     """
#     Redisから値を削除するエンドポイント

#     Args:
#         key: 削除するキー名
#     """
#     try:
#         result = redis_client.delete(key)

#         if result == 0:
#             raise HTTPException(status_code=404, detail=f"Key '{key}' not found")

#         return {
#             "message": "Value deleted successfully",
#             "key": key
#         }
#     except HTTPException:
#         raise
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=f"Redis error: {str(e)}")


# @app.get("/redis/keys")
# async def list_redis_keys(pattern: str = "*"):
#     """
#     Redisのキー一覧を取得するエンドポイント

#     Args:
#         pattern: 検索パターン（デフォルト: "*"）
#     """
#     try:
#         keys = redis_client.keys(pattern)
#         return {
#             "keys": keys,
#             "count": len(keys),
#             "pattern": pattern
#         }
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=f"Redis error: {str(e)}")


@app.post("/secrets/create", response_model=SecretCreateResponse)
async def create_secret_version(request: SecretCreateRequest):
    """
    SecretManagerにシークレットバージョンを登録するエンドポイント
    
    Args:
        request: リクエストボディ（secret_value, description）
    """
    try:
        # 既存のシークレットに新しいバージョンを追加
        response = secretsmanager_client.put_secret_value(
            SecretId=SECRET_NAME,
            SecretString=json.dumps(request.secret_value)
        )
        
        return SecretCreateResponse(
            message="Secret version created successfully",
            secret_name=SECRET_NAME,
            version_id=response.get("VersionId", "AWSCURRENT"),
            arn=response["ARN"]
        )
    except secretsmanager_client.exceptions.ResourceNotFoundException:
        raise HTTPException(status_code=404, detail=f"Secret '{SECRET_NAME}' not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"SecretManager error: {str(e)}")


@app.get("/secrets/latest", response_model=SecretGetResponse)
async def get_latest_secret_version():
    """
    SecretManagerから最新のシークレットバージョンを取得するエンドポイント
    """
    try:
        response = secretsmanager_client.get_secret_value(SecretId=SECRET_NAME)
        
        # シークレットの詳細情報も取得
        describe_response = secretsmanager_client.describe_secret(SecretId=SECRET_NAME)
        
        return SecretGetResponse(
            secret_name=SECRET_NAME,
            secret_value=json.loads(response["SecretString"]),
            version_id=response.get("VersionId", "AWSCURRENT"),
            created_date=response["CreatedDate"].isoformat(),
            description=describe_response.get("Description")
        )
    except secretsmanager_client.exceptions.ResourceNotFoundException:
        raise HTTPException(status_code=404, detail=f"Secret '{SECRET_NAME}' not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"SecretManager error: {str(e)}")
