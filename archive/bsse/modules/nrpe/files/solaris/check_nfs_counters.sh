#!/bin/bash

inc=1
STAT=OK
WARN=60
CRIT=75
IFS=$'\n'

while getopts w:c: option;do
    case $option in
    w)
    WARN=$OPTARG
    ;;
    c)
    CRIT=$OPTARG
    ;;
esac
done

for line in `echo '::rfs4_db' | sudo mdb -k |grep ^ffff| nawk '{print $2 "=" $4}'`;do
    if [ `echo $line | grep OpenOwner` ];then
        count=`echo $line | nawk -F\= '{print $2}'` 
        percent=`expr $count / 10485`
        if [ $percent -gt $WARN ];then
            STAT=WARN
        fi
        if [ $percent -gt $CRIT ];then
            STAT=CRITICAL
        fi
        pct="${percent}% "
    fi
        export VAR$inc="$line"
    inc=`expr $inc + 1`
done
    echo "CHECK_NFS_COUNT $STAT $pct | $VAR1 $VAR2 $VAR3 $VAR4 $VAR5 $VAR6 $VAR7 $VAR8 "
if [ $STAT = CRITICAL ];then
    exit 2
elif [ $STAT = WARN ];then
    exit 1
else
    exit 0
fi
