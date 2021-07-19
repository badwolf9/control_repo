# WIKI START Recipe Daemons::ntp
## OS :: Redhat; Ubuntu ; Solaris; #MacOS X
######################################
#
# h3. Host+Servicegroups affected
#
# * *all* hosts
#
# h3. Services affected
# * *ntp* or *chrony* installed, enabled and started
#
# h3. Files / directories / links affected
# * CREATE : /etc/ntp.conf /etc/chrony.conf
# * INSTALL : ntpd or chrony
#
# h3. What happens
#
#	* ntp or chrony is installed and configured
#	* ntp or chrony is then started
#
###########
# WIKI STOP

class ntpd
{
    case $kernel {
	'Linux': {
         case $facts['os']['name'] {
            /RedHat|CentOS|Fedora/ : {
			if $my_debugflag == 'yes' { notify { 'It is a RH derivative!' : }}
                package {   chrony: ensure => installed, }
	    	    file { '/etc/chrony.conf':
                    owner => 'root',
                    group => 'root',
                    mode  => '644',
                    content => epp('ntpd/chrony.conf.epp', { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'], 'ipaddress' => $facts['ipaddress'], }),
                    replace => true,
                    alias => chronydconf,
                    backup => main,
		        }
			$chronydoptiosfile='puppet:///modules/ntpd/chronyd'
			file { '/etc/sysconfig/chronyd':
				owner => 'root',
        	       	        group => 'root',
        	       	        mode  => '0644',
        	       	        source => $chronydoptiosfile,
        	       	        replace => true,
        	       	        alias => chronydoptions,
        	       	        backup => main,
			}
			    service { 'ntpd':
			    	ensure => stopped,
			    	enable => false,
		        }
			service { 'chronyd':
				ensure => running,
				enable => true,
				subscribe  => File[[chronydconf],[chronydoptions]],
				}
            }

            /Ubuntu|Debian/ :{
	    if $my_debugflag == 'yes' { notify { 'It is an Ubuntu derivative!' : }}
               if $::hostname =~ /bs-jpk/ {
               # don't try to install chrony
                 package {   'ntp': ensure => installed, }
	    	    file { '/etc/ntp.conf':
                    owner => 'root',
                    group => 'root',
                    mode  => '644',
                    content => epp('ntpd/ntp.conf.epp', { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'], 'ipaddress' => $facts['ipaddress'], }),
                    replace => true,
                    alias => ntpdconf,
                    backup => main,
		        }
			    $ntpdoptiosfile='puppet:///modules/ntpd/ntpd'
                file { '/etc/default/ntp':
                    owner => 'root',
                    group => 'root',
                    mode  => '0644',
                    source => $ntpdoptiosfile,
                    replace => true,
                    alias => ntpdoptions,
                    backup => main,
                }
			    service { 'ntp':
			    	ensure => running,
			    	enable => true,
			    	subscribe  => File[[ntpdconf],[ntpdoptions]],
		        }
               }else{
                # Install chrony and configure
                package {   chrony: ensure => installed, }
    	        file { '/etc/chrony/chrony.conf':
                    owner => 'root',
                    group => 'root',
                    mode  => '644',
                    content => epp('ntpd/chrony.conf.epp', { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'], 'ipaddress' => $facts['ipaddress'], }),
                    replace => true,
                    alias => chronydconf,
                    backup => main,
	        }
	    $chronydoptiosfile='puppet:///modules/ntpd/chronyd'
	    file { '/etc/default/chronyd':
		owner => 'root',
    	                group => 'root',
    	                mode  => '0644',
    	                source => $chronydoptiosfile,
    	                replace => true,
    	                alias => chronydoptions,
    	                backup => main,
	    }
	        service { 'ntp':
	    	ensure => stopped,
	    	enable => false,
	        }
	    service { 'chrony':
		ensure => running,
		enable => true,
		subscribe  => File[[chronydconf],[chronydoptions]],
		        }
              }
            }
		    default	: {}
		    # end os family
		}
     	}
	'SunOS': {
		file { '/etc/inet/ntp.conf':
			owner => 'root',
                        group => 'root',
                        mode  => '0644',
                        source => 'puppet:///modules/ntpd/ntp.sunos',
                        replace => true,
                        alias => ntpdconf,
                        backup => main,
		}
	#	if($operatingsystem == Solaris) {
		service { 'ntp':
			ensure => running,
			enable => true,
			subscribe => [ File[ntpdconf] ]
		}
	#	}
		file {  '/var/lib/ntp':	ensure => directory;
		}
	}
	'Darwin': {
	}
	default: {
		notice("${kernel} OS not supported for recipe ntp")
  	}
   }
}

