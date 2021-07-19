#
# This file was autogenerated by puppet.
# It can still be managed manually but will be overwritten on the next run.
#
#!/bin/sh

BACKUPDIR=/local0/backups/mysql/
BACKUPDIR2=/var/lib/mysqlbinlogs/
DATESTAMP=$(date +%Y%m%d)
DB_USER=backup
DB_PASS='readonly'

mkdir -p $BACKUPDIR
# remove backups older than $DAYS_KEEP
DAYS_KEEP=2
find ${BACKUPDIR}* -mtime +$DAYS_KEEP -exec rm -f {} \; 2> /dev/null
find  ${BACKUPDIR2} -mtime +$DAYS_KEEP -exec rm -f {} \; 2> /dev/null

# create backups securely
umask 006

# list MySQL databases and dump each
DB_LIST=`mysql -u $DB_USER -p"$DB_PASS" -Bs -e'show databases;'`

# Do a full backup (execute this script weekly)
    for DB in $DB_LIST;
       do
           echo "Backing up MySQL database \"${DB}\" ...." |logger -t MySQLbackup
           FILENAME=${BACKUPDIR}${DB}-${DATESTAMP}.sql.gz
           if [ $DB = "nagios" ];then
             mysqldump -u $DB_USER -p"$DB_PASS" --opt --flush-logs --single-transaction | gzip > $FILENAME
           else
             mysqldump -u $DB_USER -p"$DB_PASS" --opt --flush-logs $DB | gzip > $FILENAME
           fi
           echo "MySQL backup of \"${DB}\" Complete ...." |logger -t MySQLbackup
       done
