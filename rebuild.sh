#!/bin/bash
sudo /opt/systems/bin/xetus-tomcat stop \
  && sudo xetus/rebuild.bash -sv \
  && sudo /opt/systems/bin/xetus-tomcat start
