#!/bin/bash
running_home=`ps ax|grep -o "\ /[U]sers.*/tomcat"|sed -e "s|tomcat||"`
if [ -d "$running_home" ];
then
    "$running_home"tomcat/bin/xetusone.bash restart
    "$running_home"tomcat/bin/xetusone.bash stop
fi
ant -f xetus/build.xml setup \
    && tomcat/bin/xetusone.bash restart
