#!/bin/bash

package=check_griderrors

# Path to SGE installation
export SGE_ROOT=/usr/local/grid/sge/sge6.2u7/
# Name of the SGE cell to be monitored
export SGE_CELL=default
# Import environment
source $SGE_ROOT/bsse/common/settings.sh
# Extension of queues
QEXT=".q"

# List of queues ignored when summing up. Separate by pipes!
IGNORE_QUEUES="background.q|immediate.q|sc.q"

# Parse command line options
if [ "$#" == "0" ]; then
    echo "No arguments provided"
    exit 3
fi


# parse parameters
while test $# -gt 0; do
    case "$1" in
        -h|--help)
            echo "$package - Check faulty SGE queues"
            echo " "
            echo "Check all queues for errors and get performance data separately for each queue"
            echo " "
            echo "ATTN: The host running this script needs to be a submit or admin node, it is helpful to use NRPE"
            echo " "
            echo "$package -w <warning> -c <critical>"
            echo " "
            echo "options:"
            echo "-h, --help                show brief help"
            echo "-w, --warning             Number of faulty queues (not hosts!) triggering a warning"
            echo "-c, --critical            Number of faulty queues (not hosts!) triggering a critical error"
            exit 0
            ;;
        -w|--warning)
            shift
            if test $# -gt 0; then
                export warning=$1
            else
                echo "no warning level specified"
            fi
            shift
            ;;
        -c|--critical)
            shift
            if test $# -gt 0; then
                export critical=$1
            else
                echo "no critical level specified"
            fi
            shift
            ;;
    esac
done

# Get a list of all queues, filtering doubles
QUEUES=$(qconf -sql | egrep -v -E '($IGNORE_QUEUES)') 

# Get the number of faulty qeues by checking if the state column is different to 0
num_faulty_queues=`qstat -r -u "all" -g c  | grep $QEXT | egrep -v -E '($IGNORE_QUEUES)' | awk '{if ($8 > 0 ) print $0;}' | wc -l`

# Get the total number of used cores 
used_cores=`qstat -r -u "all" -g c  | grep $QEXT | egrep -v -E "($IGNORE_QUEUES)"  | awk '{ SUM += $3 } END {print SUM}'`
# Get the total number of available cores
available_cores=`qstat -r -u "all" -g c  | grep $QEXT | egrep -v -E "($IGNORE_QUEUES)" | awk '{ SUM += $5 } END {print SUM}'`
# Get the total number of cores in all queues
total_cores=`qstat -r -u "all" -g c  | grep $QEXT | egrep -v -E "($IGNORE_QUEUES)"  | awk '{ SUM += $6 } END {print SUM}'`

# Get number of used cores on each queue
all_queue_stats=''
for qs in $QUEUES; do
    ret=`qstat -r -u "all" -g c  | grep $QEXT | grep $qs | awk '{ print $3 }'`
    all_queue_stats+=" $qs=$ret,"
done


# Verbosity level
verbosity=0
# Warning threshold
thresh_warn=-1
# Critical threshold
thresh_crit=-1




perfdata=" | available_cores=$available_cores, used_cores=$used_cores, total_cores=$total_cores, $all_queue_stats"

if  test $num_faulty_queues -ge $critical
then
    echo "CRITICAL: $num_faulty_queues queues have errors"$perfdata
    exit 2
elif test $num_faulty_queues -ge $warning
then
    echo "WARNING: $queues_with_errors queues have errors"$perfdata
    exit 1
else
    echo "OK: All queues are fine"$perfdata
    exit 0
fi
