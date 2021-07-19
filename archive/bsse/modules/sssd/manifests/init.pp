# WIKI START Recipe Daemons::sssd
## OS :: RedHat;Ubuntu; !Solaris; #MacOS X
######################################
#
# h3. Host+Servicegroups affected
#
# * *all*  RedHat and Ubuntu hosts
#
# h3. Services affected
# * *sssd* installed, enabled and started
#
# h3. Files / directories / links affected
#
# * INSTALL : sssd
# * REPLACE : /etc/sssd/sssd.conf
# * REPLACE : /etc/nsswitch.conf
# * CREATE  : /etc/openldap/cacert.pem
#
# h3. What happens
#
#      * sssd is installed and configured (filter_users and _groups need to be checked)
#      * sssd is then started
#
###########
# WIKI STOP
class sssd
{
  case $::kernel {
       "Linux": {
        $sssdserverstrings = [
                        "ldaps://ldaps-hit-2.ethz.ch, ldaps://ldaps-hit-1.ethz.ch, ldaps://ldaps-rz-1.ethz.ch, ldaps://ldaps-rz-2.ethz.ch",
                        "ldaps://ldaps-hit-1.ethz.ch, ldaps://ldaps-rz-1.ethz.ch, ldaps://ldaps-hit-1.ethz.ch, ldaps://ldaps-hit-2.ethz.ch",
                        "ldaps://ldaps-hit-1.ethz.ch, ldaps://ldaps-hit-2.ethz.ch, ldaps://ldaps-rz-1.ethz.ch, ldaps://ldaps-rz-2.ethz.ch",
                        "ldaps://ldaps-hit-2.ethz.ch, ldaps://ldaps-hit-1.ethz.ch, ldaps://ldaps-rz-1.ethz.ch, ldaps://ldaps-rz-2.ethz.ch",
                        "ldaps://ldaps-rz-2.ethz.ch, ldaps://ldaps-rz-1.ethz.ch, ldaps://ldaps-hit-1.ethz.ch, ldaps://ldaps-hit-2.ethz.ch",
                        "ldaps://ldaps-rz-1.ethz.ch, ldaps://ldaps-rz-2.ethz.ch, ldaps://ldaps-hit-1.ethz.ch, ldaps://ldaps-hit-2.ethz.ch",
                        ]
                        #$my_sssduri = $sssdserverstrings[get_id_from_uniqueid( 4 )]
                        $my_sssduri = $sssdserverstrings[4]

        $ldapserverstrings = [
                        "ldaps://ldaps-hit-2.ethz.ch:636 ldaps://ldaps-hit-1.ethz.ch:636 ldaps://ldaps-rz-1.ethz.ch:636 ldaps://ldaps-rz-2.ethz.ch:636",
                        "ldaps://ldaps-hit-1.ethz.ch:636 ldaps://ldaps-rz-1.ethz.ch:636 ldaps://ldaps-hit-1.ethz.ch:636 ldaps://ldaps-hit-2.ethz.ch:636",
                        "ldaps://ldaps-hit-1.ethz.ch:636 ldaps://ldaps-hit-2.ethz.ch:636 ldaps://ldaps-rz-1.ethz.ch:636 ldaps://ldaps-rz-2.ethz.ch:636",
                        "ldaps://ldaps-hit-2.ethz.ch:636 ldaps://ldaps-hit-1.ethz.ch:636 ldaps://ldaps-rz-1.ethz.ch:636 ldaps://ldaps-rz-2.ethz.ch:636",
                        "ldaps://ldaps-rz-2.ethz.ch:636 ldaps://ldaps-rz-1.ethz.ch:636 ldaps://ldaps-hit-1.ethz.ch:636 ldaps://ldaps-hit-2.ethz.ch:636",
                        "ldaps://ldaps-rz-1.ethz.ch:636 ldaps://ldaps-rz-2.ethz.ch:636 ldaps://ldaps-hit-1.ethz.ch:636 ldaps://ldaps-hit-2.ethz.ch:636",
                        ]

#        $my_ldapuri = $ldapserverstrings[get_id_from_uniqueid( 4 )]
        $my_ldapuri = $ldapserverstrings[4]
#notify { " My LDAP URI is $my_ldapuri " : }

    unless( $::hostname =~ /bs-jpk/ ){
            if( $::operatingsystem =~ /RedHat|CentOS|Ubuntu/ ){
		package {   "sssd": ensure => installed, 
			alias => sssd
		}
		file { "/etc/nsswitch.conf":
            owner   => "root",
            group   => "root",
            mode    => '0644',
#		      content => template("sssd/nsswitch.sssd.erb"),
            content => epp('sssd/nsswitch.sssd.epp', { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'], }),
            replace => true,
            backup  => main;
		"/etc/ldap.conf":
			owner => "root",
			group => "nagios",
			mode  => '0640',
#			content  => template("sssd/ldap.conf.erb"),
			content => epp('sssd/ldap.conf.epp', { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'], 'my_classes' => $my_classes, 'my_ldapuri' => $my_ldapuri }),
			replace => true,
			alias => ldapconf,
			backup => main;
		"/etc/openldap/ldap.conf":
			ensure => link,
			target => "/etc/ldap.conf",
			require => File[ldapconf],
			replace => true,
			backup => main;
		"/etc/openldap/cacert.pem":
			owner => "root",
			group => "root",
			mode  => '0644',
			content  => file("sssd/cacert.pem"),
			replace => true,
			backup => main;
        }
        if 'service_kerberos' in $my_classes {
            notify { "This machine will be kerberized": }
            file { "/etc/sssd/sssd.conf":
                owner => "root",
                group => "root",
                mode  => '0600',
			    content => epp('sssd/sssd_krb5.conf.epp', { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'], 'my_ldapuri' => $my_sssduri }),
                replace => true,
                alias => sssdconf,
                backup => main;
            }
        } else {
            file { "/etc/sssd/sssd.conf":
                owner => "root",
                group => "root",
                mode  => '0600',
#                content => template("sssd/sssd.conf.erb"),
			    content => epp('sssd/sssd.conf.epp', { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'], 'my_ldapuri' => $my_sssduri }),
                replace => true,
                alias => sssdconf,
                backup => main,
        }
        }
# Set up scripts for sssd according to OS
                            case $operatingsystem {
                                'Ubuntu' : {
                            	    case $lsbmajdistrelease {
                            	    '14.04': {
                            	      if $my_debugflag == 'yes' {notify {"14.04 sssd service":}}
                            	      service { "sssd":
                            		provider	=> undef,
                            		enable          => true,
                            		ensure          => running,
                            		subscribe       => File[sssdconf],
                    			}
#			  	        service { "nscd":
#                            		provider => undef,
#					ensure => stopped,
#					enable => false,
#		                        }
#					service { nslcd:
#					provider => undef,
#					ensure => stopped,
#					enable => false,
#					}
                            	       }
                            	    '16.04': {
                            	       if $my_debugflag == 'yes' {notify {"16.04 sssd systemd":}}
                            	      service { "sssd":
                            		provider	=> systemd,
                            		enable          => true,
	                                ensure          => running,
    		                        subscribe       => File[sssdconf],
                            		}
			  	        service { "nscd":
                            		provider => 'systemd',
					ensure => stopped,
					enable => false,
		                        }
					service { "nslcd":
					provider => 'systemd',
					ensure => stopped,
					enable => false,
					}

                            	    }
                            	   }
                            	   }
                                default: {
                                service { "sssd":
                                        enable          => true,
            		                ensure          => running,
                    		        subscribe       => File[sssdconf],
                            		}
  	        service { "nscd":
			ensure => stopped,
			enable => false,
		}
		service { "nslcd":
			ensure => stopped,
			enable => false,
		}
                                }
                               }
            }
	  }
       }
       default: {
               notice("$kernel OS not supported for recipe sssd")
               }
       }
}
