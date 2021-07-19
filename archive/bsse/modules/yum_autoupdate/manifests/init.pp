# WIKI START Recipe Systemconfig::yum_autoupdate
## OS :: Redhat;!Ubuntu;Fedora; !Solaris; !MacOS X
######################################
#
# h3. Host / Service groups affected
#
# * *all but bs-smsvr01*, should be included by linux only
#
# h3. Services affected
#
# * *none*
#
# h3. Files / directories / links affected
#
# * REPLACE : _/etc/cron.daily/yumupdate_
#
# h3. What happens
#
# * Creates a cron script in _/etc/cron.daily/yumupdate_
# * The script updates a linux system every night at 4am
#
###########
# WIKI STOP

class yum_autoupdate {

 case $facts['os']['name'] {
  /RedHat|Fedora/: {
  case $facts['hostname'] {
    'bs-smsvr01':
    {
      notice('bs-smsvr01 not ready for autoupdate')
    }
    default:
    {
            file { '/etc/cron.daily/yumupdate':
              owner   => 'root',
              group   => 'root',
              mode    => '0755',
              content => template("yum_autoupdate/yumupdate.erb"),
              replace => true,
        }
    }
  }
  }
  default: {
     #     notice("$operatingsystem not supported for yum_autoupdate")
  }
 }
}
