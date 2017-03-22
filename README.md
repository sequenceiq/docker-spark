# trueprint/docker-spark docker image

This is the core image for spark and spark-analytics functionality.
Does not contain Jupyter notebooks.

## Build Command

cd docker-spark;
docker build --rm -t trueprint/docker-spark .;

## Push Command

docker login -u $DOCKER_USER -p $DOCKER_PASS
docker push trueprint/docker-spark
