##

# export AWS_ACCESS_KEY_ID=$(cat ~/.aws/credentials | grep aws_access_key_id | head -n1 | sed 's/ //g' | cut -d "=" -f 2) && export AWS_SECRET_ACCESS_KEY=$(cat ~/.aws/credentials | grep aws_secret_access_key | head -n1 | sed 's/ //g' | cut -d "=" -f 2)
# docker build -t trueprint/spark-min depends/spark-min && docker run -it --rm -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY trueprint/spark-min

set -e

echo "Content of core-site.xml is:"
cat $HADOOP_CONF_DIR/core-site.xml

#echo "DEBUG: Installing S3 creds..."
#bash $HADOOP_CONF_DIR/install_creds.sh
# Uncomment to debug:
# cat $HADOOP_CONF_DIR/core-site.xml

echo "Testing S3 bucket access..."
set -v
hadoop fs -ls "s3n://arivale-bi-extracts-6n2ynm/software/"
