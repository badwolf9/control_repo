##
##      Currently valid puppet groups are:
##              =>      Recipe Systemconfig
##              =>      Recipe Daemons
##              =>      Recipe Network
##              =>      Recipe Filesystems
##              =>      Recipe Other
##
# WIKI START Recipe Systemconfig::modprobe
## OS :: Redhat ;Ubuntu ;Fedora ;!Solaris; !MacOS X
######################################
#
# h3. Host+Servicegroups affected
#
# * os-linux
#
# h3. Services affected
#  
# * none
#
# h3. Files / directories / links affected
# * CREATE/DELETE : /etc/modprobe.d/*
#
# h3. What happens
#
# * Create blacklist files for bluetooth and others
#
###########
# WIKI STOP

class modprobe {

  case $kernel
  {
    /Linux|SunOS/:
    {
  if($operatingsystem =~ /RedHat|CentOS/){
    file { '/etc/modprobe.d/blacklist-bluetooth':
      ensure => absent,
    }
    file { '/etc/modprobe.d/blacklist-bluetooth.conf':
      ensure  => present,
      source => "puppet:///modules/modprobe/blacklist-bluetooth.conf",
      backup  => main,
    }
    
    if defined('service-iscsi-client'){
      file { '/etc/modprobe.d/blacklist-iscsi.conf':
        ensure => absent,
        backup => main,
      }
    } else {
      file { '/etc/modprobe.d/blacklist-iscsi.conf':
        ensure  => present,
        source => "puppet:///modules/modprobe/blacklist-iscsi.conf",
        backup  => main,
      }
    }
  }
     }
     default:
       {
    notice("${kernel} OS not supported for profile")
  }
  }
}
