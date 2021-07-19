# Services affected
#  *ntp* or *chrony* installed, enabled and started
#
# Files / directories / links affected
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
              /Archlinux/ :{
 if $my_debugflag == 'yes' { notify { 'It is an Archlinux box!' : }}
  package {'chrony':
    ensure => present,
  }
  file {'/etc/chrony.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/ntpd/chronyarch.conf',
    require => Package['chrony'],
    notify  => Service['chronyd'],
  }
  service {'chronyd':
    ensure => running,
    enable => true,
  }
              }
	    default	: {}
	    # end os family
        }
     }
	'Darwin': {
	}
	default: {
		notice("${kernel} OS not supported for recipe ntp")
  	}
   }
}

