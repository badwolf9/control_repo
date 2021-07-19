##
class defaultnode inherits baseclass
{
	#	Try to generate an array of ou_groups from classes
#	$classtemp = inline_template("<% classes.each do |c| %><% if c.to_s =~ /^ou_groups/ then %><%= c.to_s.sub(/^ou_groups_/, '') %>,<% end %><% end %>")
	#	Chop off the trainling ','
#	$classchop = inline_template("<%= @classtemp.to_s.chop() %>")
	#	Split string into an array
#	$my_groups = split($classchop,',')
# ########################################################################
# Print out some basic information for debugging:
	#notify {" === $hostname P4 run (OS : $operatingsystem ($lsbdistrelease) / InstType : $installtype / OS family : $osfamily). ===" : }
	#notify {" === $hostname P4 groups : $my_groups" : }
# ########################################################################
#        # the my_monitor variable comes from hiera and is a comma separated string listing all nagios servers
#	include service_net_sshd
	include puppetclient
#        include ssh::config
	include users
	include ntpd
#	include mount_tab
#	include tcpd
#	include backup
#	include sysctl
	include description
#	include openssh::client
#	include openssh::server
#	include icinga2
 ## end of defaultnode #############
}

class os_linux inherits baseclass
{
	include profile
#	include logrotate
	include hosts
#	include vim    
#	include pam
#	include limitsconf
#	include resolv_conf
	include sudoers
#        include samba
#	include modprobe
#	include folders
#	include udev
        # for RedHat
#        if $facts['os']['family'] =~ /RedHat/ {
#          include os_linux_redhat
#          }
        #for Ubuntu 14.04 or later can use these modules
#	if $facts['os']['release']['full'] !~ /1[02].04/ {
#          include postfix
#          }
}

class os_linux_ubuntu inherits baseclass
{
    include os_linux_ubuntu::apt_mjf
    include os_linux_ubuntu::autoupdate
}
class os_linux_ubuntu_server inherits baseclass
{   include os_linux_ubuntu::server
}
class os_linux_ubuntu_workstation inherits baseclass
{   
    include os_linux_ubuntu::workstation
    include os_linux_ubuntu_apt_mjf
    include os_linux_ubuntu::apt_mjf_wks
#    include os_linux_ubuntu::mate
}
class puppet_server inherits baseclass
{}
class os_linux_ubuntu_apt_mjf inherits baseclass
{   include os_linux_ubuntu::apt_mjf
}
class os_linux_ubuntu_apt_mjf_wks inherits baseclass
{   include os_linux_ubuntu::apt_mjf_wks
}
class os_linux_ubuntu_autoupdate inherits baseclass
{   include os_linux_ubuntu::autoupdate
}
class os_linux_ubuntu_allow_upgrade inherits baseclass
{}
class os_linux_ubuntu_x2go inherits baseclass
{   include os_linux_ubuntu::x2go
}
class os_linux_ubuntu_kde inherits baseclass
{   include os_linux_ubuntu::kde
}
class os_linux_ubuntu_mate inherits baseclass
{   include os_linux_ubuntu::mate
}
class service_apt inherits baseclass
{}
class service_debian_packages inherits baseclass
{}
class os_linux_debian inherits baseclass
{}
class service_puppet inherits baseclass
{}
class os_linux_arch inherits baseclass
{
     include os_linux_arch::base
     include os_linux_arch::pacman
     include os_linux_arch::pacman_wks
     include os_linux_arch::kde
}

class service_puppet_server inherits baseclass {}

class service_puppetboard inherits baseclass {
     include puppetboard
}

class db_mysql inherits baseclass {}

class db_postgresql inherits baseclass {}

