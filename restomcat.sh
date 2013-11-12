#!/bin/bash
running_home=`ps ax|grep -o "\ /[U]sers.*/tomcat"|sed -e "s|tomcat||"`
echo "$running_home"
if [ -d $running_home ];
then
    echo restart previous
    eval "$running_home"tomcat/bin/xetusone.bash stop
fi
tomcat/bin/xetusone.bash start
