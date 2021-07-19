# WIKI START Recipe Daemons::puppetclient
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
# * UPDATE : /etc/puppet/puppet.conf
#
# h3. What happens
#
#	* deploy a valid and updated puppet.conf
#
###########
# WIKI STOP

class puppetclient
{
 if 'service_puppet' in $my_classes 
 {
  if $my_debugflag == 'yes' {notify { 'NOTPSRV' : message => 'Not a puppet server' }}
	#
	#	puppet will be 4.x
	#	
	$puppetconf="puppet.conf"
	$puppetrootgroup = lookup('rootgroup')
	if $my_debugflag == 'yes' { notify { 'PCLIENT1' : message => "Rootgroup is $puppetrootgroup" }}
        # set up location of log file for RHEL 6, 7 and Ubuntu/Solaris
        if $::osfamily == 'RedHat' {
	    case $lsbmajdistrelease {
           '6' : { $logfile_location = '/var/log/puppet/puppet.log'}
	       '7' : { $logfile_location = '/var/log/puppetlabs/puppet/puppet.log' }
	       default: { $logfile_location = '/var/log/puppetlabs/puppet/puppet.log' }
	    }
           }else{
               # for debian family
               $logfile_location = '/var/log/puppetlabs/puppet/puppet.log'
               }
        # create log file
        file { "$logfile_location":
            owner => "root",
            group => $puppetrootgroup,
            mode  => '0644',
            ensure => present,
        }

        # set up location of config file for RHEL 6, 7 and Ubuntu/Solaris
        if $::osfamily == 'RedHat' {
	    case $lsbmajdistrelease {
           '6' :    { $conffile_location = '/etc/puppet/puppet.conf'}
	       '7' :    { $conffile_location = '/etc/puppetlabs/puppet/puppet.conf' }
	       default: { $conffile_location = '/etc/puppetlabs/puppet/puppet.conf' }
	    }
           }else{
               # for debian family
               $conffile_location = '/etc/puppetlabs/puppet/puppet.conf'
               }
        # Create conf file 
        file { "$conffile_location":
            owner => "root",
            group => $puppetrootgroup,
            mode  => '0644',
            source  => "puppet:///modules/puppetclient/$puppetconf",
            replace => true,
        }	

	if ( $::kernel == "Linux" ){
        if $lsbmajdistrelease != '6' {
        # RHEL 6 is run by a cron job not a service!
        service {'puppet':
              ensure    => running,
              enable    => true,
              }
           }
		file { "/etc/logrotate.d/puppet":
       			mode => '0640',
       			source => "puppet:///modules/puppetclient/puppet.logrotate",
		}
		file { "/var/log/puppet.log":
 			target => $logfile_location,
			ensure => link,
			replace => true;
		}	
	}
	if ( $::kernel == "SunOS" ){
        case $kernelversion { 
        # For pre-Hipster versions of openindiana
        'oi_151a9' : { notify { 'PCLIENT2' : message => "This host should be using CSWpuppet. Please manage locally" }}
            # all SunOS other than oi_151a9
        default : {
		file { "/var/svc/manifest/network/puppetd.xml":
       			mode => '0644',
       			content => file("puppetclient/puppetd.xml"),
		        }
        service {'manifest-import':
            ensure    => running,
            enable    => true,
            subscribe => File['/var/svc/manifest/network/puppetd.xml'],
            }
        service {'puppet/client':
            ensure    => running,
            enable    => true,
            subscribe => Service['manifest-import'],
            }
        }
    }
    }
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
}
