set DOCKER_PASS=
set DOCKER_USER=
set DOCKER_REGISTRY=registry.gitlab.com

docker login -u $DOCKER_USER -p $DOCKER_PASS $DOCKER_REGISTRY
docker-compose -f docker-compose.yml up -d
ngrok http 3000
