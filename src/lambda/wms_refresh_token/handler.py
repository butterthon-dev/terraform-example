import json
import logging
import os
import sys
from logging import getLogger

logging.basicConfig(level=logging.INFO)
logger = getLogger(__name__)


def entrypoint(event, context):
    logger.info("entrypoint called")
    logger.info(f"ENV={os.getenv('ENV', '')}")

    try:
        result = 1 / 0  # 0除算でエラーを発生させる

    except Exception as e:
        logger.error(f"Error occurred: {str(e)}")
        raise

    return {
        "statusCode": 200,
        "body": json.dumps({
            "status_code": 200,
            "message": f'Hello World From AWS Lambda using Python {sys.version}.'
        })
    }
