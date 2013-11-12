#!/bin/bash
kill -9 `ps ax|grep "\ /[U]sers.*/tomcat"|awk '{print $1}'`
tomcat/bin/xetusone.bash start
