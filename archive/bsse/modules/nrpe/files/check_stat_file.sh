#!/bin/bash

FILES_TO_STAT="/usr/local/bsse/MATLAB_R2017b/license.dat \
               /usr/local/bsse/other/etc/modulefiles/matlab/R2017b"

function setLogState(){
#
# SRC is the SOURCE of the error
# LVL is 1,2,3 (warn,err,unknown) - see nagios
# LOG is the loginfo
# LOGFILE is the logfile with further details (not mandatory)
#
# The output format is : timestamp:source:level:detailed_logfile:comment/loginfo
#
        SRC=$1
        LVL=$2
        LOG=$3
        LOGFILE=$4
        TIME=`date "+%s"`
        LOGDEST="/var/log/nagios-collector.log";
        echo "$SRC:$TIME:$LVL:$LOGFILE:$LOG" >>$LOGDEST
}
function test_file_stat() {
    for FILE_TO_STAT in $FILES_TO_STAT;do
        stat $FILE_TO_STAT > /dev/null 2>&1
        FILE_OK=`echo $?`
            if [ $FILE_OK != 0 ];then
                echo "File stat CRITICAL - ${FILE_TO_STAT} broken"
                setLogState "NFS file stat check" 2 "File stat went Critial for file $FILE_TO_STAT!"
                exit 2
            fi
    done
    echo "OK"
}

if [ `ps -ef|grep automount|grep -v grep|wc -l` -ge 1 ];then
    test_file_stat
else
    sleep 5
    test_file_stat
fi
setLogState "NFS file stat check" 2 "CLEAR"
exit 0
