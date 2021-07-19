## OS :: Redhat;Ubuntu LTS;Solaris;
# WIKI START SSH recipes::hosts
######################################
#
# h3. Host / Service groups affected
#
# * *all* for file creation
#
# h3. Services affected
# * *ssh* stuff 
#
# h3. Files / directories / links affected
# * REPLACE :
# * DEPLOY  : 
#
# h3. What happens
#
#  Who knows?
#
###########
# WIKI STOP

class ssh_itsc::hosts
{
# figure out what this is supposed to do on bs-smsvr01/smsvr02 and dsvr20
# particularly as can ssh only to smsvr01, smsvr02 is off? and dsvr20 (grid node?) can ping but not ssh


################  This might not be useful any more???

#class ssh::hosts {
#	include ssh::auth
#	$adminhosts  = [ "bs-dsvr20" ]
#	$schosts     = [ "bs-smsvr01", "bs-smsvr02" ]
#	$hostkeys = $hostname ? {   	/(bs-smsvr0?)/ 	 => [ $schosts ],
#				 	/(bs-dsvr20)/ => [ $adminhosts ],
#                        		default      => [ ],
#                	}
#	ssh::auth::key { $hostkeys:}
#	ssh::auth::server { $hostkeys:
#	user => "root",
#        home => $kernel ? {/Darwin/ =>"/var/root/", default => "/root" }}
#}


}