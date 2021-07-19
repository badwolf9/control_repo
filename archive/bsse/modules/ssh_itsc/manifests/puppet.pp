## OS :: Redhat;Ubuntu LTS;Solaris;
# WIKI START SSH recipes::puppet
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
# * DEPLOY  : puppet autosign key to puppet servers
#
# h3. What happens
#
#
#
###########
# WIKI STOP

class ssh_itsc::puppet {

if $facts['hostname'] =~ /(bs-puppet??|bs-grid??)/ {

  $ssh_user_name = 'puppetAutoSignKey'

  ssh_authorized_key { $ssh_user_name:
    ensure => lookup('ssh_itsc::special_keys')[$ssh_user_name][ssh_ensure],
    user   => lookup('ssh_itsc::special_keys')[$ssh_user_name][ssh_user],
    type   => lookup('ssh_itsc::special_keys')[$ssh_user_name][ssh_key_type],
    key    => lookup('ssh_itsc::special_keys')[$ssh_user_name][ssh_key],
    options=> lookup('ssh_itsc::special_keys')[$ssh_user_name][ssh_options],
    }

  }

}