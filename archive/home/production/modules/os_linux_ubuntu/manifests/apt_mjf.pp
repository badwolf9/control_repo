class os_linux_ubuntu::apt_mjf
 {
#$my_debugflag = 'yes'
 if $facts['os']['family'] =~ /Debian/ {
    if $my_debugflag == 'yes' {   notify { 'apt stuff for Ubuntu/Debian' : }}
         if $my_debugflag == 'yes' {notify { 'Version 18.04 or later' : }}
         if $facts[hostname] =~ /mf-mm01/ {
         if $my_debugflag == 'yes' {notify { 'Servers with MySQL installed should not try to install mariadb' : }}
         $mjf_ub=lookup('mjf_ub_core_packages') - ('mariadb-client')
         } else {
         $mjf_ub=lookup('mjf_ub_core_packages')
         }
	#combine into a global package parameter
	Package { ensure => 'installed' }
        package { $mjf_ub: }
  }
}
