#!/bin/sh

if [ ! -f /root/bin/addISCIInitiator2.sh ]; then
	echo This little helper script requires /root/bin/addISCIInitiator2.sh
	exit 1
fi
if [ ! -f /root/bin/attachISCSI2.sh ]; then
	echo This little helper script requires /root/bin/attachISCSI2.sh
	exit 1
fi

/root/bin/addISCIInitiator2.sh $*
if [ $? == 0 ]; then
	/root/bin/attachISCSI2.sh $*
fi
