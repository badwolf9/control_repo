# WIKI START Ubuntu config::autoupdate
## OS :: Redhat;Ubuntu LTS;Fedora ; !Solaris; !MacOS X
######################################
#
# h3. Host / Service groups affected
#
# * *Linux Debian type Systems* 
#
# h3. Services affected
# * none
#
# h3. Files / directories / links affected
# * DEPLOY : 
#
# h3. What happens
#
# * Install 
# *
###########
# WIKI STOP

class os_linux_ubuntu::autoupdate
 {
           file {"/etc/apt/apt.conf.d/10periodic":
                 ensure => absent,
                 }
         if 'os_linux_ubuntu_NO_autoupdate' in $my_classes {
            if ( $facts['os']['release']['full'] =~ /1[78]/ ) {
              $source_file_no="50_no_unattended-upgrades.1804"
              }else{
              $source_file_no="50_no_unattended-upgrades"
              }
        if $my_debugflag == 'yes' { notify { 'NO autoupdate configs for Ubuntu/Debian' : }}
           file { "/etc/apt/apt.conf.d/20auto-upgrades":
           owner => "root",
           group => "root",
           mode  => '0644',
           source  => 'puppet:///modules/os_linux_ubuntu/20_no_auto-upgrades',
           replace => true,
           }
           file { "/etc/apt/apt.conf.d/50unattended-upgrades":
           owner => "root",
           group => "root",
           mode  => '0644',
           source  => "puppet:///modules/os_linux_ubuntu/$source_file_no",
           replace => true,
           }
           } else {
        if $my_debugflag == 'yes' { notify { 'autoupdate package and configs for Ubuntu/Debian' : }}
            if ( $facts['os']['release']['full'] =~ /1[78]/ ) {
              $source_file_yes="50unattended-upgrades.1804"
              }else{
              $source_file_yes="50unattended-upgrades"
              }
            package {'unattended-upgrades' :
            ensure => 'installed',
           }
           file { "/etc/apt/apt.conf.d/20auto-upgrades":
           owner => "root",
           group => "root",
           mode  => '0644',
           source  => 'puppet:///modules/os_linux_ubuntu/20auto-upgrades',
           replace => true,
           }
           file { "/etc/apt/apt.conf.d/50unattended-upgrades":
           owner => "root",
           group => "root",
           mode  => '0644',
           source  => "puppet:///modules/os_linux_ubuntu/$source_file_yes",
           replace => true,
           }
          }
 }

