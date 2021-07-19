##
##      Currently valid puppet groups are:
##              =>      Recipe Systemconfig
##              =>      Recipe Daemons
##              =>      Recipe Network
##              =>      Recipe Filesystems
##              =>      Recipe Other
##
# WIKI START Recipe Daemons::syslog
## OS :: Redhat;Ubuntu;!Solaris; !MacOS X
######################################
#
# h3. Host / Service groups affected
#
# * *os-linux-service-syslogd*
#
# h3. Services affected
# * sylogd
#
# h3. Files / directories / links affected
# * DEPLOY : _/etc/syslog.conf_
#
# h3. What happens
#
# * Deploy the syslogd on Unix systems
#
###########
# WIKI STOP

#

class syslog {

  case $::operatingsystem {
	/RedHat|CentOS/: {
			$packagename="syslog"
			$servicename="syslog"
			$syslog_srvrs = lookup('syslog_servers')
		if !tagged("service-syslogd") {
			package { "syslogd":
				ensure => installed,
				name => $operatingsystem ? {
				default => $packagename
				}		
			}
	
			file { "/etc/syslog.conf":
				require   => Package["syslogd"],
#				content => template("syslog/syslog.conf.erb"),
				content => epp('syslog/syslog.conf.epp', { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'], }),
				alias => syslog_conf,
			}
#			file { "/etc/logrotate.d/syslog":
#				ensure => present,
#				owner => "root",
#		                group => "root",
#	        	        mode  => '0640',
#	               	 	source  => "puppet:///modules/syslog/syslog",
#			}
			service { $servicename:
				enable    => "true",
				ensure    => "running",
				pattern   => $servicename,
				require => File[syslog_conf],
				subscribe => File[syslog_conf],
			}			
		}
	}	
	/Ubuntu|Debian/: {
			$packagename="syslog"
			$servicename="syslog"
			# leave config set to defaults
			  package { "syslog":
				ensure => installed,
         			}
			  service { $servicename:
				enable    => "true",
				ensure    => "running",
				pattern   => $servicename,
			        }
	}
	'Solaris': {
			file { "/etc/syslog.conf":
				owner => "root",
				group => "sys",
				mode  => '0644',
				content => file('syslog/syslog.conf'),
				alias => syslog_conf,
			}
			file { "/var/log/messages":
				owner => "root",
				group => "sys",
				mode  => '0644',
				ensure => file;
			}
	}
	default: {
		#
		# warn in the puppet log
		#
		notice("$operatingsystem not supported for recipe syslogd")
  		}
 	}
}

