#!/bin/bash

set -m
set -e

configset() 
{
        if [ -z $POD_NAME ]; then
        	echo "POD_NAME is a mandatory environment variable."
	        exit 1
    	fi

        MY_ID=$(echo $POD_NAME | awk -F'-' '{print $NF}')

        echo "Starting kafka server..."
	rm -f /home/appuser/kafka/kafka-logs/meta.properties
	cd /home/appuser/kafka
        export KAFKA_OPTS="-javaagent:/home/appuser/kafka-jmx/jmx_prometheus.jar=7071:/home/appuser/kafka-jmx/jmx_kafka_config.yml"

        if [ -z $ZOOKEEPER_CONNECT ]; then
                echo "ZOOKEEPER_CONNECT is a mandatory environment variable, provide zookeeper nodes IP:port."
                exit 1
        fi

	exec ./bin/kafka-server-start.sh config/server.properties --override broker.id=$MY_ID --override zookeeper.connect=$ZOOKEEPER_CONNECT
}

# initilize script here
case $1 in
kafkastart)
	configset
        ;;
*)
        exec "$@"
        ;;
esac

