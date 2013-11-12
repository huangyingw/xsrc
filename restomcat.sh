#!/bin/bash
TARGET=`ps ax|grep "\ /[U]sers.*/tomcat"|awk '{print $1}'`
if [ -n "$TARGET" ]
then
    kill -9 "$TARGET"
fi
tomcat/bin/xetusone.bash start
