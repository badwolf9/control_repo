# * Install nvidia driver etc. for clients with the relation os_linux_ubuntu_nvidia set.
#   Note:
#   Add clients to the os_linux_ubuntu_cuda group if they have any version of the NVidia CUDA drivers etc installed. 
#   It prevents updating the NVidia graphics driver outside the CUDA environment.
class os_linux_ubuntu::nvidia {
    include apt
   case $kernel {
    'Linux':{
	case $operatingsystem
	{
	   /RedHat|CentOS|Fedora|Arch/: {
	   }
	   /Debian|Ubuntu/: {
            if 'os_linux_ubuntu_cuda' in $my_classes {
             notify { "CUDA present so will not update NVidia driver to latest!" : }
             }else{
	    if ( $facts['os']['release']['full'] =~ /1[678]/ )
	    {
             notify { "I am installing latest NVidia driver" : }
	     if $my_debugflag == 'yes' {notify { "I am installing latest NVidia driver" : }}
	    package { 'nvidia-common' :
	     ensure => 'latest' ,
             }
           # need to run ubuntu-drivers autoinstall
           #
           exec {'ubuntu-drivers autoinstall':
                 path => $facts['path'],
                 command => 'ubuntu-drivers autoinstall',
                 }
	    }else{
	    if $my_debugflag == 'yes' { notify { 'I am installing nvidia on earlier versions!!' : } }
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
