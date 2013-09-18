#!/bin/bash
pid=`ps ax|awk '/xetusbase\/tomcat/{print $1}'`
if [ -n "$pid" ];
then
    sudo kill -9 $pid
fi
sudo xetus/rebuild.bash -sv \
    && sudo /opt/systems/bin/xetus-tomcat start
