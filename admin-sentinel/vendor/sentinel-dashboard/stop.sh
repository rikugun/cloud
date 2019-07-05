#!/bin/bash
cd `dirname $0`
BIN_DIR=`pwd`

DEPLOY_DIR=`pwd`
CONF_DIR=$DEPLOY_DIR/conf

SERVER_NAME=`sed '/app.name/!d;s/.*=//' application.properties | tr -d '\r'`
VERSION=`sed '/app.version/!d;s/.*=//' application.properties | tr -d '\r'`
APP_FILE=$SERVER_NAME-$VERSION.jar
SERVER_PORT=`sed '/server.port/!d;s/.*=//' application.properties | tr -d '\r'`


if [ -z "$SERVER_NAME" ]; then
    SERVER_NAME=`hostname`
fi

PIDS=`ps -f | grep java | grep "$APP_FILE" |grep server.port=$SERVER_PORT |awk '{print $2}'`
if [ -z "$PIDS" ]; then
    echo "ERROR: The $SERVER_NAME does not started!"
    exit 1
fi

echo -e "Stopping the $SERVER_NAME ...\c"
for PID in $PIDS ; do
    kill $PID > /dev/null 2>&1
done

COUNT=0
while [ $COUNT -lt 1 ]; do
    echo -e ".\c"
    sleep 1
    COUNT=1
    for PID in $PIDS ; do
        PID_EXIST=`ps -f -p $PID | grep java`
        if [ -n "$PID_EXIST" ]; then
            COUNT=0
            break
        fi
    done
done

echo "OK!"
echo "PID: $PIDS"