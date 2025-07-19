FROM python:3.13-slim-bookworm

ARG DEVELOPMENT=0

# コンテナ内に.venvを作らないようにする環境変数
ENV UV_PROJECT_ENVIRONMENT='/usr/local/'
ENV UV_SYSTEM_PYTHON=1

WORKDIR /app

# NOTE: パッケージを追加したい場合はコメントアウトを解除し、`apt-get install`のパッケージを書き換えてください
#
# RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
#     --mount=type=cache,target=/var/lib/apt,sharing=locked \
#     apt-get update && \
#     apt-get install -y --no-install-recommends \
#         default-libmysqlclient-dev \
#         build-essential \
#         pkg-config

COPY --from=ghcr.io/astral-sh/uv:0.7.13 /uv /bin/uv

# Copy the project into the image
ADD . /app

RUN \
    # ローカル環境は全てのパッケージをインストール
    if [ $DEVELOPMENT = 1 ]; then \
        uv export --frozen --format requirements-txt > requirements.txt && \
        uv pip install -r requirements.txt; \
    # ローカルでない環境では開発用パッケージをインストールしない(クラウドにアップロードする場合など)
    else \
        uv export --frozen --no-dev --format requirements-txt > requirements.txt && \
        uv pip install -r requirements.txt; \
    fi

ENTRYPOINT ["./entrypoint.sh"]
