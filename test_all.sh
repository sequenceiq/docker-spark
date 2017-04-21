#!/bin/bash

set -e  # Abort on failure

if [[ $AWS_ACCESS_KEY_ID && $AWS_SECRET_ACCESS_KEY ]]; then
    echo "Injecting AWS creds from environment variables..."
    bash $HADOOP_CONF_DIR/install_creds.sh
else
    echo "WARNING: AWS creds not found within environment variables..."
fi

set +e  # Resume on failure

echo "Executing test_hadoop.sh..."
bash ./test_hadoop.sh
HADOOP_RESULT=$?

echo "Executing test_pyspark.py..."
python2.7 ./test_pyspark.py
PYSPARK_RESULT=$?

set -e  # Abort on failure

if [[ $HADOOP_RESULT -eq 0 && $PYSPARK_RESULT -eq 0 ]]; then
    echo "All tests completed successfully!"
else
    if [[ $HADOOP_RESULT -ne 0 ]]; then
        echo "ERROR: test_hadoop.sh failed with code $HADOOP_RESULT"
    fi
    if [[ $PYSPARK_RESULT -ne 0 ]]; then
        echo "ERROR: test_pyspark.py failed with code $PYSPARK_RESULT"
    fi
    exit 1
fi
