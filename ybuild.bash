#!/bin/bash

# Developer Rebuild Script for Linux/Unix development systems
#
# Author: Terence Kent

# Prototype:	isAbsolutePath "PATHSTRING"
#	Will return a true or false if the leading character is a '/'
isAbsolutePath(){
	if (( $# != 1 ))
	then
		return 1
	fi
	firstChar=`echo "$1" | awk '{split($0, pathStr, ""); printf("%s", pathStr[1]);}'`
	if [ "$firstChar" == "/" ]
	then
		return 0
	fi
	return 1
}

# Prototype:	getAbsolutePath "$PATHNAME"
# 	Will take any path (realtive or not), and return a full path
#	name. Will not work on non-existing paths.
getAbsolutePath() {
	if (( $# != 1 ))
	then
		RET_VAL=""
		return 1
	fi
	
	isAbsolutePath "$1"
	if (( $? == 0 ))
	then
		RET_VAL="$1"
	else
		if [ -d "$1" ]
		then
			trg_path="${PWD}/$1"
			RET_VAL=`bash -c "cd \"$trg_path\"; pwd"`
		else
			trg_path="${PWD}/`dirname "$1"`"
			RET_VAL=`bash -c "cd \"$trg_path\"; pwd"`/"${1##*/}"
		fi
	fi
}

getExecPath(){
	sPath=`dirname "$0"`
	getAbsolutePath "$sPath"
}

# Very basic check for wether or not the system is a linux system
isUbuntuLinux(){
	if [ ! -e /etc/issue ]
	then
		return 1
	fi
	
	return 0
}

isXetusTomcatRunning(){
	if [ ! -e $XETUS_TCAT_INIT ]
	then
		return 1
	fi
	
	$XETUS_TCAT_INIT status  > /dev/null
	
	if (( $? == 0 ))
	then
		return 0
	fi
	
	return 1
}

# Prototype:	resetDirectoryPerms
#
resetDirectoryPerms(){
	# Define the reset directories, relative to the BRANCH_XETUS_DIR
	i=0;
	DIRS_TO_RESET[((i++))]="/webapps/data/WEB-INF"
	DIRS_TO_RESET[((i++))]="/webapps/page/WEB-INF"
	DIRS_TO_RESET[((i++))]="/webapps/page/pages"
	DIRS_TO_RESET[((i++))]="/../logs"
	DIRS_TO_RESET[((i++))]="/../tmp"
	
	for ((i = 0; i < ${#DIRS_TO_RESET[@]}; i++))
	do
		TRGT_DIR="${BRANCH_XETUS_PATH}/${DIRS_TO_RESET[$i]}"
		mkdir -p ${TRGT_DIR}
		chown -R ${REAL_UID} ${TRGT_DIR}
	done
}

# reload the database
reloadBranchDB(){
	cd ${BRANCH_XETUS_PATH}/sql
	ant "reload-development-db"
	
	if (( $? != 0 ))
	then
		echo "An error occured reloading the database"
	fi
	
}

# Move the symlink for xetusbase over and update the tomcat conf's db name
swapBranch(){
	# find the current branch name
	cd /opt/xetusbase
	CURRENT_BRANCH_PATH=`pwd -P`
	CURRENT_BRANCH_NAME=`basename ${CURRENT_BRANCH_PATH}`

	# move the symlink
	rm /opt/xetusbase
	cd "$BRANCH_XETUS_PATH"
	cd ..
	BRANCH_BASE_PATH=`pwd`
	ln -s "$BRANCH_BASE_PATH" /opt/xetusbase
	
	# find the new branch name
	cd /opt/xetusbase
	NEW_BRANCH_PATH=`pwd -P`
	NEW_BRANCH_NAME=`basename ${NEW_BRANCH_PATH}`
}

printUsage(){
	echo "Usage: ${0##*/} [-v|-h]"
	echo ""
}

trap 'echo "Canceling is not supported at this time, you just have to wait..."' INT

# main()

#Default values
INITIAL_BRANCH_SETUP=false
SWAP_BRANCH=false
RESTART_TOMCAT=false
VERBOSE=false
BUILD_STD_OUT=/dev/null
BUILD_STD_ERR=/dev/null
XETUS_TCAT_INIT=/opt/xetusbase/3rdparty/tomcat/bin/xetus-tomcat
MYSQL_USER="root"
MYSQL_PASSWORD="bl0ss0m"

#make sure the script was launched with SUDO
if [ -z $SUDO_USER ]
then
	echo "${0##*/} must be ran using sudo"
	echo ""
	echo "example:"
	printf "	%s\n" "sudo ${0##*/}"
	exit 1
fi

# Capture the real user info
REAL_UID=$SUDO_UID
REAL_USER=$SUDO_USER


# configure the rebuild here
while getopts hRisv option
do
	case "$option" in
		v)	VERBOSE=true
			;;
		i)	INITIAL_BRANCH_SETUP=true
			SWAP_BRANCH=true
			;;
		s)	SWAP_BRANCH=true
			;;	
		*)	printUsage;
			exit 1
			;;
	esac

done

# Capture wether or not tomcat was running when we started
isXetusTomcatRunning
if (( $? == 0 ))
then
	RESTART_TOMCAT=true
	$XETUS_TCAT_INIT stop
fi

# Get the base path for our script
getExecPath
BRANCH_XETUS_PATH="$RET_VAL"

if [ $VERBOSE == "true" ]
then
	BUILD_STD_OUT=/dev/stdout
	BUILD_STD_ERR=/dev/stderr
fi

echo "Cleaning out previous build..."
# do the clean
cd ${BRANCH_XETUS_PATH}
ant clean > $BUILD_STD_OUT 2> $BUILD_STD_ERR

echo "Reseting Permissions..."
# reset the various directory permissions
resetDirectoryPerms

if [ ! -e ${BRANCH_XETUS_PATH}/../tomcat ]
then
	# install tomcat if it's missing
	ant install
fi


# The rebuild is tricky, because you have to preserve the classpath
# so check if the classpath is set in the .profile (it should be)
# if not, then it must be in the bashrc (bummer), and we'll have to
# use a much more fancy (read error-prone) su command

su - ${REAL_USER} -l -c "cat .profile" | grep "CLASSPATH" > /dev/null 2> /dev/null

if (( $? == 0 ))
then	echo "Building..."
	# the classpath is set in the .profile, do a regular su command
	su - ${REAL_USER} -l -c "cd ${BRANCH_XETUS_PATH}; ant" \
		> $BUILD_STD_OUT \
		2> $BUILD_STD_ERR
else
	echo "(We've detected your CLASSPATH variable is not set in your .profile, you should really change this)"
	echo "Building..."
	# the classpath is set in the .bashrc file, do the more complicated command
	su - ${REAL_USER} -l -c \
		"bash -l -i -c 'cd ${BRANCH_XETUS_PATH}; ant'" \
		> $BUILD_STD_OUT \
		2> $BUILD_STD_ERR
fi

if (( $? != 0  ))
then
	if [ $RESTART_TOMCAT == "true" ]
	then
		echo "Build failed, not restarting tomcat"
		exit 1
	fi
	
	echo "Build Failed, rebuild with -v to see why"
	exit 1
fi


if [ $RESTART_TOMCAT == "true" ]
then
	$XETUS_TCAT_INIT start
fi

echo "Rebuild Complete"

exit 0;
