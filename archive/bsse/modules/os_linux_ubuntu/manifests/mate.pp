# WIKI START Ubuntu config::os_linux_ubuntu_mate
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
# * Install Mate Desktop
#
# h3. What happens
#
# * On 14.04 do not install Mate desktop as it has a dependency on ntp. 14.04 will soon be EoLife
# * On 16.04 install XFCE4 desktop as this does not have a dependency on ntp
# * On 18.04 install mate desktop as this does not have a dependency on ntp
#
###########
# WIKI STOP

class os_linux_ubuntu::mate {
    include apt
   case $kernel {
    'Linux':{
	case $operatingsystem {
	   /RedHat|CentOS|Fedora/: {
	   }
	   /Debian|Ubuntu/: {
	    if ( $facts['os']['release']['full'] =~ /1[46]/ )
            {
	     if $my_debugflag == 'yes' {notify { "Ubuntu 14 & 16 need XFCE 4!!!" : }}
	    package { 'xfce4' :
	     ensure => 'latest' ,
             }
            }elsif ( $facts['os']['release']['full'] =~ /18|20/ )
	    {
	     if $my_debugflag == 'yes' {notify { "Ubuntu 17++ gets Mate!!!" : }}
	    package { 'ubuntu-mate-desktop' :
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
