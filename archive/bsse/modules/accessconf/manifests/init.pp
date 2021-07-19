##
##      Currently valid puppet groups are:
##              =>      Recipe Systemconfig
##              =>      Recipe Daemons
##              =>      Recipe Network
##              =>      Recipe Filesystems
##              =>      Recipe Other
##
# WIKI START Recipe Systemconfig::accessconf
## OS :: Redhat;Ubuntu; #Solaris; #MacOS X
######################################
#
# h3. Host / Service groups affected
#
# * *all linux systems in group ou-service-user-login using access.conf*
#
# h3. Services affected
# * *pam_access* configured
#
# h3. Files / directories / links affected
# * CREATE : /etc/security/access.conf
#
# h3. What happens
#
#       The config files for pam_access.so are created (and thereby activated)
#
###########
# WIKI STOP
# $my_groups comes from classes.pp

class accessconf {
    case $::kernel {
        /Linux/: {
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
# create the access.conf file in the template.
                    $fname = '/etc/security/access.conf'
#                    $modtime = exec{ getmtime:
#                                      command => "/usr/bin/stat -c \"%y\" $fname",
#                                }

#$modtime = File["/etc/security/access.conf"]["mtime"]
#notify { "In accessconf the Groups of this machine are  $my_groups" : }
#notify { " In accessconf the classes are $data" : }
#notice ("modtime is $modtime")
		    file { "$fname":
   	             ensure => present,
                     replace => true,
                     backup => main,
                     #content => template("accessconf/access.conf.erb"),
                     content => epp('accessconf/access.conf.epp', { 'fqdn' => $facts['fqdn'], 'modtime' => mtime, 'puppetversion' => $facts['puppetversion'], 'my_classes' => $data, 'my_groups' => $my_groups, }),
                     }
	          }
          default: {}
	}	
}
