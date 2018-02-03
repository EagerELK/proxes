#!/bin/bash

docker login --email=$DOCKER_HUB_EMAIL --username=$DOCKER_HUB_USERNAME --password=$DOCKER_HUB_PASSWORD
docker build -t proxes-os:$TRAVIS_TAG .
docker push $DOCKER_HUB_USERNAME/proxes-os:$TRAVIS_TAG
