# WIKI START Recipe Daemons::geneious
## OS :: Redhat;Ubuntu;Solaris
######################################
#
# h3. Host+Servicegroups affected
#
# * *all* geneious servers
#
# h3. Services affected
# * *postgres server and related files* installed
#
# h3. Files / directories / links affected
# * CREATE : /local0/pgsql and admin folders
#
# h3. What happens
#
#	* postgres server is installed ready for geneious lic mgr
#       * Not used at time of creating this page.
###########
# WIKI STOP

class geneious
{
   case $osfamily {
	"RedHat": {
#ensure firewall is off

# set up folder on second drive

#install postgres server

# set files for scripts etc


	}
	default: {
		notice("$osfamily not supported for recipe geneious")
  	}
   }
}

