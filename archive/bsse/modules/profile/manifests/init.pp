##
##      Currently valid puppet groups are:
##              =>      Recipe Systemconfig
##              =>      Recipe Daemons
##              =>      Recipe Network
##              =>      Recipe Filesystems
##              =>      Recipe Other
##
# WIKI START Recipe Systemconfig::profile
## OS :: Redhat ;Ubuntu ;Fedora ; Solaris; !MacOS X
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
# h3. Files / directories / links affected (this needs looking at!! MJF)
# * CREATE : _/etc/motd.sh_
# * CREATE : _/etc/motd_
# * REPLACE : _/etc/profile_
# * REPLACE : _/etc/bashrc_
# * REPLACE : _/etc/inputrc_
# * REPLACE : _/etc/sysconfig/i18n_
#
# h3. What happens
#
# * Dump a default /etc/profile which changes LS_COLOR (not Solaris/OI) and enables vim as default EDITOR and as vi alias
# * Create the script /etc/motd.sh with the information that the host is puppetized and some additional information (last puppet run).
# * The parameters do not have type identifiers (eg STRING) because solaris and OI only define variables for inputrc, profile and bashrc
# * MJF tested 2017 10 13
###########
# WIKI STOP

class profile (
  $profile_path        = $profile::params::profile_path,
  $profile_source      = $profile::params::profile_source,
  $motd_source         = $profile::params::motd_source,
  $motd_path           = $profile::params::motd_path,
  $motd_mode           = $profile::params::motd_mode,
  $i18n_source         = $profile::params::i18n_source,
  $i18n_path           = $profile::params::i18n_path,
  $bashrc_path         = $profile::params::bashrc_path,
  $bashrc_src          = $profile::params::bashrc_src,
  $inputrc_src         = $profile::params::inputrc_src,
  $inputrc_path        = $profile::params::inputrc_path,
  $owner               = $profile::params::owner,
  $group               = $profile::params::group,
  $mode                = $profile::params::mode,
) inherits profile::params {
# profile
file { "${profile_path}":
		ensure => present,
		path => "${profile_path}",
		content => template("${profile_source}"),
		backup => main,
	}
#bashrc
   file { "${bashrc_path}":
                ensure => present,
                path => "${bashrc_path}",
                source => "${bashrc_src}",
                backup => main,
	}
# motd.sh, inputrc, and i18n on Linux only.
	if($::kernel =~ /Linux/){
		file { "${motd_path}":
			ensure => present,
			path => "${motd_path}",
			owner => $owner,
			group => $group,
			mode => "${motd_mode}",
			source => "${motd_source}",
			backup => main,
		}
#inputrc
		file { "${inputrc_path}":
	                ensure => present,
        	        path => "${inputrc_path}",
        	        source => "${inputrc_src}",
	                backup => main,
		}

# i18n 
	if($::operatingsystem =~ /RedHat|CentOS/){
			file { "/etc/sysconfig":
    				ensure => "directory",
			}
			file { "${i18n_path}":
				ensure => present,
				path => "${i18n_path}",
				owner => $owner,
				group => $group,
				mode => $mode,
				content => template("${i18n_source}"),
				backup => main,
			}
		}
	}
}
