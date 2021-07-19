##
##      Currently valid puppet groups are:
##              =>      Recipe Systemconfig
##              =>      Recipe Daemons
##              =>      Recipe Network
##              =>      Recipe Filesystems
##              =>      Recipe Other
##
# WIKI START Recipe Network::tcpd
## OS :: Redhat;Ubuntu; #Solaris; #MacOS X
######################################
#
# h3. Host / Service groups affected
#
# * *all*
#
# h3. Services affected
# * *tcpd* configured
#
# h3. Files / directories / links affected
# * CREATE : /etc/hosts.allow
# * CREATE : /etc/hosts.deny
#
# h3. What happens
#
#	The config files for tcpd are installed, tcpd does not need to run actively
#
###########
# WIKI STOP

class tcpd
{
   case $kernel 
   {
	'Linux':
	{
		if 'hw_dell' in $my_classes {
                  $isadell = true
                  }else{
                  $isadell = false
                  }
                 if $my_debugflag == 'yes' {notify { " Dell is $isadell" : }}

		if 'ou_groups_hierlemann' in $my_classes {
                  $isahima = true
                  }else{
                  $isahima = false
                  }
		if 'service_nfsserver' in $my_classes {
                  $isanfssrv = true
                  }else{
                  $isanfssrv = false
                  }

	        file { '/etc/hosts.allow':
			owner => 'root',
			group => 'root',
			mode  => '0755',
#			content  => template("tcpd/hosts.allow.erb"),
			content => epp('tcpd/hosts.allow.epp', { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'], }),
			replace => true,
			backup => main,
		}
	        file { '/etc/hosts.deny':
			owner => 'root',
			group => 'root',
			mode  => '0755',
#			content  => template("tcpd/hosts.deny.erb"),
			content => epp('tcpd/hosts.deny.epp', { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'], }),
			replace => true,
			backup => main,
		}
        }
   }
}

