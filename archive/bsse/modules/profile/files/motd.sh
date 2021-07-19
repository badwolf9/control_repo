#!/bin/bash
#
# Author: basil.neff@bsse.ethz.ch
# Date: 2014.07
#
# Prints information that the host is puppetized and some additional information:
# * Hostname, IP, Kernel, CPU, Memory
# * last puppet run
# * Who is logged in

# Only show it to root!
WHOAMI=`/usr/bin/whoami`
if [ "${WHOAMI}"=="root" ]; then
    # Get IP address
    # We look for eth0 first, in case it's running a docker container
    if [ ! -z `facter ipaddress_eth0` ];then
        IP_ADDRESS=`facter ipaddress_eth0`
    else
        IP_ADDRESS=`facter ipaddress`
    fi
    # Get Puppet information
    PUPPET_INFO_FILE='/var/run/puppetlabs/lastrun'
    PUPPET_ALTERNATIVE_FILE='/opt/puppetlabs/puppet/cache/state/state.yaml'
    if [ -f ${PUPPET_INFO_FILE} ];then
        PUPPET_LAST_RUN=`cat ${PUPPET_INFO_FILE}| grep "Last run" | awk '{ print $(NF) }'`
    else
        PUPPET_LAST_RUN=`stat -c '%Y' ${PUPPET_ALTERNATIVE_FILE}`
    fi
    DATE_NOW=`/bin/date +%s`
    YAML_FILE=`/usr/bin/locate last_run_summary.yaml|grep state|head -1`
    NUM_FAIL=`cat ${YAML_FILE}|grep failure`
    NUM_SUCC=`cat ${YAML_FILE}|grep success`
# test the os family
OSFAM=`facter osfamily`
if [  "${OSFAM}"=="Debian" ]; then
#echo "Debian"
    PUPPET_FILE_AGE=`echo "(${DATE_NOW} - ${PUPPET_LAST_RUN})/60" | bc`
else
#echo "DeadRat!"
    let PUPPET_FILE_AGE=`echo "(${DATE_NOW} - ${PUPPET_LAST_RUN})/60" | bc`
fi
    PUPPET_CONF_FILE='/etc/puppetlabs/puppet/puppet.conf'
    if [ -f ${PUPPET_CONF_FILE} ];then
        PUPPETSERVER=`cat ${PUPPET_CONF_FILE}|grep "server ="|cut -d= -f2|cut -d. -f1`
    else
        PUPPETSERVER=`cat /etc/puppet/puppet.conf|grep "server ="|cut -d= -f2|cut -d. -f1`
    fi
    WHO=`/usr/bin/w`
    PUPPET_VERSION=`puppet -V`
    # Add | in the beginning of each line
    USERS=`echo "${WHO}" | sed '1,2d' | while read line; do printf "\033[0;37m| \033[0m%s\n" "$line "; done`

echo -e "\033[1;32m01000100 00101101 01000010 01010011 01010011 01000101
\033[0;37m+---------------- \033[0mSystem Data\033[0;37m -----------------------
|  \033[0m        Host\033[1;32m: \033[0;35m`hostname` [ IP: ${IP_ADDRESS} ]
\033[0;37m|   \033[0mDescription\033[1;32m: \033[0;35m`cat /etc/description | sed -e '/^#/d' | sed -e 's/\n/\n\\\033[0;37m|\\\033[0m            \\\033[0;35m/'`
\033[0;37m|        \033[0mKernel\033[1;32m: \033[0;35m`uname -r`
\033[0;37m|           \033[0mCPU\033[1;32m: \033[0;35m`cat /proc/cpuinfo | grep processor | wc -l` x`cat /proc/cpuinfo | grep "model name" | head -n 1 | awk -F: '{ print $2 }'`
\033[0;37m|        \033[0mUptime\033[1;32m: \033[0;35m`uptime | sed 's/.*up \([^,]*\), .*/\1/'` \033[0m| Load\033[1;32m: \033[0;35m`cat /proc/loadavg | awk '{ print $1", "$2", "$3 }'`
\033[0;37m|        \033[0mMemory\033[1;32m: \033[0;35m`awk '/MemTotal/ {printf( "%.0f\n", $2 / 1024 )}' /proc/meminfo` MB (`awk '/MemFree/ {printf( "%.0f\n", $2 / 1024 )}' /proc/meminfo` MB free)\033[0m
\033[0;37m+---------------- \033[0mWho is on this Server\033[0;37m ------------
${USERS}
\033[0;37m+---------------- \033[0mPuppet Information\033[0;37m ---------------
| \033[0;31mThis host is puppetized! It is linked to the${PUPPETSERVER} server. Please do not change any local configuration.
\033[0;37m|   \033[0m   Last run\033[1;32m: \033[0;35m `echo ${PUPPET_LAST_RUN}|awk '{print strftime("%d.%m.%Y %H:%M",$1)}'` (${PUPPET_FILE_AGE}m ago with outcome${NUM_FAIL} and${NUM_SUCC})
\033[0;37m+---------------------------------------------------\033[0m"

fi 
