#!/bin/bash
running_home=`ps ax|grep -o "\ /[U]sers.*/tomcat"|sed -e "s|\/tomcat||"`
if [ -d $running_home ];
then
    "$running_home"tomcat/bin/xetusone.bash stop \
        ; cp -fv "$running_home".gitignore ./ \
        ; ln -s /opt/sql sql \
        ; ant -f xetus/build.xml setup \
        && tomcat/bin/xetusone.bash start \
        && git init && git add . && git ci -am "n" && git gc
fi
