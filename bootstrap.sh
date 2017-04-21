#!/bin/bash

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_HOME/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

# customizing core-site.xml configuration
sed s/HOSTNAME/$HOSTNAME/ $HADOOP_CONF_DIR/core-site.xml.template > $HADOOP_CONF_DIR/core-site.xml

# setting spark defaults
# cp $SPARK_HOME/conf/metrics.properties.template $SPARK_HOME/conf/metrics.properties

# Skip in standalone mode:
#$HADOOP_HOME/sbin/start-dfs.sh
#$HADOOP_HOME/sbin/start-yarn.sh

if [[ ! -z $AWS_ACCESS_KEY_ID ]]; then
	bash $SPARK_HOME/install_creds.sh
fi

CMD=${1:-"exit 0"}
if [[ "$CMD" == testall ]]; then
	bash $SPARK_HOME/testall.sh
elif [[ "$CMD" == "-d" ]];
then
	echo "sshd service not yet supported"
	exit 1
	#service sshd start
	#service sshd stop
	#/usr/sbin/sshd -D -d
else
	/bin/bash -c "$*"
fi
