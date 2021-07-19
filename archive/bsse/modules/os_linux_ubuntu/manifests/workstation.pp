# WIKI START Ubuntu config::os_linux_ubuntu_workstation
## OS :: !Redhat;Ubuntu; !Solaris; !MacOS X
######################################
#
# h3. Host / Service groups affected
#
# * *Linux Systems* 
#
# h3. Services affected
# * none
#
# h3. Files / directories / links affected
# * CONFIG: grub set up for a workstation login
#
# h3. What happens
#
# * Copy grub file to /etc/default with boot options "quiet splash"
#   and regenerate /boot/grub.cfg on Ubuntu based systems
#
# * Ensure that it is not possible for an ordinary user to upgrade to the next Ubuntu version.
#
###########
# WIKI STOP

class os_linux_ubuntu::workstation {
       $my_debugflag = lookup('shallIdebug', Array[String], 'unique')
       case $::osfamily {
        'Debian': {
           if $my_debugflag == 'yes' { notify { 'workstation installation' : } }
           # set default target for workstation as graphical
           if $facts['os']['release']['full'] !~ /1[24]/ {
           file { '/etc/systemd/system/default.target' :
             ensure => 'link',
             replace => true,
             target => '/lib/systemd/system/graphical.target',
             }
           }
           file { "/etc/default/grub":
           owner => "root",
           group => "root",
           mode  => '0644',
           source  => 'puppet:///modules/os_linux_ubuntu/grub.wks',
           replace => true,
           notify => Exec['update-grub2'],
           }
           exec { 'update-grub2':
             refreshonly => true,
             command => '/usr/sbin/update-grub2',
             }
#           if $facts['os']['release']['full'] =~ /12.04|14.04|16.04/ {
#              file { "/root/bin/netsetup16.sh":
#                  owner => "root",
#                  group => "root",
#                  mode  => '0755',
#                  source  => 'puppet:///modules/os_linux_ubuntu/netsetup16.sh',
#                  replace => true,
#                  notify => Exec['update-interfaces'],
#           }
#              exec { 'update-interfaces':
#               command => '/root/bin/netsetup16.sh',
#               }
#             }else{
#             # 17 or later
#             }
         if 'os_linux_ubuntu_allow_upgrade' in $my_classes and $facts['os']['release']['full'] !~ /12.04/ {
#######  # allow upgrades
            case $facts['os']['release']['full'] {
              /14.04/: { 
              notify { "Upgrades in 14.04 will be allowed" : }
                         file { '/usr/bin/do-release-upgrade':
                         owner => 'root',
                         group => 'root',
                         mode  => '0644',
                         replace => true,
                         content  => file("os_linux_ubuntu/do_release_upgrade_1404"),
                         }
                       }
              /16.04/: {
              notify { "Upgrades in 16.04 will be allowed" : }
                         file { "/usr/bin/do-release-upgrade":
                         owner => 'root',
                         group => 'root',
                         mode  => '0644',
                         replace => true,
                         content  => file("os_linux_ubuntu/do_release_upgrade_1604"),
                         }
                       }
              /18.04/: {
              notify { "Upgrades in 18.04 will be allowed" : }
                         file { "/usr/bin/do-release-upgrade":
                         owner => 'root',
                         group => 'root',
                         mode  => '0644',
                         replace => true,
                         content => file("os_linux_ubuntu/do_release_upgrade_1804"),
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
              notify { "Upgrades will NOT be allowed" : }
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

           if $facts['os']['release']['full'] =~ /1[46]/ {
           # for 14.04
           # would be great to install remmina so that it works with latest MS patches
           # by default libfreerdp2 and remmina are not installed so assume can just add the ppa and install them
            file { "/etc/apt/preferences.d/remmina-ppa-pin-1000":
              owner => "root",
              group => "root",
              mode  => '0644',
              source  => 'puppet:///modules/os_linux_ubuntu/remmina-ppa-pin-1000',
              replace => true,
              }
           # Just to be sure
#            package { 'libwinpr2-2' : ensure => 'absent' }
#            package { 'libfreerdp2-2' : ensure => 'absent' }
            $remmina_pkg = [ 'remmina', 'remmina-common', 'remmina-plugin-rdp', 'remmina-plugin-secret', 'remmina-plugin-vnc' ]
#            package { $remmina_pkg : ensure => 'absent' }
#            $freerdpver = $facts['os']['release']['full'] ? {
#              /14.04/ => 'libfreerdp1',
#              default => 'libfreerdp1',
#            }
#             $freerdpver = libfreerdp1
              $freerdpver = $facts['os']['release']['full'] ? {
              /14.04/ => 'libfreerdp1',
              default => 'libfreerdp2-2',
              }

	    apt::ppa { 'ppa:remmina-ppa-team/remmina-next' : }
	    apt::key { "ppa:remmina-ppa-team/remmina-next" : 
		 id => '04E38CE134B239B9F38F82EE8A993C2521C5F0BA',
                 server => 'keyserver.ubuntu.com',
	             }
        # Install libfreerdp1
	    package { "$freerdpver" :
	     ensure => 'latest' ,
             #install_options => ['--no-install-recommends'],
	     require => [
	        Apt::Ppa['ppa:remmina-ppa-team/remmina-next'],
		Class['apt::update'],
		    ],
	     }
         # Install remmina and the usual plugins
	    package { 'remmina' :
	     ensure => 'latest' ,
	     #install_options => ['--no-install-recommends'],
	     require => [
	        Apt::Ppa['ppa:remmina-ppa-team/remmina-next'],
		Class['apt::update'],
		    ],
	     }
           }else{
                    # 18.04
         # Install remmina and the usual plugins
        package { 'remmina' :
         ensure => 'latest' ,
         #install_options => ['--no-install-recommends'],
         }
        }
       # ##### /Remmina
             
          }
       default: {
         fail("The ${module_name} module is not supported on ${::osfamily}")
         }
      }
}
