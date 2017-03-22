# trueprint/docker-spark docker image

This is the core image for spark and spark-analytics functionality.
Does not contain Jupyter notebooks.

## Build Command

    cd docker-spark;
    docker build --rm -t trueprint/docker-spark .;

## Push Command

    docker login -u $DOCKER_USER -p $DOCKER_PASS
    docker push trueprint/docker-spark

## Run tests

    docker run --rm -it -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -v /tmp/tests/output:/var/docker-spark/output trueprint/docker-spark

## Run as daemon (not working right now, requires bootstrap.sh to be re-enabled)

    docker run --rm -it -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -v /tmp/tests/output:/var/docker-spark/output trueprint/docker-spark -d
