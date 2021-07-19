#!/usr/bin/bash

LOGFILE=/var/log/dirvish/log
DATE=`/usr/gnu/bin/date "+%a %b %d %Y"`

#
#	Check 1. - Did dirvish run?
#
LOGDATE=`head -1 $LOGFILE`
    if [ "$LOGDATE" = "$DATE" ];then
        /bin/true
    else
	echo "Dirvish doesn't appear to have run."
	exit 2 
    fi

#
#	Check 2. Are all banks normal?
#
LINECOUNT=`wc -l $LOGFILE|nawk '{print $1}'`
FAILURE=`cat $LOGFILE|head -\`expr $LINECOUNT - 1\`|tail -\`expr $LINECOUNT - 2\`| grep -v "dirvish \-\-vault"|nawk '{print $4 " " $5 " " $6 " " $7 "\n" }'`
if [ `cat $LOGFILE|head -\`expr $LINECOUNT - 1\`|tail -\`expr $LINECOUNT - 2\`| grep -v "dirvish \-\-vault"|wc -l` = 0 ]
    then
	/bin/true
 
else
        IFS=$'\n'
	    for i in `echo $FAILURE`;do printf "$i \n";done
	exit 2 
        IFS=" "
fi

#
#	Check 3. - Did dirvish finish?
#
LASTLINE=`tail -1 $LOGFILE|nawk '{print $2}'`
    if [ "$LASTLINE" = "done" ];then
	/bin/true
    else
	echo "Dirvish is still running"
	exit 1 
    fi
echo "Dirvish completed successfully :-)"
exit 0
