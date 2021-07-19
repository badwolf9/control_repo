class p4upgrade {

        case $::kernel {
                /Linux/: {
        notify { "Host update file being copied  : }
        file { '/root/bin/host2p4.sh':
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => '0755',
          content  =>  file('p4upgrade/host2p4.sh'),
        }
      }
             default: {  notice("$::operatingsystem not supported for Puppet 4 upgrade script")
                    }
       }
}