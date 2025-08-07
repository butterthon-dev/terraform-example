import json
from logging import getLogger
import sys

import requests

logger = getLogger(__name__)


def entrypoint(event, context):
    response = requests.get("https://example.com/", timeout=30)
    result = 1 / 0  # 0除算でエラーを発生させる
    return {
        "statusCode": 200,
        "body": json.dumps({
            "status_code": response.status_code,
            "message": f'Hello World From AWS Lambda using Python {sys.version}.'
        })
    }
