# WIKI START Recipe Filesystems::nfs4
## OS :: Redhat ;Ubuntu;Debian;Fedora; #Solaris; #MacOS X
######################################
#
# h3. Centreon Dependencies
##EXEC::EXEC_FIND_DEPENDENCIES ###FILEPATH###/###FILENAME###
#
# h3. Host / Service groups affected
#
# * *all supported*
#
# h3. Services affected
# * *idmap* enabled and started
#
# h3. Files / directories / links affected
# * CREATE : /etc/idmapd.conf
# * CREATE : /etc/default/nfs-common (ubuntu)
# * INSTALL nfs-common
# * INSTALL nfs4-acl-tools (not debian/ubuntu)
#
# h3. What happens
#
#	The idmapd is installed and started after its config is established
#
###########
# WIKI STOP

class nfs4
{
   case $facts['kernel']
   {
	"Linux":
	{ 
	        case $facts['os']['name']
		{
		    /Debian|Ubuntu/:{
                  if 'service_nfsserver' in $my_classes {
                    package{
                            nfs-kernel-server: ensure => installed, }
                    }
                  if $facts['os']['release']['full'] =~ /^1[024]/ {
	            if $my_debugflag == 'yes' {notify { 'OS is 10, 12 or 14 LTS' : } }
                    service { "idmapd":
                        ensure => running,
                        enable => true,
                        subscribe  => File[idmapdconf],
                        pattern => "rpc.idmapd",
                       }
                }else{
	            if $my_debugflag == 'yes' {notify { 'OS is 16.04LTS or later' : } }
	        	service { "nfs-config":
	    	                      ensure => running,
		      		      hasstatus => true,
	        		      enable => true,
                                      provider => systemd,
	        		}
                }
			$nfs4pkg="nfs-common"
		    }
		    default:{
				$nfs4pkg="nfs-utils"
				if ($facts['os']['release']['major'] >= '7') {
					$idsvc="nfs-idmap"
				} else {
					$idsvc="rpcidmapd"
				}
				$nfs4tools="nfs4-acl-tools"
		  		package {	$nfs4tools: ensure => installed,  }

				# Start server only if NFS Server class
				if( tagged("service-nfsserver" ) )
				{
					service { "nfs":
						ensure => running,
						enable => true,
						pattern => "nfsd",
						alias => nfsd,
					}
				}
		    }
		}
	
		package {	$nfs4pkg: ensure => installed,  
	      			alias => nfs4_tools,
    	}

        file { "/etc/idmapd.conf":
            owner => "root",
            group => "root",
            mode  => "644",
            content  => epp("nfs4/idmapd.conf.epp" , { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'], }),
            require => Package[nfs4_tools],
            replace => true,
            backup => main,
            alias => idmapdconf,
        }
        file { "/var/run/nrpe.nfs4":
            owner => "root",
            group => "root",
            mode => "755",
            ensure => directory;
        }

        case $facts['os']['name'] { /RedHat|CentOS/ : {
	        service { $idsvc:
	              ensure => running,
	              enable => true,
	              subscribe  => File[idmapdconf],
		      pattern => "rpc.idmapd",
	        }
		}
		}
	}
	default: {
	  notice("$facts['kernel'] OS not supported for nfs4")
	}
   }
}

