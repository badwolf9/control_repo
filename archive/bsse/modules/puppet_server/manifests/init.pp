# WIKI START Recipe Daemons::puppet_server
## OS :: Redhat;Ubuntu;Fedora;Solaris
######################################
#
# h3. Host+Servicegroups affected
#
# * *all others* hosts
#
# h3. Services affected
# * *puppet*
#
# h3. Files / directories / links affected
# * UPDATE : /var/run/lastrun
#
# h3. What happens
#
#	* deploy a valid lastrun
#
###########
# WIKI STOP

class puppet_server
{
        file {'/var/run/puppetlabs':
             ensure => 'directory',
             }
	file { "/var/run/puppetlabs/lastrun":
	    owner => "root",
	    group => $puppetrootgroup,
	    mode  => '0644',
            replace => true,
	    content => inline_template("Last run (modulus 3600) : <%= Time.now.gmtime.to_i - (Time.now.gmtime.to_i % 3600) %>\n"),
            }
}


