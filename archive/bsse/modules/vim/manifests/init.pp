# WIKI START Recipe Systemconfig::vim
## OS :: Redhat ;Ubuntu;Fedora;Solaris 11; !MacOS X
######################################
#
# h3. Host / Service groups affected
#
# * *os-linx* for file creation
#
# h3. Services affected
# * none 
#
# h3. Files / directories / links affected
# * DEPLOY : /etc/vimrc on Linux
# * DEPLOY : /usr/share/vim/vimrc on Solaris
#
# h3. What happens
#
# * Generate a config file for the vim editor
#
###########
# WIKI STOP

class vim {
  case $::kernel
 {
  'SunOS':
  {  
      file { '/root/.vimrc':
          ensure  => present,
          mode    => '0644',
          owner   => root,
          group   => root,
          content => file("vim/vimrc_solaris"),
      }
  }  
  'Linux':
  {
    case $::operatingsystem {
    /RedHat|CentOS/ :
    {
          file { '/etc/vimrc':
                  ensure  => present,
                  mode    => '0644',
                  owner   => root,
                  group   => root,
                  content => file("vim/vimrc"),
          }
    }
    /Ubuntu|Debian/ :
    {
          file { '/etc/vim/vimrc':
                  ensure  => present,
                  mode    => '0644',
                  owner   => root,
                  group   => root,
                  content => file("vim/vimrc"),
          }
       }
    }
       }
  default: {
        notice("${kernel} OS not supported for VIM")
  }
 }
}

