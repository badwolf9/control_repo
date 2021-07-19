#!/bin/bash

PYTHON3_EXISTS=`/mnt/itsc/solaris/bin/python3 -V  > /dev/null 2>&1`
RESULT=$?
if [ $RESULT != 0 ];then
    echo "CRITICAL: python3 does not exist"
    exit 2
else
    echo "OK: python3 exists"
    exit 0
fi
