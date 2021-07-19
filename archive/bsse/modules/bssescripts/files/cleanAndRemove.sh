#!/bin/bash
# WIKI START Script group Misc::removeAndClean.sh
## OS :: Redhat 5;RedHat 6;#Ubuntu;#Debian;#Solaris; #MacOS X
######################################
#
# h3. Deployment
#
# * This file is deployed via puppet into */root/bin*
#
# h3. Function
#
# * stops iscsid / iscsi and removes all related modules
# * stops hplip and removes it from system
# * stops and removes smartd if -s flag is given
#
# h3. Runs on
#
# * any EL5/6
#
# h3. Prerequisites
#
# h3. Parameters
#
# * [-s] to stop and remove smartd
#
# h3. What happens
#
# * test for iscsi usage and if not stop iscsi
# * try to stop and remove hplip
#
###########
# WIKI STOP

ISCSI=`iscsiadm -m session 2>&1|grep No.active.sessions`
ISCSI2=`ls -ltr /dev/mapper/ | wc -l`

if [ -z "$ISCSI" ]; then
	echo "Active ISCSI sessions found. Will not stop iscsi!!!"
else
	if [ "$ISCSI2" -gt 2 ]; then
		echo "Found devices in /dev/mapper! Will not stop iscsi!!!"
	else
		if [ ! -z "`ps ax| grep -v grep | grep iscsi`" ]; then
			echo "Stopping iscsi ..."
			service iscsid stop
			service iscsi stop
			echo "Removing iscsi modules ..."
			rmmod dm_multipath libcxgbi iscsi_boot_sysfs be2iscsi iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi libiscsi2 scsi_transport_iscsi2 scsi_transport_iscsi cxgbi 2>&1 >/dev/null
			rmmod be2iscsi iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi libiscsi2 scsi_transport_iscsi2 scsi_transport_iscsi 2>&1 >/dev/null
			rmmod be2iscsi iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi libiscsi2 scsi_transport_iscsi2 scsi_transport_iscsi 2>&1 >/dev/null
			rmmod be2iscsi iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi libiscsi2 scsi_transport_iscsi2 scsi_transport_iscsi 2>&1 >/dev/null
		fi
	fi
fi

echo "Stoping and removing hplip"
/etc/init.d/hplip stop
rpm -e hplip hpijs sane-backends sane-frontends libsane-hpaio sane-backends-libs xsane 2>&1 >/dev/null

if [ "$1" == "-s" ]; then
	echo "Stopping and removing smartd"
	service smartd stop
	rpm -e smartmontools ocsinventory-agent	  2>&1 >/dev/null
fi

if [ -f /etc/init.d/bluetooth ]; then
	/etc/init.d/bluetooth stop
	rmmod bluetooth
	yum remove -y bluez
fi

test -f /root/bin/clearLogCollector && /root/bin/clearLogCollector -u linux-misc
