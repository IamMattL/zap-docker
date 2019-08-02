#!/usr/bin/env bash

CONTAINER_ID=$(docker run -u zap -p 8090:8090 -d owasp/zap2docker-weekly zap-webswing.sh -daemon -port 8090 -host 0.0.0.0 -config api.disablekey=true -config scanner.attackOnStart=true -config view.mode=attack -config connection.dnsTtlSuccessfulQueries=-1 -config api.addrs.addr.name=.* -config api.addrs.addr.regex=true)

# the target URL for ZAP to scan
TARGET_URL=$1

docker exec $CONTAINER_ID zap-cli -p 8090 status -t 120 && docker exec $CONTAINER_ID zap-cli -p 8090 open-url $TARGET_URL

docker exec $CONTAINER_ID zap-cli -p 8090 spider $TARGET_URL

docker exec $CONTAINER_ID zap-cli -p 8090 active-scan -r $TARGET_URL

docker exec $CONTAINER_ID zap-cli -p 8090 alerts

# docker logs [container ID or name]
divider==================================================================
printf "\n"
printf "$divider"
printf "ZAP-daemon log output follows"
printf "$divider"
printf "\n"

docker logs $CONTAINER_ID

docker stop $CONTAINER_ID
