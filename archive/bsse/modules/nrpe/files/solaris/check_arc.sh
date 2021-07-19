#!/bin/bash

MAXSIZE=`/usr/bin/kstat -p zfs:0:arcstats:c_max|nawk '{print $2}'`
TARGETSIZE=`/usr/bin/kstat -p zfs:0:arcstats:c|nawk '{print $2}'`
SIZE=`/usr/bin/kstat -p zfs:0:arcstats:size|nawk '{print $2}'`
DATASIZE=`/usr/bin/kstat -p zfs:0:arcstats:data_size|nawk '{print $2}'`

PCNT_USE=`expr 100 \* $SIZE / $MAXSIZE`
PCNT_TARGET=`expr 100 \* $TARGETSIZE / $MAXSIZE`
PCNT_DATA=`expr 100 \* $DATASIZE / $MAXSIZE`

echo "Arc OK Arcsize is $SIZE target is $TARGETSIZE datasize is $DATASIZE|Used=${PCNT_USE}% Target=${PCNT_TARGET}% Data=${PCNT_DATA}%"
exit 0
