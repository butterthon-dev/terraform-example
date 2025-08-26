import os

import psutil


bind = f"0.0.0.0:8000"

worker_class = "uvicorn.workers.UvicornWorker"
workers = psutil.cpu_count(logical=True) * 2 + 1

# https://github.com/benoitc/gunicorn/pull/862#issuecomment-53175919
max_requests = 500
max_requests_jitter = 200

# https://cloud.google.com/load-balancing/docs/https#timeouts_and_retries
keepalive = 75

timeout = 360
loglevel = "info"

accesslog = "-"  # Output to stdout
errorlog = "-"   # Output to stderr
