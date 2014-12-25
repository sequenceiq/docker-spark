FROM sequenceiq/hadoop-docker:2.6.0
MAINTAINER SequenceIQ

RUN curl -s http://d3kbcqa49mib13.cloudfront.net/spark-1.2.0-bin-hadoop2.4.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-1.2.0-bin-hadoop2.4 spark
ENV SPARK_HOME /usr/local/spark
RUN mkdir $SPARK_HOME/yarn-remote-client
ADD yarn-remote-client $SPARK_HOME/yarn-remote-client

RUN $BOOTSTRAP && $HADOOP_PREFIX/bin/hadoop dfsadmin -safemode leave && $HADOOP_PREFIX/bin/hdfs dfs -put $SPARK_HOME-1.2.0-bin-hadoop2.4/lib /spark

ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop
ENV SPARK_JAR hdfs:///spark/spark-assembly-1.2.0-hadoop2.4.0.jar
ENV PATH $PATH:$SPARK_HOME/bin:$HADOOP_PREFIX/bin

#This enables ssh sessions from remote host.
echo "root:root" | chpasswd
echo "Port 22" >> /etc/ssh/sshd_config
service sshd restart

#Adding spark and hadoop paths for remote ssh sessions.
echo "export PATH=$PATH" >> /root/.bash_profile
echo "export PATH=$PATH" >> /root/.bashrc

CMD ["/etc/bootstrap.sh", "-d"]
