#!/bin/bash

if [ -z $2 ]; then
	echo "Usage : $0 <kvm-name> <dst-server> [--add|--force]"
	echo -e "\tMigrates the KVM from the current system to the dst-server LIVE (w.o shutdown)"
	echo -e "\tIf [add] is given, the dst-servers initiator will be added on the dst server"
	exit 1	
fi

NAME=$1
DST=$2
ADD=$3
TIMEOUT=900
if [ "$ADD" == "--force" ]; then
	FORCE="--unsafe"
fi

if [ -z "$FORCE" ]; then
	echo "Migrating $NAME to $DST. Please make sure the KVM is running! Press return to continue."
	read Y
fi

if [ ! "`virsh list |grep runn|grep $NAME`" ]; then
	echo "KVM $NAME not running."
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

for i in `virsh dumpxml $NAME |grep source.dev|grep mapper| sed -e "s/.*dev.mapper.eql-//" -e "s/.\/>//" -e "s/^.\{36\}//"`; do
		DEVLIST="$DEVLIST $i"
done

if [ "$ADD" == "--add" ]; then
	echo "Step 1.) Adding & Attaching : $DEVLIST on $DST"
	ssh $DST "/root/bin/add+attach2.sh $DEVLIST"
else 
	for i in `echo $DEVLIST`; do
		echo "Step 1.) Attaching : $i on $DST"
		ATTACH=`ssh $DST "/root/bin/attachISCSI2.sh $i"`
                if [ -z "`echo $ATTACH|grep $i`" ]; then
			echo "####################################### WARNING ##################################################"
                        echo "Could not attach the iscsi volume! Trying to add the initiator on the EQL! Press <CTRL+C> to break"
			echo "####################################### WARNING ##################################################"
			ssh $DST "/root/bin/add+attach2.sh $DEVLIST"
                fi
	done
fi

GREPLIST=`echo $DEVLIST | sed "s/ /.-\|/g" | sed -r "s/$/.-/g"`
DESTPARTITIONS=`ssh $DST "ls -la /dev/mapper/" | grep -E "($GREPLIST)" | wc -l`
SRCPARTITIONS=`echo $DEVLIST | wc -w`

if [ "$DESTPARTITIONS" -lt "$SRCPARTITIONS" ]; then
	echo "ERROR : Only $DESTPARTITIONS partitions found on target host. Expected at least $SRCPARTITIONS"
	exit 1
fi
if [ "$DESTPARTITIONS" -ne "$SRCPARTITIONS" ]; then
	echo "WARNING : Destination Server has more partitions ($DESTPARTITIONS) than expected ($SRCPARTITIONS)."
	echo "Press <RETURN> to continue or <CTRL+C> to stop!"
	read Y
fi

echo "Step 2a.) Trying to clear the clients memory cache (linux only, timeout 5sec)"
ssh -A -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no $NAME "echo 3 > /proc/sys/vm/drop_caches;free -m | grep cache:"
echo "Step 2b.) Running the migration with timeout $TIMEOUT"
virsh migrate $FORCE --timeout $TIMEOUT --verbose --persistent --live $NAME qemu+ssh://$DST/system

if [ $? -ne 0 ]; then
	echo "Migration failed!"
	exit 1
fi

echo "Step 3.) Locally detaching iSCSI volumes... "
for i in "`echo $DEVLIST`"; do
	/root/bin/detachISCSI2.sh $i
done

echo -n "Step 4.) Local "
virsh autostart $NAME --disable
echo -e "To remove the KVM locallly, please run\nvirsh undefine $NAME"

