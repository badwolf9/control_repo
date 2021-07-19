#
class os_linux_ubuntu::workstation {
       $my_debugflag = lookup('shallIdebug', Array[String], 'unique')
       case $::osfamily {
        'Debian': {
           if $my_debugflag == 'yes' { notify { 'workstation installation' : } }
           # set default target for workstation as graphical
           file { '/etc/systemd/system/default.target' :
             ensure => 'link',
             replace => true,
             target => '/lib/systemd/system/graphical.target',
             }
          # if $facts['os']['release']['full'] !~ /12/ {
          # set default locales
           if $my_debugflag == 'yes' { notify { ' setting default locale, need new shell to get effect' : } }
           file { "/etc/default/locale":
           owner => "root",
           group => "root",
           mode  => '0644',
           source  => 'puppet:///modules/os_linux_ubuntu/locale',
           replace => true,
            }

         if 'os_linux_ubuntu_allow_upgrade' in $my_classes {
#######  # allow upgrades
            case $facts['os']['release']['full'] {
              /18.04/: {
           if $my_debugflag == 'yes' { notify { "Upgrades in 18.04 will be allowed" : } }
                         file { "/usr/bin/do-release-upgrade":
                         owner => 'root',
                         group => 'root',
                         mode  => '0644',
                         replace => true,
                         content => file("os_linux_ubuntu/do_release_upgrade_1804"),
                         }
                       }
              /19.10/: {
           if $my_debugflag == 'yes' { notify { "Upgrades in 19.10 will be allowed" : } }
                         file { "/usr/bin/do-release-upgrade":
                         owner => 'root',
                         group => 'root',
                         mode  => '0644',
                         replace => true,
                         content => file("os_linux_ubuntu/do_release_upgrade_1910"),
                         }
                       }

              default: {  }
              }
            file { "/etc/update-motd.d/91-release-upgrade":
               owner   => 'root',
               group   => 'root',
               mode => '0644',
               replace => true,
               source => 'puppet:///modules/os_linux_ubuntu/91-release-upgrade',
            }
            file {"/etc/update-manager/release-upgrades":
               owner   => 'root',
               group   => 'root',
               mode => '0644',
               replace => true,
               source => 'puppet:///modules/os_linux_ubuntu/release-upgrades_allow',
            }
          }else{
########  # prevent notifications about upgrades and the opportunity to upgrade to a newer version
           if $my_debugflag == 'yes' {  notify { "Upgrades will NOT be allowed" : } }
            file { "/usr/bin/do-release-upgrade":
               ensure => absent,
            }
            file { "/etc/update-motd.d/91-release-upgrade":
               ensure => absent,
            }
            file {"/etc/update-manager/release-upgrades":
               owner   => 'root',
               group   => 'root',
               mode => '0644',
               replace => true,
               source => 'puppet:///modules/os_linux_ubuntu/release-upgrades',
            }
           }

        # 18.04 onwards
         # Install remmina and the usual plugins
#        package { 'remmina' :
#         ensure => 'latest' ,
         #install_options => ['--no-install-recommends'],
#         }
        
       # ##### /Remmina
             
          }
       default: {
         notify { "The ${module_name} module is not supported on ${::osfamily}" : }
         }
      }
}
