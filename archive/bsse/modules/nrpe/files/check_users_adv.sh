#!/bin/bash

# Path to getent
GETENT="/usr/bin/getent"
W="/usr/bin/w"

PROGNAME=`basename $0`

#functions
function print_usage() {
  echo "Usage: $PROGNAME [ -e <string> ] [ -w <integer> ] [ -c <integer> ]"
  echo "e.g. $PROGNAME -w 200 -c 250 "
  echo ""
}

function print_help() {
  echo ""
  print_usage
  echo " -u : comma delimited list of users to exclude"
  echo " -g : comma delimited list of groups to exclude"
  echo ""
  echo " -w : Warning level for users logged on  (default: 1 user)"
  echo " -c : Critical level for users logged on (default: 2 users)"
  echo ""
  echo "This plugin checks how many different users are logged on."
  echo ""
  exit 0
}

function test_integer() {
  LABEL=$1
  VALUE=$2

  if ! echo $VALUE | grep -qE '^[0-9]+(\.[0-9]+)?$' ; then
     OUTPUT="$LABEL has no integer value ($VALUE)! Please correct this parameter"
     EXITCODE=3
  fi

}

#defaults
EXITCODE=0
WARNING=50 # Warning at 1
CRITICAL=100 # Critical at 2

if [ ! -x $GETENT ]; then
  OUTPUT="Please correct path to getent ($GETENT)"
  EXITCODE=3
else if [ ! -x $W ]; then
  OUTPUT="Please correct path to w ($W)"
  EXITCODE=3
fi fi

#get args
args=`getopt u:g:hw:c: $*`
set -- $args
for i
do
  case "$i" in
    -u) EXCLUDE_USERS=`echo "$2" | sed "s/,/ /"`;shift;shift;;
    -g) EXCLUDE_GROUPS=`echo "$2" | sed "s/,/\|/"`;shift;shift;;
    -c) CRITICAL=$2;shift;shift;;
    -w) WARNING=$2;shift;shift;;
    -h) print_help
  esac
done

test_integer "-c" $CRITICAL
test_integer "-w" $WARNING

if [ $EXITCODE -eq 0 ]; then
  LOGINS=`$W  -h | cut -f1 -d" " | sort | uniq`

  GROUP_USERS=`$GETENT group | awk -F:  "/^($EXCLUDE_GROUPS):/  {print \$3}"`
  GROUP_USERS=`echo $GROUP_USERS | awk -F: '{print $4}' | sed "s/,/ /g"`

  EXCLUDED_USERS=`echo $EXCLUDE_USERS" "$GROUP_USERS`

  for i in $EXCLUDED_USERS; do
    LOGINS=`echo $LOGINS | sed "s/$i//"`
  done

  COUNT=0

  for i in $LOGINS; do
    COUNT=$[ $COUNT+1 ]
  done

  if [ $COUNT -eq 1 ]; then
    USER_TXT="$COUNT user logged on: $LOGINS"
  else if [ $COUNT -gt 0 ]; then
    USER_TXT="$COUNT different users logged on: $LOGINS"
  else
    USER_TXT="no user logged on"
  fi fi

  if [ $COUNT -ge $CRITICAL ]; then
    OUTPUT="CRITICAL: $USER_TXT | users=$COUNT;$WARNING;$CRITICAL"
    EXITCODE=2
  else if [ $COUNT -ge $WARNING ]; then
    OUTPUT="WARNING: $USER_TXT | users=$COUNT;$WARNING;$CRITICAL"
    EXITCODE=1
  else
    OUTPUT="OK: $USER_TXT | users=$COUNT;$WARNING;$CRITICAL"
  fi fi
fi

echo $OUTPUT
exit $EXITCODE

