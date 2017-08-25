##

# export AWS_ACCESS_KEY_ID=$(cat ~/.aws/credentials | grep aws_access_key_id | head -n1 | sed 's/ //g' | cut -d "=" -f 2) && export AWS_SECRET_ACCESS_KEY=$(cat ~/.aws/credentials | grep aws_secret_access_key | head -n1 | sed 's/ //g' | cut -d "=" -f 2)
# docker build -t trueprint/spark-min depends/spark-min && docker run -it --rm -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY trueprint/spark-min

set -e

echo -e "\nTesting S3 bucket access...\n"
set -v
hadoop fs -ls "s3n://arivale-bi-extracts-6n2ynm/software/"
