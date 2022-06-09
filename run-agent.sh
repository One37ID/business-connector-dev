export DOCKER_PASS=
export DOCKER_USER=
export DOCKER_REGISTRY=registry.gitlab.com

docker login -u $DOCKER_USER -p $DOCKER_PASS $DOCKER_REGISTRY
docker-compose -f docker-compose.yml up -d
