#! /bin/bash
# Creates backup on the master host and imports the backup on the slave host
# by Marcel Czink <marcel.czink@bsse.ethz.ch> 2011/6/16
# @Log simplified, as we now do straming replication - John 12/6/2016
# global variables
BACKUP_DIR=/local0/backups/pg_full
BACKUP_DIR_XLOG=/local0/backups/pg_xlog
DAYS_TO_RETAIN=0 # This realy means 1 days
POSTGRES_BIN=/usr/pgsql-9.5/bin
DB_DIR=/var/lib/pgsql/9.5
PG_DATA_DIR=$DB_DIR/data
DATE=`/bin/date +%Y-%m-%d_%H%M`
BACKUP_PATH="${BACKUP_DIR}/${DATE}"

line="------------------------------------------------------------------------"

RES_COL="60"
MOVE_TO_COL="\\033[${RES_COL}G"
SETCOLOR_INFO="\\033[1;38m"
SETCOLOR_SUCCESS="\\033[1;32m"
SETCOLOR_FAILURE="\\033[1;31m"
SETCOLOR_WARNING="\\033[1;33m"
SETCOLOR_NORMAL="\\033[0;39m"

function setLogState(){
        SRC=$1
        LVL=$2
        LOG=$3
        LOGFILE=$4
        TIME=`/bin/date +%s`
        LOGDEST="/var/log/nagios-collector.log";
        echo "$SRC:$TIME:$LVL:$LOGFILE:$LOG" >>$LOGDEST
}

function echo_info() {
    echo -e "${1}${MOVE_TO_COL}${SETCOLOR_INFO}${2}${SETCOLOR_NORMAL}"
    setLogState "geneious-sync" 1 "${1} ${2}"
}

function echo_success() {
    echo -e "${1}${MOVE_TO_COL}${SETCOLOR_SUCCESS}${2}${SETCOLOR_NORMAL}"
    setLogState "geneious-sync" 0 "${1} ${2}"
}
function echo_failure() {
    echo -e "${1}${MOVE_TO_COL}${SETCOLOR_FAILURE}${2}${SETCOLOR_NORMAL}"
    setLogState "geneious-sync" 2 "${1} ${2}!"
}
function rvalue() {
        if [ "$?" -eq 0 ] ; then
                echo_success "${1} " "ok"
        else
                echo_failure "${1} " "fail"
                exit 1
        fi
}

function rvalue_info() {
        if [ "$?" -eq 0 ] ; then
                echo_success "${1} " "ok"
        else
                echo_info "${1} " "warning"
        fi
}

# __Main__
echo $line
echo "This is the productive system. Starting backup"
echo $line
# Clean up before starting
echo "Backing up Postgres databases ...." |logger -t PostgresBackup
# You need to update the timestamp on $BACKUP_DIR or it gets deleted - John 27/06/2011
touch $BACKUP_DIR
/usr/bin/find $BACKUP_DIR -maxdepth 1 -type d -mtime +$DAYS_TO_RETAIN -execdir rm -rf {} \;
/usr/bin/find $BACKUP_DIR_XLOG -type f -mtime +$DAYS_TO_RETAIN -exec rm {} \;
rvalue "Removing backups older than $DAYS_TO_RETAIN days"

# Perform backup
sudo -u postgres $POSTGRES_BIN/psql -U postgres -c "SELECT pg_start_backup('${BACKUP_PATH}')"
rvalue  "Running pg_start_backup"
/usr/bin/rsync -a --exclude "pg_xlog/*" ${PG_DATA_DIR} ${BACKUP_PATH}/
sudo -u postgres $POSTGRES_BIN/psql -U postgres -c "SELECT pg_stop_backup()"
setLogState geneious-sync 1 CLEAR
setLogState geneious-sync 2 CLEAR

# Log it
echo "Backed up Postgres databases with exit status $EXIT_STATUS ...." |logger -t PostgresBackup
