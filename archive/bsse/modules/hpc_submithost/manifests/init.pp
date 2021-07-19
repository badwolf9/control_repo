# WIKI START Recipe Daemons::hpc_submithost
## OS :: Redhat 5;RedHat 6;!Ubuntu 10;!Fedora 13; #Solaris; #MacOS X
######################################
#
# h3. Host+Servicegroups affected
#
# * All SGE submit-hosts
#
# h3. Services affected
# 
#
# h3. Files / directories / links affected
# * CREATE : /etc/modulefiles/*
# * CHANGE : /etc/profiles
#
# h3. What happens
#
#	* installs the modulefiles
#	* enables the module environment
#
###########
# WIKI STOP

class module_env
{

# Set path and directory
$moduledir    = "/etc/modulefiles"
$module_app   = "$moduledir/applications"
$module_env   = "$moduledir/environment"
$module_lib   = "$moduledir/libraries"
$module_com   = "$moduledir/compiler"
$module_penv  = "$moduledir/parallel-environments"

# specific
$app_matlab   = "$module_app/matlab"


   case $kernel {
	"Linux": {

		# Install module files
                
		file { "$module_env/module":
                        mode => "644",
                        owner => root,
                        group => root,
                        source => "puppet://bs-puppet42.ethz.ch/files/$operatingsystem/$module_env/module",
                        ensure => present,
                }
     	}
	default: {
		#
		# warn in the puppet log
		#
		notice("$kernel OS not supported for recipe hpc_submithost")
  		}
 	}
}
