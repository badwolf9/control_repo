# WIKI START Ubuntu config::os_linux_ubuntu_x2go
## OS :: Redhat ;Ubuntu LTS;Fedora ; !Solaris; !MacOS X
######################################
#
# h3. Host / Service groups affected
#
# * *Linux Systems* 
#
# h3. Services affected
# * x2go server
#
# h3. Files / directories / links affected
# * Setup X2go server
#
# h3. What happens
#
# * Add repo and install x2go server
#
###########
# WIKI STOP

class os_linux_ubuntu::x2go
{
# modules needed
    include apt
    include ::wget
    
   # notify { ' Installing X2go ' : }
   case $kernel {
	'Linux':{
	   case $operatingsystem
		{
		   /RedHat|CentOS|Fedora|Arch/: {
		   }
		   /Debian|Ubuntu/: {
                   # test if workstation or x2go relations set in Centreon
                   if (os_linux_ubuntu_x2go in $my_classes) or (os_linux_ubuntu_workstation in $my_classes){
                   # for a server install need to explicitly include the x2go relation in Centreon
        	    if ( $facts['os']['release']['full'] =~ /18|20/ )
	            {
        	     if $my_debugflag == 'yes' {notify { "In ubuntu 18++ x2go is different!!!" : } }
			package { 'x2goserver' : 
				    ensure => 'latest', 
				    }
			package { 'x2goserver-xsession' : 
				    ensure => 'latest' , 
				    }
#			package { 'x2gomatebindings' : 
#				    ensure => 'latest' , 
#				    }
	            }else{
                        # for 14.04 and 16.04 use the ppa for x2go
			apt::ppa { 'ppa:x2go/stable' : }
	    		apt::key { 'ppa:x2go/stable' : 
			 id  => 'A7D8D681B1C07FE41499323D7CDE3A860A53F9FD',
			}
			package { 'python-software-properties' : 
				    ensure => 'latest' 
				    }
			package { 'x2goserver' : 
				    ensure => 'latest', 
				    #require that the apt update is finished!
                                    require => [ Apt::Ppa['ppa:x2go/stable'], Class['apt::update'], ],
				    }
			package { 'x2goserver-xsession' : 
				    ensure => 'latest' , 
#				    require => Apt::Ppa['ppa:x2go/stable'], 
                                    require => [ Apt::Ppa['ppa:x2go/stable'], Class['apt::update'] ],
				    }
                        if $lsbmajdistrelease =~ /1[68]/ {
			package { 'x2gomatebindings' : 
				    ensure => 'latest' , 
#				    require => Apt::Ppa['ppa:x2go/stable'], 
                                    require => [ Apt::Ppa['ppa:x2go/stable'], Class['apt::update'] ],
				    }
                         }
        	       }
                     }
                   }
                 }
	}
	'SunOS': { }
	default: {
	         }
    }
}

