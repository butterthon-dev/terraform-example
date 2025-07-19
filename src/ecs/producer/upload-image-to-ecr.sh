aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin 184321346292.dkr.ecr.ap-northeast-1.amazonaws.com
docker build --platform=linux/amd64 -t producer-viz-butterthon-dev .
docker tag producer-viz-butterthon-dev:latest 184321346292.dkr.ecr.ap-northeast-1.amazonaws.com/producer-viz-butterthon-dev:latest
docker push 184321346292.dkr.ecr.ap-northeast-1.amazonaws.com/producer-viz-butterthon-dev:latest
