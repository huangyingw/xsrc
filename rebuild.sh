#!/bin/bash
sudo /opt/systems/bin/xetus-tomcat stop \
  && sudo xetus/rebuild.bash -sv \
  && sudo /opt/systems/bin/xetus-tomcat start \
  && echo now begin to tail log to find.cc, when you finish, press ctrl-c \
  && tail -f logs/tomcat/xetus-tomcat.log > find.cc
