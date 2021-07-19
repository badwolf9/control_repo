##
##      Currently valid puppet groups are:
##              =>      Recipe Systemconfig
##              =>      Recipe Daemons
##              =>      Recipe Network
##              =>      Recipe Filesystems
##              =>      Recipe Other
##
# WIKI START Recipe Systemconfig::limitsconf
## OS :: Redhat ;Ubuntu;Fedora; !Solaris; !MacOS X
######################################
#
# h3. Host+Servicegroups affected
#
# * *os-linux*
#
# h3. Services affected
# * none
#
# h3. Files / directories / links affected
# * DEPLOY : _/etc/security/limits.conf_
#
# h3. What happens
#
# * Increases the limit of open files on Linux systems_
#
###########
# WIKI STOP

class limitsconf {

case $::kernel {
	'Linux': {

		file { "/etc/security/limits.conf":
			content => file('limitsconf/limits.conf'),
		}

	}	
	default: {
		#
		# warn in the puppet log
		#
		notice("$kernel OS not supported for recipe limitsconf")
  		}
 	}


}

