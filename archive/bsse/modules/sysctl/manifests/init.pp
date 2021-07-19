##
##	Currently valid puppet groups are:
##		=>	Recipe Systemconfig
##		=>	Recipe Daemons
##		=>	Recipe Network
##		=>	Recipe Filesystems
##		=>	Recipe Other
##
# WIKI START Recipe Systemconfig::sysctl
## OS :: Redhat;Ubuntu;Fedora; !Solaris; !MacOS X
######################################
#
# h3. Host+Servicegroups affected
#
# * All hosts * affected. Actual sysctl params should be define in the sysctl.conf
#
# h3. Services affected
# * none *
#
# h3. Files / directories / links affected
# 	* CREATE OR UPDATE : /etc/sysctl.conf
#
# h3. What happens
#
#	* roll out sysctl.conf
#	* does NOT activate the settings until reboot!
#
###########
# WIKI STOP

class sysctl
{
  case $::kernel {
    /Linux/: {

      $defaultsysctl="sysctl/sysctl.conf.epp"

    file { '/etc/sysctl.conf':
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      replace => true,
      backup  => main,
#      content => template($defaultsysctl),
      content => epp("$defaultsysctl", { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'], 'my_classes' => $my_classes, }),
    }
  }
  default: {
    #
    # warn in the puppet log
    #
    notice("${::operatingsystem} not supported for recipe sysctl")
      }
   }
}
