import os
from pyspark.sql import SparkSession

print("Beginning PySpark test...")

def print_env_var_debug(env_var):
    print("ENV VAR DEBUG: {}={}".format(
        env_var, os.getenv(env_var)))

print_env_var_debug('PATH')
print_env_var_debug('PYTHONPATH')
print_env_var_debug('SPARKHOME')
print_env_var_debug('SPARK_MASTER')

print("Initializing spark instance from SparkSession.builder...")
spark = (SparkSession.builder
         .master(os.getenv('SPARK_MASTER'))
         .appName('Arivale Spark ETL')
         .enableHiveSupport()
         .config("spark.sql.crossJoin.enabled", True)
         .getOrCreate())

spark.sparkContext.setLogLevel('ERROR')

TEST_FILE_NAME = "s3n://arivale-bi-extracts-6n2ynm/software/arivale-dw/stages/beta/dw-manifest.yaml"
print("Checking S3 permissions on test file: {}".format(TEST_FILE_NAME))
spark.sparkContext.textFile(TEST_FILE_NAME).collect()

print("PySpark test completed successfully!")
