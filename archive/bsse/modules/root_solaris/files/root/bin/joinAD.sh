#!/bin/bash

LOG=/var/log/joinAD.log
net ads testjoin -k | grep -q 'Join is OK'
JOINOK=$?

if [ $JOINOK != 0 ];then
    echo "Trying Join @ `date`" >> $LOG
    net ads -U bs-admin%"M123inavsPW." join >> $LOG 2>&1
else
    echo "Join is okay @ `date`" >> $LOG
fi
