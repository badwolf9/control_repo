#!/bin/bash
# ===============================================================================#
#
#           Create fixed network config
#
# ===============================================================================#
# #
#NETCFGDIR=/etc/sysconfig/network-scripts
# For Ubuntu 14 and 16
NETCFGDIR="/etc/network"

#
#           IF is the device name in the final system (might differ from
#       install time)
# #
# What if there is no network interface up?
# get it from /sys
# make sure networking is up
# what happens if we are not on eth0?
# check for first interface IFACE :
IFACE=`ls -l /sys/class/net|grep -m 1 pci|grep -o '[^/]*$'`
echo "Testing the network config" > /root/netsetuplog.txt
echo "The network interface is $IFACE" >> /root/netsetuplog.txt

# now bring it up and liven things up.....
/sbin/ip link set $IFACE up
/sbin/dhclient $IFACE
echo "We are in the Ubuntu 18.04 LTS Bionic post install script, is the networking up?" >> /root/netsetuplog.txt
/sbin/ip addr list >> /root/netsetuplog.txt
# if the networking failed the rest of the script will too. so there.

#IF=/sbin/ifconfig|grep Ethernet|cut -d " " -f 1
IF=$IFACE
echo "The new variable for interface is (IF)  $IF" >> /root/netsetuplog.txt

# test if interface exists (yes or no)
    rc=`/usr/bin/ifdata -pe $IF`
    if [ $rc == yes ]; 
    then 
    echo "Found $IF with ifdata" >> /root/netsetuplog.txt
	MAC=$(ifdata -ph $IF) 
	IP=$(ifdata -pa $IF) 
	NET=$(ifdata -pN $IF) 
	SM=$(ifdata -pn $IF)
	BC=$(ifdata -pb $IF)
    else 
    echo "Did not find $IF with ifdata" >> /root/netsetuplog.txt
	MAC=`ifconfig $IF |grep ether|awk '{print $2}'`
	DHLEASE="/var/lib/dhcp/dhclient.${IF}.leases"
    
	if [ -f $DHLEASE ]; 
	then 
	echo "There is a dhcp lease file $DHLEASE" >> /root/netsetuplog.txt
	IP=`facter ipaddress_$IF` 
	BC=`ip -4 a s $IF|grep brd|awk '{print $4}'` 
	SM=`cat	/var/lib/dhcp/dhclient*.leases | sort -u|grep subnet-mask|awk '{print $3}'|sed "s/;//"` 
	else 
	echo "No DHCP lease file found" >> /root/netsetuplog.txt
	IP=ip -4 a s $IF|grep inet|awk '{print $2}'|sed "s/\/.*//" 
	BC=`ifconfig $IF | grep -v 127.0.0.1 | grep inet.addr |tail -1|awk '{print $3}'|sed "s/^.*://g"` 
	SM=`ifconfig $IF | grep -v 127.0.0.1 | grep inet.addr |tail -1|awk '{print 4}'|sed "s/^.*://g"` 
	fi

	NETGREP=`echo $IP|sed "s/\..*$//"` 
	NET=`netstat -rn| awk '{print $1" "$2}'| grep $NETGREP|awk '($2=="0.0.0.0") {print  $1}'` 
    fi

	GW=`netstat -rn | grep -m 1 "^0.0.0.0"|awk '{print $2}'`

        echo "Assuming MAC : $MAC"  >> /root/netsetuplog.txt
        echo "Assuming IP  : $IP/$SM (Broadcast : $BC)"  >> /root/netsetuplog.txt
        echo "Assuming NET : $NET"  >> /root/netsetuplog.txt
        echo "Assuming GW  : $GW"  >> /root/netsetuplog.txt
        echo "Assuming IF  : $IF" >> /root/netsetuplog.txt

mkdir -p $NETCFGDIR/bak

# need to test if there is already an entry for eth0
grep -m 1 eth0 $NETCFGDIR/interfaces 
if [ $? -eq 0 ]
then
echo "entry for eth0 already exists!"
echo "entry for eth0 already exists!" >> /root/netsetuplog.txt
exit 0
fi

## =======================
# change after testing
#grep -v dns $NETCFGDIR/interfaces  > /root/interfaces 
# temporary for testing
#NETCFGDIR="/root"
test -f $NETCFGDIR/interfaces && mv $NETCFGDIR/interfaces  $NETCFGDIR/bak/interfaces.AUTOBAK-BSSE
## =======================

grep -v dns $NETCFGDIR/bak/interfaces.AUTOBAK-BSSE  > $NETCFGDIR/interfaces 

# append new text to interfaces file

    echo "Generating interfaces file with interfaces lo and $IF" >> /root/netsetuplog.txt
    echo "auto eth0" >>$NETCFGDIR/interfaces 
    echo "iface eth0 inet static" >>$NETCFGDIR/interfaces 
    echo "address $IP" >>$NETCFGDIR/interfaces 
    echo "netmask $SM" >>$NETCFGDIR/interfaces 
    echo "broadcast $BC" >>$NETCFGDIR/interfaces 
    echo "gateway ${GW} "  >>$NETCFGDIR/interfaces 
    echo "network $NET" >>$NETCFGDIR/interfaces
    echo "dns-search ethz.ch d.ethz.ch" >>$NETCFGDIR/interfaces 
    echo "dns-nameservers 129.132.98.12 129.132.250.2"  >>$NETCFGDIR/interfaces 

cp $NETCFGDIR/interfaces $NETCFGDIR/interfaces.bak

echo "Finished changing network interfaces file on $HOSTNAME"
echo "======================================================"

