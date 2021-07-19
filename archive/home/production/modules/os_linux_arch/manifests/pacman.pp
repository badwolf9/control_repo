class os_linux_arch::pacman {
case $operatingsystem {
 /Debian|Ubuntu/ : {
 notify { "Arch pacman module is not for Ubuntu!" : }
 }
 /Arch/: {
# For Arch Linux
notify { "This install base packages for Arch only!" : }
    if $my_debugflag == 'yes' {   notify { 'pacman base stuff for Arch' : }}
        $mjf_arch=lookup('mjf_arch_core_packages')
        #combine into a global package parameter
        Package { ensure => 'installed' }
        package { $mjf_arch: }
   file { '/root/yay.pkg.tar.xz' :
     ensure => present,
     replace => true,
     owner => 'root',
     group => 'root',
     mode  => '644',
     source => 'puppet:///modules/os_linux_arch/yay.pkg.tar.xz',
     }
}
 default: {}
}
}
