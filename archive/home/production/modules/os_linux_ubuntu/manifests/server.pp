# Files / directories / links affected
# * CONFIG: grub set up for a workstation login
#
# * Copy grub file to /etc/default with boot options "quiet splash"
#   and regenerate /boot/grub.cfg on Ubuntu based systems
#
###########
# 

class os_linux_ubuntu::server {
       $my_debugflag = lookup('shallIdebug', Array[String], 'unique')
       case $::osfamily {
        'Debian': {
           if $my_debugflag == 'yes' { notify { 'Server installation' : } } 
          # set default locales
           notify { ' setting default locale' : }
           file { "/etc/default/locale":
           owner => "root",
           group => "root",
           mode  => '0644',
           source  => 'puppet:///modules/os_linux_ubuntu/locale',
           replace => true,
           }
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
           # installation has default target set as multi-user.
         }
       default: {
         fail("The ${module_name} module for setting defaults in grub is not supported on ${::osfamily}")
         }
      }
}
