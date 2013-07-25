#!/bin/bash
sudo /opt/systems/bin/xetus-tomcat stop \
  && cp -fv /opt/xetusbase/.gitignore ./ \
  && sudo xetus/rebuild.bash -i \
  && sudo /opt/systems/bin/xetus-tomcat start \
  && git init && git add . && git ci -am "n" && git gc
