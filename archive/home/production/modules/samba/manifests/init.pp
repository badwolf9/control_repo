##
##       Currently valid puppet groups are:
##               =>      Recipe Systemconfig
##               =>      Recipe Daemons
##               =>      Recipe Network
##               =>      Recipe Filesystems
##               =>      Recipe Other
##
# WIKI START Recipe Daemons::samba
## OS :: Redhat ;Ubuntu;Fedora; !Solaris; !MacOS X
######################################
#
# h3. Host+Servicegroups affected
#
# * *all* hosts will be get a valid smb.conf (for ADS bind)
#
# h3. Services affected
# * *none* 
#
# h3. Files / directories / links affected
# * CREATE : /etc/samba/smb.conf
#
# h3. What happens
#
#	* generate a valid smb.conf according to group membership (see files/RedHat/samba/smb.conf.erb
#
###########
# WIKI STOP
class samba
#define samba($my_groups)
{
        # 20171220 MJF: This module and template were not getting the my_groups array from classes.pp.
        # Use a local copy of my_groups here from the my_node_classes array in hiera (node specific). This seems to work.
        #
	#	Try to generate an array of ou_groups from hiera lookup
        $data = lookup('my_node_classes')
	$classtemp = inline_template("<% @data.each do |c| %><% if c.to_s =~ /^ou_groups/ then %><%= c.to_s.sub(/^ou_groups_/, '') %>,<% end %><% end %>")
	#	Chop off the trainling ','
	$classchop = inline_template("<%= @classtemp.to_s.chop() %>")
	#	Split string into an array
	$my_groups = split($classchop,',')

	# become more quiet
   	# notice("Netgroups defined for SAMBA : $my_groups")
      case $::kernel {
	"Linux": {
   	   if 'service_net_samba' in $my_classes   {
		file { "/etc/samba/smb.conf":
			owner => "root",
			group => "root",
			mode  => '0644',
			replace => true,
			backup => main,
                        content =>  epp('samba/smb.conf.epp', { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'], 'my_classes' => $my_classes, 'my_groups' => $my_groups, }),
			alias => smb_conf
    		}
		if 'service_samba' in $my_classes {
			service { "smb":
				ensure => running,
				enable => true,
				subscribe  => File[smb_conf],
				pattern => "smbd",
			}
		} else {
			service { "smb":
				ensure => stopped,
				enable => false,
				pattern => "smbd",
			}

		}
     	    }
	}
	'SunOS': {
		notice("Samba should not be configured on Solaris.")
	}
	default: {
		# notice("$kernel not supported for recipe SAMBA")
  		} 	
	}
}
