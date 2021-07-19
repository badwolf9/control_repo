#!/bin/sh
#
# WIKI START Script group iSCSI::addISCIInitiator.sh
## OS :: Redhat 5;RedHat 6;#Ubuntu;#Debian;#Solaris; #MacOS X
######################################
#
# h3. Deployment
#
# * This file is deployed via puppet into */etc/bsse/bin* 
#
# h3. Function
#
# This script adds a given iscsi initiator name to a given volume
#
# h3. Runs on
#
# * any iSCSI enabled initiatior host
#
# h3. Prerequisites
#
# * iSCSI initiator tools installed and configured
# * access to the EQL tools in /usr/local/itsc/equallogic
# * equallogic-host-tools installed
# * ehcmd running (part of EQL host tools / HIT)
#
# h3. Parameters
#
# * *Usage $0 [-u user] [-i inititator] <volume1> <volumeN>
#
# * <volume>    	- the name of the iscsi target
# * [-u user]   	- the AD user to connect to the EQL (default : grpadmin)
# * [-i initiator]   	- the initiator to use, if no initiatorname is given, the local iniators name is used
#
# h3. What happens
#
# * check for aboves requirements (iSCSI) or bail out
# * take the script from /usr/local/itsc/equallogic/etc/enableINIT.cmd and hand it to the eqltools
#
###########
# WIKI STOP

EQSVRMGM="bs-eqgrp01-m.ethz.ch"
EQUSER="grpadmin"
EQPASS="grpadmin"
EQLLOG="/var/log/eql.log"
DESTDIR="/local0/kvm"
TMPDIR=/var/run
TEMPFILE=`mktemp`
TMPDIR=/tmp
INITIATOR=`cat /etc/iscsi/initiatorname.iscsi | sed "s/.*=//"`	

if [ -z "$1" ]; then
	echo "Usage $0 [-u user] [-i inititator] <volume1> <volumeN>"
	echo -e "\t<volume>    	  - the name of the iscsi target"
	echo -e "\t[-u user]   	  - the user to connect to the EQL (default : grpadmin)"
	echo -e "\t[-p password]  - the user's password"
	echo -e "\t[-i initiator] - the initiator to use, if no initiatorname is given, the local iniators name is used"
	exit 1
fi

echo Preflight check ...

echo -n "Testing itsc / EqlCli script availability : "
if [ ! -e /usr/local/itsc/equallogic/bin/EqlCli.py ]; then
	if [ ! -e /usr/local/itsc ]; then
		echo "FATAL : /usr/local/itsc not autofs mounted. (maybe restart autofs?)"
		exit 1
	else
		echo "FATAL : EqlCli can not be read. Permission problem in /usr/local/itsc/equallogic/bin/EqlCli.py ??"
		exit 1
	fi
fi
echo "ok."
echo -n "Testing for equallogic tools : "
if [ -z "`rpm -qa equallogic-host-tools`" ]; then
	echo "FATAL : Package equallogic-host-tools not installed"
	exit 1
else
	if [ -z "`ps ax|grep ehcmd`" ]; then
		echo "FATAL : ehcmd not running. Please install equallogic-host-tools"
		exit 1
	fi
fi
echo "ok."

args=("$@")

if ([ "${args[0]}" == "-u" ] || [ "${args[0]}" == "-i" ]); then
        unset args[0]
        unset args[1]
	if [ $1 == "-u" ]; then
		EQUSER=$2
	fi
	if [ $1 == "-i" ]; then
		INITIATOR=$2
	fi
fi
if ([ "${args[2]}" == "-u" ] || [ "${args[2]}" == "-i" ]); then
        unset args[2]
        unset args[3]
	if [ $3 == "-u" ]; then
		EQUSER=$4
	fi
	if [ $3 == "-i" ]; then
		INITIATOR=$4
	fi
fi

TARGETS=(${args[@]})

TARGETS=(${args[@]})
TSIZE=${#args[@]}

rm $TEMPFILE

for i in `seq 0 $((TSIZE-1))`; do
	VOL=${TARGETS[$i]}
	cat  /usr/local/itsc/equallogic/etc/enableINIT.cmd |sed -e "s/BSSE_VOL/$VOL/g" -e "s/BSSE_INITIATOR/$INITIATOR/g" >>$TEMPFILE
done
echo "logout" >>$TEMPFILE

echo "Adding initiator $INITIATOR to $TSIZE targets with user $EQUSER"

#echo -n "Please your passwd for $EQUSER -> "
EQOUT=`/usr/local/itsc/equallogic/bin/EqlCli.py -g $EQSVRMGM -a $EQUSER -p $EQPASS -f $TEMPFILE`
rm $TEMPFILE

ERROR=`echo $EQOUT | grep  Error`
if [ ! -z "$ERROR" ]; then
	echo FATAL : An error occured on target modification.
	echo -e "$ERROR"
	rm -rf $TEMPFILE
	exit 1
else
	date >>$EQLLOG
	echo "$EQOUT" >>$EQLLOG
fi

