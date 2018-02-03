#!/bin/bash

docker -v
docker login --username=$DOCKER_HUB_USERNAME --password=$DOCKER_HUB_PASSWORD
docker build -t $DOCKER_HUB_USERNAME/proxes-os:latest .
docker tag $DOCKER_HUB_USERNAME/proxes-os $DOCKER_HUB_USERNAME/proxes-os:$TRAVIS_TAG
docker push $DOCKER_HUB_USERNAME/proxes-os:latest
docker push $DOCKER_HUB_USERNAME/proxes-os:$TRAVIS_TAG
