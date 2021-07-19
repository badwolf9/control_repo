## OS :: Redhat;Ubuntu LTS;Solaris;
# WIKI START SSH recipes::hpc
######################################
#
# h3. Host / Service groups affected
#
# * *all* for file creation
#
# h3. Services affected
# * *ssh* stuff 
#
# h3. Files / directories / links affected
# * REPLACE :
# * DEPLOY  : hpc key to headnodes and grid nodes
#
# h3. What happens
#
#
#
###########
# WIKI STOP

class ssh_itsc::hpc 
{
 $ssh_user_name = 'hpc'
 if $facts['hostname'] =~ /(bs-solaris42|bs-openindiana42|bs-rhel?p4client|bs-ubup4client00?|bs-headnode01|bs-headnode02|bs-grid??)/ {
   ssh_itsc::deploy_key { $ssh_user_name:
     ssh_key_type  => lookup('ssh_itsc::special_keys')[$ssh_user_name][ssh_key_type],
     ssh_key       => lookup('ssh_itsc::special_keys')[$ssh_user_name][ssh_key],
     ssh_user      => lookup('ssh_itsc::special_keys')[$ssh_user_name][ssh_user],
     ssh_name      => $ssh_user_name,
     ssh_ensure    => lookup('ssh_itsc::special_keys')[$ssh_user_name][ssh_ensure],
     ssh_options   => lookup('ssh_itsc::special_keys')[$ssh_user_name][ssh_options],
     }
  }
}