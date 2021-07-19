# WIKI START Recipe group Daemons::recipe udev
## OS :: Redhat ;!Ubuntu;Fedora ;!Solaris; #MacOS X
######################################
#
# h3. Host+Servicegroups affected
#
# * *all* hosts
#
# h3. Files / directories / links affected
# * CREATE : /etc/udev/rules.d/99-vmware-scsi.rules
#
# h3. What happens
#
#	* Modify the timeout value for VMware SCSI devices so that
#         in the event of a failover, we don't time out.
#
###########
# WIKI STOP

class udev
{
   case $facts['kernel'] {
	"Linux": {
		if($facts['os']['name'] =~ /RedHat|CentOS|Fedora/)
		{
		file { "/etc/udev/rules.d/99-vmware-scsi.rules":
			owner => "root",
                        group => "root",
                        mode  => '0644',
                        content => template("udev/99_vmware_scsi.rules.erb"),
                        replace => true,
                        alias => udevconf,
                        backup => main,
		}
		}
     	}
	default: {
		notice("$facts['kernel'] OS not supported for recipe udev")
  	}
   }
}
