FROM sequenceiq/hadoop-ubuntu:2.6.0
MAINTAINER SequenceIQ

#support for Hadoop 2.4.0+
RUN curl -s http://d3kbcqa49mib13.cloudfront.net/spark-1.3.0-bin-hadoop2.4.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-1.3.0-bin-hadoop2.4 spark
ENV SPARK_HOME /usr/local/spark
RUN mkdir $SPARK_HOME/yarn-remote-client
ADD yarn-remote-client $SPARK_HOME/yarn-remote-client
RUN $BOOTSTRAP && $HADOOP_PREFIX/bin/hadoop dfsadmin -safemode leave && $HADOOP_PREFIX/bin/hdfs dfs -put $SPARK_HOME-1.3.0-bin-hadoop2.4/lib /spark

ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop
ENV SPARK_JAR hdfs:///spark/spark-assembly-1.3.0-hadoop2.4.0.jar
ENV PATH $PATH:$SPARK_HOME/bin:$HADOOP_PREFIX/bin
RUN sudo apt-get update
RUN sudo apt-get install -y python-pip\
                            python-zmq\
                            python-dev\
                            libatlas-dev\
                            libpng12-dev\
                            libfreetype6\
                            libfreetype6-dev\
                            g++\
                            libzmq-dev\
                            liblapack-dev\
                            gfortran\
                            build-essential\
                            python-qt4
RUN pip install markupsafe\
                jsonschema\
                numpy\
                pandas\
                matplotlib\
                supervisor
RUN pip install "ipython[all]"

EXPOSE 8888
ADD start-supervisor.sh /usr/local/bin/
ADD supervisord.conf /etc/supervisord.conf
                
RUN mkdir /var/log/supervisord/
# update boot script
COPY bootstrap.sh /etc/bootstrap.sh
RUN chown root.root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

RUN mkdir /ipython
ENTRYPOINT ["/etc/bootstrap.sh"]
