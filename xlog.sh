#!/bin/bash
TARGET=find.cc
if [ -n "$1" ]
then
    TARGET="$1"
fi
echo now, begin to log
running_home=`ps ax|grep -o "\ /[U]sers.*/tomcat"|sed -e "s|tomcat||"`
if [ -d $running_home ];
then
    eval tail -f "$running_home"logs/xetusone.log > "${TARGET}"
fi
