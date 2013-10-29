#!/bin/bash
TARGET=find.cc
if [ -n "$1" ]
then
    TARGET="$1"
fi
echo now, begin to log
running_home=`ps ax|grep -o "\ /Users.*/tomcat"|awk 'NR==1{print $1}'|sed -e "s|tomcat||"`
if [ -d "$running_home" ];
then
    tail -f "$running_home"logs/xetusone.log > "${TARGET}"
fi
