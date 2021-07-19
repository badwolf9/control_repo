#!/bin/bash
# Author:       dirk.doerflinger@bsse.ethz.ch
# Date:         Project started on 20.08.2013
#
#
# WIKI START Unixlike Servers::JPK special setup
##OS::Linux;!Solaris;!Mac OS X;!Windows
##############################
#{toc}
#h3. What's it for
# The JPK machines are Ubuntu machines controlling microscopes in the mueller group. After a lot of problems with LDAP users and NFS we decided to create local users (jpk<ldapusername>) instead and ask users to use smb:// to connect to the BSS fileservers.
#h3. What it does
# This script reads a list of all users in the mueller group (from puppet). Then it creates local users with the same name (preceding jpk) and their home in /local0/jpkdata/. Users are also added to the local groups bssejpk and video. Main group ist bsse-spm, which is a legacy group, having existed in AD already.  
#h3. Dependencies
# /usr/local/itsc/scripts/tools/misc/createJPKUserlist.sh is run as a daily cronjonb on bs-admin01, creating the file jpkusers.list in /usr/local/itsc/ubuntu/root/
# /etc/puppet/bin/autorebuild.sh copies that file to bs-puppet://etc/puppetlabs/....pam/files
# Puppet distributes that file to the JPK servers. See the PAM module in puppet
#h2. Caveats
# Both the TEMPFILE (removed after user creation) and the PASSWORDFILE (in /root) contain plaintext passwords.
# WIKI STOP

USERS=`cat /root/jpkusers.list`
TEMPFILE=/tmp/newusers.create
PASSWORDFILE="/tmp/users.`date +"%Y%m%d%H%M"`"

rm -f $TEMPFILE
rm -f $PASSWORDFILE
echo `hostname` > $PASSWORDFILE

for user in $USERS; do
# check if user is already there
    USEREXISTS=`grep jpk$user /etc/passwd`
    if [ -n "$USEREXISTS" ]; then
	echo "User jpk$user exists, leaving alone!"
	echo "  User jpk$user exists, leaving alone!" >> $PASSWORDFILE
    else
	echo "User jpk$user doesn't exist, creating"
	password="jpk$user$RANDOM"
	echo "jpk$user:$password::32594::/local0/jpkdata/jpk$user:/bin/bash" >> $TEMPFILE
	echo "jpk$user:$password" >> $PASSWORDFILE
    fi
done

#Run creation script
/usr/sbin/newusers $TEMPFILE
# remove users file
rm -f $TEMPFILE

for user in $USERS; do
    INGROUP=`grep jpk$user /etc/group|grep spmuser`
    if [ -z "$INGROUP" ]; then
	echo "# User jpk$user not in spmuser. Adding."
	sed -i "s/\(^spmuser.*\)/\1, jpk$user/" /etc/group
	sed -i "s/\(^spmuser.*\)/\1, jpk$user/" /etc/gshadow
    fi
    INVGROUP=`grep jpk$user /etc/group|grep video`
    if [ -z "$INVGROUP" ]; then
	echo "# User jpk$user not in group video. Adding."
	sed -i "s/\(^video.*\)/\1, jpk$user/" /etc/group
	sed -i "s/\(^video.*\)/\1, jpk$user/" /etc/gshadow
    fi
done

echo "DONE. Please get the created users and their passwords from $PASSWORDFILE and make sure that $PASSWORDFILE is deleted afterwards!"
