# WIKI START Recipe Systemconfig::folders
## OS :: Redhat ;Ubuntu ;Fedora; CentOS; #Solaris; #MacOS X
######################################
#
# h3. Host+Servicegroups affected
#
# * Linux Hosts 
#
# h3. Services affected
# * *none*
#
# h3. Files / directories / links affected
# * CREATE : /local0/scratch, /local0/tmp
#
# h3. What happens
#
#	Create system generic folders and links
#
###########
# WIKI STOP

class folders
{
   case $kernel {
  /Linux/: {
    file {   '/local0/tmp':
         ensure => directory,
        group  => 'root',
        mode   => '1777',
        owner  => 'root';
    }
    file {   '/local0/scratch':
         ensure => directory,
        group  => 'root',
        mode   => '1777',
        owner  => 'root';
    }
   }
  default: {
    #
    # warn in the puppet log
    #
    notice("${kernel} OS not supported for recipe folders")
      }
    }
}
