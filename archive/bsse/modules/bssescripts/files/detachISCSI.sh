#
#
# WIKI START Script group iSCSI::detachISCSI.sh
## OS :: Redhat 5;RedHat 6;#Ubuntu;#Debian;#Solaris; #MacOS X
######################################
#
# h3. Deployment
#
# * This file is deployed via puppet into */root/bin*
#
# h3. Function
#
# * test if the given target is used (mounted, used in a running KVM)
# * detaches an iSCSI target to the host its run on
#
# h3. Runs on
#
# * any iSCSI enabled initiatior host
# * used mainly for KVM server
#
# h3. Prerequisites
#
# * iSCSI initiator tools installed and configured
# * libvirt installed
#
# h3. Parameters
#
# * <target> - a wildcard which will automatically looked up on the locally bound targets
# * [-q] for quiet      
#
# h3. What happens
#
# * check if the target is used (mounted or used in a running KVM), if so bail out
# * log out of the iSCSI target
# * set the target to mode manual
#
###########
# WIKI STOP

if [ $# -lt 1 ]; then
        echo "Usage : $0 [-q] <target>"
	echo -e "Where : -q for quiet mode"
	echo -e "Please note that target can be an alias or an snapshot as well"
        exit
fi

CMD="-u"
TIMEOUT=20
TARGET=$1
if [ $TARGET == "-q" ]; then
	TARGET=$2
	QUIET=1
fi
TARGETBAK=$TARGET
EQSVRMGM="bs-eqgrp01-m.ethz.ch"
EQSVR="bs-eqgrp01.ethz.ch"
INITIATOR=`cat /etc/iscsi/initiatorname.iscsi | sed "s/.*=//"`

ISCSIDISCOVERYCOUNT=`iscsiadm -m session | grep $TARGET | awk '{print $4}' | uniq | wc -l`
TARGET=`iscsiadm -m session | grep $TARGET | awk '{print $4}' | uniq `

if [ -z "$TARGET" ]; then
	TARGET=$TARGETBAK
fi

if [ "$ISCSIDISCOVERYCOUNT" == "1" ]; then
	if [ -z "$QUIET" ]; then
		echo Found $ISCSIDISCOVERYCOUNT target : $TARGET.
	fi
else
	echo "Found $ISCSIDISCOVERYCOUNT targets (Need to have exactly 1). Please refine your target definition."
	echo -e "\tTargets found :"
	iscsiadm -m session | grep $TARGET | awk '{print $4}' | uniq | sed "s/^/\t/"
	exit 1
fi

DEVID=`echo $TARGET | sed "s/.*equallogic://"`

if [ -e "/dev/mapper/eql-$DEVID" ]; then
        DEVICE=/dev/mapper/eql-$DEVID
        echo -n "Testing if filesystem is mounted"
        if [ ! -z `df -h | grep $DEVICE` ]; then
                echo " : ERROR, locally mounted! STOP."
                exit 1
        fi
        echo -en " : OK\nTesting if filesystem is used in a KVM"
        TEST_VMS=`for i in \`virsh list | grep running | awk '{print $2}'\`; do virsh dumpxml $i | grep $DEVID ;done`
        if [ ! -z "$TEST_VMS" ]; then
                echo " : ERROR, mounted in a running VM $VM! STOP."
                exit 1
        fi
        echo " : OK"
else
        echo "Did not find iscsi device in /dev/mapper/$DEVID. STOP"
        exit 1
fi

echo DEV : $DEVICE

echo "Removing iSCSI target from host."
iscsiadm -m node -T $TARGET -u

echo "Unsetting automatic iSCSI login for target : $TARGET"
iscsiadm -m node -T $TARGET -o update -n node.startup -v manual

