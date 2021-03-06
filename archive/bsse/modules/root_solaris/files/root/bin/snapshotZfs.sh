#!/bin/bash
# @log: 2010-11-13 Try to trap send errors with the word cannot in them
# @log: 2010-11-14 Disabling scrub/resilver test
# @log: 2010-11-17 Changed lock file warning to value of 3 for nagios to return 'unknown'
# @log: 2010-11-24 Removed "ssh $REMOTE exit"
# @log: 2011-02-22 Added PID to lockfile
# @log: 2011-03-11 Changed logic that checks lockfile
# @log: 2011-04-30 Changed usage logic to avoid "to many arguments error"
# @log: 2011-07-25 Removed scrub check, and added Connect timeout check
# @log: 2011-07-26 Added ${LOC_FS_BASE} to 'in Sync' message
# @log: 2011-07-27 Stop bombing out when snapshots differ, just do a copysnap instead
# @log: 2011-07-28 Add tail and remove of temp log for more verbose logging in copysnap
# @log: 2011-08-17 Connect timeout option only works on Solaris 11
# @log: 2014-08-04 Changed snapshot logic, to snapshot filesystems first, then copy to the backup. Makes times more real
#
# Please make changes to this file from the Puppet master

while getopts h:l:r:f:k:c:i: option;do
    case $option in
    h)
    REMOTE=$OPTARG
    ;;
    l)
    LOC_FS_BASE=$OPTARG
    ;;
    r)
    REM_FS_BASE=$OPTARG
    ;;
    f)
    FILESYSTEMS=$OPTARG
    ;;
    k)
    DAYS_TO_RETAIN=$OPTARG
    ;;
    c)
    CREATE=$OPTARG
    ;;
    i)
    ID=$OPTARG
    ;;
esac
done
FILESYSTEM1=`echo $FILESYSTEMS|nawk '{print $1}'`
if [ -z $REMOTE ]||[ -z $LOC_FS_BASE ]||[ -z $REM_FS_BASE ]||[ -z $FILESYSTEM1 ]||[ -z $DAYS_TO_RETAIN ]||[ -z $CREATE ]||[ -z $ID ];then
    echo "Usage: $0 -h<host> -l<LOC_FS_BASE> -r<REM_FS_BASE> -f<FILESYSTEMS> -k<RETENTION> -c<y|n> -i<IDENTIFIER>"
    echo "Where: "
    echo "host is the FQDN of the host"
    echo "LOC_FS_BASE is the local pool base, eg: dataPool/export/group"
    echo "REM_FS_BASE is the remote pool base, eg:  dataPool/snapshots/group/ or dataPool/snapshots/bs-ssvr06- "
    echo "FILESYSTEMS if begin with a / will be all filesytems in the directory, or without a / just that filesystem"
    echo "     or you can use a string of filesystems eg: \"bsse cina cisd\" "
    echo "RETENSION is how many snapshots versions we will keep on this host"
    echo "CREATE is set to y if a local snapshot has not been taken by another snapshot script"
    echo "IDENTIFIER is to uniquely identify this process for locking purposes"
    exit 255
fi

ZFS=/sbin/zfs
DATE=`/bin/date +%Y-%m-%d_%H%M`
LOCKFILE=/var/run/snapshots/.snapshot.$ID.lck
ERROR_LOG=/var/log/zfsSnapshotError.log 
RUN_DIR=/var/run/snapshots
if [ ! -d $RUN_DIR ];then
    mkdir $RUN_DIR
fi

createsnap () {
#
#	Set up variables for this run
#
PREV_SNAP=`$ZFS list -t snapshot -r "${LOC_FS_BASE}/${FILE_SYS}" |tail -1|awk '{print $1}'`
PREV_SNAP_TIME=`$ZFS list -t snapshot -r "${LOC_FS_BASE}/${FILE_SYS}" |tail -1|awk '{print $1}'|awk -F\@ '{print $2}'|awk '{print $1}'`
REM_PREV_SNAP_TIME=`ssh $REMOTE "$ZFS list -t snapshot -r ${REM_FS_BASE}${FILE_SYS}" |tail -1|awk -F\@ '{print $2}'|awk '{print $1}'`
if [ -z $REM_PREV_SNAP_TIME ];then
    if [ $? != "0" ];then
        printf "2,`date +%Y-%m-%d\ %H%M`,Connection failed when snapshotting ${LOC_FS_BASE}/${FILE_SYS} to $REMOTE\n" >> $ERROR_LOG
        return $?
    fi
fi

NEW_SNAP=0
#
#	Check if remote snapshot exists
#
    if [ x$REM_PREV_SNAP_TIME = x ];then
       echo "Remote snapshot ${FILE_SYS} does not exist"
       NEW_SNAP=1
    elif [ x$PREV_SNAP_TIME != x$REM_PREV_SNAP_TIME ];then 
       NEW_SNAP=0
       return 0
    fi

#
#	Often get too new snapshots while testing. Shouldn't happen in production
#
    if [ x$PREV_SNAP_TIME = x$DATE ];then
       printf "2,`date +%Y-%m-%d\ %H%M`,Error $PREV_SNAP_TIME too new\n" >> $ERROR_LOG
       return 2
    fi

#
#	Create new snapshot
#
    $ZFS snapshot ${LOC_FS_BASE}/${FILE_SYS}@$DATE
}

copysnap () {
#
#	Set up variables for this run
#
NEWEST_SNAP=`$ZFS list -t snapshot -r "${LOC_FS_BASE}/${FILE_SYS}" |tail -1|awk '{print $1}'`
NEWEST_SNAP_TIME=`$ZFS list -t snapshot -r "${LOC_FS_BASE}/${FILE_SYS}" |tail -1|awk '{print $1}'|awk -F\@ '{print $2}'|awk '{print $1}'`
REM_NEWEST_SNAP_TIME=`ssh $REMOTE "$ZFS list -t snapshot -r ${REM_FS_BASE}${FILE_SYS}" |tail -1|awk -F\@ '{print $2}'|awk '{print $1}'`
if [ -z $REM_PREV_SNAP_TIME ];then
    if [ $? != "0" ];then
        printf "2,`date +%Y-%m-%d\ %H%M`,Connection failed when snapshotting ${LOC_FS_BASE}/${FILE_SYS} to $REMOTE\n" >> $ERROR_LOG
        return $?
    fi
fi

NEW_SNAP=0

#
#	Check if remote snapshot exists
#
    if [ x$REM_NEWEST_SNAP_TIME = x ];then
       echo "Remote snapshot ${FILE_SYS} does not exist"
       NEW_SNAP=1
    fi
#
#	Check if FILE_SYS is already in sync. If so do nothing	
#
    if [ x${NEWEST_SNAP_TIME} = x${REM_NEWEST_SNAP_TIME} ];then
       printf "Snapshots for ${LOC_FS_BASE}/${FILE_SYS} in Sync \n"
       return 0
    fi
#
#	Check if any previous shapshots exist, if not, make a new one
#       Else assume this is an incremental snapshot
#
    if [ x$NEWEST_SNAP = x${FILE_SYS} ] || [ $NEW_SNAP = 1 ];then 
       echo "No snapshots exist, creating new snapshot  of ${FILE_SYS}"
       $ZFS send ${LOC_FS_BASE}/${FILE_SYS}@${NEWEST_SNAP_TIME}| \
       ssh $REMOTE "$ZFS recv -F -v ${REM_FS_BASE}${FILE_SYS}" > /tmp/zfssend.$$.log 2>&1
            if [ `grep cannot /tmp/zfssend.$$.log | wc -l` -gt 0 ];then
                printf "1,`date +%Y-%m-%d\ %H%M`,`head -1 /tmp/zfssend.$$.log`\n" >> $ERROR_LOG
       		rm /tmp/zfssend.$$.log
                return 1
            fi
       tail -1 /tmp/zfssend.$$.log
       rm /tmp/zfssend.$$.log

#
#	Check if everything worked
#
       echo "**** Finished full snapshot at `date`"
       RESULT=`ssh $REMOTE "$ZFS list -t snapshot -H -r ${REM_FS_BASE}${FILE_SYS}@${NEWEST_SNAP_TIME}"|wc -l`
       if [ $RESULT = 1 ];then
           printf "**** Snapshot successful\n"
       else 
           printf "2,`date +%Y-%m-%d\ %H%M`,Something went wrong with ${REM_FS_BASE}${FILE_SYS} on $REMOTE!! \n" >> $ERROR_LOG
       fi
    else
       printf "\n**** Starting incremental snapshot ${FILE_SYS} at `date` \n"
       $ZFS send -i ${LOC_FS_BASE}/${FILE_SYS}@${REM_NEWEST_SNAP_TIME} ${LOC_FS_BASE}/${FILE_SYS}@${NEWEST_SNAP_TIME}| \
       ssh $REMOTE "$ZFS recv -F -v ${REM_FS_BASE}${FILE_SYS}" > /tmp/zfssend.$$.log 2>&1
            if [ `grep cannot /tmp/zfssend.$$.log | wc -l` -gt 0 ];then
                printf "1,`date +%Y-%m-%d\ %H%M`,`head -1 /tmp/zfssend.$$.log`\n" >> $ERROR_LOG
       		rm /tmp/zfssend.$$.log
                return 1
            fi
       tail -1 /tmp/zfssend.$$.log
       rm /tmp/zfssend.$$.log

#
#	Check if everything worked
#
       echo "**** Finished incremental snapshot at `date`"
       RESULT=`ssh $REMOTE "$ZFS list -t snapshot -H -r ${REM_FS_BASE}${FILE_SYS}@${NEWEST_SNAP_TIME}"|wc -l`
       if [ $RESULT = 1 ];then
           printf "**** Snapshot successful ........ \n"
           NUM_SNAPS=`$ZFS list -tsnapshot -Hr ${LOC_FS_BASE}/${FILE_SYS} |wc -l`
           if [ $NUM_SNAPS -gt $DAYS_TO_RETAIN ];then
                NO_OF_SNAPS_TO_DELETE=`expr $NUM_SNAPS - $DAYS_TO_RETAIN`
                echo "There are ${NO_OF_SNAPS_TO_DELETE} snapshots to delete ..."
                DEL=`$ZFS list -tsnapshot -Hr ${LOC_FS_BASE}/${FILE_SYS}|awk '{print "/sbin/zfs destroy " $1 ";"}'|head -${NO_OF_SNAPS_TO_DELETE}`
                echo "#!/bin/sh" > $RUN_DIR/deleteSnapshot${FILE_SYS}
                echo $DEL >> $RUN_DIR/deleteSnapshot${FILE_SYS}
                chmod +x $RUN_DIR/deleteSnapshot${FILE_SYS}
                $RUN_DIR/deleteSnapshot${FILE_SYS} && rm $RUN_DIR/deleteSnapshot${FILE_SYS}
            fi
       else 
           printf "2,`date +%Y-%m-%d\ %H%M`,Something went wrong with ${REM_FS_BASE}${FILE_SYS} on $REMOTE!! \n" >> $ERROR_LOG
       fi
    fi
}
#
#       Check first if remote server is reachable
#
if [ `uname -r` = "5.11" ] && [ `ssh $REMOTE -o ConnectTimeout=10 ": : :";echo $?` -ne '0' ];then
    echo "1,`date +%Y-%m-%d\ %H%M`,Connect timeout on $REMOTE" >> $ERROR_LOG
    exit 1
fi

#
#	Check if any snaphots are currently running. 
#	Check 3 times, and if so - exit 1
#
LOOPCOUNT=3
while [ -f $LOCKFILE ];do
    while [ $LOOPCOUNT -gt '0' ] && [ -f $LOCKFILE ];do
	PID=`cat $LOCKFILE`
	if [ `ps -ef|grep $PID|grep -v $$` ];then
        	echo "Lock file exists, for pid `cat $LOCKFILE` sleeping 10 minutes @ `date`"
        	sleep 600
	else
		rm -f $LOCKFILE
		echo "Deleted stale lockfile for $PID ...."
	fi
        LOOPCOUNT=`expr $LOOPCOUNT - 1`
    done
    if [ -f $LOCKFILE ];then
        echo "3,`date +%Y-%m-%d\ %H%M`,Lock file exists Can't start snapshots for $LOC_FS_BASE" >> $ERROR_LOG
        exit 1
    fi
done

printf "0,`date +%Y-%m-%d\ %H%M`, Starting snapshots of ${LOC_FS_BASE} $FILESYSTEMS to $REMOTE \n" >> $ERROR_LOG
echo $$ > $LOCKFILE

if [ `echo $FILESYSTEMS|cut -c1` = "/" ];then
    for FILE_SYS in `ls $FILESYSTEMS`;do
        if [ $CREATE = "y" ];then
            createsnap
        fi
    done
    for FILE_SYS in `ls $FILESYSTEMS`;do
        copysnap
    done
else
    for FILE_SYS in $FILESYSTEMS;do
        if [ $CREATE = "y" ];then
            createsnap
        fi
    done
    for FILE_SYS in $FILESYSTEMS;do
        copysnap
    done
fi

printf "0,`date +%Y-%m-%d\ %H%M`, Finished snapshot of ${LOC_FS_BASE} $FILESYSTEMS to $REMOTE \n" >> $ERROR_LOG
rm $LOCKFILE
