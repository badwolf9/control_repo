class os_linux_ubuntu::kde {
    include apt
   case $kernel {
    'Linux':{
	case $operatingsystem {
	   /RedHat|CentOS|Fedora|Arch/: {
	   }
	   /Debian|Ubuntu/: {
           if os_linux_ubuntu_kde in $my_classes {
           notify { "Will install  KDE desktop" : }
	    if ( $facts['os']['release']['full'] =~ /1[46]/ )
            {
	     if $my_debugflag == 'yes' {notify { "Ubuntu 14 & 16 !!!" : }}
	    package { 'kubuntu-desktop' :
	     ensure => 'latest' ,
             }
            }elsif ( $facts['os']['release']['full'] =~ /1[89]|2[01]/ )
	    {
	     if $my_debugflag == 'yes' {notify { "Ubuntu 18++ gets KDE!!!" : }}
	    package { 'kubuntu-desktop' :
	     ensure => 'latest' ,
             }
	    }
            # in all cases install the kde desktop manager and make sure that the xorg input package is installed.
            if ( $facts['os']['release']['full'] =~ /1[4]/ )
            {
            package { 'kdm' :
	     ensure => 'latest' ,
                    }
            }else{
            package { 'sddm' :
	     ensure => 'latest' ,
                    }
            }
	    package { 'xserver-xorg-input-all' :
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
