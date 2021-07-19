#!/bin/sh
#
# WIKI START Script group iSCSI::createISCSI.sh
## OS :: Redhat 5;RedHat 6;#Ubuntu;#Debian;#Solaris; #MacOS X
######################################
#
# h3. Deployment
#
# * This file is deployed via puppet into */root/bin* 
#
# h3. Function
#
# This complex script creates a new iSCSI volume, its steps are :
#
# * create an iSCSI target (asking for the EQL password interactively)
# * acquire the target device name
# * restrict access to this target to the server its created on
#
# See what happens below for detailed info
#
# h3. Runs on
#
# * any iSCSI enabled initiatior host
#
# h3. Prerequisites
#
# * iSCSI initiator tools installed and configured
# * iSCSI target allows access for the initiator
# * access to the EQL tools in /usr/local/itsc/equallogic
# * equallogic-host-tools installed
# * ehcmd running (part of EQL host tools / HIT)
#
# h3. Parameters
#
#
# * *Usage $0 <target-name> <size in GB>*
#
# * <name>    - the name of the iscsi target
# * <img size> - the size of the system image in GB
#
# h3. What happens
#
# * check for aboves requirements (iSCSI) or bail out
# * create an iSCSI target on bs-eqgrp01.ethz.ch after the password was given (interactively)
#   this is done using the template in /usr/local/itsc/equallogic/etc/createvol.cmd 
# * restrict access to this target to the server its created on
# * set the target to mode autologin
# * wait for the device to show up in /dev/mapper and print it out
#
###########
# WIKI STOP

EQSVRMGM="bs-eqgrp03-m.ethz.ch"
EQSVR="bs-eqgrp03.ethz.ch"
DESTDIR="/local0/kvm"
INITIATOR=`cat /etc/iscsi/initiatorname.iscsi | sed "s/.*=//"`

if [ -z "$2" ]; then
	echo -e "Usage $0 <name> <sysimg size in GB>"
	echo -e "\tWill create iscsi target named <name> with size <size>"
	exit 1
fi

function main {

echo Preflight check ...

if [ -z "`echo $2 | egrep -v \"[a-z|A-Z]\"`" ]; then
       echo "Disk ($2) size must be integer in GB, dont put size characters such as M,G"
       exit 1
fi

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

echo "Will create a new iscsi target. Press <RETURN> to continue or <CTRL+C> to exit"
echo "ISCSI access will be restriced to : $INITIATOR"
read y

SZ=$(($2*1024))

TEMPFILE=`mktemp`

echo -n "Please enter passwd for EQL login : "
cat  /usr/local/itsc/equallogic/etc/createvol.cmd |sed -e "s/BSSE_NAME/$1/g" -e "s/BSSE_SIZE/$SZ/" -e "s/BSSE_DESC/$1 system disk/" -e "s/BSSE_INITIATOR/$INITIATOR/" >$TEMPFILE
EQOUT=`/usr/local/itsc/equallogic/bin/EqlCli.py -g $EQSVRMGM -a grpadmin -f $TEMPFILE`
rm $TEMPFILE

ERROR=`echo $EQOUT | grep  Error`
if [ ! -z "$ERROR" ]; then
	echo FATAL : An error occured on target creation.
	echo -e "$ERROR"
	rm -rf $1
	exit 1
fi

ITARGET=`echo $EQOUT | grep target.name.is.|sed -e "s/.*target.name.is.//" -e "s/$1.*/$1/" -e "s/ //"`

echo -e "\nISCI Target is : $ITARGET"
echo Discovering iSCSI Target from EQL...

ISCSIDISCOVERY=`iscsiadm -m discovery -t st -p $EQSVR | grep $ITARGET|head -1`
#iscsiadm -m discovery -t st -p $EQSVR | grep $ITARGET
PORTAL=`echo $ISCSIDISCOVERY| awk '{print $1}'`
DEVID=`echo $ISCSIDISCOVERY | awk '{print $2}'| awk -F: '{print $2}'`
if [ -z "$PORTAL" ] || [ -z "$DEVID" ]; then
	echo "FATAL : Discovery failed."
	exit 1
fi
echo Binding $ITARGET from $PORTAL

iscsiadm -m node -p $PORTAL -T $ITARGET -l

echo "Waiting for device to show up in /dev/mapper ... ($DEVID)"
for i in `seq 1 20`; do
	sleep 1
	echo -n .
	DEV=`ls /dev/mapper | grep $DEVID`
	if [ ! -z "$DEV" ]; then
		DEVOK=1
		break
	fi
done
if [ -z $DEVOK ]; then
	echo WARNING : Failed to detect iscsi device in /dev/mapper, assuming standard naming
	DEV="eql-$DEVID"
fi

echo DEV : /dev/mapper/$DEV

echo "Setting automatic iSCSI login for target : $ITARGET"
iscsiadm -m node -T $ITARGET -o update -n node.startup -v automatic

echo "Setting readahead to 65535k ..."
blockdev --setra 65535 /dev/mapper/$DEV

}

main $1 $2
