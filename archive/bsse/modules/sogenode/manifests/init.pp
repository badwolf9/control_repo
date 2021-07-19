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

class sogenode
{
  $gridroot="/usr/local/grid"
  $sgepath="/usr/local/grid/soge"
  $sgebinpath="${sgepath}/bin/lx24-amd64"
  case $operatingsystem {
	/RedHat|CentOS|Fedora/: {
          if !tagged("ou-service-gridnodes-soge-master") {
	      file { "/etc/init.d/sgeexecd.bsse-SoGE":
 	      owner => "root",
	      group => "root",
	      mode  => '755',
	      #content  => template("sogenode/sgeexecd.bsse-SoGE"),
	      replace => true,
	      alias => sgeExecd-SoGE,
	    }
	    service { "sgeexecd.bsse-SoGE":
	      path		=> "/etc/init.d/sgeexecd.bsse-SoGE",
	      enable		=> true,
	      provider	=> redhat,
	      ensure		=> running,
	      pattern		=> "sge_execd",
	      require 	=> File[sgeExecd-SoGE],
	    }
          }  
          else {
            notice("This is a master host, won't run sgeexecd!")
	    service { "sgeexecd.bsse-SoGE":
	      path		=> "/etc/init.d/sgeexecd.bsse-SoGE",
	      enable		=> false,
	      provider	=> redhat,
	      ensure		=> "stopped",
	      pattern		=> "sge_execd",
	      require 	=> File[sgeExecd-SoGE],
	    }
            file { "/etc/init.d/sgeexecd.bsse-SoGE":
 	      owner => "root",
	      group => "root",
	      mode  => '755',
	      #content  => template("sogenode/sgeexecd.bsse-SoGE"),
	      replace => true,
	      alias => sgeExecd-SoGE,
              ensure => 'absent',
	    }
            file { "/etc/init.d/sgemaster.bsse-SoGE":
              owner => "root",
              group => "root",
              mode  => '755',
              content  => template("sogenode/sgemaster.bsse-SoGE"),
              replace => true,
              alias => sgeMaster-SoGE,
            }
            service { "sgemaster.bsse-SoGE":
              path            => "/etc/init.d/sgemaster.bsse-SoGE",
              enable          => true,
              provider        => redhat,
              ensure          => running,
              pattern         => "sge_qmaster",
              require         => File[sgeMaster-SoGE],
            }
           
          }
          file { "/usr/lib64/nagios/plugins/check_griderrors.sh":
 	    owner => "root",
	    group => "root",
	    mode  => '755',
	    #content  => template("sogenode/plugins/check_griderrors.sh"),
	    replace => true,
	  }

          package { "ganglia-gmond.x86_64":
            ensure          => installed,
          }
	  file { "/etc/ganglia/gmond.conf":
 	    owner => "root",
	    group => "root",
	    mode  => '755',
	    #content  => template("sogenode/gmond.conf"),
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
