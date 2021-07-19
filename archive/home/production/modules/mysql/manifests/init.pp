# WIKI START Recipe Daemons::mysql from forge
## OS :: #Redhat;Ubuntu;Fedora; #Solaris; #MacOS X
######################################
#
# h3. Host+Servicegroups affected
#
# * Ubuntu Hosts in group *service-net-mysql* will get mysql server installed
# * *all others* hosts will be left alone
#
# h3. Services affected
# MySQL
#
# h3. Files / directories / links affected
# * CREATE : 
#
# h3. What happens
#
# * Install MySQL server using the Puppet Forge mysql module
#
# * Standard settings for a BSSE install
#
###########
# WIKI STOP
class mysql {
	    if $facts['os']['family'] == 'Debian' {
                 class { '::mysql::server':
                       root_password => 'masterm1',
                       override_options => {
                              server_id => 42,
                            }
                        }
                 }
}