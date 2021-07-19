# WIKI START Recipe Daemons5::postfix5
######################################
## OS :: Redhat;Ubuntu;Fedora; !Solaris; #MacOS X
#
# h3. Host / Service groups affected
#
# * *all* 
#
# h3. Services affected
#
# * *none*
#
# h3. Files / directories / links affected
#
# * REPLACE : /etc/postfix/main.cf
#
# h3. What happens
#
# * Creates a default postfix main.cf which binds to localhost only
#
###########
# WIKI STOP

class postfix {


	case $facts['kernel']{
	   'Linux': {
             case $facts['os']['name'] {
               /^(Debian|Ubuntu)$/: { $mailcf='main.ubuntu.cf'
                       package { 'postfix' :
                               require      => File["/root/postfix.seeds"],
                               responsefile => "/root/postfix.seeds",
                               ensure => installed,
                               }
                       file  {'/root/postfix.seeds':
                               content => epp('postfix/postfix.epp', { 'myhostname' => $facts['hostname'], 'fqdn' => $facts['fqdn'],  'modtime' => mtime, 'puppetversion' => $facts['puppetversion'],}),
                               ensure => present,
                             }
                                    }
               'RedHat', 'Fedora', 'CentOS': { $mailcf='main.redhat.cf'
                       package { 'postfix' :
                                 ensure => installed,
                               }
                                    }
                default: { $mailcf='main.redhat.cf'
                       package { 'postfix' :
                                 ensure => installed,
                               }
                                    }
                 }
		file { '/etc/postfix/main.cf':
			ensure => present,
			path => '/etc/postfix/main.cf',
			content => file("postfix/$mailcf"),
			backup => main,
		}		
		service { 'postfix':
			ensure => running,
			enable => true, 
			pattern => 'postfix',
			subscribe  => File['/etc/postfix/main.cf'],
		}
	}
	
        'SunOS': {
                #
                # Solaris derivates come here
                #
        }
        default: {
                #
                # warn in the puppet log
                #
                notice("$operatingsystem not supported for recipe postfix")
                }
        }
}
