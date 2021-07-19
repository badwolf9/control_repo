##
##      Puppet D-BSSE Framework documentation
##
# WIKI START D-BSSE Puppet 4 Framework::Puppet config basenode.pp
## OS :: All
######################################
#
# h3. Purpose of the file
#
# * Defines basic variables - used globally - such as networks, dns server, gateways, libdirs, generic uid/gid's
# * Reads Hiera to get base data
# h3. See also
#
# * [Puppet config common.yaml]
# * [Puppet config Debian.yaml]
# * [Puppet config RedHat.yaml]
#
###########
# WIKI STOP

class baseclass {
        # Ubuntu  uses /usr/lib
	if($architecture == "x86_64") and ($facts['os']['family'] == 'RedHat') {
		$libdir = "/usr/lib64"
	} else {
		$libdir = "/usr/lib"
	}
### variables in hiera common.yaml 20171125
##Note: if these are used in only one module/class they can be named as class::variable
##      and called directly from the manifest.
##
$rootgroup = lookup('rootgroup')
$my_project = lookup('my_project')
$my_puppet_server = lookup('my_puppet_server')
$dns_servers = lookup('dns_servers')
$domain = lookup('domain')
$syslog_servers = lookup('syslog_servers')
$rsyslog_servers = lookup('rsyslog_servers')
$my_timezone = lookup('my_timezone')
$my_ntp_server = lookup('my_ntp_server')
$my_update = lookup('my_update')
$my_monitor = lookup('my_monitor')
#
# ################################
# Modified MJF for Puppet 4
# ################################
#
        if 'ou_groups_cina' in $my_classes {
            notice('CINA')
            $ng0 = 'cina-user'
        }

        if 'ou_groups_bewi' in $my_classes {
	    notice('BEWI')
	  $ng1 = 'bewi-user'
	}
        if 'ou_groups_stel' in $my_classes {
	    notice('STEL')
	     $ng2 = 'stel-user'
        }
        if 'ou_groups_hima' in $my_classes {
	    notice('HIMA')
	    $ng3 = 'hima-user'
        }
        if 'ou_groups_itsc' in $my_classes {
	    notice('ITSC')
	    $ng4 = 'itsc-user'
        }
# build an array of user groups having only defined values
	$netgroup = delete_undef_values([$ng0,$ng1,$ng2,$ng3,$ng4])
        #notify { 'OUGROUPS' : message => "Found ou_groups $netgroup" }
}

class baseclass::cina
{
#	$netgroup = [ "cina-user" ]
}
