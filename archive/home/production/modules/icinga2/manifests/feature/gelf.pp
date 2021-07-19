# == Class: icinga2::feature::gelf
#
# This module configures the Icinga 2 feature gelf.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the feature gelf, absent disables it. Defaults to present.
#
# [*host*]
#   GELF receiver host address. Icinga defaults to '127.0.0.1'.
#
# [*port*]
#   GELF receiver port. Icinga defaults to '12201'.
#
# [*source*]
#   Source name for this instance. Icinga defaults to 'icinga2'.
#
# [*enable_send_perfdata*]
#   Enable performance data for 'CHECK RESULT' events. Icinga defaults to false.
#
# [*enable_ha*]
#   Enable the high availability functionality. Only valid in a cluster setup. Icinga defaults to false.
#
#
class icinga2::feature::gelf(
  Enum['absent', 'present']                $ensure               = present,
  Optional[Stdlib::Host]                   $host                 = undef,
  Optional[Stdlib::Port::Unprivileged]     $port                 = undef,
  Optional[String]                         $source               = undef,
  Optional[Boolean]                        $enable_send_perfdata = undef,
  Optional[Boolean]                        $enable_ha            = undef,
) {

  if ! defined(Class['::icinga2']) {
    fail('You must include the icinga2 base class before using any icinga2 feature class!')
  }

  $conf_dir = $::icinga2::globals::conf_dir
  $_notify  = $ensure ? {
    'present' => Class['::icinga2::service'],
    default   => undef,
  }

  # compose attributes
  $attrs = {
    host                 => $host,
    port                 => $port,
    source               => $source,
    enable_send_perfdata => $enable_send_perfdata,
    enable_ha            => $enable_ha,
  }

  # create object
  icinga2::object { 'icinga2::object::GelfWriter::gelf':
    object_name => 'gelf',
    object_type => 'GelfWriter',
    attrs       => delete_undef_values($attrs),
    attrs_list  => keys($attrs),
    target      => "${conf_dir}/features-available/gelf.conf",
    order       => 10,
    notify      => $_notify,
  }

  # import library 'perfdata'
  concat::fragment { 'icinga2::feature::gelf':
    target  => "${conf_dir}/features-available/gelf.conf",
    content => "library \"perfdata\"\n\n",
    order   => '05',
  }

  # manage feature
  icinga2::feature { 'gelf':
    ensure => $ensure,
  }
}
