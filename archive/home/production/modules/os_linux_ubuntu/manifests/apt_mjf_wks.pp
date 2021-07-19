class os_linux_ubuntu::apt_mjf_wks
 {
 if $facts['os']['family'] =~ /Debian/ {
#$my_debugflag = 'yes'
    if $my_debugflag == 'yes' {   notify { 'apt stuff for Ubuntu/Debian workstations' : }}
         if $my_debugflag == 'yes' {notify { 'Workstation is version 18.04 or later' : }}
         $mjf_ub_wks=lookup('mjf_ub_wks_packages')
	#combine into a global package parameter
	Package { ensure => 'installed' }
        package { $mjf_ub_wks: }
 }
}
