class iscsi
{
   case $operatingsystem {
	/RedHat|CentOS|Fedora/: {
		file {  "/etc/iscsi/iscsid.conf":
			content => template("$PUPPETFILES/$operatingsystem/etc/iscsid.conf"),
			mode => 700,
		}
		file {  "/etc/iscsi/initiatorname.iscsi":
			content => template("$PUPPETFILES/$operatingsystem/etc/iscsi/initiatorname.iscsi.erb"),
			mode => 644,
		}
		if($lsbmajdistrelease < 6)
		{
			package { "iscsi-initiator-utils":	ensure => installed;
				  "device-mapper-multipath":	ensure => installed;
				  "dkms":			ensure => installed;
				  "kernel-devel":		ensure => installed;
				}
		     	package { "equallogic-host-tools":	ensure => installed,
				  alias => equallogichosttools,
			}
		} else {
		     	package { "iscsi-initiator-utils":	ensure => installed;
				  "device-mapper-multipath":	ensure => installed;
				  "dkms":			ensure => installed;
				  "kernel-devel":		ensure => installed;
			}
		     	package { "equallogic-host-tools":	ensure => installed,
				  alias => equallogichosttools,
			}
     		}

		service { "iscsi":
                        path            => "/etc/init.d/iscsi",
                        enable          => true,
                        provider        => redhat,
		}
		service { "iscsid":
                        path            => "/etc/init.d/iscsid",
                        enable          => true,
                        provider        => redhat,
		}
		service { "ehcmd":
                        path            => "/etc/init.d/ehcmd",
                        enable          => true,
                        provider        => redhat,
			ensure		=> running,
			require		=> Package[equallogichosttools];
		}
        }
	default: {
		#
		# warn in the puppet log
		#
		notice("$operatingsystem OS not supported for recipe iscsi (client)")
  		}
 	}
}
