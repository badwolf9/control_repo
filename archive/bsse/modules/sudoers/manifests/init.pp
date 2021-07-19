# WIKI START Recipe Daemons::sudoers
## OS :: Redhat;Ubuntu; Solaris; #MacOS X
######################################
#
# h3. Host+Servicegroups affected
#
# * *all* hosts
#
# h3. Services affected
# * *sudoers* installed
#
# h3. Files / directories / links affected
# * CREATE : /etc/sudoers
#
# h3. What happens
#
#	* sudoers file is installed
#
###########
# WIKI STOP

class sudoers
{
   case $kernel {
  'Linux': {
    file { '/etc/sudoers':
                        owner   => 'root',
                        group   => 'root',
                        mode    => '0440',
                        content => template("sudoers/sudoers.erb"),
                        replace => true,
                        alias   => sudoers,
                        backup  => main,
    }
  }
    'SunOS': {
    file { '/etc/sudoers':
                        owner   => 'root',
                        group   => 'root',
                        mode    => '0440',
                        source  => 'puppet:///modules/sudoers/sudoers',
                        replace => true,
                        alias   => sudoers,
                        backup  => main,
    }
  }
  default: {
    notice("${kernel} OS not supported for recipe sudoers")
    }
   }
}

