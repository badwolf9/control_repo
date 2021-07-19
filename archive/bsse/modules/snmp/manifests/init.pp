## OS :: Redhat ;Ubuntu ;Fedora ; Solaris; !MacOS X
# WIKI START Recipe Daemons::snmp
######################################
#
# h3. Centron Dependencies
##EXEC::EXEC_FIND_DEPENDENCIES ###FILEPATH###/###FILENAME###
#
# h3. Host / Service groups affected
#
# * *defaultnode* for config / package deployement
#
# h3. Services affected
# * *snmpd* enabled and started
#
# h3. Files / directories / links affected
# * DEPLOY : /etc/snmp/snmpd.conf (Linux)
# * DEPLOY : /etc/snmp/conf/snmpd.conf  (OpenSolaris)
#
# h3. What happens
#
# * Deploy the BSSE snmpd.conf 
# * Install / Update the net-snmp package
# * Restart the snmpd daemon
#
###########
# WIKI STOP
class snmp {
  case $facts['os']['family'] {
	'Debian': {
		$snmp_package='snmpd'
		$nogroup='nogroup'
		file { '/etc/default/snmpd':
			owner => 'root',
			group => 'root',
			mode => '0644',
			content => file('snmp/snmpd_ubuntu.conf'),
		}
	}
	'Solaris':{
		$snmp_package="net-snmp"
		$nogroup="nobody"
		$snmpoptions="snmpd.options"
	}
	default: {
		$snmp_package="net-snmp"
		$nogroup="nobody"
		$snmpoptions="snmpd"
	}
  }

  case $facts['kernel'] {
   'Linux': {
	package {   "$snmp_package": ensure => installed,
                    alias => net-snmp_client
                }
	file { "/etc/snmp/snmpd.conf":
        	owner => "root",
        	group => $nogroup,
        	mode  => '0640',
                content => epp('snmp/snmpd.conf.epp', { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'], 'manufacturer' => $facts['manufacturer'], }),
		#content => template("snmp/snmpd.conf.erb"),
		require => Package[net-snmp_client],
		alias => snmpdconf,
	}
	
  	if($::operatingsystem != "Ubuntu" and $::operatingsystem != "Debian"){
      file { "/etc/sysconfig/$snmpoptions":
  	owner => "root",
  	group => "root",
  	mode => "0644",
  	content => file("snmp/snmpd.options"),
    alias => snmpdoptions
      }
	    file { "/etc/logrotate.d/snmpd":
		owner => "root",
		group => "root",
		mode => "0644",
		content => file("snmp/logrotate.d/snmpd"),
	    }
	} else {
		#	FAKE snmpdoptions for ubuntu
	    file { "/etc/snmp/snmptrapd.conf": alias => snmpdoptions }
	}
		
        service { "snmpd":
	   enable => true,
	   ensure => running,
	   subscribe => [ Package[net-snmp_client], File[snmpdconf], File[snmpdoptions] ],
        }
   }
   "SunOS": {
	case $operatingsystem {

           "Solaris": {

		file { "/etc/net-snmp/snmp/snmpd.conf":
      owner   => "root",
      group   => "nobody",
      mode    => "640",
      #content => template("snmp/snmpd.conf.erb"),
      content => epp('snmp/snmpd.conf.epp', { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'],  'manufacturer' => $facts['manufacturer'], }),
      alias   => snmpdconf,
		}
		package { "net-snmp":
			ensure => installed,
			provider => "pkg",
		}

		service { "net-snmp":
		   enable => true,
		   ensure => running,
		   subscribe => [ File[snmpdconf] ],
		  # subscribe => [ Package[net-snmp_client], File[snmpdconf] ]
		}
	   }
	   "OpenIndiana": {
	        file { "/etc/net-snmp/snmp/snmpd.conf":
                        owner => "root",
                        group => "nobody",
                        mode  => "640",
                        content => file('snmp/snmpd.conf'),
                        alias => snmpdconf,
                }
	   }

	}
}

   default: {
	notice("$kernel OS not supported for SNMP")
   }
  }
}
