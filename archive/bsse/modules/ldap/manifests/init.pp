# * *nothing. This recipe is deprecated by sssd* 

class ldap
{
  case $::kernel {
    "Linux": {

	#
	#	LDAP-RZ-2 is buggy ATM
	#
	$LDAPSERVERSTRINGS = [ 
			"ldaps://ldaps-hit-2.ethz.ch:636 ldaps://ldaps-hit-1.ethz.ch:636 ldaps://ldaps-rz-1.ethz.ch:636 ldaps://ldaps-rz-2.ethz.ch:636",
			"ldaps://ldaps-hit-1.ethz.ch:636 ldaps://ldaps-rz-1.ethz.ch:636 ldaps://ldaps-hit-1.ethz.ch:636 ldaps://ldaps-hit-2.ethz.ch:636",
			"ldaps://ldaps-hit-1.ethz.ch:636 ldaps://ldaps-hit-2.ethz.ch:636 ldaps://ldaps-rz-1.ethz.ch:636 ldaps://ldaps-rz-2.ethz.ch:636",
			"ldaps://ldaps-hit-2.ethz.ch:636 ldaps://ldaps-hit-1.ethz.ch:636 ldaps://ldaps-rz-1.ethz.ch:636 ldaps://ldaps-rz-2.ethz.ch:636",
			"ldaps://ldaps-rz-2.ethz.ch:636 ldaps://ldaps-rz-1.ethz.ch:636 ldaps://ldaps-hit-1.ethz.ch:636 ldaps://ldaps-hit-2.ethz.ch:636",
			"ldaps://ldaps-rz-1.ethz.ch:636 ldaps://ldaps-rz-2.ethz.ch:636 ldaps://ldaps-hit-1.ethz.ch:636 ldaps://ldaps-hit-2.ethz.ch:636",
			]

	#$LDAPHOSTID = get_id_from_uniqueid( 4 )

	#$my_ldapuri = $LDAPSERVERSTRINGS[get_id_from_uniqueid( 4 )]
	$my_ldapuri = $LDAPSERVERSTRINGS[3]

	notify {"HOST LDAPURI = $my_ldapuri" : }

  case $::operatingsystem{
		/Debian|Ubuntu/:{
			$LDAPCONF="ldap.conf"
			$LDAPMODE='0644'
			package {   "ldap-utils": 
				ensure => installed,
				alias => openldapclient
			}
			package {   "libnss-ldap": 
				ensure => installed,
				alias => nssldap_client
			}
			file {  "/etc/openldap":
				ensure => link,
				force => true,
				target => "/etc/ldap/",
			}
		}

                
		# RedHat based systems	
		default :{
                        if($lsbmajdistrelease < 6){ 
				$LDAPCONF="ldap.conf"
				$LDAPMODE='0644'
			} else { 
				$LDAPCONF="nslcd.conf"
				$LDAPMODE='0640'
			}

			package {   "openldap": 
				ensure => installed,
				alias => openldapclient
			}

#			  notice("OS for NSS : $osMajor / $lsbmajdistrelease")

			if($lsbmajdistrelease < 6){
				package {   "nss_ldap": 
					ensure => installed,
					alias => nssldap_client
					}
			  } else {
				package {   "nss-pam-ldapd": 
					ensure => installed,
					alias => nssldap_client
				}
				#file { "/etc/ldap.conf":
				#	owner => "root",
				#	group => "root",
				#	mode  => '0644',
				#	content  => template('ldap/ldap.conf.erb'),
				#	require => Package[openldapclient],
				#	replace => true,
				#	alias => ldapconf-el6,
				#	backup => main;
				#}
			   }
		}
	}
	notice("LDAP CONFIG : $LDAPCONF")
	file {"/etc/$LDAPCONF":
	        owner => "root",
	        group => "root",
	        mode  => $LDAPMODE,
#	        content  => template('ldap/$LDAPCONF.erb'),
		content => epp("ldap/$LDAPCONF.epp", { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'], 'my_classes' => $my_classes, 'my_ldapuri' => $my_ldapuri }),
		require => Package[openldapclient],
		replace => true,
		alias => ldapconf,
		backup => main;
	      "/etc/$LDAPCONF.test":
		ensure => absent;
	    "/etc/openldap/cacert.pem":
	        owner => "root",
	        group => "root",
	        mode  => '0644',
	        content  => file('ldap/cacert.pem'),
		require => Package[openldapclient],
		replace => true,
		alias => ldapcert,
		backup => main;
	    "/etc/openldap/ldap.conf":
		ensure => link,
		target => "/etc/ldap.conf",
		require => File[ldapconf],
		replace => true,
		backup => main;
	    }
	    if( $::operatingsystem =~ /RedHat|CentOS/ ){
		if($::lsbmajdistrelease >= 6){
		                	service { "nslcd":
                	        		path            => "/etc/init.d/nslcd",
                	        		enable          => true,
                	        		provider        => redhat,
                	        		ensure          => running,
						subscribe  	=> File[ldapconf],
                			}
					file {
						"/etc/nscd.conf":
						owner => "root",
						group => "root",
						mode  => '0644',
						content  => file('ldap/nscd.conf'),
						replace => true,
						alias => nscdconf,
						backup => main;
					}
		                	service { "nscd":
                	        		path            => "/etc/init.d/nscd",
                	        		enable          => true,
                	        		provider        => redhat,
                	        		ensure          => running,
						subscribe	=> File[nscdconf],
                			}
		                	service { "sssd":
                	        		path            => "/etc/init.d/sssd",
                	        		enable          => false,
                	        		provider        => redhat,
                	        		ensure          => stopped,
                			}
		}
	    }
	        file { "/etc/nsswitch.conf":
	            owner => "root",
	            group => "root",
	            mode  => '0644',
	            content  => template('ldap/nsswitch.conf.erb'),
		    require => Package[[openldapclient],[nssldap_client]],
		    replace => true,
		    backup => main;
	        }
    }
    default: {
            notice("$operatingsystem not supported for LDAP")
    }
}
}
