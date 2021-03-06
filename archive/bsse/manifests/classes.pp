##
##	Puppet D_BSSE Framework documentation
##
# WIKI START D-BSSE Puppet 4 Framework::Puppet config classes.pp
## OS :: Redhat;Ubuntu;Solaris
######################################
#
# h3. Purpose of the file
#
# * Contains all imported centreon classes and effectively defines their functions
# * Functions are defined manually by adding recipes to centreon classes
# * New centreon classes are autoimported (see /etc/puppet/bin/generatePuppetConf.pl)
#
# h3. See also
#
# * [Puppet config nodes.pp]
#
###########
# WIKI STOP
class defaultnode inherits baseclass
{
	#	Try to generate an array of ou_groups from classes
	$classtemp = inline_template("<% classes.each do |c| %><% if c.to_s =~ /^ou_groups/ then %><%= c.to_s.sub(/^ou_groups_/, '') %>,<% end %><% end %>")
	#	Chop off the trainling ','
	$classchop = inline_template("<%= @classtemp.to_s.chop() %>")
	#	Split string into an array
	$my_groups = split($classchop,',')
# ########################################################################
# Print out some basic information for debugging:
	#notify {" === $hostname P4 run (OS : $operatingsystem ($lsbdistrelease) / InstType : $installtype / OS family : $osfamily). ===" : }
	#notify {" === $hostname P4 groups : $my_groups" : }
# ########################################################################
        # the my_monitor variable comes from hiera and is a comma separated string listing all nagios servers
	nrpe { "bs-nagios":
	      allowed_hosts => [$my_monitor]
	     } 
	include service_net_sshd
	include puppetclient
#        include ssh::config
	include bssescripts
	include users
	include ntpd
	include autofs::config
	include autofs::service
	include mount_tab
	include tcpd
	include backup
	include linkfarm
	include sysctl
	include description
#	include openssh::client
#	include openssh::server
#	include ssh_itsc
 ## end of defaultnode #############
}

class os_linux inherits baseclass
{
	include ssh_itsc
	include profile
	include logrotate
	include hosts
	include sssd
	include vim    
	include pam
	include service_nfs4client
	include limitsconf
	include resolv_conf
	include sudoers
	include accessconf
	# samba { "samba_$fqdn": my_groups => $my_groups }	
        include samba
	include modprobe
	include folders
	include nfs4
	include nfs_exports
#	include vmtoolsd
	if $facts['virtual'] == 'vmware' {
          #notify { "Including openvmtools" : }
          include vmtools
          }
	include udev
        # for RedHat
        if $facts['os']['family'] =~ /RedHat/ {
          include os_linux_redhat
          }
        #for Ubuntu 14.04 or later can use these modules
	if $facts['os']['release']['full'] !~ /1[02].04/ {
          include module_env
          include krb5
          include postfix
          }
}

class os_sun_solaris11 inherits baseclass
{
	include root_solaris
	include ntpd
	include syslog
#	include ssh::config
	include sudoers
	include description
	include cron
	include vim    
}
class os_sun inherits baseclass
{ 
	include profile
#	include openssh::server
	include hosts
	include syslog
}

class service_puppet_upgrade_to_P4 inherits baseclass
{
#    include p4upgrade
}

class service_net_snmp
{
	include snmp
}


class service_net_sshd inherits baseclass
{
        #include ssh::admins
        #include ssh::backup
        #include ssh::pivilegedusers
        #include ssh::hosts
        #include ssh::puppet
        #include ssh::hpc
}
class ou_service_gridnodes_soge inherits baseclass
{
	include profile
	include logrotate
	include hosts
	include sssd
	include vim    
	include krb5
	include pam
	include service_nfs4client
	include ntpd
	include module_env
#	include openssh::server
	include resolv_conf
	include sogenode
  include ou_service_gridnodes
}
class os_linux_ubuntu inherits baseclass
{
    include os_linux_ubuntu::apt_itsc
    include os_linux_ubuntu::autoupdate
}
class os_linux_ubuntu_server inherits baseclass
{    include os_linux_ubuntu::server
     include os_linux_ubuntu::x2go # - not for server (normally - override with Centreon relation)
     include os_linux_ubuntu::mate # - not for server (normally - override with Centreon relation)
}
class os_linux_ubuntu_workstation inherits baseclass
{   include os_linux_ubuntu::workstation
    include os_linux_ubuntu::x2go
    include os_linux_ubuntu::mate
}
class service_net_ssh_itsc inherits baseclass
{
#include ssh_itsc
}
class ssh_itsc inherits baseclass
{
include ssh_itsc::scripts
include ssh_itsc::privusers
include ssh_itsc::puppet
include ssh_itsc::hosts
include ssh_itsc::backup
include ssh_itsc::hpc
}
class service_kvm inherits baseclass
{
	include kvmserver
}
class os_linux_redhat5 inherits baseclass
{
	include yum_autoupdate
	include bsserepo
}

class ou_service_multihomed inherits baseclass
{
	include rc_local
}

class service_autofs inherits baseclass
{
	include autofs::config
}
class service_net_cups inherits baseclass
{
	include cups
}

class db_mysql inherits baseclass
{}
class db_postgresql inherits baseclass
{}
class hw_dell inherits baseclass
{
  	include hardware_dell
}
class hw_dalco inherits baseclass
{
        include hardware_dalco
}
class service_iscsi_client inherits baseclass
{
	include iscsi
}


class xxx_ou_linux_test inherits baseclass
{
	notice("I am a test host of xxx_ou_linux_test")
	include profile
	include logrotate
	include hosts
	include sssd
	include vim    
	include krb5
	include pam
	include service_nfs4client
	include ntpd
	include module_env
#	include openssh::server
	include resolv_conf
}

class service_rsyslogd inherits baseclass
{
	include rsyslog
}

class service_net_dns inherits baseclass
{
	include bind
}
class service_dhcpd inherits baseclass
{ 
	include dhcp_server
}
class service_whatever inherits baseclass
{
  include whatever
}
class service_puppetboard inherits baseclass
{
include puppetboard
}




########################################3
#
# Only classes automatically input should come after here
# MJF Jan2018
#
########################################3

class hw_dell_openmanage inherits baseclass
{}
class hw_dell_openmanage_pasv inherits baseclass
{}
class hw_hp inherits baseclass
{}
class hw_hp_dl380g5 inherits baseclass
{}
class hw_ibm inherits baseclass
{}
class hw_ibm_x3850 inherits baseclass
{}
class hw_kvm inherits baseclass
{}
class hw_sm inherits baseclass
{}
class hw_sun inherits baseclass
{}
class postgresql inherits baseclass
{}
class os_macosx_105 inherits baseclass
{}
class os_sun_service_zpool inherits baseclass
{}
class os_sun_solaris10_sparc inherits baseclass
{}
class os_sun_solaris11_zone inherits baseclass
{}
class ou_groups_bsse inherits baseclass
{}
class ou_groups_bewi inherits baseclass
{}
class ou_groups_cina
{}
class ou_groups_cisd inherits baseclass
{}
class ou_groups_hima inherits baseclass
{}
class ou_groups_iber inherits baseclass
{ }
class ou_groups_it
{ }
class ou_groups_panke inherits baseclass
{ }
class ou_groups_stel inherits baseclass
{ }
class ou_groups_paro inherits baseclass
{ }
class ou_service_gridnodes inherits baseclass
{ }
class ou_service_gridnodes_soge_master inherits baseclass
{}
class puppet_iptables inherits baseclass
{}
class service_nfs inherits baseclass
{}
class service_nfs_qnap01_cina inherits baseclass
{}
class service_NFS_server inherits baseclass
{}
class service_dirvish inherits baseclass
{}
class service_flexlm inherits baseclass
{}
class service_fontserver inherits baseclass
{}
class service_http inherits baseclass
{}
class service_https inherits baseclass
{}
class service_nx inherits baseclass
{}
class service_openbis inherits baseclass
{ }
class service_puppet inherits baseclass
{}
class service_puppet_server inherits baseclass
{
include puppet_server
}
class service_rsync inherits baseclass
{}
class service_samba inherits baseclass
{}
class service_net_samba inherits baseclass
{}
class shutdown_group01 inherits baseclass
{}
class os_linux_redhat54_pasv inherits baseclass
{}
class ou_groups_itsc inherits baseclass
{}
class cluster_stelling inherits baseclass
{}
class service_sunfm inherits baseclass
{}
class ou_groups_mueller inherits baseclass
{}
class disk_io_sd0 inherits baseclass
{}
class disk_io_sd1 inherits baseclass
{}
class disk_io_sda inherits baseclass
{}
class disk_io_sda3 inherits baseclass
{}
class ou_user_login inherits baseclass
{}
class disk_io_sdx inherits baseclass
{}
class disk_io_cmdk0 inherits baseclass
{}
class os_macosx_105_server inherits baseclass
{}
class os_windows inherits baseclass
{}
class os_windows_server2008r2 inherits baseclass
{}
class service_NFS3_client inherits baseclass
{}
class service_nfs3client inherits baseclass
{}
class disk_io_zpool_dataPool inherits baseclass
{}
class disk_io_zpool_rpool inherits baseclass
{}
class os_linux_debian inherits baseclass
{}
class os_linux_jpk inherits baseclass
{}
class service_nfs4client inherits baseclass
{}
class service_autofs_passv inherits baseclass
{}
class ou_netgroup_adminsrv_hima inherits baseclass
{}
class service_nfsserver inherits baseclass
{
include nfs_exports
}
class service_user_login inherits baseclass
{}
class os_linux_redhat6 inherits baseclass
{}
class ou_netgroup_adminsrv_cina inherits baseclass
{}
class ou_netgroup_adminsrv_cisd inherits baseclass
{}
class ou_netgroup_adminsrv_iber inherits baseclass
{}
class ou_netgroup_adminsrv_itsc inherits baseclass
{}
class ou_netgroup_adminsrv_panke inherits baseclass
{}
class ou_netgroup_adminsrv_paro inherits baseclass
{}
class ou_netgroup_adminsrv_stel inherits baseclass
{}
class service_syslogd inherits baseclass
{}
class os_linux_redhat6_server inherits baseclass
{}
class test inherits baseclass
{}
class os_sun_disk_io_zpool_rpool inherits baseclass
{}
class os_sun_service_disk_io_zpool_dataPool inherits baseclass
{}
class ou_service_grid_cluster_stelling inherits baseclass
{}
class ou_service_grid_submit inherits baseclass
{}
class ou_service_user_login inherits baseclass
{}
class ou_shutdown_group01 inherits baseclass
{}
class service_bandwidth_aggr0 inherits baseclass
{}
class service_bandwidth_aggr1 inherits baseclass
{}
class service_bandwidth_bond0 inherits baseclass
{}
class service_bandwidth_bond1 inherits baseclass
{}
class service_bandwidth_br0 inherits baseclass
{}
class service_bandwidth_eth0 inherits baseclass
{}
class service_bandwidth_eth3 inherits baseclass
{}
class service_bandwidth_ipmp0 inherits baseclass
{}
class service_bandwidth_ixgb0 inherits baseclass
{}
class service_bandwidth_nge3 inherits baseclass
{}
class service_db_mysql inherits baseclass
{}
class service_db_postgresql inherits baseclass
{
 include postgresql
}
class service_disk_io_cmdk0 inherits baseclass
{}
class service_disk_io_sda inherits baseclass
{}
class service_disk_io_sda3 inherits baseclass
{}
class service_net_http inherits baseclass
{}
class service_nsca inherits baseclass
{}
class ou_grid_submit inherits baseclass
{}
class service_net_flexlm inherits baseclass
{}
class service_net_fontserver inherits baseclass
{}
class service_net_https inherits baseclass
{}
class service_net_nx inherits baseclass
{}
class ou_service_device_controller inherits baseclass
{}
class ou_backup inherits baseclass
{}
class ou_netgroup_adminsrv_bewi inherits baseclass
{}
class ou_groups_benenson inherits baseclass
{}
class ou_groups_dsf_user inherits baseclass
{}
class ou_groups_mf inherits baseclass
{}
class ou_groups_dsf inherits baseclass
{}
class ou_groups_guests inherits baseclass
{}
class service_db_mysql_pasv inherits baseclass
{}
class os_sun_nfs_counters inherits baseclass
{}
class os_client_linux inherits baseclass
{}
class os_linux_active inherits baseclass
{}
class os_agrl_linux inherits baseclass
{}
class os_macosx_106_server inherits baseclass
{}
class ou_groups_khammasch inherits baseclass
{}
class ou_groups_khammash inherits baseclass
{}
class os_linux_redhat6_pasv inherits baseclass
{}
class os_linux_passiv inherits baseclass
{}
class ou_groups_fussenegger inherits baseclass
{}
class ou_groups_beerenwinkel inherits baseclass
{}
class ou_netgroup_adminsrv_beerenwinkel inherits baseclass
{}
class ou_groups_hierlemann inherits baseclass
{}
class ou_netgroup_adminsrv_hierlemann inherits baseclass
{}
class ou_groups_stelling inherits baseclass
{}
class ou_netgroup_adminsrv_stelling inherits baseclass
{}
class ou_groups_bsse_common inherits baseclass
{}
class service_net_crowd inherits baseclass
{}
class ou_groups_guest_students inherits baseclass
{}
class ou_netgroup_adminsrv_benenson inherits baseclass
{}
class ou_netgroup_adminsrv_khammash inherits baseclass
{}
class ou_netgroup_adminsrv_mueller inherits baseclass
{}
class os_windows_hw inherits baseclass
{}
class os_windows_old inherits baseclass
{}
class service_terminalserver_logons inherits baseclass
{}
class ou_group_pantazis inherits baseclass
{}
class ou_netgroup_adminsrv_pantazis inherits baseclass
{}
class ou_netgroup_conf2wiki inherits baseclass
{}
class ou_netgroups_conf2wiki inherits baseclass
{}
class service_bandwidth_net4 inherits baseclass
{}
class service_bandwidth_net0 inherits baseclass
{}
class ou_groups_reddy inherits baseclass
{}
class ou_netgroup_adminsrv_reddy inherits baseclass
{}
class ou_groups_pantazis inherits baseclass
{}
class service_atlassian inherits baseclass
{ 
  include limitsconf
}
class ou_groups_scu inherits baseclass
{}
class ou_groups_singlecellunit inherits baseclass
{}
class ou_service_grid_nologin inherits baseclass
{}
class service_bandwidth_eth2 inherits baseclass
{}
class hw_xserve inherits baseclass
{}
class ou_netgroup_adminsrv_singlecellunit inherits baseclass
{}
class ou_groups_master_students inherits baseclass
{}
class ou_groups_tay inherits baseclass
{}
class ou_shutdown_group01_linux inherits baseclass
{}
class ou_shutdown_group01_solaris inherits baseclass
{}
class mon_beerenwinkel inherits baseclass
{}
class mon_cina inherits baseclass
{}
class mon_grid inherits baseclass
{}
class mon_hierlemann inherits baseclass
{}
class service_bandwidth_eth4 inherits baseclass
{}
class service_bandwidth_eth5 inherits baseclass
{}
class mon_it inherits baseclass
{}
class mon_itsc inherits baseclass
{}
class mon_openbis inherits baseclass
{}
class mon_mueller inherits baseclass
{}
class mon_common inherits baseclass
{}
class mon_grid_mpi01 inherits baseclass
{}
class mon_grid_mpi02 inherits baseclass
{}
class mon_grid_mpi03 inherits baseclass
{}
class mon_grid_mpi04 inherits baseclass
{}
class mon_grid_regular inherits baseclass
{}
class mon_stelling inherits baseclass
{}
class mon_cisd inherits baseclass
{}
class mon_grid_all inherits baseclass
{}
class mon_grid_manage inherits baseclass
{}
class mon_grid_sc inherits baseclass
{}
class mon_iber inherits baseclass
{}
class mon_khammash inherits baseclass
{}
class mon_panke inherits baseclass
{}
class mon_virt_host inherits baseclass
{}
class os_linux_cpuload inherits baseclass
{}
class os_linux_cpuload_grid inherits baseclass
{}
class service_bandwidth_ixgbe0 inherits baseclass
{}
class mon_grid_allnodes inherits baseclass
{}
class ou_groups_schroeder inherits baseclass
{}
class service_dd inherits baseclass
{}
class ou_groups_stadler inherits baseclass
{}
class hw_management_hp inherits baseclass
{}
class hw_dell_m620 inherits baseclass
{}
class ou_service_grid_cluster_stelling_1 inherits baseclass
{}
class mon_grid_sc02 inherits baseclass
{}
class ou_service_gridnodes_soge_qmaster inherits baseclass
{}
class ou_service_gridnodes_munge inherits baseclass
{}
class ou_service_gridnodes_munge_master inherits baseclass
{}
class ou_service_gridnodes_slurm_master inherits baseclass
{}
class mon_soge_all inherits baseclass
{}
class ou_groups_borgwardt inherits baseclass
{}
class ou_service_usermanager inherits baseclass
{}
class hw_management_dell inherits baseclass
{}
class os_macosx_server inherits baseclass
{}
class mon_sis inherits baseclass
{}
class ou_groups_sis inherits baseclass
{}
class os_linux_redhat7 inherits baseclass
{}
class ou_groups_deepseq_analysis inherits baseclass
{}
class mon_borgwardt inherits baseclass
{}
class service_md_raid inherits baseclass
{}
class ou_shutdown_group04 inherits baseclass
{}
class ou_shutdown_group02 inherits baseclass
{}
class ou_shutdown_group03 inherits baseclass
{}
class ou_groups_sis_scopem inherits baseclass
{}
class xxx_ou_linux_test_1 inherits baseclass
{}
class ou_groups_dittrich inherits baseclass
{}
class mon_panke_1 inherits baseclass
{}
class mon_reddy inherits baseclass
{}
class ou_service_user_login_1 inherits baseclass
{}
class ou_service_ceph inherits baseclass
{}
class service_kerberos inherits baseclass
{}
class service_net_smtp inherits baseclass
{}
class service_net_https_port8443 inherits baseclass
{}
class service_net_hima_dc inherits baseclass
{}
class ou_groups_cina_guests inherits baseclass
{}
class hw_nvidia_cuda inherits baseclass
{
include nvidia
}
class hw_nvidia_driver inherits baseclass
{
include nvidia
}
class hw_nvidia_nvs inherits baseclass
{
include nvidia
}
class mon_schroeder inherits baseclass
{}
class service_dirvish_1 inherits baseclass
{}
class service_nginx inherits baseclass
{
include nginx
}
class service_db_postgresql_slave inherits baseclass
{}
class service_db_postgresql_master inherits baseclass
{}
class ou_groups_platt inherits baseclass
{}
class ou_netgroup_adminsrv_borgwardt inherits baseclass
{}
class service_db_pgsql_geneious inherits baseclass
{
include geneious
}
class service_megasasctl inherits baseclass
{}
class os_bwtrain inherits baseclass
{}
class os_linux_ubuntu_NO_autoupdate inherits baseclass
{}
class service_apt inherits baseclass
{}
class service_debian_packages inherits baseclass
{}
class service_ltsmounts inherits baseclass
{}
class service_zfs_snapshot inherits baseclass
{}
class puppetboard inherits baseclass
{}
class os_linux_ubuntu_autoupdate inherits baseclass
{}
class os_linux_ubuntu_securityupdates inherits baseclass
{}
class os_linux_ubuntu_mate inherits baseclass
{
 include os_linux_ubuntu::mate
}
class os_linux_ubuntu_kde inherits baseclass
{
 include os_linux_ubuntu::kde
}
class os_linux_ubuntu_gnome inherits baseclass
{
 include os_linux_ubuntu::gnome
}
class os_linux_ubuntu_x2go inherits baseclass
{
 include os_linux_ubuntu::x2go
}
class os_linux_ubuntu_nvidia inherits baseclass
{
 include os_linux_ubuntu::nvidia
}
class os_linux_ubuntu_cuda inherits baseclass
{}
class os_linux_ubuntu_allow_upgrade inherits baseclass
{}
class ou_groups_lts inherits baseclass
{}
class puppet_generics inherits baseclass
{}
class os_linux_yum_update_disabled inherits baseclass
{}
class hw_dell_1 inherits baseclass
{}
class vmtools inherits baseclass
{
include openvmtools
}
class puppet_server inherits baseclass
{}
