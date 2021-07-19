# WIKI START Recipe Daemons::sgenode
## OS :: Redhat 5;RedHat 6;!Ubuntu 10;!Fedora 13; #Solaris; #MacOS X
######################################
#
# h3. Host+Servicegroups affected
#
# * Hosts with ou-service-gridnode group membership
#
# h3. Services affected
# * *sgeexecd* installed and started
# * *gmond* ganglia client node
#
# h3. Files / directories / links affected
# * CREATE : /etc/init.d/sgeexecd.bsseGrid
# * CREATE : /etc/ganglia/gmond.conf
# * CREATE : /usr/lib64/nagios/plugins/check_griderrors.sh
# * ENABLE SERVCE : sgeexecd.bsseGrid
# * ENABLE SERVCE : gmond
#
# h3. What happens
#
#	* installs the init.d script for a sge exec host
#	* enables the sge exec service and starts it
#
###########
# WIKI STOP

class sgenode
{
   case $operatingsystem {
	/RedHat|CentOS|Fedora/: {
		file { "/etc/init.d/sgeexecd.bsseGrid":
 			owner => "root",
			group => "root",
			mode  => 755,
			##content  => template("$PUPPETFILES/$operatingsystem/etc/init.d/sgeexecd.bsseGrid"),
			replace => true,
			alias => sgeExecdGrid,
		}
		file { "/usr/lib64/nagios/plugins/check_griderrors.sh":
 			owner => "root",
			group => "root",
			mode  => 755,
			#content  => template("$PUPPETFILES/$operatingsystem/usr/lib64/nagios/plugins/check_griderrors.sh"),
			replace => true,
		}
		file { "/etc/init.d/sgeexecd.bsseSGE8":
 			owner => "root",
			group => "root",
			mode  => 755,
			#content  => template("$PUPPETFILES/$operatingsystem/etc/init.d/sgeexecd.bsseSGE8"),
			replace => true,
                          ensure => 'absent',
			alias => sgeExecdSGE,
		}
		file { "/etc/init.d/sgeexecd.bsseGE":
			owner => "root",
			group => "root",
			mode  => 755,
			#content  => template("$PUPPETFILES/$operatingsystem/etc/init.d/sgeexecd.bsseGE"),
			replace => true,
                        alias => sgeExecdGE,
                        ensure => 'absent',
		}
		service { "sgeexecd.bsseGrid":
			path		=> "/etc/init.d/sgeexecd.bsseGrid",
			enable		=> true,
			provider	=> redhat,
			ensure		=> running,
			pattern		=> "sge_execd",
			require 	=> File[sgeExecdGrid],
		}
                package { "ganglia-gmond.x86_64":
                        ensure          => installed,
                }
		service { "sgeexecd.bsseHPC":
			path		=> "/etc/init.d/sgeexecd.bsseHPC",
			enable		=> false,
			provider	=> redhat,
			ensure		=> stopped,
			require		=> File[gridswlink],
		}
		file { "/etc/ganglia/gmond.conf":
 			owner => "root",
			group => "root",
			mode  => 755,
			#content  => template("$PUPPETFILES/$operatingsystem/etc/ganglia/gmond.conf"),
			replace => true,
			alias => gmondconf,
		}
		service { "gmond":
			path		=> "/etc/init.d/gmond",
			enable		=> true,
			provider	=> redhat,
			ensure		=> running,
			pattern		=> "sge_execd",
			require 	=> File[gmondconf],
		}

     	}
	default: {
		#
		# warn in the puppet log
		#
		notice("$operatingsystem OS not supported for recipe sgenode")
  		}
 	}
}
