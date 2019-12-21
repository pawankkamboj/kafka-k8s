FROM centos:7
MAINTAINER DevOps "pawank.kamboj@gmail.com"

#- update base image and install require RPMs
RUN yum -y install iproute net-tools wget sudo bind-utils tcpdump java-1.8.0-openjdk java-1.8.0-openjdk-devel && \
        yum clean all && \
        rm -rf /var/cache/yum/* && \
        rm -f /etc/localtime && ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime && \
        useradd appuser && \
        rm -rf /etc/security/limits.d/* && \
        echo "#- adding appuser user in sudoers" >> /etc/sudoers && \
        echo 'Cmnd_Alias DEVOPSCMD = /usr/sbin/tcpdump, /usr/bin/chown, /usr/bin/chmod, /usr/bin/yum' >> /etc/sudoers && \
        echo 'appuser      ALL=(ALL)       NOPASSWD:DEVOPSCMD' >> /etc/sudoers

#- switch user
USER root

#- add package
RUN yum -y install which nmap-ncat && yum clean all

#- install kafka
USER appuser
ENV VERSION 2.3.1
RUN wget -q http://mirrors.estointernet.in/apache/kafka/${VERSION}/kafka_2.12-${VERSION}.tgz && \
    tar zxf kafka_2.12-$VERSION.tgz && \
    mv kafka_2.12-$VERSION kafka && \
    rm -rf kafka/site-docs kafka_2.12-$VERSION.tgz && \
    mkdir -p /home/appuser/kafka/kafka-logs /home/appuser/kafka-jmx && \ 
    wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.12.0/jmx_prometheus_javaagent-0.12.0.jar -O /home/appuser/kafka-jmx/jmx_prometheus.jar && \
    wget https://github.com/prometheus/jmx_exporter/raw/master/example_configs/kafka-2_0_0.yml -O /home/appuser/kafka-jmx/jmx_kafka_config.yml

#- startup file
COPY run.sh /usr/bin/run.sh

#- add kafka config file
COPY --chown=appuser:appuser server.properties /home/appuser/kafka/config/server.properties

#- work dir
WORKDIR /home/appuser/kafka

#- entrypoint script
ENTRYPOINT ["/usr/bin/run.sh"]

#- set current date/time
ARG BUILD_DATE
LABEL org.opencontainers.image.created=$BUILD_DATE 

#- Use PROD to run on PROD
CMD  ["kafkastart"]
