##
##      Currently valid puppet groups are:
##              =>      Recipe group Systemconfig
##              =>      Recipe group Daemons
##              =>      Recipe group Network
##              =>      Recipe group Filesystems
##              =>      Recipe group Other
##
# WIKI START Recipe group Daemons::recipe cups
## OS :: Redhat 5;RedHat 6;Ubuntu;Debian;Fedora 13; #Solaris; #MacOS X
######################################
#
# h3. Host / Service groups affected
#
# * *all linux systems in group service-net-cups
#
# h3. Services affected
# * *cups* configured
#
# h3. Files / directories / links affected
# * CREATE : /etc/cups/printers.conf
#
# h3. What happens
#
#       The config files for cups is created
#
###########
# WIKI STOP

#
####
##### Test for tagged must be a class, if folder not present will fail, if package cups not present will fail  20170725 on vagrant client
####  No: Gets the printers.conf file from a folder files under /etc/puppetlabs/code/environments/production/modules/cups
####
#
class cups
{
        case $kernel {
                /Linux/: {
			if ( tagged('service_net_cups') ) {
				notify { 'Service net cups tagged check, if ok here goes cups set up' : }
                		package { 'cups':
                			ensure => 'installed',
                			}
                		file { "/etc/cups/printers.conf":
                        	        ensure => present,
                        	        backup => main,
					owner => root,
					group => lp,
					mode => '640',
                        	        source => 'puppet:///modules/cups/printers.conf',
					alias   => cupsconf	
                  			}
				service { "cups":
					ensure => running,
                        		enable => true,
                        		subscribe  => File[cupsconf]
					}
			}
                }
	}	
}
