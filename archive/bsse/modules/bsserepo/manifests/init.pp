# WIKI START Recipe Systemconfig::bsserepo
## OS :: Redhat;#Ubuntu;#Fedora;#Solaris; #MacOS X
######################################
#
# h3. Host+Servicegroups affected
#
# * *all* hosts running el5 / el6 / el7
#
# h3. Services affected
# *yum*
#
# h3. Files / directories / links affected
# * CREATE : /etc/yum.repos.d/bsse.repo
#
# h3. What happens
#
#	the bsse repositories are enabled
#
###########
# WIKI STOP

class bsserepo
{
	case $operatingsystem  {
	  /RedHat|CentOS|Fedora/: {
		case $facts['os']['release']['major'] {
		 5: {
		 	$bsserepofile="bsse5.repo.erb"
		 	$bsserepoRPM="BSSE-Repo"
		 }
		 6: {
		 	$bsserepofile="bsse6.repo.erb"
		 	$bsserepoRPM="BSSE-Repo-EL6"
		 }
		 7: {
		 	$bsserepofile="bsse7.repo.erb"
		 	$bsserepoRPM="BSSE-Repo-EL7"
		 }
		 default: {
		 	$bsserepofile="bsse7.repo.erb"
		 	$bsserepoRPM="BSSE-Repo-EL7"
		 }
		}
		if $my_debugflag == 'yes' {notify { "BSSE REPO RPM is ${bsserepoRPM}" : } }
		package { "$bsserepoRPM":
				ensure => absent,
			}
		file 	{  "/etc/yum.repos.d/bsse.repo":
				content => template("bsserepo/$bsserepofile"),
				mode => '644';
			}
		file 	{  "/etc/yum.repos.d/bsse6.repo":
				backup => main,
				ensure => absent,
			}
		file 	{  "/etc/yum.repos.d/bsserh6.repo":
				backup => main,
				ensure => absent,
			}
     		}
     	  /Ubuntu|Debian/: { notice("Debian family not supported by bsserepo") }
	  default: {
			#
			# warn in the puppet log
			#
			notice("$kernel OS not supported for recipe bsserepo")
  			}
 		}
}
