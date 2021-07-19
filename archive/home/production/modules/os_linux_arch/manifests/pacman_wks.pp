class os_linux_arch::pacman_wks {
case $operatingsystem {
 /Debian|Ubuntu/ : {
 notify { "Arch pacman wks module is not for Ubuntu!" : }
 }
 /Arch/: {
# For Arch Linux
notify { "This installs workstation packages for Arch only!" : }
    if $my_debugflag == 'yes' {   notify { 'pacman workstation stuff for Arch' : }}
        $mjf_arch_wks=lookup('mjf_arch_core_packages_workstation')
        #combine into a global package parameter
        Package { ensure => 'installed' }
        package { $mjf_arch_wks: }
 }
 default: {}
}
}
