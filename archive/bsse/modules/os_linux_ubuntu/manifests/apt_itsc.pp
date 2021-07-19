# WIKI START Ubuntu config::apt_itsc
## OS :: Redhat;Ubuntu LTS;Fedora ; !Solaris; !MacOS X
######################################
#
# h3. Host / Service groups affected
#
# * *Linux Debian type Systems* 
#
# h3. Services affected
# * none
#
# h3. Files / directories / links affected
# * DEPLOY : apt-file package (Debian based systems)
#
# h3. What happens
#
# * Install apt-file on Ubuntu/Debian based systems
# * Install some other utilities needed for operation and checking
# * For JPK machines on 10.04 or 12.04 do not install the full set of core packages but
# * exclude biosdevname (jpk has own version where needed), lsb, git, tshark, sssd-tools and perl plugin for nagios.
# *
###########
# WIKI STOP

class os_linux_ubuntu::apt_itsc
 {
#$my_debugflag = 'yes'
    if $my_debugflag == 'yes' {   notify { 'apt stuff for Ubuntu/Debian' : }}
	# watch list for jpk, 12.04 names might be different!!
        # the package libnagios-plugin-perl does not exist after 16.04LTS
        #
       if $facts['os']['release']['full'] =~ /^1[02]/ {
         if $my_debugflag == 'yes' {notify { 'Version 10 or 12' : }}
         $itsc_ub_basel=lookup('itsc_ub_core_packages') + ('libnagios-plugin-perl') - ('lsb') - ('biosdevname') - ('sssd-tools') - ('tshark') - ('git')
         } elsif  $facts['os']['release']['full'] =~ /^1[46]/ {
         if $my_debugflag == 'yes' {notify { 'Version 14 or 16' : }}
         $itsc_ub_basel=lookup('itsc_ub_core_packages') + ('libnagios-plugin-perl')
         } else {
         if $my_debugflag == 'yes' {notify { 'Version 17.04 or later' : }}
         $itsc_ub_basel=lookup('itsc_ub_core_packages') + ('tcl')
         }
	#combine into a global package parameter
	Package { ensure => 'installed' }
        package { $itsc_ub_basel: }
 }

