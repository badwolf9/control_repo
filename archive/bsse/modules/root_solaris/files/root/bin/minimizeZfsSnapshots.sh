#!/usr/bin/bash
# This file is managed by Puppet

ZFS=/usr/sbin/zfs
TMPDIR=/tmp/snapshotsToDelete

while getopts l:f:k: option;do
    case $option in
    l)
    LOC_FS_BASE=$OPTARG
    ;;
    f)
    FILESYSTEMS=$OPTARG
    ;;
    k)
    DAYS_TO_RETAIN=$OPTARG
    ;;
esac
done

deletesnap () {
#
#	Delete 
#
           NUM_SNAPS=`zfs list -tsnapshot -Hr ${LOC_FS_BASE}${FILE_SYS} |wc -l`
           if [ $NUM_SNAPS -gt $DAYS_TO_RETAIN ];then
                NO_OF_SNAPS_TO_DELETE=`expr $NUM_SNAPS - $DAYS_TO_RETAIN`
                DEL=`zfs list -tsnapshot -Hr ${LOC_FS_BASE}${FILE_SYS}|awk '{print "zfs destroy " $1 ";"}'|head -${NO_OF_SNAPS_TO_DELETE}`
                printf "Running: $DEL \n "
                echo "#!/bin/sh" > $TMPDIR/deleteSnapshot${FILE_SYS}
                echo $DEL >> $TMPDIR/deleteSnapshot${FILE_SYS}
                chmod +x $TMPDIR/deleteSnapshot${FILE_SYS}
                $TMPDIR/deleteSnapshot${FILE_SYS}
            fi
}

# main
mkdir -p $TMPDIR
if [ `echo $FILESYSTEMS|cut -c1` = "/" ];then
    for FILE_SYS in `ls $FILESYSTEMS`;do
        deletesnap
    done
else
    for FILE_SYS in $FILESYSTEMS;do
        deletesnap
    done
fi
rm -f $TMPDIR/deleteSnapshot*
