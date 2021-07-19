# WIKI START Recipe Daemons::rsyslog
## OS :: !Redhat 5;RedHat;Ubuntu ;; !Solaris; !MacOS X
######################################
#
# h3. Host / Service groups affected
#
# * *service-rsyslogd*
#
# h3. Services affected
# * rsylogd
#
# h3. Files / directories / links affected
# * DEPLOY : _/etc/rsyslog.conf_
#
# h3. What happens
#
# * Deploy the rsyslogd on Unix systems
#
###########
# WIKI STOP

#

class rsyslog {

case $operatingsystem {
	/RedHat|CentOS|Ubuntu/: {
		$rsyslogconf="rsyslog.conf.erb"
		$rsyslog_srvrs=lookup('rsyslog_servers')
		$syslog_srvrs=lookup('syslog_servers')
		package { "rsyslog":
			ensure => installed,
		}
		file { "/etc/rsyslog.conf":
			require   => Package["rsyslog"],
			content => template("rsyslog/$rsyslogconf"),
			alias => rsyslog_conf,
		}
		service { "rsyslog":
			enable    => "true",
			ensure    => "running",
			pattern   => "rsyslog",
			require => File[rsyslog_conf],
			subscribe => File[rsyslog_conf],
		}			
	}	
	default: {
		#
		# warn in the puppet log
		#
		notice("$operatingsystem not supported for recipe rsyslogd")
  		}
 	}


}

