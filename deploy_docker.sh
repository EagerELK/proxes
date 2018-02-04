#!/bin/bash

docker -v
docker login --username=$DOCKER_HUB_USERNAME --password=$DOCKER_HUB_PASSWORD
docker build -t eagerelk/proxes:latest .
docker tag eagerelk/proxes eagerelk/proxes:$TRAVIS_TAG
docker push eagerelk/proxes:latest
docker push eagerelk/proxes:$TRAVIS_TAG
