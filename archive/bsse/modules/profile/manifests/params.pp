class profile::params {
 	$owner = 'root'
	$group = 'root'
	$mode  = '0644'
 case $::operatingsystem {
   /RedHat|CentOS|Fedora/: {
        $inputrc_src = 'puppet:///modules/profile/inputrc'
        $inputrc_path = '/etc/inputrc'
	$bashrc_src  = 'puppet:///modules/profile/bashrc'
	$bashrc_path = '/etc/bashrc'
        $profile_path = '/etc/profile'
        $motd_source = 'puppet:///modules/profile/motd.sh'
        $motd_path = '/etc/motd.sh'
	$motd_mode = '0555'
        $i18n_source = 'profile/i18n.erb'
        $i18n_path = '/etc/sysconfig/i18n'
        $profile_source = $::hostname ? {
     		/(bs-smsvr0?)/    => 'profile/profile.sc.erb',
		/(bs-headnode0?)/ => 'profile/profile.hpc.erb',
        	default           => 'profile/profile.el.erb',
          }
   }
   /Ubuntu|Debian/: {
	 $inputrc_src = 'puppet:///modules/profile/inputrc.ubu'
         $inputrc_path = '/etc/inputrc'
	 $bashrc_src  = 'puppet:///modules/profile/bash.bashrc'
	 $bashrc_path = '/etc/bashrc'
	 $profile_source = 'profile/profile.ubu.erb'
	 $profile_path = '/etc/profile'
         $i18n_source = ''
         $i18n_path = ''
	 $motd_source = 'puppet:///modules/profile/motd.sh'
         $motd_path = '/etc/motd.sh'
         $motd_mode = '0555'
	 }
   'Solaris': { 
	 $bashrc_src  = 'puppet:///modules/profile/bashrc.solaris'
	 $bashrc_path = '/etc/bash/bashrc'
	 $profile_source = 'profile/profile.solaris.erb'
	 $profile_path = '/etc/profile'
      }
	'OpenIndiana': {
	 $bashrc_src  = 'puppet:///modules/profile/bashrc.solaris'
	 $bashrc_path = '/etc/bash/bashrc'
	 $profile_source = 'profile/profile.solaris.erb'
	 $profile_path = '/etc/profile'
      }
      
   default: {
     }
   }
}
