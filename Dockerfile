FROM sequenceiq/hadoop-docker:2.4.1
MAINTAINER SequenceIQ

RUN curl -s https://s3-eu-west-1.amazonaws.com/seq-spark/spark-v1.0.1-rc2.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-v1.0.1-rc2 spark
RUN $BOOTSTRAP && $HADOOP_PREFIX/bin/hadoop dfsadmin -safemode leave && $HADOOP_PREFIX/bin/hdfs dfs -put /usr/local/spark/assembly/target/scala-2.10 /spark

ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop
ENV SPARK_JAR hdfs:///spark/spark-assembly-1.0.1-hadoop2.4.1.jar

CMD ["/etc/bootstrap.sh", "-d"]