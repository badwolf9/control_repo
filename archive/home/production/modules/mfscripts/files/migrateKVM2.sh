#!/bin/bash

if [ -z $2 ]; then
	echo "Usage : $0 <kvm-name> <dst-server> [add]"
	echo -e "\tMigrates the KVM from the current system to the dst-server"
	echo -e "\tIf [add] is given, the dst-servers initiator will be added on the dst server"
	exit 1	
fi

NAME=$1
DST=$2
ADD=$3

echo "Migrating $NAME to $DST. Please make sure the KVM is stopped! Press return to continue."
read Y

if [ ! -z "`virsh list |grep runn|grep $NAME`" ]; then
	echo "KVM $NAME still running."
	exit 1
fi
if [ -z "`virsh list --all |grep $NAME`" ]; then
	echo "KVM $NAME not defined!"
	exit 1
fi

if [ ! -z "`ssh $DST \"virsh list | grep runn | grep $NAME\"`" ]; then
	echo "KVM already running on $DST !!!"
	exit 1
fi

virsh dumpxml $NAME | ssh $DST "cat >/local0/kvm/etc/$NAME.xml"

for i in `virsh dumpxml $NAME |grep source.dev|grep mapper| sed -e "s/.*dev.mapper.eql-//" -e "s/.\/>//" -e "s/^.\{36\}//"`; do
		DEVLIST="$DEVLIST $i"
done

if [ "$ADD" == "add" ]; then
	echo "Adding & Attaching : $DEVLIST"
	ssh $DST "/root/bin/add+attach2.sh $DEVLIST"
else 
	for i in `echo $DEVLIST`; do
		echo "Attaching : $i"
		ATTACH=`ssh $DST "/root/bin/attachISCSI2.sh $i"`
                if [ -z "`echo $ATTACH|grep $i`" ]; then
                        echo "Could not attach the iscsi volume! Is the initiator allowed to bind the target?"
                        exit 1
                fi
	done
fi

ssh $DST "virsh define /local0/kvm/etc/$NAME.xml"
ssh $DST "virsh start $NAME"

echo "Locally detaching iSCSI volumes... "
for i in `echo $DEVLIST`; do
	/root/bin/detachISCSI2.sh $i
done
