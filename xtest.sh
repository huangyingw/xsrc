#!/bin/bash
if [ -z "$1" ];
then
  echo "Please provide commit message"
  exit 1
fi
  sudo /opt/systems/bin/xetus-tomcat stop \
  ; sudo xetus/rebuild.bash -sv \
  && sudo /opt/systems/bin/xetus-tomcat start \
  && ant -f /opt/xetusbase/xetus/test/build.xml reload-db \
  && sudo chmod -R 777 tmp/ logs/ \
  && ant -f /opt/xetusbase/xetus/test/build.xml \
  && ~/gitrc/g.sh "$1"
