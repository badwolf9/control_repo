## OS :: Redhat;Ubuntu LTS;Solaris;
# WIKI START SSH recipes::privusers
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
# * DEPLOY  : user keys to selected machines
#
# h3. What happens
#
#
#
###########
# WIKI STOP

class ssh_itsc::privusers
{
  #$hash_name = 'ssh_itsc::special_users'
  #$priv_users = lookup("${hash_name}")
  if $facts['hostname'] =~ /(bs-ubup4client001|bs-svn02|bs-puppet42|bs-nagiostest01|bs-appsvr01|bs-apptest02|bs-monitor01|bs-monitor02|bs-crowd01|bs-wiki01|bs-jira01|bs-lamp02|bs-dsvr43|bs-dsvr44|bs-ssvr05|bs-ssvr09|bs-dsvr37|bs-jpk431|bs-dsvr33)/ {
   $ssh_user_name1 = 'bneff'
    ssh_itsc::deploy_key { $ssh_user_name1:
      ssh_key_type => lookup('ssh_itsc::special_keys')[$ssh_user_name1][ssh_key_type],
      ssh_key      => lookup('ssh_itsc::special_keys')[$ssh_user_name1][ssh_key],
      ssh_user     => lookup('ssh_itsc::special_keys')[$ssh_user_name1][ssh_user],
      ssh_name     => $ssh_user_name1,
      ssh_ensure   => lookup('ssh_itsc::special_keys')[$ssh_user_name1][ssh_ensure],
      ssh_options  => lookup('ssh_itsc::special_keys')[$ssh_user_name1][ssh_options],
      }
    }

if $facts['hostname'] =~ /(bs-rhel7p4client|bs-rhel6p4client|bs-ubup4client002|bs-svn01|bs-svn03|bs-svn04)/ {
  $ssh_user_name2 = 'brinn'
   ssh_itsc::deploy_key { $ssh_user_name2:
     ssh_key_type  => lookup('ssh_itsc::special_keys')[$ssh_user_name2][ssh_key_type],
     ssh_key       => lookup('ssh_itsc::special_keys')[$ssh_user_name2][ssh_key],
     ssh_user      => lookup('ssh_itsc::special_keys')[$ssh_user_name2][ssh_user],
     ssh_name     => $ssh_user_name2,
     ssh_ensure    => lookup('ssh_itsc::special_keys')[$ssh_user_name2][ssh_ensure],
     ssh_options   => lookup('ssh_itsc::special_keys')[$ssh_user_name2][ssh_options],
      }
    }

if $facts['hostname'] =~ /(bs-ubup4client001|bs-svn01)/ {
  $ssh_user_name3 = 'svnsync'
   ssh_itsc::deploy_key { $ssh_user_name3:
     ssh_key_type  => lookup('ssh_itsc::special_keys')[$ssh_user_name3][ssh_key_type],
     ssh_key       => lookup('ssh_itsc::special_keys')[$ssh_user_name3][ssh_key],
     ssh_user      => lookup('ssh_itsc::special_keys')[$ssh_user_name3][ssh_user],
      ssh_name     => $ssh_user_name3,
     ssh_ensure    => lookup('ssh_itsc::special_keys')[$ssh_user_name3][ssh_ensure],
     ssh_options   => lookup('ssh_itsc::special_keys')[$ssh_user_name3][ssh_options],
      }
  }
}