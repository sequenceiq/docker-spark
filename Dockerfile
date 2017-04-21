FROM ubuntu:15.04
MAINTAINER Aaron Steers "asteers@arivale.com"

LABEL Name=docker-spark
LABEL Version=1.0

USER root

# Ref: https://github.com/trueprint/bi-extract-service/blob/master/depends/spark-full/Dockerfile

##########################################
### SECTION ONE: PLATFORM AND PRE-REQS ###
##########################################

#Setup build environment for libpam
RUN apt-get -yq update && \
    apt-get -y -qq build-dep pam --fix-missing
#Rebuild and install libpam with --disable-audit option
RUN export CONFIGURE_OPTS=--disable-audit && \
    cd /root && \
    apt-get -bq source pam && \
    dpkg -i libpam-doc*.deb \
            libpam-modules*.deb \
            libpam-runtime*.deb \
            libpam0g*.deb

# install dev tools
RUN apt-get -yq install --fix-missing \
                        curl \
                        tar \
                        sudo \
                        openssh-server \
                        openssh-client \
                        rsync

# java
ENV JAVA_HOME /usr/java/default/
RUN mkdir -p $JAVA_HOME && \
    curl -Ls 'http://download.oracle.com/otn-pub/java/jdk/7u51-b13/jdk-7u51-linux-x64.tar.gz' \
    -H 'Cookie: oraclelicense=accept-securebackup-cookie' \
    | tar --strip-components=1 -xz -C $JAVA_HOME
# Java8: http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz

# apt-get statements
RUN apt-get update && \
    apt-get -y -qq install --fix-missing \
                        build-essential \
                        bzip2 \
                        ca-certificates \
                        checkinstall \
                        dnsutils \
                        e2fsprogs \
                        libbz2-dev \
                        libc6-dev \
                        libffi-dev \
                        libgdbm-dev \
                        libgss3 \
                        libncursesw5-dev \
                        libreadline-gplv2-dev \
                        libpq-dev \
                        libssl-dev \
                        libstdc++6 \
                        libsqlite3-dev \
                        locales \
                        postgresql \
                        python-dev \
                        python3-dev \
                        tk-dev \
                        wget \
                        unixodbc-dev \
                        zlib1g-dev

# Update python from 2.7.9 to 2.7.12
RUN curl -O https://www.python.org/ftp/python/2.7.12/Python-2.7.12.tgz && \
    tar xzf Python-2.7.12.tgz && \
    cd Python-2.7.12 && \
    ./configure --enable-unicode=ucs4 && \
    make altinstall

# Install setuptools and pip for python:
RUN wget https://bootstrap.pypa.io/get-pip.py -O - | python3
RUN wget https://bootstrap.pypa.io/get-pip.py -O - | python2.7

RUN python2.7 -m pip install \
                awscli \
                coverage \
                nose \
                PyYAML \
                pyodbc \
                psycopg2 \
                snowflake-connector-python \
                unittest2
RUN python3 -m pip install \
                awscli \
                coverage \
                nose \
                PyYAML \
                pyodbc \
                psycopg2 \
                snowflake-connector-python \
                unittest2

#Configure locales:
RUN locale-gen en_US en_US.UTF-8; locale-gen it_IT it_IT.UTF-8; dpkg-reconfigure locales

RUN apt-get -y install \
               telnet \
               nmap \
               net-tools
RUN nmap localhost
RUN netstat -nlp # | grep :9000
#Not working:
RUN telnet localhost 9000 || true


#####################################
### SECTION TWO: HADOOP and SPARK ###
#####################################


# General environment variables:
ENV HOME /usr/local/

# Hadoop environment variables:
ENV PATH $PATH:$JAVA_HOME/bin
ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_USER_NAME root
ENV YARN_CONF_DIR   $HADOOP_HOME/etc/hadoop
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop/
ENV PATH $PATH:$HADOOP_HOME/bin

# PySpark environment variables:
ENV SPARK_MASTER local
ENV SPARK_HOME /usr/local/spark
ENV SPARK_CONF_DIR $HADOOP_CONF_DIR
ENV PATH $PATH:$SPARK_HOME/bin
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/build:$SPARK_HOME/python/lib/py4j-0.10.4-src.zip:${PYTHONPATH:-}

# install hadoop bits
RUN curl -s http://apache.cs.utah.edu/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz \
  | tar -xz -C /usr/local/ && \
    ln -s /usr/local/hadoop-2.7.3 /usr/local/hadoop

# install spark bits:
RUN curl -s http://d3kbcqa49mib13.cloudfront.net/spark-2.1.0-bin-hadoop2.7.tgz | tar -xz -C /usr/local/ && \
    cd /usr/local && \
    ln -s spark-2.1.0-bin-hadoop2.7 spark


#####################################
### SECTION THREE: IMPORTED FILES ###
#####################################

WORKDIR $SPARK_HOME

# Import config and test files
COPY ./conf $HADOOP_CONF_DIR
COPY ./*.sh $SPARK_HOME/
COPY ./*.py $SPARK_HOME/
RUN chmod +x $HADOOP_CONF_DIR/*.sh \
             $SPARK_HOME/*.sh \
             $SPARK_HOME/*.py

# configure core-site.xml:
RUN sed s/HOSTNAME/localhost/ $HADOOP_CONF_DIR/core-site.xml.template > $HADOOP_CONF_DIR/core-site.xml

EXPOSE 50020 50090 50070 50010 50075 8031 8032 8033 8040 8042 49707 22 8088 8030

CMD ["bash", "bootstrap.sh"]

###################################################
### SECTION FOUR: MORE CONFIG (STILL DEBUGGING) ###
###################################################


# format a new distributed filesystem
RUN $HADOOP_HOME/bin/hdfs namenode -format

###############################
## SECTION FOUR: Testing ######
###############################

# # passwordless ssh
# RUN rm -f /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_rsa_key /root/.ssh/id_rsa && \
#     ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
#     ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
#     ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa && \
#     cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
# # Config and test sshd
# COPY ssh_config /root/.ssh/config
# RUN chmod 600 /root/.ssh/config && \
#     chown root:root /root/.ssh/config
# # fix the 254 error code
# RUN sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config && \
#     echo "UsePAM no" >> /etc/ssh/sshd_config && \
#     echo "Port 9000" >> /etc/ssh/sshd_config
# #was: echo "Port 2122" >> /etc/ssh/sshd_config

# RUN service ssh start
# # Verify connectivity on sshd port
