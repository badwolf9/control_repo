##

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
# MJF
# ################################
#
}