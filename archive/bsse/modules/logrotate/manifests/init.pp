##
# WIKI START Recipe Systemconfig::logrotate
## OS :: Redhat ;Ubuntu ;Fedora ; !Solaris; !MacOS X
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
# * REPLACE : _/etc/logrotate.d/syslog_
#
# h3. What happens
#
# * Dump a default /etc/logrotate.d/syslog_ which adds missingok
#
###########
# WIKI STOP

class logrotate {

  case $::kernel
  {
    /Linux/:
    {
    file { '/etc/logrotate.d/syslog':
      ensure  => present,
      path    => '/etc/logrotate.d/syslog',
      content => file('logrotate/syslog'),
      backup  => main,
                        }
  }
    default:
  {
        notice("$::kernel OS not supported for logrotate")
  }
    }
}
