# WIKI START Ubuntu config::os_linux_ubuntu_server
## OS :: Redhat 5;RedHat 6;Ubuntu LTS;Fedora ; !Solaris; !MacOS X
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
###########
# WIKI STOP

class os_linux_ubuntu::server {
       $my_debugflag = lookup('shallIdebug', Array[String], 'unique')
       case $::osfamily {
        'Debian': {
           if $my_debugflag == 'yes' { notify { 'Server installation' : } } 
           file { "/etc/default/grub":
           owner => "root",
           group => "root",
           mode  => '0644',
           source  => 'puppet:///modules/os_linux_ubuntu/grub.srv',
           replace => true,
           notify => Exec['update-grub2'],
           }
           exec { 'update-grub2':
             refreshonly => true,
             command => '/usr/sbin/update-grub2',
             }
           # set default target for server as console
           if $facts['os']['release']['full'] !~ /1[24]/ {
           file { '/etc/systemd/system/default.target' :
             ensure => 'link',
             replace => true,
             target => '/lib/systemd/system/multi-user.target',
             }
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
#               refreshonly => true,
#               command => '/root/bin/netsetup16.sh',
#               }
#             }else{
#             # 17 or later
#             }
         }
       default: {
         fail("The ${module_name} module for setting defaults in grub is not supported on ${::osfamily}")
         }
      }
}
