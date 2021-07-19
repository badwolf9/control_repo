#!/bin/bash
#
# RAM usage monitor plugin for Nagios
# Written by Vinicius de Figueiredo Silva (viniciusfs@gmail.com)
# Last Modified: 27-11-2007
# Modified by Robert Waffen (zero0ne@zero0ne.de)
#
# Usage: ./check_ram
#
# Description:
# This plugin checks how much percentage of RAM is in use.
# Tested only in Linux (Debian, Ubuntu, CentOS and Red Hat Enterprise)
# and Solaris 8/9.
#
#
# Extension:
#       * shows cached memory
#       * realy used memory
#       * free memory
#######################################################################

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

MB_MODE=0

RAM_TOTAL=0
RAM_FREE=0
RAM_CACHED=0
RAM_INUSE=0

print_help() {
        echo "CHECK_RAM - RAM usage monitor plugin for Nagios"
        echo "Copyright (c) 2007 Vinicius de Figueiredo Silva (viniciusfs@gmail.com)"
        echo ""
        echo "This script checks for RAM usage and generates an alarm when"
        echo "RAM usage is over threshold values."
        echo ""
        echo "Options:"
        echo "  -m"
        echo "     Prints output and performance data in MB instead of percentage."
        echo ""
        print_usage
        echo ""
        echo "Example: check_ram 80 90"
        echo ""
        echo "This example will generates a warning alarm when RAM usage is over 80%"
        echo "and a critical alarm when RAM usage is over 90%."
}

print_usage() {
        echo "UUsage: check_ram2   "
}

case "$1" in
        --help|-h)
                print_help
                exit $STATE_OK
                ;;
        *)
                if [ $# -lt 2 ]; then
                        print_usage
                        exit $STATE_UNKNOWN
                elif [ $1 -ge $2 ]; then
                        print_usage
                        echo "Warning value must be greater than Critical value."
                        exit $STATE_UNKNOWN
                elif [ $1 -lt 1 ] || [ $1 -gt 100 ] || [ $2 -lt 1 ] || [ $2 -gt 100 ]; then
                        print_usage
                        echo "Values are out of range [0-100]."
                        exit $STATE_UNKNOWN
                fi
                ;;
esac

WARN=$1
CRIT=$2

OS=`uname -a | awk '{ print $1 }'`

case "$OS" in
        Linux)
                RAM_TOTAL=`free -m | grep -i mem | awk '{ print $2 }'`
                RAM_INUSE=`free -m | grep -e "-/+" | awk '{ print $3 }'`
                RAM_FREE=`free -m | grep -e "-/+" | awk '{ print $4 }'`
                RAM_CACHED=`free -m | grep -i mem | awk '{ print $7 }'`
                ;;
        SunOS)
                RAM_TOTAL=`prtconf | grep ^"Memory size" | awk '{print $3}'`
                RAM_FREE=`vmstat 1 5 | tail -1 | awk '{print $5}'`
                RAM_FREE=$(($RAM_FREE/1000))
                RAM_INUSE=$(($RAM_TOTAL-$RAM_FREE))
                ;;
esac

PERC_INUSE=$(((100*$RAM_INUSE)/$RAM_TOTAL))
PERC_FREE=$(((100*$RAM_FREE)/$RAM_TOTAL))
PERC_CACHED=$(((100*$RAM_CACHED)/$RAM_TOTAL))
PERFDATA="used=$PERC_INUSE%;free=$PERC_FREE%;cached=$PERC_CACHED%;$WARN;$CRIT;0;100"

if [ $3 ] && [ $3 = "-m" ]; then
        MB_MODE=1
        RAM_WARN=$((($RAM_TOTAL*$WARN)/100))
        RAM_CRIT=$((($RAM_TOTAL*$CRIT)/100))
        RAM_C=$((($RAM_TOTAL*$RAM_CACHED)/100))
        RAM_F=$((($RAM_TOTAL*$RAM_FREE)/100))
        PERFDATA="used=${RAM_INUSE}MB;free=${RAM_FREE}MB;cached=${RAM_CACHED}MB;$RAM_WARN;$RAM_CRIT;0;$RAM_TOTAL"
fi

if [ $PERC_INUSE -ge $CRIT ]; then
        if [ $MB_MODE -eq 1 ]; then
                echo "RAM CRITICAL - ${RAM_INUSE}MB of ${RAM_TOTAL}MB in use, free=${RAM_FREE}MB, cached=${RAM_CACHED}MB |$PERFDATA"
        else
                echo "RAM CRITICAL - RAM usage in $PERC_INUSE%, free=$PERC_FREE%, cached=$PERC_CACHED% |$PERFDATA"
        fi
        exit $STATE_CRITICAL
elif [ $PERC_INUSE -ge $WARN ]; then
        if [ $MB_MODE -eq 1 ]; then
                echo "RAM WARNING - ${RAM_INUSE}MB of ${RAM_TOTAL}MB in use, free=${RAM_FREE}MB, cached=${RAM_CACHED}MB |$PERFDATA"
        else
                echo "RAM WARNING - RAM usage in $PERC_INUSE%, free=$PERC_FREE%, cached=$PERC_CACHED% |$PERFDATA"
        fi
        exit $STATE_WARNING
else
        if [ $MB_MODE -eq 1 ]; then
                echo "RAM OK - ${RAM_INUSE}MB of ${RAM_TOTAL}MB in use, free=${RAM_FREE}MB, cached=${RAM_CACHED}MB |$PERFDATA"
        else
                echo "RAM OK - RAM usage in $PERC_INUSE%, free=$PERC_FREE%, cached=$PERC_CACHED% |$PERFDATA"
        fi
        exit $STATE_OK
fi

