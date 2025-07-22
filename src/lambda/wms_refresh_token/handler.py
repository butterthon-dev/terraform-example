import json
import sys

import requests

def entrypoint(event, context):
    response = requests.get("https://example.com/", timeout=30)
    return {
        "statusCode": 200,
        "body": json.dumps({
            "status_code": response.status_code,
            "message": f'Hello World From AWS Lambda using Python {sys.version}.'
        })
    }
