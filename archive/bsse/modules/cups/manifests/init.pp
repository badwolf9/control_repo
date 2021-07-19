##
##      Currently valid puppet groups are:
##              =>      Recipe Systemconfig
##              =>      Recipe Daemons
##              =>      Recipe Network
##              =>      Recipe Filesystems
##              =>      Recipe Other
##
# WIKI START Recipe Daemons::cups
## OS :: Redhat;Ubuntu;Debian;Fedora; #Solaris; #MacOS X
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
#       The config file for cups is created
#       Bug somewhere means that cups.conf is changed almost every puppet run.
#       Note: need to add in new printers by hand to the file printer.conf in the files directory
###########
# WIKI STOP

#
##### Test for tagged must be a class, if folder not present will fail, if package cups not present will fail  20170725 on vagrant client
#
class cups
{
        case $kernel {
                /Linux/: {
                            # my_classes is defined in site.pp
			if 'service_net_cups' in $my_classes {
			if $my_debugflag == 'yes' {notify { 'Service net cups tagged check, if ok here goes cups set up' : }}
#                         case $facts['os']['family'] {
#                              'Debian' : {
                		package { 'cups':
                			ensure => 'installed',
                			}
#                                       }
#                              default: {
#                		package { 'cups-client':
#                			ensure => 'installed',
#                			}
#                                        }
#                        }
                		file { "/etc/cups/printers.conf":
                        	        ensure => present,
                        	        #backup => main,
					owner => root,
					group => lp,
					mode => '0600',
                        	        content => file('cups/printers.conf'),
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
