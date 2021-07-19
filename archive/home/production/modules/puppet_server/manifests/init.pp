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


