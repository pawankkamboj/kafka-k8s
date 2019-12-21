#!/bin/bash
set -e
sh -c  /home/appuser/zookeeper/bin/zkGenConfig.sh ;
exec "$@"
