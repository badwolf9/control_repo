# WIKI START Recipe Daemons::vmtoolsd
## OS :: Redhat;Ubuntu LTS;Fedora ; !Solaris; !MacOS X
######################################
#
# h3. Host / Service groups affected
#
# * *Linux* 
#
# h3. Services affected
# * vmtoolsd - VMware tools
#
# h3. Files / directories / links affected
# * DEPLOY : open-vm-tools
#
# h3. What happens
#
# * Install open-vm-tools
# *
###########
# WIKI STOP

class vmtoolsd
 {

    if $::kernel == 'Linux' {
        if $facts['virtual'] == 'vmware' {
            package {   'open-vm-tools':
                ensure => installed,
                }

            case $::operatingsystem {
                /RedHat|CentOS/ : {
                    service {  'vmtoolsd' :
                    ensure => running,
                    require => Package['open-vm-tools'],
                    }
                }
                /Ubuntu|Debian/ : {

                    if 'os_linux_ubuntu_workstation' in $my_classes {
                       # Edge case for jpk vm: 
                       if $facts['fqdn'] !~ /jpk/ {
                       notify { "This is vmtoolsd" : }
                       package {   'open-vm-tools-desktop':
                         ensure => installed,
                         }
                       }
                      }
                #    if $facts['os']['release']['major'] !~ /1[02]/ {
                        file { '/etc/init.d/open-vm-tools':
                        ensure  => present,
                        mode    => '0755',
                        owner   => root,
                        group   => root,
                        content => file("vmtoolsd/open-vm-tools"),
                        require => Package['open-vm-tools'],
                        subscribe => Service['open-vm-tools'],
                        }
                    #}
                    service {  'open-vm-tools' :
                    ensure => running,
                    require => Package['open-vm-tools'],
                    }
                }
               default: {
                   notice('vmtools not applicable for this OS')
                }
         }
    }
 }

}