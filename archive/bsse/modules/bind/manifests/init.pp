##
##      Currently valid puppet groups are:
##              =>      Recipe Systemconfig
##              =>      Recipe Daemons
##              =>      Recipe Network
##              =>      Recipe Filesystems
##              =>      Recipe Other
##
# WIKI START Recipe Network::bind
## OS :: Redhat ;Ubuntu;Fedora; !Solaris; #MacOS X
######################################
#
# h3. Host+Servicegroups affected
#
# * Hosts in group *service-dns* will get the named.conf
#
# h3. Services affected
# * *bind* enabled and started in case of service-dns membership
#
# h3. Files / directories / links affected
# * CREATE : /etc/named.conf
#
# h3. What happens
#
# * Deploy named.conf
# * *named* restarted if required
# - Not used as at date of this page
###########
# WIKI STOP

class bind
{
   case $facts['kernel'] {
  'Linux': {
    $binddpkg='bind'
    if(tagged('service-dns'))
    {
       package {
      $binddpkg: ensure => installed,
      alias  => bind_pkg,
      }

       file { '/etc/named.conf':
      owner   => 'named',
      group   => 'root',
      mode    => '0640',
      content => file(bind/named.conf),
      require => Package[bind_pkg],
      replace => true,
      alias   => bind_conf,
       }

       service { 'named':
        ensure    => running,
        enable    => true,
        subscribe => File[bind_conf],
        pattern   => 'named',
         }
    }

    }
  default: {
                #
                # warn in the puppet log
                #
                notice("${kernel} OS not supported for recipe named.")
                }
       }
}
