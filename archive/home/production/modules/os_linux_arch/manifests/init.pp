class os_linux_arch::base {
case $operatingsystem {
 /Debian|Ubuntu/ : {
 notify { "Arch module is not for Ubuntu!" : }
 }
 /Arch/: {
# For Arch Linux
notify { "This is for Arch installs only!" : }
    if $my_debugflag == 'yes' {   notify { 'dhcpcd.conf' : }}
	file { "/etc/dhcpcd.conf" :
               ensure => present,
		owner => "root",
		group => "root",
		mode  => '0644',
		source  => "puppet:///modules/os_linux_arch/dhcpcd.conf",
             }

    if $my_debugflag == 'yes' {   notify { 'Pacman mirrorlist for Switzerland' : }}
	file { "/etc/pacman.d/mirrorlist" :
               ensure => present,
		owner => "root",
		group => "root",
		mode  => '0644',
		source  => "puppet:///modules/os_linux_arch/mirrorlist",
             }
    if $my_debugflag == 'yes' {   notify { 'Mail stuff for martin' : }}
	file {
		"/home/martin/.claws-mail":
               ensure => directory,
		owner => "martin",
		group => "martin",
		mode  => '0700',
		source  => "puppet:///modules/os_linux_arch/claws-mail",
		recurse  => true,
#		purge => true,
#		replace => true,
                alias => clawsconfigs,
	}
	file { "/home/martin/.claws-mail/passwordstorerc" :
		mode  => '0600',
             }
	file { "/home/martin/.claws-mail/accountrc" :
		mode  => '0600',
             }
	file { "/home/martin/.claws-mail/mairix.sh" :
		mode  => '0755',
             }
	file {
		"/home/martin/.bogofilter":
		ensure => directory,
		owner => "martin",
		group => "martin",
		mode  => '0755',
		source  => "puppet:///modules/os_linux_arch/bogofilter",
		recurse  => true,
#		purge => true,
#		replace => true,
                alias => bogofconfigs,
	}

 }
 default: {}
}
}
