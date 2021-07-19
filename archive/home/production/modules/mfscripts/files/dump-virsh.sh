#!/bin/sh

if [ ! -e "/usr/bin/virsh" ]; then
	echo "virsh not found. exit."
	exit 1
fi

OUTFILE="/etc/bsse/virtual-clients"

ps ax | grep -v grep | grep dump-virsh.sh 
RUNNING=`ps ax | grep -v grep | grep dump-virsh.sh | wc -l`

if [ "$RUNNING" == "1" ]; then
	VIRSHDUMP=`ps ax|grep -v grep | grep virsh|grep list | wc -l`
	if [ "$RUNNING" == "0" ]; then
		rm -rf $OUTFILE
		virsh list --all | grep -v "Id.Name" | grep -v "^---" >$OUTFILE
	else
		echo "Another virsh list is running. not doing anything."
		exit 1
	fi
fi
