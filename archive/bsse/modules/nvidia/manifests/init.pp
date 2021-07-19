# WIKI START Recipe Systemconfig::nvidia-install
## OS :: RedHat 7; !Solaris; !MacOS X
######################################
#
# h3. Host+Servicegroups affected
#
# * hw-nvidia*
#
# h3. Services affected
#
# * none
#
# h3. Files / directories / links affected
# * CREATE : /root/bin/nvidia-install.sh
#            /root/bin/nvidia.sh
#
# h3. What happens
#
# * install and compile an NVIDIA driver with a specific version
#
###########
# WIKI STOP

class nvidia {
  if 'hw_nvidia_nvs' in $my_classes {
        $nvidiaversion = '340.104'
  }elsif 'hw_nvidia_cuda' in $my_classes {
        $nvidiaversion = '384.111'
  }elsif 'hw_nvidia_driver' in $my_classes {
        $nvidiaversion = '384.111'
  }
  if 'hw_nvidia_nvs' in $my_classes or 'hw_nvidia_cuda' in $my_classes or 'hw_nvidia_driver' in $my_classes {
    case $facts['osfamily'] {
      'RedHat|Ubuntu':
        {
        file { '/root/bin/nvidia.sh':
                owner => 'root',
                group => 'root',
                mode => '0744',
                content => file('nvidia/nvidia'),
                replace => true,
                }
        file { '/root/bin/nvidia-install.sh':
                owner => 'root',
                group => 'root',
                mode => '0744',
                content => epp('nvidia/nvidia-install.epp', { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'], 'nvidiaversion' => $nvidiaversion }),
                replace => true,
                }
        file { '/usr/lib/systemd/scripts/postinst':
                owner => 'root',
                group => 'root',
                mode => '0744',
                content => file('nvidia/postinst'),
                replace => true,
                }
        file { '/usr/lib/systemd/system/postinst.service':
                owner => 'root',
                group => 'root',
                mode =>  '0744',
                content => file('nvidia/postinst.service'),
                replace => true,
                }
        }
     default: { 
                notice ("Nvidia manifest is only for RedHat machines!")
     }
     }
  }
}
