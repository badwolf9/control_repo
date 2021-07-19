#!/bin/bash
#
# Written by Frank Baschin
# EMail: fbaschin@athena.de
# http://www.athena.de
#
# Created:      08/04/2008
#
# changed:      10/04/2008
#               added WARNING state for all what is not "Error"
#
# changed:      10/12/2009 - by Klavs Klavsen <klavs@EnableIT.dk>
#               Totally rewritten. Now checks for actual state of log entry - so check can
#               ignore log entries that has been marked as repaired and the ones that are
#               informational - and also general cleanup - no unnecessary snmp checks etc.
#               Work graciously sponsored by Berlingske Media
#
# Description:  Used to monitor HP Insight Manager Log entrys
#               If all are okay clear all log entrys
#               POST Messages with drive array warnings are repressed
#
# License: This nagios plugin comes with ABSOLUTELY NO WARRANTY. You may redistribute copies of
# the plugins under the terms of the GNU General Public License. For more information about these
# matters, see the GNU General Public License.
#
#
# Planed:
# Pre-Check if Insight Manager has errors
#
#
##################################################################################
# You may have to change this, depending on where you installed your
# Nagios plugins
#
PATH="/usr/bin:/usr/sbin:/bin:/sbin"
LIBEXEC="/usr/lib64/nagios/plugins/"
. $LIBEXEC/utils.sh

VERSION="1.1"
# Processes to check
community=""
hostname=""
debug=0
exitstatus=$STATE_OK
INSIGHTLOG_ARRAY="enterprises.232.6.2.11.3.1.8"
INSIGHTLOG_STATARRAY="enterprises.232.6.2.11.3.1.2"
#keep newlines in vars
IFS=""

#STATARRAY contains the status of each logentry.
#
REPAIR=6 # 6 = repaired
INFO=2 # 2 = informational
CAUTION=9 # 9 = caution
CRITICAL=15 # 15 = critical
# ? = unknown ( I don't know what number this has )
#

################################################################################


print_usage() {
        echo "Usage: $0 -H <hostname> -C <community> {-d DEBUG}"
}

print_help() {
        echo ""
        print_usage
        echo ""
        echo "System process and port monitor plugin for Nagios"
        echo ""
        echo "This plugin not developped by the Nagios Plugin group."
        echo "Please do not e-mail them for support on this plugin, since"
        echo "they won't know what you're talking about "
        echo ""
        echo "For contact info, read the plugin itself..."
}

check_insight-log()
{
        LOG_ARRAY=`snmpwalk -Os -c  $community -v 1 $hostname $INSIGHTLOG_STATARRAY`
        if [ $? -ne 0 ]
        then
                echo "SYSTEM WARNING - no SNMP response from server $hostname "
                exitstatus=$STATE_UNKNOWN
                exit $exitstatus

        fi
                                INFOC=`echo -e $LOG_ARRAY | cut -d ":" -f 2 | grep $INFO | wc -l`
                                REPAIRC=`echo -e $LOG_ARRAY | cut -d ":" -f 2 | grep $REPAIR | wc -l`
                                CAUTIONC=`echo -e $LOG_ARRAY | cut -d ":" -f 2 | grep $CAUTION | wc -l`
                                CRITICALC=`echo -e $LOG_ARRAY | cut -d ":" -f 2 | grep $CRITICAL | wc -l`
                                UNKNOWNC=`echo -e $LOG_ARRAY | cut -d ":" -f 2 | grep -Ev "$INFO|$REPAIR|$CAUTION|$CRITICAL" | wc -l`

        if [ $CRITICALC -ne 0 ] || [ $CAUTIONC -ne 0 ] 
                                then
                exitstatus=$STATE_CRITICAL
        fi

        # Get Log entries
        LOGTXT=`snmpwalk -Os -c  $community -v 1 $hostname $INSIGHTLOG_ARRAY`
}

## Main
while getopts ":C:H:d:v" options;
do
        case $options in
                v ) echo "Version $VERSION"
                        exit 1;;
                C ) community="$OPTARG";;
                H ) hostname="$OPTARG";;
                d ) debug=1;;
                ? ) print_help
                        exit 1;;

        esac
done

# Debugging
if [ $debug -eq 1 ]
then
  echo "Debug: community: $community";
  echo "Debug: hostname: $hostname";
fi

# Error Checking
if [ "$community" == "" ] || [ "$hostname" == "" ]
then
        print_help
  exit 1
fi

# Check routine
check_insight-log

# Output if all okay
echo "Status: Critical:$CRITICALC Caution:$CAUTIONC Unknown:$UNKNOWNC Info:$INFOC Repaired:$REPAIRC"
echo $LOGTXT
exit $exitstatus

