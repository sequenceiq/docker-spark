FROM sequenceiq/hadoop-docker:2.6.0
MAINTAINER SequenceIQ

# Env variables
ENV SPARK_HOME /usr/local/spark
ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop
ENV PATH $PATH:$SPARK_HOME/bin:$HADOOP_PREFIX/bin

# Copy
COPY yarn-remote-client $SPARK_HOME/yarn-remote-client
COPY bootstrap.sh /etc/bootstrap.sh

#support for Hadoop 2.6.0
RUN curl -s http://d3kbcqa49mib13.cloudfront.net/spark-1.6.1-bin-hadoop2.6.tgz | tar -xz -C /usr/local/ \
    && cd /usr/local && ln -s spark-1.6.1-bin-hadoop2.6 spark \
    &&  $BOOTSTRAP && $HADOOP_PREFIX/bin/hadoop dfsadmin -safemode leave && $HADOOP_PREFIX/bin/hdfs dfs -put $SPARK_HOME-1.6.1-bin-hadoop2.6/lib /spark

# update boot script
RUN chown root.root /etc/bootstrap.sh \
    && chmod 700 /etc/bootstrap.sh \
    && rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm \
    && yum -y install R

ENTRYPOINT ["/etc/bootstrap.sh"]
