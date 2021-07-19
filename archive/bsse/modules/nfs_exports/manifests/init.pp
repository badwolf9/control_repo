# WIKI START Recipe Filesystems::nfs_exports
## OS :: Redhat;Ubuntu;Debian;Fedora; #Solaris; #MacOS X
######################################
#
# h3. Centreon Dependencies
##EXEC::EXEC_FIND_DEPENDENCIES ###FILEPATH###/###FILENAME###
#
# h3. Host / Service groups affected
#
# * *service-nfs* linux machines
#
# h3. Services affected
# * */etc/exports* is installed
# * *nfs* enabled and started
#
# h3. Files / directories / links affected
# * CREATE : /etc/exports
#
# h3. What happens
#
#	The nfs exports file is installed and nfs is started after its config is established
#
###########
# WIKI STOP

#my_networks:
#  specialServerNets: ["172.31.45.0/24"]
#  nonroutableServerNets: ["10.20.8.0/22", "172.31.27.128/26", "172.31.92.0/24"]
#  routableServerNets: ["129.132.27.0/25","129.132.151.0/26","195.176.122.0/24","129.132.76.128/26", "2001:67c:10ec:2643::/118"]
#  dockNets: ["129.132.228.0/23","129.132.128.64/26","129.132.97.128/25","129.132.42.0/25","129.132.151.192/26"]
#  specNets:  ["172.31.52.128/25","172.31.72.128/25"]
#  dmzNets:  ["129.132.14.128/26","129.132.0.192/28","2001:67c:10ec:3c42::/118"]
#  idNets: ["129.132.178.128/27", "129.132.199.16/28", "129.132.77.96/27", "129.132.168.224/27"]

class nfs_exports
{
  case $facts['kernel']
  {
    "Linux":
    {
       if "service_nfsserver" in $my_classes {
           if $facts['os']['family'] =~ /RedHat/ {
                $my_nfs = "nfs"
                }else{
                $my_nfs = "nfs-server"
                }
                service { $my_nfs:
			ensure => running,
			enable => true,
			pattern => "nfsd",
			alias => nfsd,
                        }
#
if lookup('nfs_exports::shares')[$facts['hostname']] != undef {
# --- start of found hostname in hiera common.yaml
$shares = lookup('nfs_exports::shares')[$facts['hostname']]
#$sharedirs = $shares.map | $key, $value | {
#$value[0]
#}
#notify { "Share folders are $sharedirs " : }
$mjfexp = $shares.map | $key, $value | {
  $sharedir = values($value)[1]
  $nshares = join(flatten(values($value)[0].map |$netsel |{
  if $netsel =~ /Nets/ {
  lookup("my_networks.$netsel")
  }else{
  $netsel
  }
  }).map | $netsel0 | {
   # get the parameters of the share
   $shareparams = values($value)[2]
   # and put the network address and params together
   "${netsel0}$shareparams"
   }, " ")
 # use ! as an element separator to make it easy later to split into an array
 "$sharedir !  $nshares !"
 }
# The output of all this stuff into a hash to pass to the original template:
$nfsshares = Hash(split(join($mjfexp, ""), "!"))
#
    	file { "/etc/exports":
    	        owner => "root",
    	        group => "root",
    	        mode => '0644',
                content => epp('nfs_exports/exports.epp', { 'fqdn' => $facts['fqdn'], 'puppetversion' => $facts['puppetversion'], 'shares' => $nfsshares, }),
	        notify => Service["nfsd"],
    	}


#----- end lookup is not undefined    	
         }
#---- end service_nfsserver 
        }
#--- end Kernel is Linux
    }
    default: {
	      notice("$facts['kernel'] OS not supported for nfs_exports")
    }
#--end case kernel
   }
#- end class
}
