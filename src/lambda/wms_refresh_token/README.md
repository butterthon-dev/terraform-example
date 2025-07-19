``` shell
# ECR認証
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin 184321346292.dkr.ecr.ap-northeast-1.amazonaws.com

# Dockerイメージビルド
docker build --platform linux/amd64 -t wms-refresh-token-viz-butterthon-dev .

# Dockerイメージにタグ付け
docker tag wms-refresh-token-viz-butterthon-dev:latest 184321346292.dkr.ecr.ap-northeast-1.amazonaws.com/wms-refresh-token-viz-butterthon-dev:latest

# Dockerイメージをプッシュ
docker push 184321346292.dkr.ecr.ap-northeast-1.amazonaws.com/wms-refresh-token-viz-butterthon-dev:latest
```
