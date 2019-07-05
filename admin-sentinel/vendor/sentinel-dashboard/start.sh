#!/bin/bash
#set -x
cd `dirname $0`
BIN_DIR=`pwd`
DEPLOY_DIR=`pwd`

SERVER_NAME=`sed '/app.name/!d;s/.*=//' application.properties | tr -d '\r'`
VERSION=`sed '/app.version/!d;s/.*=//' application.properties | tr -d '\r'`
APP_FILE=$SERVER_NAME-$VERSION.jar
SERVER_PORT=`sed '/server.port/!d;s/.*=//' application.properties | tr -d '\r'`
SPRING_PROFILE=`sed '/spring.profiles.active/!d;s/.*=//' application.properties | tr -d '\r'`

JAVA_OPTS=" -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true "

. setenv.sh

if [ -z "$SERVER_NAME" ]; then
    SERVER_NAME=`hostname`
fi

PIDS=`ps -f | grep java | grep "$APP_FILE" |grep server.port=$SERVER_PORT |awk '{print $2}'`
if [ -n "$PIDS" ]; then
    echo "ERROR: The $SERVER_NAME already started!"
    echo "PID: $PIDS"
    exit 1
fi

if [ -n "$SERVER_PORT" ]; then
    JAVA_OPTS="${JAVA_OPTS} -Dserver.port=${SERVER_PORT}"

    SERVER_PORT_COUNT=`netstat -tln | grep :$SERVER_PORT | wc -l`
    if [ $SERVER_PORT_COUNT -gt 0 ]; then
        echo "ERROR: The $SERVER_NAME port $SERVER_PORT already used!"
        exit 1
    fi
fi

if [ -n "$DUBBO_PORT" ]; then
    JAVA_OPTS="${JAVA_OPTS} -Ddubbo.protocol.port=${DUBBO_PORT}"

    SERVER_PORT_COUNT=`netstat -tln | grep :$DUBBO_PORT | wc -l`
    if [ $SERVER_PORT_COUNT -gt 0 ]; then
        echo "ERROR: The $SERVER_NAME dubbo port $DUBBO_PORT already used!"
        exit 1
    fi
fi

LOGS_DIR=$DEPLOY_DIR/logs

if [ ! -d $LOGS_DIR ]; then
    mkdir $LOGS_DIR
fi
STDOUT_FILE=$LOGS_DIR/stdout.log


LIB_DIR=$DEPLOY_DIR/lib
CLASSPATH=''
if [ -d $LIB_DIR ]; then
LIB_JARS=`ls $LIB_DIR|grep .jar|awk '{print "'$LIB_DIR'/"$0}'|tr "\n" ":"`
CLASSPATH=" -classpath ./:$LIB_JARS "
fi

if [ -n "$SPRING_PROFILE" ]; then
    JAVA_OPTS="${JAVA_OPTS} -Dspring.profiles.active=${SPRING_PROFILE}"
fi


JAVA_DEBUG_OPTS=""
if [ "$1" = "debug" ]; then
    JAVA_DEBUG_OPTS=" -Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n "
fi
JAVA_JMX_OPTS=""
if [ "$1" = "jmx" ]; then
    JAVA_JMX_OPTS=" -Dcom.sun.management.jmxremote.port=1099 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false "
fi
JAVA_MEM_OPTS=""
BITS=`java -version 2>&1 | grep -i 64-bit`
if [ -n "$BITS" ]; then
    JAVA_MEM_OPTS=" -server -Xmx2g -Xms512m -Xmn256m -XX:PermSize=128m -Xss256k -XX:+DisableExplicitGC -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection -XX:LargePageSizeInBytes=128m -XX:+UseFastAccessorMethods -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70 "
else
    JAVA_MEM_OPTS=" -server -Xms1g -Xmx1g -XX:PermSize=128m -XX:SurvivorRatio=2 -XX:+UseParallelGC "
fi

echo -e "Starting the $SERVER_NAME ...\c"
nohup java $JAVA_OPTS $JAVA_MEM_OPTS $JAVA_DEBUG_OPTS $JAVA_JMX_OPTS $CLASSPATH  -jar $APP_FILE $* > $STDOUT_FILE 2>&1 &

COUNT=0
while [ $COUNT -lt 1 ]; do
    echo -e ".\c"
    sleep 1
    if [ -n "$SERVER_PORT" ]; then
            COUNT=`netstat -an | grep $SERVER_PORT | wc -l`
    else
    	COUNT=`ps -f | grep java | grep "$APP_FILE" | awk '{print $2}' | wc -l`
    fi
    if [ $COUNT -gt 0 ]; then
        break
    fi
done

echo "OK!"
PIDS=`ps -f | grep java | grep "$APP_FILE" | awk '{print $2}'`
echo "PID: $PIDS"