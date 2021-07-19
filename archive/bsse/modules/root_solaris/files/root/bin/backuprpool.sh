#!/bin/bash

# Deployed by puppet

POOL_BASE=dataPool/rpoolsnaps
BACKUP_POOL=$POOL_BASE/$HOSTNAME
BACKUP_DIR=/rpoolsnaps/$HOSTNAME
DATE=`/bin/date +%Y-%m-%d`
DAYS_TO_RETAIN=14 # Actually will be 15 days

if ! zfs list -r $POOL_BASE;then
  zfs create -o mountpoint=/rpoolsnaps dataPool/rpoolsnaps
fi
if ! zfs list -r $BACKUP_POOL;then
  zfs create $BACKUP_POOL
fi

CONFFILE=$BACKUP_DIR/rpoolconfig.$DATE
ROOTDISK=`zpool status rpool|tail -3|head -1|awk '{print "/dev/rdsk/" $1}'`

echo "`/bin/date`" > $CONFFILE
echo "\n***** Pool list *****\n " >> $CONFFILE
zpool list >> $CONFFILE
echo "\n***** Pool status *****\n " >> $CONFFILE
zpool status rpool >> $CONFFILE
echo "\n***** ZFS list *****\n" >> $CONFFILE
zfs list -r rpool >> $CONFFILE
echo "\n***** Root disk vtoc *****\n" >> $CONFFILE
prtvtoc $ROOTDISK  >> $CONFFILE

# Clean out old snapshots
find $BACKUP_DIR/ -mtime +$DAYS_TO_RETAIN -exec rm {} \;
zfs snapshot -r rpool@$DATE
zfs destroy rpool/swap@$DATE
zfs destroy rpool/dump@$DATE
zfs send -Rv rpool@$DATE | gzip > "$BACKUP_DIR/rpool@${DATE}.zfs.gz"
zfs destroy -r rpool@$DATE
