## OS :: Redhat;Ubuntu LTS;Solaris;
# WIKI START SSH recipes::ssh_itsc
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
# * DEPLOY  : /root/bin/sshCommandWrapper.sh
#
# h3. What happens
#
#
#
###########
# WIKI STOP


class ssh_itsc
{

include ssh_itsc::scripts

include ssh_itsc::privusers

include ssh_itsc::puppet

include ssh_itsc::hosts

include ssh_itsc::backup

include ssh_itsc::hpc


#$node_key = ssh_itsc::gethost_key('bs-jira01')

#Notify {"hello PQL":
#    message => "$node_key ",
#}

}
