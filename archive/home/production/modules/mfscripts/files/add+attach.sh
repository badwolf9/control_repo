#!/bin/sh

if [ ! -f /root/bin/addISCIInitiator.sh ]; then
	echo This little helper script requires /root/bin/addISCIInitiator.sh
	exit 1
fi
if [ ! -f /root/bin/attachISCSI.sh ]; then
	echo This little helper script requires /root/bin/attachISCSI.sh
	exit 1
fi

/root/bin/addISCIInitiator.sh $*
if [ $? == 0 ]; then
	/root/bin/attachISCSI.sh $*
fi
