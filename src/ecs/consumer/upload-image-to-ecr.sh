aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin 184321346292.dkr.ecr.ap-northeast-1.amazonaws.com
docker build --platform=linux/amd64 -t consumer-viz-butterthon-dev .
docker tag consumer-viz-butterthon-dev:latest 184321346292.dkr.ecr.ap-northeast-1.amazonaws.com/consumer-viz-butterthon-dev:latest
docker push 184321346292.dkr.ecr.ap-northeast-1.amazonaws.com/consumer-viz-butterthon-dev:latest
