# WIKI START Recipe Systemconfig::module_env
## OS :: Redhat ;Ubuntu; #Solaris; #MacOS X
######################################
#
# h3. Host+Servicegroups affected
#
# * All linux machines
#
# h3. Services affected
# 
#
# h3. Files / directories / links affected
# * CREATE : /etc/modulefiles/*
# * CHANGE : /etc/profiles
#
# h3. What happens
#
#	* installs the modulefiles
#	* enables the module environment
#
###########
# WIKI STOP

class module_env
{

# Set path and directory
$moduledir    = '/etc/modulefiles'
$modulerepodir    = '/etc/modulefiles/repo'

   case $kernel {
  'Linux': {

    # Install module files

    file { $moduledir:
                        ensure => directory,
                        mode   => '0755',
                        group  => root,
      owner  => root,
    }
    file { $modulerepodir:
                        ensure => directory,
                        mode   => '0755',
                        group  => root,
      owner  => root,
    }

    file { "${moduledir}/bsse":
      ensure => absent,
    }
    file { "${moduledir}/openmpi-x86_64":
      ensure => absent,
    }
    file { "${moduledir}/grid":
      ensure => absent,
    }
    file { "${moduledir}/environment/module":
      ensure => absent,
    }
    file { "${moduledir}/module":
      ensure => absent,
    }
    file { "${moduledir}/environment":
      ensure => absent,
      force  =>true,
    }

    file {  "${modulerepodir}/bsse":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/bsse.erb"),
        owner   => root;
      "${modulerepodir}/grid":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/grid.erb"),
        owner   => root;
      "${modulerepodir}/steling":
        ensure => absent;
      "${modulerepodir}/stel":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/stel.erb"),
        owner   => root;
      "${modulerepodir}/stelling":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/stelling.erb"),
        owner   => root;
      "${modulerepodir}/stadler":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/stadler.erb"),
        owner   => root;
      "${modulerepodir}/singlecellunit":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/singlecellunit.erb"),
        owner   => root;
      "${modulerepodir}/hima":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/hima.erb"),
        owner   => root;
      "${modulerepodir}/hierlemann":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/hierlemann.erb"),
        owner   => root;
      "${modulerepodir}/khammash":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/khammash.erb"),
        owner   => root;
      "${modulerepodir}/reddy":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/reddy.erb"),
        owner   => root;
      "${modulerepodir}/paro":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/paro.erb"),
        owner   => root;
      "${modulerepodir}/iber":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/iber.erb"),
        owner   => root;
      "${modulerepodir}/bewi":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/bewi.erb"),
        owner   => root;
      "${modulerepodir}/beerenwinkel":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/beerenwinkel.erb"),
        owner   => root;
      "${modulerepodir}/panke":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/panke.erb"),
        owner   => root;
      "${modulerepodir}/cisd":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/cisd.erb"),
        owner   => root;
      "${modulerepodir}/itsc":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/itsc.erb"),
        owner   => root;
      "${modulerepodir}/dsu":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/dsu.erb"),
        owner   => root;
      "${modulerepodir}/cina":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/cina.erb"),
        owner   => root;
      "${modulerepodir}/mueller":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/mueller.erb"),
        owner   => root;
      "${modulerepodir}/fussenegger":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/fussenegger.erb"),
        owner   => root;
      "${modulerepodir}/local":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/local.erb"),
        owner   => root;
      "${modulerepodir}/master-students":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/master-students.erb"),
        owner   => root;
      "${modulerepodir}/tay":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/tay.erb"),
        owner   => root;
      "${modulerepodir}/bachelor-students":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/bachelor-students.erb"),
        owner   => root;
                }
    if tagged('ou-groups-guest-students'){
      file {
           "${modulerepodir}/guest-students":
                          ensure  => present,
                          mode    => '0644',
                          group   => root,
         content => template("module_env/guest-students.erb"),
        owner   => root;
      }
    }
#       if $facts['os']['release']['full'] !~ /1[02].04/ {
         package  { 'environment-modules':
         ensure => present;
#         }
        }
       }
  default: {
    #
    # warn in the puppet log
    #
    notice("${kernel} OS not supported for recipe module_env")
      }
   }
}
