#!/bin/bash

cd $SPARK_HOME

set -e

if [[ $AWS_ACCESS_KEY_ID && $AWS_SECRET_ACCESS_KEY ]]; then
    echo "Injecting AWS creds from environment variables..."
    bash ./install_creds.sh
else
    echo "WARNING: AWS creds not found within environment variables..."
fi

set +e  # Resume on failure

echo -e "\nExecuting test_hadoop.sh...\n"
bash ./test_hadoop.sh
HADOOP_RESULT=$?

echo -e "\nExecuting test_pyspark.py...\n"
python2.7 ./test_pyspark.py
PYSPARK_RESULT=$?

set -e  # Abort on failure

if [[ $HADOOP_RESULT -eq 0 && $PYSPARK_RESULT -eq 0 ]]; then
    echo -e "\nAll tests completed successfully!\n"
else
    if [[ $HADOOP_RESULT -ne 0 ]]; then
        echo "ERROR: test_hadoop.sh failed with code $HADOOP_RESULT"
    fi
    if [[ $PYSPARK_RESULT -ne 0 ]]; then
        echo "ERROR: test_pyspark.py failed with code $PYSPARK_RESULT"
    fi
    exit 1
fi
