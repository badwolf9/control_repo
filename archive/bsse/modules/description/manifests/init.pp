# WIKI START Recipe Systemconfig::description
## OS :: Redhat;Ubuntu;Solaris
######################################
#
# h3. Host+Servicegroups affected
#
# * *all* hosts
#
# h3. Services affected
# * *description* installed
#
# h3. Files / directories / links affected
# * CREATE : /etc/description
#
# h3. What happens
#
#	* description file is installed with minimal text.
#
###########
# WIKI STOP

class description
{
   case $kernel {
	"Linux": {
		file { "/etc/description":
			owner => "root",
                        group => "root",
                        mode  => "0640",
                        content => epp("description/description.epp" , { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'], 'is_virtual' => $is_virtual, }),
                        replace => false,
                        alias => description,
                        backup => main,
		}
	}
	"SunOS": {
		file { "/etc/description":
			owner => "root",
                        group => "root",
                        mode  => "0640",
                        content => epp("description/description.epp" , { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'], 'is_virtual' => $is_virtual, }),
                        replace => false,
                        alias => description,
                        backup => main,
		}
	}
	"Darwin": {
	}
	default: {
		notice("$kernel OS not supported for recipe sudoers")
  	}
   }
}

