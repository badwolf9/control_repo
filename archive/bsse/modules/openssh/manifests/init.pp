# WIKI START Recipe Systemconfig::openssh
## OS :: Redhat ;Ubuntu;Fedora ; Solaris; MacOS X
######################################
#
# h3. Centreon Dependencies
##EXEC::EXEC_FIND_DEPENDENCIES ###FILEPATH###/###FILENAME###
#
# h3. Host+Servicegroups affected
#
# * *os-linux* hosts will be affected: openssh::server
# * *os-sunos* hosts will be affected: openssh::server
# * *all others* hosts will be affected: openssh::client
#
# h3. Services affected
# * none
#
# h3. Files / directories / links affected
# * DEPLOY : _/etc/ssh/ssh_known_hosts_
#
# h3. What happens
#
#       * collects the public ssh hostkey from server machines (openssh::server)
#       * deploys the ssh hostkeys in /etc/ssh/ssh_known_hosts (openssh::client and openssh::server)
#
###########
# WIKI STOP

class openssh::common {
	
	if ( $::operatingsystem != "Darwin" )
	{
		file { "/etc/ssh": 	ensure => directory,
					mode => "0755", owner => root, group => root,
		}
	}
}

class openssh::client inherits openssh::common {

	case $::kernel {
    	  "Linux": {
	        $known_hosts_file="/etc/ssh/ssh_known_hosts"
		file { $known_hosts_file: mode => "0644", owner => root, group => 0; }
		Sshkey <<||>>
	  }
    	  "SunOS": {
	        $known_hosts_file="/etc/ssh/ssh_known_hosts"
		file { $known_hosts_file: mode => "0644", owner => root, group => 0; }
		Sshkey <<||>>
	  }
	  "Darwin": {
                $known_hosts_file="/etc/ssh_known_hosts"
   	        file { $known_hosts_file: mode => "0644", owner => root, group => 0; }
		Sshkey <<||>>
	  }
          default: {
                notice("$::operatingsystem not supported for SSH")
          }

       }
}

class openssh::server inherits openssh::client {

	# Now add the key, if we've got one
	case $sshrsakey {
		"": { 
			err("no sshrsakey on $::fqdn")
		}
		default: {
			#@@sshkey { "$hostname.$domain": type => ssh-dss, key => $sshdsakey_key, ensure => present, }
			debug ( "Storing rsa key for $::hostname.$::domain" )
			@@sshkey { "$::hostname": type => ssh-rsa,
						key => $sshrsakey,
						ensure => present,
			}
		}
	}
}

define openssh::server::config($ensure) {
	replace {
		"sshd_config_$name":
			file => "/etc/ssh/sshd_config",
			pattern => "^$name +(?!\\Q$ensure\\E).*",
			replacement => "$name $ensure",
			notify => Service[sshd],
	}
}

