FROM python:3.13-slim-bookworm

ARG DEVELOPMENT=0

# コンテナ内に.venvを作らないようにする環境変数
ENV UV_PROJECT_ENVIRONMENT='/usr/local/'
ENV UV_SYSTEM_PYTHON=1
# Pythonの標準出力をバッファリングしないように設定
ENV PYTHONUNBUFFERED=1

WORKDIR /app

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
