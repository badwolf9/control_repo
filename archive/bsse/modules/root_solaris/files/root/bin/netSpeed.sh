#!/bin/bash
#
# Make changes in puppet
#
while getopts i:s:f: option;do
    case $option in
    i)
    IFACE=$OPTARG
    ;;
    s)
    SIZE=$OPTARG
    ;;
    f)
    FREQ=$OPTARG
    ;;
esac
done
if [ -z $IFACE ];then
    echo "Usage: $0 -i <interface> -s [M|m|K|k]"
    exit 1
fi

if [ -z $SIZE ];then
    SIZE=M
fi

if [ -z $FREQ ];then
    FREQ=10
fi

if [ $SIZE = M ]||[ $SIZE = m ];then
    DIVISOR=`expr 1000000 \* $FREQ`
elif [ $SIZE = K ]||[ $SIZE = k ];then
    DIVISOR=`expr 10000 \* $FREQ`
fi

while :;do
    OBYTES_INIT=`kstat -p "link:0:$IFACE:obytes64" |awk '{print $2}'`
    RBYTES_INIT=`kstat -p "link:0:$IFACE:rbytes64" |awk '{print $2}'`
    sleep $FREQ
    OBYTES_NEXT=`kstat -p "link:0:$IFACE:obytes64" |awk '{print $2}'`
    RBYTES_NEXT=`kstat -p "link:0:$IFACE:rbytes64" |awk '{print $2}'`
    OBYTES_PS=`expr $OBYTES_NEXT - $OBYTES_INIT`
    RBYTES_PS=`expr $RBYTES_NEXT - $RBYTES_INIT`
    OMBYTES_PS=`expr $OBYTES_PS / $DIVISOR`
    RMBYTES_PS=`expr $RBYTES_PS / $DIVISOR`
    printf "`date +%H%M` Sent $OMBYTES_PS ${SIZE}bytes/sec Received $RMBYTES_PS ${SIZE}bytes/sec \n"
done
