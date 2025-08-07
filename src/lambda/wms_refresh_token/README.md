``` shell
# ECR認証
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin 184321346292.dkr.ecr.ap-northeast-1.amazonaws.com

# Dockerイメージビルド
docker build --platform linux/amd64 -t viz-butterthon-dev-ecr-wms_refresh_token .

# Dockerイメージにタグ付け
docker tag viz-butterthon-dev-ecr-wms_refresh_token:latest 184321346292.dkr.ecr.ap-northeast-1.amazonaws.com/viz-butterthon-dev-ecr-wms_refresh_token:latest

# Dockerイメージをプッシュ
docker push 184321346292.dkr.ecr.ap-northeast-1.amazonaws.com/viz-butterthon-dev-ecr-wms_refresh_token:latest
```
