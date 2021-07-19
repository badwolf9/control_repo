#!/bin/bash

# migrate a host from P3 client to puppetlabs P4
#0. Is a proxy set and/or can the puppetlabs server be reached?
CAN_PING=`wget -T 2 -t 2 -O - apt.puppetlabs.com/README.txt| grep -c "Puppet Labs Repositories"`
if ! [[ $CAN_PING == 1 ]]
then
# no response, set proxy?
CHECK_PROXY=$HTTP_PROXY
  if ! [[ $CHECK_PROXY =~ "proxy.ethz.ch:3128" ]]
  then
    export HTTP_PROXY=http://proxy.ethz.ch:3128
  fi
fi
# check if can reach outside world
#
#ping -c 1 apt.puppetlabs.com
CAN_PING=`wget -T 2 -t 2 -O - apt.puppetlabs.com/README.txt| grep -c "Puppet Labs Repositories"`
if ! [[ $CAN_PING == 1 ]]
then
 echo "Network (apt.puppetlabs.com) not reachable, exiting ......."
 exit 2
 fi
#
# Network is up/working to outside world so keep on going
# 1. test if P4 agent installed
PUPPVER=`puppet --version`
echo "Puppet version is $PUPPVER"
if ! [[ ${PUPPVER} =~ ^(4.*) ]]
 then
 # Puppet agent v4 is not installed"
 # 2. Get the release of the OS
 FACTVER=`facter --version`
 if ! [[ ${FACTVER} =~ ^(3.*) ]]
  then
  
  OSVER=`facter lsbdistrelease`
  OSREL=`facter lsbdistcodename`
  else
  OSVER=`facter os.release.full`
  OSREL=`facter os.distro.codename`
  fi


# ==============================================================
#####
##### Here is where must now distinguish between RHEL and Ubuntu
#####  
# ===============================================================
OS_FAMILY=`facter osfamily`
# will be either RedHat or Debian
#
if [[ $OS_FAMILY == 'RedHat' ]]
then
## RHEL/CentOS/Fedora specific
# test if P3 agent installed
rpm -qa|grep "puppet "
P3STATUS=$?
if  [[ $P3STATUS = 0 ]]
then
 echo "puppet agent v3 is still installed"
 # stop P3 puppet service
 service puppet stop
 # remove puppet v3
 yum -y remove puppet hiera
 rm /usr/bin/hiera
fi
OSMAJVER=`facter lsbmajdistrelease`
echo "OS MAJ VER is $OSMAJVER"
 # Install the puppetlabs repository and then install puppet agent
rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-${OSMAJVER}.noarch.rpm
yum -y install puppet-agent
NRPE_SRV="nrpe"
#end RHEL section
else 
#begin Ubuntu section

 # test if P3 agent installed
 P3STATUS=`dpkg -l|grep "puppet "|cut -c 1-2`
 echo "P3 package status is $P3STATUS"
 if ! [ $P3STATUS == "rc" ]
 then
 echo "puppet agent v3 is still installed"
 # stop P3 puppet service
 service puppet stop
 # remove puppet v3
 apt-get -y remove puppet hiera ruby-hiera
# apt-get -y remove hiera
 rm /usr/bin/hiera
 fi 
# #######
 # Install the puppetlabs repository and then install puppet agent
wget https://apt.puppetlabs.com/puppetlabs-release-pc1-${OSREL}.deb -O /tmp/puppetlabs.deb
 dpkg -i /tmp/puppetlabs.deb
 apt-get update
export DEBIAN_FRONTEND=noninteractive
apt-get -o Dpkg::Options::="--force-confnew" -y install puppet-agent
NRPE_SRV="nagios-nrpe-server"
fi

#end Debian section
fi
# ============================================
#######
####### From here on is common ground again
#######
# ============================================
# 3. Turn off ssh agent forwarding as this causes problems
TESTSSH=`ssh-add -L 2>/dev/null`
NOIDENT="The agent has no identities."
if [ "$TESTSSH" == "$NOIDENT" ]
then
echo "Agent forwarding swtiched off"
else
echo "Agent forwarding is switched on!!!!"
echo "Turning it off:"
ssh-add -D
echo "And after deleting all identities:"
ssh-add -L 2>/dev/null
fi

if [ -d /var/lib/ssl ]
then
echo "Removing puppet ssl folder"
rm -rf /var/lib/puppet/ssl
fi
if [ -d /etc/puppetlabs/puppet/ssl ]
then
echo "Removing puppetlabs ssl folder"
rm -rf /etc/puppetlabs/puppet/ssl
fi
if ! [ -d /etc/puppet/bin ]
then
echo "Creating puppet bin folder"
mkdir -p /etc/puppet/bin
fi

if ! [ -h /usr/bin/puppet ]
then
ln -s /opt/puppetlabs/puppet/bin/puppet /usr/bin/puppet
ln -s /opt/puppetlabs/puppet/bin/hiera /usr/bin/hiera
ln -s /opt/puppetlabs/puppet/bin/facter /usr/bin/facter
ln -s /opt/puppetlabs/puppet/bin/mco /usr/bin/mco
fi

if ! [ -d /etc/puppetlabs/puppet ]
then
echo "Puppet Labs system not installed, aborting"
exit 3
fi

# generate correct puppet.conf file
cat > /etc/puppetlabs/puppet/puppet.conf <<EOF
[main]
server = bs-puppet.ethz.ch
runtinterval = 1h
[agent]
environment = production
stringify_facts = false
EOF

#sign certificate
# Key starts below
# vvvvvvvvvvvvv
## STARTKEY
# first get the puppet key
cat > /root/puppet.key <<EOF
-----BEGIN RSA PRIVATE KEY-----
MIIDewIBAAKBwQDGtKjFsJhIaN29hVyi9s37Y3Wf+Se30yUfnq3+DNZpA/ADA3en
gpjvPg2ihTd3iRhWLMRSLJIcafPyPWzh7gPwrS9nhgvInLxuUiOfjE9PrweBvDQh
ZzKWrbHMufyr+xyJsssrif3zYxY2ezI1W5KFJqL5T1uARlTw1S+jL4aGba7DhBYd
1Bb0vl8FzeWn8nB89fHAhpZWC471qCOEqG5rMsHexZMJihHoolLly6y7zK+0DsV1
EOclGRxXVzrUukkCASMCgcEAgpP54P8E/GIrUKgYTdViycUEJ0v1h21+y6LKG/nO
ugnm3WittziQYrO/0TL4kGFnw5nC1uoW33jTge3Z1kvz9e4mdzrUiyUrXnB9zz7y
Sk5ypbYw4sAojucrsmuXabOj4VTunVu5itIHkaYQKAsLBbDQP5+lJca2vEzDy2iH
bCWgaiDzBLmVGtRLNAObIdie4fvz01ikkLz04myFfDASS9mKLBUwuGpI1d7GK3d5
fxhNEJeqq/M3UEmapZb2kkmLAmEA63DOLAPKnV8gqQqKuvnNpSu4MDy+z5KyFLtR
nRrbmhz2SHs+ftpY6WrNJ2MismMxkgywuYbWrkNucPazSnVlMErtN0AZRdT4C594
zzv1nYqe2h9msw3OWojFIocJeNQJAmEA2A6oJlOpr0nqCNgfln18cyWBXR+sgli5
TkDgmOTn+dSuHFEjBxb8iXSwH/X4R56mLtknCCrxwGXNQmVXL04Ox3tmkPXs15jt
zzVpvifRteVvDplEx3q5fOiuqCIeUMRBAmAa6FITqKlxEi+eSlj/bQGPODJOp9tK
7DGb+CaVnKtiEfBCzEGoGPQ37vLf7hKYC1YfUehPt6OBoU5zT2TykRLg8p7EfFqo
5SOpjpF2xQYgoiDIeJ4F1bEu6w83JWArEOsCYBKE6ddmQb6RTpMLNehT5hh/jr7W
1EWv1V56luiIpitbX2GDTCUt2yG5i3B0KzlWvcmAU82ABhfONipDM1vTfZwR5DhP
l/U4/nDYsUrQNovvGCXSn37QAUU4g//IaP+bywJhAMNlUbRRCQwBlYGt+RLz8f4j
+M7CIH6FKu0ticUALN3vLDxvvkkN/Z61J9k42CZNt/ZdHzbJnyAH9Y+TvUDwZ2Ui
qxDJdVt7xLMjcKvrm7BSTcny7kR8dDoGLBfJkdYBBg==
-----END RSA PRIVATE KEY-----
EOF
## ENDKEY
# ^^^^^^^^^^^^^
# Key would finish above - removed for wiki entry!
chmod 0400 /root/puppet.key

# next revoke any certs on the puppet server
HNAME=`/opt/puppetlabs/puppet/bin/facter fqdn`
echo "Revoking keys for host ${HNAME}"

ssh -i /root/puppet.key -o ConnectTimeout=10 -o BatchMode=yes -o StrictHostKeyChecking=no bs-puppet.ethz.ch /etc/puppet/bin/autoSign.sh "revoke" "${HNAME}"

sleep 10

echo "Run puppet agent to generate a CSR"
# run puppet agent on host to generate a CSR
/opt/puppetlabs/puppet/bin/puppet agent -t

# now sign the certificate on the puppet server
ssh -i /root/puppet.key -o ConnectTimeout=10 -o BatchMode=yes -o StrictHostKeyChecking=no bs-puppet.ethz.ch /etc/puppet/bin/autoSign.sh "${HNAME}"

sleep 10
#run puppet agent again x 2P
echo "Run puppet again..."
/opt/puppetlabs/puppet/bin/puppet agent -t
echo "and again..."
/opt/puppetlabs/puppet/bin/puppet agent -t

# remove the puppet key from the host
echo "Remove puppet key"
rm /root/puppet.key

# fix nagios monitoring
# kill nagios process
PNRPE="/usr/sbin/nrpe -c /etc/nagios/nrpe.cfg -d"
pkill "$PNRPE"

echo "Stop nrpe.."
service $NRPE_SRV stop
# run puppet, should restart the nagios service
/opt/puppetlabs/puppet/bin/puppet agent -t

echo "Start nrpe.."
service $NRPE_SRV start
# see if can get rid of the old hiera file
if ! [ -L /usr/bin/hiera ]; then
 # not a symbolic link, is then an older version
 rm -f /usr/bin/hiera
 ln -s /opt/puppetlabs/puppet/bin/hiera /usr/bin/hiera
fi
# alles klar?