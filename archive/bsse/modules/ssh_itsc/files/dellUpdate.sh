#!/bin/bash
wget -q -O - http://linux.dell.com/repo/hardware/latest/bootstrap.cgi | bash
yum install srvadmin* -y
yum install dell_ft_install -y
yum install $(bootstrap_firmware) -y
/usr/sbin/update_firmware --yes

