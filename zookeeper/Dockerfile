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

#- install dependency
USER root
RUN yum -y install which nmap-ncat && yum clean all

#- install zookeeper
USER appuser
ENV VERSION 3.4.14
RUN wget -q https://www-eu.apache.org/dist/zookeeper/zookeeper-${VERSION}/zookeeper-${VERSION}.tar.gz && \
  tar zxf zookeeper-$VERSION.tar.gz && \
  mv zookeeper-$VERSION zookeeper && \
  rm -rf $(find ./zookeeper | egrep "(\.(exe|bat)$)") && \
  rm -rf zookeeper/docs zookeeper-$VERSION.tar.gz

COPY --chown=appuser:appuser script/zkMetrics.sh /home/appuser/zookeeper/bin/zkMetrics.sh
COPY --chown=appuser:appuser script/zkOk.sh /home/appuser/zookeeper/bin/zkOk.sh
COPY --chown=appuser:appuser script/zkGenConfig.sh /home/appuser/zookeeper/bin/zkGenConfig.sh
COPY run.sh /usr/bin/run.sh

ENV ZOO_USER=appuser \
    ZOO_CONF_DIR=/home/appuser/zookeeper/conf \
    ZOO_DATA_DIR=/home/appuser/zookeeper/data/data \
    ZOO_DATA_LOG_DIR=/home/appuser/zookeeper/data/datalog \
    ZOO_PORT=2181 \
    ZOO_TICK_TIME=2000 \
    ZOO_INIT_LIMIT=5 \
    ZOO_SYNC_LIMIT=2 \
    ZOO_MAXCLIENTCNXNS=60

#- set current date/time
ARG BUILD_DATE
LABEL org.opencontainers.image.created=$BUILD_DATE 

ENTRYPOINT ["/usr/bin/run.sh"]
CMD ["/home/appuser/zookeeper/bin/zkServer.sh", "start-foreground"]

