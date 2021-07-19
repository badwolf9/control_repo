#!/bin/bash
# @log: 2011-03-01 Changed daily retention to 28 days.
# @log: 2015-10-06 Added a check to see if enough monthly/weekly snapshots exist
# @log: 2015-10-07 Removed check for zfs already running if we are cleaning home dirs.
#                  Otherwise it gets out of sync with DR system
# Changes to this file should be made on the Puppet master

ZFS_BASE=$1
FILESYSTEMS=$2

dayconvert () {
         case $MONTH in
             01)
             MONTH_PLUS=0
             ;;
             02)
             MONTH_PLUS=31
             ;;
             03)
             MONTH_PLUS=59
             ;;
             04)
             MONTH_PLUS=90
             ;;
             05)
             MONTH_PLUS=120
             ;;
             06)
             MONTH_PLUS=151
             ;;
             07)
             MONTH_PLUS=181
             ;;
             08)
             MONTH_PLUS=212
             ;;
             09)
             MONTH_PLUS=243
             ;;
             10)
             MONTH_PLUS=273
             ;;
             11)
             MONTH_PLUS=304
             ;;
             12)
             MONTH_PLUS=334
             ;;
          esac
          if [ `expr $YEAR % 4` = 0 ]&&[ $MONTH -gt 02 ];then
              MONTH_PLUS=`expr $MONTH_PLUS + 1`
          fi
# Calculate day since 0000-01-01 (-1)
     DAY_COUNT=`expr 3 + $YEAR \* 365 + $MONTH_PLUS + $DAY`
# Calculate DAY_OF_WEEK where 0 = Sun
     DAY_OF_WEEK=`expr $DAY_COUNT % 7`
     DAY_OF_MONTH=`expr $DAY_COUNT % 28`
}

getstatus () {
#
#	If a snapshot is more than 100 days old - delete it
#	If it's older than 60 days, and not a one in 4 Sunday - delete it
#	- a "one in 4 Sunday" happens every 28 days, and $DAY_OF_MONTH will = 0
#	If it's older than 28 days, and not a Sunday - delete it
#
     DESTROY=false
     if [ `expr $TODAY - $DAY_COUNT` -gt 100 ];then
         DESTROY=true
     fi
     if [ `expr $TODAY - $DAY_COUNT` -gt 90 ]&&[ $DAY_OF_MONTH != 0 ];then
         DESTROY=true
     fi
     if [ `expr $TODAY - $DAY_COUNT` -gt 28 ]&&[ $DAY_OF_WEEK != 0 ];then
         DESTROY=true
     fi
     if [ $DAY_OF_MONTH == 0 ];then
         MONTHLY_SNAPS=`expr $MONTHLY_SNAPS + 1`
     fi
     if [ $DAY_OF_WEEK == 0 ];then
         WEEKLY_SNAPS=`expr $WEEKLY_SNAPS + 1`
     fi
}
#
#	For each snapshot in a file system, convert the date it was created into
#	the number of days from 1 Jan 0000
#
deletesnap () {
FS_TO_RETAIN=false
MONTHLY_SNAPS=0
WEEKLY_SNAPS=0
for SNAPSHOT in `zfs list -tsnapshot -H -r $ZFS_BASE/$FILE_SYS|awk '{print $1}'`;do
     YEAR=`echo $SNAPSHOT | awk -F\@ '{print $2}'|awk -F\- '{print $1}'`
     MONTH=`echo $SNAPSHOT | awk -F\@ '{print $2}'|awk -F\- '{print $2}'`
     DAY=`echo $SNAPSHOT | awk -F\@ '{print $2}'|awk -F\- '{print $3}'|cut -c1-2`
     dayconvert
     getstatus
         if [ $DESTROY = 'false' ];then
             FS_TO_RETAIN=true
         fi
done
    if [ $MONTHLY_SNAPS -lt 4 ]&&[ -z `echo $SNAPSHOT|egrep '/home/|/gridhome/'` ];then
        echo "Only $MONTHLY_SNAPS Monthly snapshots yet - aborting"
        return 1
    elif [ $WEEKLY_SNAPS -lt 12 ]&&[ -z `echo $SNAPSHOT|egrep '/home/|/gridhome/'` ];then
        echo "Only $WEEKLY_SNAPS Weekly snapshots yet - aborting"
        return 1
    fi
    if [ $FS_TO_RETAIN != 'true' ];then
         echo "No unexpired snapshots"
           if [ ! -z `echo $SNAPSHOT|egrep '/home/|/gridhome/'` ];then
             removeOldHome
             return 1
           else
             return 1
           fi
    fi
for SNAPSHOT in `zfs list -tsnapshot -H -r $ZFS_BASE/$FILE_SYS|awk '{print $1}'`;do
     YEAR=`echo $SNAPSHOT | awk -F\@ '{print $2}'|awk -F\- '{print $1}'`
     MONTH=`echo $SNAPSHOT | awk -F\@ '{print $2}'|awk -F\- '{print $2}'`
     DAY=`echo $SNAPSHOT | awk -F\@ '{print $2}'|awk -F\- '{print $3}'|cut -c1-2`
        dayconvert
        getstatus
            if [ $DESTROY = 'true' ];then
		echo "Destroying $SNAPSHOT at `/bin/date +%Y-%m-%d_%H%M`"
 		zfs destroy $SNAPSHOT
		# Dubugging
                # echo "zfs destroy $SNAPSHOT days old = `expr $TODAY - $DAY_COUNT` day of month = $DAY_OF_MONTH"
            fi
done
}
removeOldHome () {

alwaysValid="brinn kohleman ryanj"
  for Us in $alwaysValid;do
    id $Us > /dev/null  2>&1
    if [ $? != 0 ];then
      echo "$Us has left or LDAP is not working" |mailx -s "$0 says:" john.ryan@bsse.ethz.ch
      return 1
    fi
  done

  if [ $FILE_SYS = winprofiles ]||[ $FILE_SYS = nagiostest ];then
    echo "No unexpired snapshots for $FILE_SYS on $HOSTNAME"|mailx -s "$0 says:" john.ryan@bsse.ethz.ch
  else
    echo "Destroying last of $ZFS_BASE/$FILE_SYS"
    zfs destroy -r $ZFS_BASE/$FILE_SYS
  fi
}
#
#	Main section
#	If a zfs command is already running, abort, as this process is not critical
#
ZFS_RUNNING=`/bin/ps -ef |grep zfs|grep -v grep|wc -l`
if [ $ZFS_RUNNING -ge 1 ]&&[ -z `echo $FILESYSTEMS|egrep '/home|/gridhome'` ];then
    echo "ZFS command already running - aborting"
    exit 0
fi

#
#	Establish today's number of days from 1 Jan 0000
#

YEAR=`/bin/date +%Y`
MONTH=`/bin/date +%m`
DAY=`/bin/date +%d`
dayconvert
TODAY=$DAY_COUNT
if [ `echo $FILESYSTEMS|cut -c1` = "/" ];then
    for FILE_SYS in `ls $FILESYSTEMS`;do
        deletesnap
    done
else
    FILE_SYS=$FILESYSTEMS
    deletesnap
fi
