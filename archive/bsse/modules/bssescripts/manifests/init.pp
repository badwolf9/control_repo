# WIKI START Recipe Systemconfig::bssescripts
## OS :: Redhat ;Ubuntu ;Fedora ;Solaris; #MacOS X
######################################
#
# h3. Host+Servicegroups affected
#
# * *all* hosts with supported os
#
# h3. Services affected
# *none*
#
# h3. Files / directories / links affected
# * CREATE : /etc/bsse

# h3. What happens
#
#	Helper scripts are deployed and kept in sync
#	needs nrpe user and /root/bin folder to exist
#
###########
# WIKI STOP

class bssescripts
{
   $bssescriptbin=lookup('bssescripts::bssescriptbin')
   # notify { 'SCRIPTBIN1' : message => "Script folder is $bssescriptbin" }
   case $kernel {
	"Linux": {
#		group { 'nrpe' :
#			ensure => present,
#			}
		file {  "/etc/bsse":
			mode => '0750',
			ensure => directory,
			owner => "root",
			group => "nrpe",
		}
		file { "$bssescriptbin":
			ensure => directory,
			owner => "root",
			group => "root",
			mode => '0700',
		    }
		file {  "$bssescriptbin/clearLinuxMemoryCache.sh":
				source => "puppet:///modules/bssescripts/clearLinuxMemoryCache.sh",
				mode => '0700';
			"$bssescriptbin/rhn6.sh":
				source => "puppet:///modules/bssescripts/rhn6.sh",
				mode => '0700';
			"$bssescriptbin/joinAD.sh":
				source => "puppet:///modules/bssescripts/joinAD.sh",
				mode => '0700';
			"$bssescriptbin/rhn.sh":
				source => "puppet:///modules/bssescripts/rhn.sh",
				mode => '0700';
			"$bssescriptbin/clearLogCollector":
				source => "puppet:///modules/bssescripts/clearLogCollector",
				mode => '0700';
			"$bssescriptbin/registerHost.sh":
				source => "puppet:///modules/bssescripts/registerHost.sh",
				mode => '0700';
			"$bssescriptbin/cleanAndRemove.sh":
				source => "puppet:///modules/bssescripts/cleanAndRemove.sh",
				mode => '0700';
		}
		if(tagged("service-kvm")){
			file { "$bssescriptbin/makeKick.sh":
				target => "/local0/kvm/bin/makeKick-iscsi.sh",
				ensure => link,
				replace => true,
			}
		}
     	}
	default: {
		#
		# warn in the puppet log
		#
		notice("$kernel OS not supported for recipe bssescripts")
  		}
 	}
}
