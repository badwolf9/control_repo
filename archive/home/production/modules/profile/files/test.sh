#!/bin/sh

export PUPPET_FILE_AGE_SEC=1586067904
        PUPPET_FILE_AGE=`echo $PUPPET_FILE_AGE_SEC/60 | bc`
        DATE_NOW=`/bin/date +%s`
        PUPPET_LAST_RUN=`echo $DATE_NOW - $PUPPET_FILE_AGE_SEC | bc`

echo $PUPPET_LAST_RUN

echo "Last run: `echo ${PUPPET_FILE_AGE_SEC}|awk '{print strftime("%d.%m.%Y %H:%M",$1)}'`"
