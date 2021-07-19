# WIKI START Recipe Systemconfig::x2go
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

class x2go
{
    include ::wget
   # notify { ' Installing X2go ' : }
   case $kernel {
	'Linux':{
	   case $operatingsystem
		{
		   /RedHat|CentOS|Fedora/: {
		   if $facts['os']['release']['full'] =~ /6/ 
                   {
                   include rhsm
                   rh_repo { 'BSSE_epel-6_epel-6':
                              ensure => present,
                           }
                   rh_repo { 'rhel-6-server-optional-rpms':
                              ensure => present,
                           }
		   #wget https://www.rpmfind.net/linux/centos/6.9/os/x86_64/Packages/perl-File-Which-1.09-2.el6.noarch.rpm
		   #package install perl-File-Which
                   }
		   package { 'x2goserver' : 
		    ensure => 'latest', 
		    }
		   package { 'x2goserver-xsession' : 
		    ensure => 'latest' , 
		    }
}
		   /Debian|Ubuntu/: {
		    # modules needed
		    include apt

        	    if ( $facts['os']['release']['full'] =~ /17/ )
	            {
        	     notify { "17.10 x2go is different!!!" : }
	            }else{
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
			package { 'x2gomatebindings' : 
				    ensure => 'latest' , 
#				    require => Apt::Ppa['ppa:x2go/stable'], 
                                    require => [ Apt::Ppa['ppa:x2go/stable'], Class['apt::update'] ],
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

