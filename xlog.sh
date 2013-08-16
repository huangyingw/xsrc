#!/bin/bash
TARGET=find.cc
if [ -n "$1" ]
then
    TARGET="$1"
fi
tail -f /opt/xetusbase/logs/tomcat/xetus-tomcat.log > "${TARGET}"
