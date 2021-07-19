#!/bin/bash
#
# WIKI START Script group Networking::registerHost.sh
## OS :: Redhat 5;RedHat 6;#Ubuntu;#Debian;#Solaris; #MacOS X
######################################
#
# h3. Deployment
#
# * This file is deployed via puppet into */root/bin*
#
# h3. Function
#
# * test if /usr/local/itsc is available
# * register an IP address + hostname
#
# h3. Runs on
#
# * any python enabled host
#
# h3. Prerequisites
#
# * [SANS|http://sans.ethz.ch/] tools in /usr/local/itsc
# * python 2.6
#
# h3. Parameters
#
# * *Usage : $0 <fqdn> <subnet> <komcenter username>*
# * <fqdn>   - full qualified domain name for the host
# * <subnet> - subnet in which we search for a free IP (i.e. 129.132.27.0)
# * <user>   - your uid which will be used to connect to the komcenter
#
# h3. What happens
#
# * activateBSSE with group itsc (which will enable the itsc repo including the SANS tools)
# * run ipctl with the given parameters
#
###########
# WIKI STOP


if [ -z "$3" ]; then
	echo "Usage : $0 <fqdn> <subnet> <komcenter username>"
	exit 1
fi

if [ ! "`echo $1 | sed 's/.*\..*\..*/ABC/'`" == "ABC" ]; then
	echo "FATAL : $1 is not an FQDN"
	exit 1
fi

if [ ! "`echo $2 | sed 's/[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*/ABC/'`" == "ABC" ]; then
	echo "FATAL : $2 is not an IP/Subnet"
	exit 1
fi

HOST=$1
NET=$2
USER=$3

#. /usr/local/bsse/activateBSSE.env itsc
module load repo/itsc
module load sans/tools

IPCTL=`which ipctl`

if [ -z "$IPCTL" ]; then
	echo -e "ERROR : Could not find ipctl.\nPlease check if autofs is running and you have enough permissions to access the SANS scripts folder."
	exit 1
fi

echo -e "ip add $NET $HOST reverse:y\nquit\n" | ipctl -u $3 -i

#| ipctl -u mokai -i

