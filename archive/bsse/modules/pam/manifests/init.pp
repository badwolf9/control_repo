# WIKI START Recipe Systemconfig::pam
## OS :: Redhat ;Ubuntu LTS;Fedora; !Solaris; !MacOS X
######################################
#
# h3. Host / Service groups affected
#
# * *Linux Systems* 
#
# h3. Services affected
# * none
#
# h3. Files / directories / links affected
# * DEPLOY : _/etc/pam.d/system-auth_ (Redhat based systems)
# * DEPLOY : _/etc/pam.d/common-auth_ (Debian based systems)
# This doesn't happen on bs-jpk* systems!
#
# h3. What happens
#
# * Deploy the system-auth-ac and password-auth-ac on Red Hat Linux systems
# * Deploy the common-auth on Ubuntu Linux systems unless it is a JPK machine
#   in which case deploy the JPK user creation script 20171203
#
###########
# WIKI STOP

class pam
{
   case $kernel {
	"Linux":{
		case $operatingsystem
		{
		   /RedHat|CentOS|Fedora/: {
            if 'service_kerberos' in $my_classes {
                $systempam="system-auth-ac-krb5"
                $passwdpam="password-auth-ac-krb5"
                    } else {
                    $systempam="system-auth-ac"
                    $passwdpam="password-auth-ac"
                    }
		    	    file {  "/etc/pam.d/password-auth-ac":
                		ensure => present,
                		mode => '0644',
                		owner => root,
                		group => root,
                		path => "/etc/pam.d/password-auth-ac",
                		content => template("pam/$passwdpam.erb"),
			        	replace => true
        		}
		       file { "/etc/pam.d/system-auth-ac":
                		ensure => present,
                		mode => '0644',
                		owner => root,
                		group => root,
        #        		path => "/etc/pam.d/$systempam",
                		content => template("pam/$systempam.erb"),
			        	replace => true
        	       }
			
		   }
		   /Debian|Ubuntu/: {
                     if ( 'bs-jpk' in $hostname ) {
		       file { "/root/jpkusers.list":
	            	 ensure => present,
                   mode    => '0644',
                   owner   => root,
                   group   => root,
                   path    => "/root/jpkusers.list",
                   content  => file("pam/jpkusers.list"),
        	       }
		       file { "/root/bin/createLocalJPKUsers.sh":
	               	 ensure => present,
                	 mode => "0755",
                	 owner => root,
                	 group => root,
                	 path => "/root/bin/createLocalJPKUsers.sh",
                	 content => file("pam/createLocalJPKUsers.sh",)
        	       }

                     }
                     else {
$systempam="common-auth"
		       notice("PAM SRC : $systempam")
		       file { $systempam:
                	 ensure => present,
                	 mode => '0644',
                	 owner => root,
                	 group => root,
                	 path => "/etc/pam.d/$systempam",
                	 content => template("pam/$systempam.erb"),
			 replace => true
        	       }
$systempam1="common-account"
		       notice("PAM SRC1 : $systempam1")
		       file { $systempam1:
                	 ensure => present,
                	 mode => '0644',
                	 owner => root,
                	 group => root,
                	 path => "/etc/pam.d/$systempam1",
                	 content => template("pam/$systempam1.erb"),
			 replace => true
        	       }
$systempam2="common-password"
		       notice("PAM SRC2 : $systempam2")
		       file { $systempam2:
                	 ensure => present,
                	 mode => '0644',
                	 owner => root,
                	 group => root,
                	 path => "/etc/pam.d/$systempam2",
                	 content => template("pam/$systempam2.erb"),
			 replace => true
        	       }
$systempam3="common-session"
		       notice("PAM SRC3 : $systempam3")
		       file { $systempam3:
                	 ensure => present,
                	 mode => '0644',
                	 owner => root,
                	 group => root,
                	 path => "/etc/pam.d/$systempam3",
                	 content => template("pam/$systempam3.erb"),
			 replace => true
        	       }
$systempam4="common-session-noninteractive"
		       notice("PAM SRC4 : $systempam4")
		       file { $systempam4:
                	 ensure => present,
                	 mode => '0644',
                	 owner => root,
                	 group => root,
                	 path => "/etc/pam.d/$systempam4",
                	 content => template("pam/$systempam4.erb"),
			 replace => true
        	       }
                     }
		   }
		}
     	}
	'SunOS': { }

	'Darwin': { }

	default: {
		#
		# warn in the puppet log
		#
		#notice("$kernel OS not supported for recipe pam")
  		}
 	}
}

