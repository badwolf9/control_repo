#!/bin/bash
#
# Author: basil.neff@bsse.ethz.ch
# Date: 2014.07
#
# Prints information that the host is puppetized and some additional information:
# * Hostname, IP, Kernel, CPU, Memory
# * last puppet run
# * Who is logged in
#set -x
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
    #	Check when Puppet Last ran
    if [ -f /etc/nagios/nrpe.cfg ];then
        PUPPET_NAG_CHECK=`grep check_puppet /etc/nagios/nrpe.cfg|awk -F\= '{print $(NF)}'`
        $PUPPET_NAG_CHECK > /dev/null 2>&1
        RESULT=`echo $?`
        #	Green 32m, purple 35m, red 31m, orange 33m
        case $RESULT in
	    0 ) COLOUR=32m ;;
	    1 ) COLOUR=33m ;;
	    2 ) COLOUR=31m ;;
        esac
    PUPPET_FILE_AGE_SEC=`$PUPPET_NAG_CHECK|awk '{print $(NF-1)}'|awk -F\; '{print $1}'|sed -e s'|age=||'|sed -e s'|s||'`
    PUPPET_FILE_AGE=`echo $PUPPET_FILE_AGE_SEC/60 | bc`
    DATE_NOW=`/bin/date +%s`
    PUPPET_LAST_RUN=`echo $DATE_NOW - $PUPPET_FILE_AGE_SEC | bc`
    else
       printf "##########\n########## No Nagios config file found! Using Puppet report file\n##########\n"
        COLOUR=31m
        LRFILE=`/usr/bin/locate last_run_summary.yaml`
        PUPPET_LAST_RUN=`grep last_run ${LRFILE}|cut -d ":" -f 2|tr -d " "`
        DATE_NOW=`/bin/date +%s`
        PUPPET_FILE_AGE=`expr $DATE_NOW - $PUPPET_LAST_RUN | bc`
    fi
    #	Get success and failure counts
    YAML_FILE=`/usr/bin/locate last_run_summary.yaml|grep state|head -1`
    NUM_FAIL=Unknown
    NUM_SUCC=Unknown
    if [ -f $YAML_FILE ];then
        NUM_FAIL=`cat ${YAML_FILE}|grep failure`
        NUM_SUCC=`cat ${YAML_FILE}|grep success`
    fi
    #	Find our Puppet server
    PUPPET_CONF_FILE='/etc/puppetlabs/puppet/puppet.conf'
    if [ -f ${PUPPET_CONF_FILE} ];then
        PUPPETSERVER=`cat ${PUPPET_CONF_FILE}|grep "server ="|cut -d= -f2|cut -d. -f1`
    else
        PUPPETSERVER=`cat /etc/puppet/puppet.conf|grep "server ="|cut -d= -f2|cut -d. -f1`
    fi
    #	Get logged in users
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
\033[0;37m|   \033[0m   Last run: \033[0;${COLOUR} `echo ${PUPPET_LAST_RUN}|awk '{print strftime("%d.%m.%Y %H:%M",$1)}'` (${PUPPET_FILE_AGE}m ago with outcome${NUM_FAIL} and${NUM_SUCC})
\033[0;37m+---------------------------------------------------\033[0m"
fi 
