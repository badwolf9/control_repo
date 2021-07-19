##
##      Currently valid puppet groups are:
##              =>      Recipe Systemconfig
##              =>      Recipe Daemons
##              =>      Recipe Network
##              =>      Recipe Filesystems
##              =>      Recipe Other
##
# WIKI START Recipe Systemconfig::profile
## OS :: Redhat 5;RedHat 6;Ubuntu 10;Fedora 13; Solaris; !MacOS X
######################################
#
# h3. Host+Servicegroups affected
#
# * os-linux
#
# h3. Services affected
#  
# * none
#
# h3. Files / directories / links affected
# * CREATE : _/0815 /abcd /tmp/XYZ_
# * CREATE : _/usr/local/<GROUPS>_
# * DEPLOY : _/usr/lib64/nagios/plugins/check_0815_bsse_
# * CREATE OR DELETE : _/nas-bsse_
#
# h3. Files / directories / links affected
# * CREATE : _/etc/motd.sh_
# * CREATE : _/etc/motd_
# * REPLACE : _/etc/profile_
# * REPLACE : _/etc/bashrc_
# * REPLACE : _/etc/inputrc_
#
# h3. What happens
#
# * Dump a default /etc/profile which changes LS_COLOR and enables vim as default EDITOR and as vi alias
# * Create the script /etc/motd.sh with the information that the host is puppetized and some additional information (last puppet run).
#
###########
# WIKI STOP

class profile {

  case $::kernel {
    /Darwin/: {
	file { "/etc/profile":
		ensure => present,
		path => "/etc/profile",
		source => "puppet:///modules/profile/profile",
		backup => main,
	}

    }
    /Linux|SunOS/:
    {
	#	Define http_proxy for device controllers
	if(tagged('ou-service-device-controller'))
	{
		$profile_source = 'puppet:///modules/profile/profile.devctl'
	} else {
		if($::operatingsystem =~ /RedHat|CentOS/){
			if($::lsbmajdistrelease > '5'){
				$profile_source = 'puppet:///modules/profile/profile.el6.erb',
			} else {
				$profile_source = $::hostname ? { /(bs-smsvr0?)/ => 'puppet:///modules/profile/profile.sc',
					        /(bs-headnode0?)/ => 'puppet:///modules/profile/profile.hpc',
                  		 default => 'puppet:///modules/profile/profile.erb',
				}
			}
		} else {
			# Debian / Fedora / Solaris
			$profile_source = 'puppet:///modules/profile/profile.erb',
		}
	}
	#	notice("$::hostname is using profile from : $profile_source")
	
	# motd.sh on Linux only.
	if($::kernel =~ /Linux/){
		file { '/etc/motd.sh':
			ensure => present,
			path => $::operatingsystem ? {
				default => '/etc/motd.sh',
			},
			owner => 'root',
			group => 'root',
			mode => '0555',
			source => 'puppet:///modules/profile/motd.sh',
			backup => main,
		}
		
		if($::operatingsystem =~ /RedHat|CentOS/){
			file { "/etc/sysconfig":
    				ensure => "directory",
			}
			file { "/etc/sysconfig/i18n":
				ensure => present,
				path => "/etc/sysconfig/i18n",
				owner => "root",
				group => "root",
				mode => '0644',
				content => template("$::puppetfiles/$::operatingsystem/etc/sysconfig/i18n.erb"),
				backup => main,
			}
		}
	}

	file { "/etc/profile":
		ensure => present,
		path => $::operatingsystem ?{
			default => "/etc/profile",
		},
		content => template($profile_source),
		backup => main,
	}


	$bashrcpath = $::operatingsystem ? {
			'Ubuntu' =>  "$::puppetfiles/$::operatingsystem/etc/bash.bashrc",
			'Ubuntu' =>  "$::puppetfiles/$::operatingsystem/etc/bashrc",
			'Debian' =>  "$::puppetfiles/$::operatingsystem/etc/bash.bashrc",
			'Solaris' => "$::puppetfiles/$::operatingsystem/etc/bash/bashrc",
			'OpenIndiana' => "$::puppetfiles/$::operatingsystem/etc/bash/bashrc",
			default   => "$::puppetfiles/$::operatingsystem/etc/bashrc",
		}

        file { "/etc/bashrc":
                ensure => present,
                path => $::operatingsystem ?{
                        'Ubuntu'  => "/etc/bash.bashrc",
                        'Debian'  => "/etc/bash.bashrc",
                        'Solaris' => "/etc/bash/bashrc",
                        'OpenIndiana' => "/etc/bash/bashrc",
			 default  => "/etc/bashrc",
			},
                content => template($bashrcpath),
                backup => main,
	}
	
	$inputrcpath = "$::puppetfiles/$::operatingsystem/etc/inputrc"
	case $::operatingsystem {
		'Solaris': { }
		'OpenIndiana': { }
		default: {
	        	file { "/etc/inputrc":
	                ensure => present,
        	        path => "/etc/inputrc",
        	        content => template($inputrcpath),
	                backup => main,
			}	
		}
	}
     }
     default:
     {
	#	notice("$::kernel OS not supported for profile")
     }
  }
}
