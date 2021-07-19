# WIKI START Recipe Systemconfig::yum
## OS :: RedHat; !Ubuntu; Fedora; !Solaris; !MacOS X
######################################
#
# h3. Host / Service groups affected
#
# h3. Services affected
#
# * *none*
#
# h3. Files / directories / links affected
#
#
# h3. What happens
#
###########
# WIKI STOP

class yum {
 if $my_debugflag == 'yes' { notify { 'Yum stuff would go here!' : }}
}
