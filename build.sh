#!/bin/bash

DOCKERHUB_ROOT=trueprint
IMAGE=docker-spark

docker build --rm=false -t $DOCKERHUB_ROOT/$IMAGE:latest .
docker run --rm -it\
    -e CIRCLECI\
    -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY\
    -v /tmp/tests/output:/var/docker-spark/output\
    $DOCKERHUB_ROOT/$IMAGEL:latest testall
