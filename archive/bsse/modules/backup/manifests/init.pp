# WIKI START Recipe Daemons::backup
## OS :: Redhat ;Ubuntu;Fedora ; #Solaris; #MacOS X
######################################
#
# h3. Host+Servicegroups affected
#
# * Hosts in group *service_db_mysql* will set a my.cnf and create a cron.weekly entry
# * *all others* hosts will be left alone
#
# h3. Services affected
# *none*
#
# h3. Files / directories / links affected
# * CREATE : /etc/my.cnf
# * CREATE : /etc/cron.weekly/createMySQLbackup.sh
#
# h3. What happens
#
# * configure my.cnf for mysql and add a mysql cron script
#
# * Other backup part should go into here as well
#
###########
# WIKI STOP
class backup {

        case $::kernel {
                /Linux/: {
      if ('service_db_mysql' in lookup('my_node_classes', Array[String],'unique')) {
        file { '/etc/cron.weekly/createMySQLbackup.sh':
          ensure  => present,
          backup  => main,
          owner   => 'root',
          group   => 'root',
          mode    => '0700',
          content  =>  file('backup/createMySQLbackup.sh'),
        }
        file { '/local0/mysqlbinlogs':
          ensure => directory,
          mode   => '0750',
          owner  => 'mysql',
          group  => 'mysql',
        }
        file { '/var/lib/mysqlbinlogs':
          ensure => link,
          target => '/local0/mysqlbinlogs',
        }
        file { '/etc/my.cnf':
          backup  => main,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => epp('backup/my.cnf.epp', { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'],}),
        }
                            }
                }
                default: {}
        }

}
