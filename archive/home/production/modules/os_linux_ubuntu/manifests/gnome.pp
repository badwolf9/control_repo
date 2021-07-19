# WIKI START Ubuntu config::os_linux_ubuntu_gnome
## OS :: !Redhat ;Ubuntu LTS;!Fedora ; !Solaris; !MacOS X
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
# * Install Gnome Desktop
#
# h3. What happens
#
# * 
#
###########
# WIKI STOP

class os_linux_ubuntu::gnome {
    include apt
   case $kernel {
    'Linux':{
	case $operatingsystem {
	   /RedHat|CentOS|Fedora|Arch/: {
	   }
	   /Debian|Ubuntu/: {
	    if ( $facts['os']['release']['full'] =~ /1[46]/ )
            {
	     if $my_debugflag == 'yes' {notify { "Ubuntu 14 & 16 !!!" : }}
#	    package { 'ubuntu-desktop' :
#	     ensure => 'latest' ,
#             }
            }elsif ( $facts['os']['release']['full'] =~ /18|20/ )
	    {
	     if $my_debugflag == 'yes' {notify { "Ubuntu 17++ gets KDE!!!" : }}
	    package { 'ubuntu-desktop' :
	     ensure => 'latest' ,
             }
	    }
           }
        default: { }
        }
      }
    'SunOS': { }
    'Darwin': { }
    default: { }
    }
}
