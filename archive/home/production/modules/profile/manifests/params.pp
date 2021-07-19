class profile::params {
 	$owner = 'root'
	$group = 'root'
	$mode  = '0644'
	$inputrc_src = 'puppet:///modules/profile/inputrc.ubu'
        $inputrc_path = '/etc/inputrc'
	$bashrc_src  = 'puppet:///modules/profile/bash.bashrc'
	$bashrc_path = '/etc/bashrc'
	$profile_source = 'profile/profile.ubu.erb'
	$profile_path = '/etc/profile'
	$motd_source = 'puppet:///modules/profile/motd.sh'
        $motd_path = '/etc/motd.sh'
        $motd_mode = '0555'
}

