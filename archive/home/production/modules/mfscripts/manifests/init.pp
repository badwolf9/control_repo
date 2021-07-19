
class mfscripts
{
   $mjfscriptbin=lookup('mfscripts::mfscriptbin')
   notify { 'SCRIPTBIN1' : message => "Script folder is $mfscriptbin" }
   case $kernel {
	"Linux": {
#		group { 'nrpe' :
#			ensure => present,
#			}
		file {  "/etc/mjf":
			mode => '0750',
			ensure => directory,
			owner => "root",
#			group => "nrpe",
		}
		file { "$mfscriptbin":
			ensure => directory,
			owner => "root",
			group => "root",
			mode => '0700',
		    }
#		file {  "$mfscriptbin/clearLinuxMemoryCache.sh":
#				source => "puppet:///modules/mfscripts/clearLinuxMemoryCache.sh",
#				mode => '0700';
#			"$mfscriptbin/rhn6.sh":
#				source => "puppet:///modules/mfscripts/rhn6.sh",
#				mode => '0700';
#			"$mfscriptbin/joinAD.sh":
#				source => "puppet:///modules/mfscripts/joinAD.sh",
#				mode => '0700';
#			"$mfscriptbin/rhn.sh":
#				source => "puppet:///modules/mfscripts/rhn.sh",
#				mode => '0700';
#			"$mfscriptbin/clearLogCollector":
#				source => "puppet:///modules/mfscripts/clearLogCollector",
#				mode => '0700';
#			"$mfscriptbin/registerHost.sh":
#				source => "puppet:///modules/mfscripts/registerHost.sh",
#				mode => '0700';
#			"$mfscriptbin/cleanAndRemove.sh":
#				source => "puppet:///modules/mfscripts/cleanAndRemove.sh",
#				mode => '0700';
#		}
     	}
	default: {
		#
		# warn in the puppet log
		#
		notice("$kernel OS not supported for recipe mfscripts")
  		}
 	}
}
