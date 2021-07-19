class profile (
  $profile_path        = $profile::params::profile_path,
  $profile_source      = $profile::params::profile_source,
  $motd_source         = $profile::params::motd_source,
  $motd_path           = $profile::params::motd_path,
  $motd_mode           = $profile::params::motd_mode,
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
 }
}