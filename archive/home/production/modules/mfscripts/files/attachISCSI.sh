#
# WIKI START Script group iSCSI::attachISCSI.sh
## OS :: Redhat 5;RedHat 6;#Ubuntu;#Debian;#Solaris; #MacOS X
######################################
#
# h3. Deployment
#
# * This file is deployed via puppet into */root/bin*
#
# h3. Function
#
# * attaches an iSCSI target to the host its run on
# * sets target to autologin the have it reestablished after reboot
#
# h3. Runs on
#
# * any iSCSI enabled initiatior host
# * used mainly for KVM server
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
# * <target> - a wildcard which will automatically looked up on the available targets
# * [-q] for quiet	
#
# h3. What happens
#
# * check for aboves requirements or bail out
# * discover available iscsi targets on *bs-eqgrp01.ethz.ch*
# * if exactly one target fits the <target> parameter, log into the target, otherwise bail out
# * set the target to mode autologin
# * wait for the device to show up in /dev/mapper and dump it
#
###########
# WIKI STOP

if [ $# -lt 1 ]; then
        echo "Usage : $0 [-q] <target> [-u]"
	echo "-q for quiet mode"
	#echo "-u to logout"
	echo "Please note that target can be an alias as well"
        exit
fi

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
	SKIP_PREFLIGHT=1
	QUIET=1
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
	SKIP_PREFLIGHT=1
	QUIET=1
fi

TARGETS=(${args[@]})
TARGETS=(${args[@]})
TSIZE=${#args[@]}



CMD="-l"
TIMEOUT=20
TARGET=$1
if [ $TARGET == "-q" ]; then
	TARGET=$2
	QUIET=1
fi
EQSVRMGM="bs-eqgrp01-m.ethz.ch"
EQSVR="bs-eqgrp01.ethz.ch"

for i in `seq 0 $((TSIZE-1))`; do
        TARGET=${TARGETS[$i]}

	ISCSIDISCOVERYCOUNT=`iscsiadm -m discovery -t st -p $EQSVR | grep $TARGET | uniq | wc -l`

	if [ $ISCSIDISCOVERYCOUNT == "1" ]; then
		if [ -z "$QUIET" ]; then
			echo Found $ISCSIDISCOVERYCOUNT target : $ISCSIDISCOVERY.
		fi
	else
		echo "Found $ISCSIDISCOVERYCOUNT targets (Need to have exactly 1). Please refine your target definition."
		exit 1
	fi

	ISCSIDISCOVERY=`iscsiadm -m discovery -t st -p $EQSVR | grep $TARGET | uniq`
	PORTAL=`echo $ISCSIDISCOVERY| awk '{print $1}'`
	TARGET=`echo $ISCSIDISCOVERY | awk '{print $2}'`
	DEVID=`echo $TARGET | awk -F: '{print $2}'`

	iscsiadm -m node -p $PORTAL -T $TARGET $CMD

	echo "Waiting for device to show up in /dev/mapper ... ($DEVID)"
	for i in `seq 1 $TIMEOUT`; do
	        sleep 1
	        echo -n .
	        DEV=`ls /dev/mapper | grep $DEVID | head -1`
	        if [ ! -z "$DEV" ]; then
	                DEVOK=1
	                break
	        fi
	done

	if [ -z $DEVOK ]; then
	       echo Failed to detect device in /dev/mapper
 	       DEV="eql-$DEVID"
	fi	

	echo DEV : /dev/mapper/$DEV

	echo "Setting automatic iSCSI login for target : $TARGET"
	iscsiadm -m node -p $PORTAL -T $TARGET -o update -n node.startup -v automatic
	
	echo "Setting readahead to 65535k ..."
	blockdev --setra 65535 /dev/mapper/$DEV
done
