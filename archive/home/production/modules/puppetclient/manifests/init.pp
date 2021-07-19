class puppetclient
{
 if 'service_puppet' in $my_classes 
 {
  if $my_debugflag == 'yes' {notify { 'NOTPSRV' : message => 'Not a puppet server' }}
	$puppetconf="puppet.conf"
	$puppetrootgroup = lookup('rootgroup')
	if $my_debugflag == 'yes' { notify { 'PCLIENT1' : message => "Rootgroup is $puppetrootgroup" }}
        # set up location of log file
        if $::osfamily == 'RedHat' {
	    case $lsbmajdistrelease {
           '6' : { $logfile_location = '/var/log/puppet/puppet.log'}
	       '7' : { $logfile_location = '/var/log/puppetlabs/puppet/puppet.log' }
	       default: { $logfile_location = '/var/log/puppetlabs/puppet/puppet.log' }
	    }
           }else{
               # for debian family and Arch
               $logfile_location = '/var/log/puppetlabs/puppet/puppet.log'
               }
        # create log file
        file { "$logfile_location":
            owner => "root",
            group => $puppetrootgroup,
            mode  => '0644',
            ensure => present,
        }

               $conffile_location = '/etc/puppetlabs/puppet/puppet.conf'
        # Create conf file 
        file { "$conffile_location":
            owner => "root",
            group => $puppetrootgroup,
            mode  => '0644',
            source  => "puppet:///modules/puppetclient/$puppetconf",
            replace => true,
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
