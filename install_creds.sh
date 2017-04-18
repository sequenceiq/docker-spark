#!/bin/bash

### Inject creds from env variables (or script args) into the spark/hadoop config file "core-site.xml"

AWS_ACCESS_KEY_ID=${1:-$AWS_ACCESS_KEY_ID}
AWS_SECRET_ACCESS_KEY=${2:-$AWS_SECRET_ACCESS_KEY}

ORIG_DIR=$(pwd)
PARENT_DIR=$( dirname "${BASH_SOURCE[0]}" )
TEMPLATE_FILE="core-site.xml.template"

TEMPLATE_FILE_TEXT=$(<$HADOOP_CONF_DIR/$TEMPLATE_FILE)
REMOVE_TEXT="</configuration>"
APPEND_TEXT="
  <property>
    <name>fs.s3.awsAccessKeyId</name>
    <value>$AWS_ACCESS_KEY_ID</value>
  </property>
  <property>
    <name>fs.s3.awsSecretAccessKey</name>
    <value>$AWS_SECRET_ACCESS_KEY</value>
  </property>
  <property>
    <name>fs.s3n.awsAccessKeyId</name>
    <value>$AWS_ACCESS_KEY_ID</value>
  </property>
  <property>
    <name>fs.s3n.awsSecretAccessKey</name>
    <value>$AWS_SECRET_ACCESS_KEY</value>
  </property>
  <property>
    <name>fs.s3a.awsAccessKeyId</name>
    <value>$AWS_ACCESS_KEY_ID</value>
  </property>
  <property>
    <name>fs.s3a.awsSecretAccessKey</name>
    <value>$AWS_SECRET_ACCESS_KEY</value>
  </property>
</configuration>"

NEW_FILE_TEXT="${TEMPLATE_FILE_TEXT//$REMOVE_TEXT/$APPEND_TEXT}"
echo -e $NEW_FILE_TEXT > $HADOOP_CONF_DIR/core-site.xml.new
cp $HADOOP_CONF_DIR/core-site.xml.new $HADOOP_CONF_DIR/core-site.xml
