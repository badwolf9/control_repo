# WIKI START Recipe Daemons::cron
## OS :: !RedHat;!Ubuntu;Solaris; #MacOS X
######################################
#
# h3. Host+Servicegroups affected
#
# * *Solaris* hosts
#
# h3. Services affected
# * *default/cron* installed
#
# h3. Files / directories / links affected
# * CREATE : /etc/default/cron
#
# h3. What happens
#
#	* default cron file is installed on Solaris systems
#
###########
# WIKI STOP

class cron
{
   case $facts['kernel'] {
	"SunOS": {
		file { "/etc/default/cron":
			owner => "root",
                        group => "sys",
                        mode  => '0644',
                        source => "puppet:///modules/cron/cron",
                        replace => true,
                        alias => cron,
                        backup => main,
		}
	}
	"Linux": {
	}
	"Darwin": {
	}
	default: {
		notice("$kernel OS not supported for recipe cron")
  	}
   }
}

