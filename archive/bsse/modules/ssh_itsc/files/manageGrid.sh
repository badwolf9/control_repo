#!/bin/bash
# Author:	John Ryan
#			Basil Neff
# Creates the grid user

PATH=/usr/sbin:/usr/bin
LOGFILE='/var/log/manageGrid.log'
RANDOM_ID=${RANDOM}
TMP_USER_FILE="/tmp/grid.${RANDOM_ID}.user.usermanager"
TMP_GROUP_FILE="/tmp/grid.${RANDOM_ID}.group.usermanager"

export SGE_ROOT=/usr/local/grid/soge/

source $SGE_ROOT/bsse/common/settings.sh

QCONF="${SGE_ROOT}/bin/lx-amd64/qconf"
SED='/bin/sed'
DATE='/bin/date'

while getopts pn:g:du option;do
    case $option in
    n)
    NETHZ_USER=$OPTARG
    ;;
    p)
    DUMMY_PASS=true
    ;;
    g)
    GROUPNAME=$OPTARG
    ;;
    d)
    DELETE=true
    ;;
    u)
    UPDATE=true
    ;;
    esac
done

if [ -z "$NETHZ_USER" ]; then
  printf " Usage: `basename $0` -n <username> -g <group> [-d -u] \
  \n Example: `basename $0` -n ryanj -g it\n"
  exit 1
fi

if [ -z "$GROUPNAME" ];then
  PRIMARY_GROUP=`id -gn $NETHZ_USER`
  PRIMARY_GROUP="defaultdepartment"
else
  PRIMARY_GROUP=bsse-$GROUPNAME
fi
echo "----------" | tee -a ${LOGFILE}
echo "grid action for $NETHZ_USER in Group $PRIMARY_GROUP @ `${DATE}` " | tee -a ${LOGFILE} 2>&1

createuser() {
	echo "Create user $NETHZ_USER in grid" | tee -a ${LOGFILE} 2>&1
	echo "Create tmp user file ${TMP_USER_FILE} for $NETHZ_USER" | tee -a ${LOGFILE} 2>&1
	echo "name ${NETHZ_USER}" > ${TMP_USER_FILE}
	echo "oticket 0" >> ${TMP_USER_FILE}
	echo "fshare 0" >> ${TMP_USER_FILE}
	echo "delete_time 0" >> ${TMP_USER_FILE}
	echo "default_project NONE" >> ${TMP_USER_FILE}
	echo "tmp file ${TMP_USER_FILE} created" | tee -a ${LOGFILE} 2>&1
	echo "${QCONF} -Auser ${TMP_USER_FILE}" | tee -a ${LOGFILE} 2>&1
	${QCONF} -Auser ${TMP_USER_FILE}
	
	echo "Create tmp group file ${TMP_GROUP_FILE} for $NETHZ_USER" | tee -a ${LOGFILE} 2>&1
	${QCONF} -su ${PRIMARY_GROUP} > ${TMP_GROUP_FILE}
	${SED} -i 's/entries /entries ${NETHZ_USER},/g' ${TMP_GROUP_FILE} | tee -a ${LOGFILE} 2>&1
	echo "${QCONF} -Mu ${TMP_GROUP_FILE}" | tee -a ${LOGFILE} 2>&1
	${QCONF} -Mu ${TMP_GROUP_FILE} | tee -a ${LOGFILE} 2>&1
}

deleteuser() {
	echo "Delete user $NETHZ_USER in grid" | tee -a ${LOGFILE} 2>&1
	${QCONF} -duser ${NETHZ_USER} | tee -a ${LOGFILE} 2>&1
	echo "Create tmp file ${TMP_GROUP_FILE} for $NETHZ_USER" | tee -a ${LOGFILE} 2>&1
	${QCONF} -su ${PRIMARY_GROUP} > ${TMP_GROUP_FILE} | tee -a ${LOGFILE} 2>&1
	${SED} -i 's/${NETHZ_USER}//g' ${TMP_GROUP_FILE} | tee -a ${LOGFILE} 2>&1
	${SED} -i 's/entries ,/entries /g' ${TMP_GROUP_FILE} | tee -a ${LOGFILE} 2>&1
	echo "${QCONF} -Mu ${TMP_GROUP_FILE}" | tee -a ${LOGFILE} 2>&1
	${QCONF} -Mu ${TMP_GROUP_FILE} | tee -a ${LOGFILE} 2>&1
}

    if [ `id -g $NETHZ_USER` == '' ];then
        echo "User $NETHZ_USER does not exist" | tee -a ${LOGFILE} 2>&1
        exit 1
    fi

    if [ ! -z $UPDATE ]&&[ ! -z $DELETE ];then
        echo "Cannot call -d with -u" | tee -a ${LOGFILE} 2>&1
        exit 1
    #fi
    # Check if the user already exist, update him
    #if [ -d /export/home/$NETHZ_USER ];then
    #    echo "Home dir already exists" | tee -a ${LOGFILE} 2>&1
    #    UPDATE=true
    #fi
    #if [ ! -z $UPDATE ];then
    #    if [ ! -d /export/home/$NETHZ_USER ];then
    #        createuser
    #    fi
    #    echo "Updating" | tee -a ${LOGFILE} 2>&1
    #    # do something, needed?
    elif [ ! -z $DELETE ];then
        # Check if user exist
        deleteuser
    else
        createuser
    fi
    
echo "Done" | tee -a ${LOGFILE} 2>&1
exit 0
