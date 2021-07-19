#!/bin/bash

function mountCheck {
    if [ ! -d /${1}/snapshots ];then
        return 2
    else
        return 0
    fi
}

# __main__
for MOUNTPOINT in lts11 lts21;do
    mountCheck $MOUNTPOINT
    RESULT=$?
    if [ $RESULT == 2 ];then
        # Try to mount
        sudo mount /${MOUNTPOINT}
        mountCheck $MOUNTPOINT
        RESULT=$?
            if [ $RESULT == 2 ];then
                echo "Mount CRITICAL - ${MOUNTPOINT} broken"
	        exit 2
            fi
    fi
done
echo "Mount OK"
exit 0
