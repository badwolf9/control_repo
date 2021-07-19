# WIKI START Recipe Dell::hardware_dell
## OS :: Redhat;Ubuntu; #Solaris; #MacOS X
######################################
#
# h3. Host+Servicegroups affected
#
# * Hosts with group hardware_dell
#
# h3. Services affected
# * *srvadmin services running
#
# h3. Files / directories / links affected


# * CREATE : 
# * CREATE : 
# * ENABLE SERVCE : 
# * ENABLE SERVCE : 
# h3. What happens
#
#	* Relation in Centreon set to either Dalco or Dell and appropriate management syste
#         software installed and started.
#
#
###########
# WIKI STOP

class hardware_dell
{
  case $::operatingsystem {
    /RedHat|CentOS|Fedora/: {
        
      file    {  "/etc/yum.repos.d/dell-omsa-repository.repo":
        content => file('hardware_dell/dell-omsa-repository.repo'),
        mode => '0644',
      }
                                                                                                                                                          
      package { "srvadmin*":
        ensure => installed,
      }
      package { "firmware-tools":
        ensure => installed,
      }
        
      service { "racsvc":
	path		=> "/etc/init.d/racsvc",
	enable		=> true,
        provider	=> redhat,
	ensure		=> running,
	pattern		=> "racsvc",
      }

      service { "instsvcdrv":
	path		=> "/etc/init.d/instsvcdrv",
	enable		=> true,
        provider	=> redhat,
	ensure		=> running,
	pattern		=> "instsvcdrv",
      }
      service { "dataeng":
	path		=> "/etc/init.d/dataeng",
	enable		=> true,
        provider	=> redhat,
	ensure		=> running,
	pattern		=> "dataeng",
      }
      service { "dsm_om_shrsvc":
	path		=> "/etc/init.d/dsm_om_shrsvc",
	enable		=> true,
        provider	=> redhat,
	ensure		=> running,
	pattern		=> "dsm_om_shrsvc",
      }


      
#      file { "/etc/ganglia/gmond.conf":
# 	owner => "root",
#	group => "root",
#        mode  => 755,
#	content  => template("$PUPPETFILES/$operatingsystem/etc/ganglia/gmond.conf"),
#	replace => true,
#	alias => gmondconf,
#      }
                
		# test grid
#		file { "/etc/init.d/sgeexecd.bsseHPC-Test":
# 			owner => "root",
#			group => "root",
#			mode  => 755,
#			content  => template("$PUPPETFILES/$operatingsystem/etc/init.d/sgeexecd.bsseHPC-Test"),
#			replace => true,
#		}
#		service { "sgeexecd.bsseHPC-Test":
#			path		=> "/etc/init.d/sgeexecd.bsseHPC-Test",
#			enable		=> true,
#			provider	=> redhat,
#			ensure		=> stopped,
#		}
    }
    default: {
      #
      # warn in the puppet log
      #
      notice("$operatingsystem OS not supported for recipe hardware_dell")
    }
  }
}
