# == Class: icinga2::feature::influxdb
#
# This module configures the Icinga 2 feature influxdb.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the feature influxdb, absent disables it. Defaults to present.
#
# [*host*]
#    InfluxDB host address. Icinga defaults to 127.0.0.1.
#
# [*port*]
#    InfluxDB HTTP port. Icinga defaults to 8086.
#
# [*database*]
#    InfluxDB database name. Icinga defaults to icinga2.
#
# [*username*]
#    InfluxDB user name.
#
# [*password*]
#    InfluxDB user password.
#
# [*enable_ssl*]
#    Either enable or disable SSL. Other SSL parameters are only affected if this is set to 'true'.
#    Icinga defaults to 'false'.
#
# [*ssl_key_path*]
#   Location of the private key.
#
# [*ssl_cert_path*]
#   Location of the certificate.
#
# [*ssl_cacert_path*]
#   Location of the CA certificate.
#
# [*ssl_key*]
#   The private key in a base64 encoded string to store in ssl_key_path file.
#   Default depends on platform:
#     /var/lib/icinga2/certs/InfluxdbWriter_influxdb.key on Linux
#     C:/ProgramData/icinga2/var/lib/icinga2/certs/InfluxdbWriter_influxdb.key on Windows
#
# [*ssl_cert*]
#   The certificate in a base64 encoded string to store in ssl_cert_path file.
#   Default depends on platform:
#     /var/lib/icinga2/certs/InfluxdbWriter_influxdb.crt on Linux
#     C:/ProgramData/icinga2/var/lib/icinga2/certs/InfluxdbWriter_influxdb.crt on Windows
#
# [*ssl_cacert*]
#   The CA root certificate in a base64 encoded to store in ssl_cacert_path file.
#   Default depends on platform:
#     /var/lib/icinga2/certs/InfluxdbWriter_influxdb_ca.crt on Linux
#     C:/ProgramData/icinga2/var/lib/icinga2/certs/InfluxdbWriter_influxdb_ca.crt on Windows
#
# [*host_measurement*]
#    The value of this is used for the measurement setting in host_template. Defaults to '$host.check_command$'.
#
# [*host_tags*]
#    Tags defined in this hash will be set in the host_template.
#
#  [*service_measurement*]
#    The value of this is used for the measurement setting in host_template. Defaults to '$service.check_command$'.
#
# [*service_tags*]
#    Tags defined in this hash will be set in the service_template.
#
# [*enable_send_thresholds*]
#    Whether to send warn, crit, min & max tagged data. Icinga defaults to 'false'.
#
# [*enable_send_metadata*]
#    Whether to send check metadata e.g. states, execution time, latency etc. Icinga defaults to 'false'.
#
# [*flush_interval*]
#    How long to buffer data points before transfering to InfluxDB. Icinga defaults to '10s'.
#
# [*flush_threshold*]
#    How many data points to buffer before forcing a transfer to InfluxDB. Icinga defaults to '1024'.
#
# # [*enable_ha*]
#   Enable the high availability functionality. Only valid in a cluster setup. Icinga defaults to false.
#
#
# === Example
#
# class { 'icinga2::feature::influxdb':
#   host     => "10.10.0.15",
#   username => "icinga2",
#   password => "supersecret",
#   database => "icinga2"
# }
#
#
class icinga2::feature::influxdb(
  Enum['absent', 'present']                $ensure                 = present,
  Optional[Stdlib::Host]                   $host                   = undef,
  Optional[Stdlib::Port]                   $port                   = undef,
  Optional[String]                         $database               = undef,
  Optional[String]                         $username               = undef,
  Optional[String]                         $password               = undef,
  Optional[Boolean]                        $enable_ssl             = undef,
  Optional[Stdlib::Absolutepath]           $ssl_key_path           = undef,
  Optional[Stdlib::Absolutepath]           $ssl_cert_path          = undef,
  Optional[Stdlib::Absolutepath]           $ssl_cacert_path        = undef,
  Optional[String]                         $ssl_key                = undef,
  Optional[String]                         $ssl_cert               = undef,
  Optional[String]                         $ssl_cacert             = undef,
  String                                   $host_measurement       = '$host.check_command$',
  Hash                                     $host_tags              = { hostname => '$host.name$' },
  String                                   $service_measurement    = '$service.check_command$',
  Hash                                     $service_tags           = { hostname => '$host.name$', service => '$service.name$' },
  Optional[Boolean]                        $enable_send_thresholds = undef,
  Optional[Boolean]                        $enable_send_metadata   = undef,
  Optional[Icinga2::Interval]              $flush_interval         = undef,
  Optional[Integer[1]]                     $flush_threshold        = undef,
  Optional[Boolean]                        $enable_ha              = undef,
) {

  if ! defined(Class['::icinga2']) {
    fail('You must include the icinga2 base class before using any icinga2 feature class!')
  }

  $user          = $::icinga2::globals::user
  $group         = $::icinga2::globals::group
  $conf_dir      = $::icinga2::globals::conf_dir
  $ssl_dir       = $::icinga2::globals::cert_dir
  $_ssl_key_mode = $::kernel ? {
    'windows' => undef,
    default   => '0600',
  }
  $_notify       = $ensure ? {
    'present' => Class['::icinga2::service'],
    default   => undef,
  }

  File {
    owner   => $user,
    group   => $group,
  }

  $host_template = { measurement => $host_measurement, tags => $host_tags }
  $service_template = { measurement => $service_measurement, tags => $service_tags}

  if $enable_ssl {

    # Set defaults for certificate stuff
    if $ssl_key {
      if $ssl_key_path {
        $_ssl_key_path = $ssl_key_path }
      else {
        $_ssl_key_path = "${ssl_dir}/InfluxdbWriter_influxdb.key"
      }

      $_ssl_key = $::osfamily ? {
        'windows' => regsubst($ssl_key, '\n', "\r\n", 'EMG'),
        default   => $ssl_key,
      }

      file { $_ssl_key_path:
        ensure  => file,
        mode    => $_ssl_key_mode,
        content => $_ssl_key,
        tag     => 'icinga2::config::file',
      }
    } else {
      $_ssl_key_path = $ssl_key_path
    }

    if $ssl_cert {
      if $ssl_cert_path {
        $_ssl_cert_path = $ssl_cert_path }
      else {
        $_ssl_cert_path = "${ssl_dir}/InfluxdbWriter_influxdb.crt"
      }

      $_ssl_cert = $::osfamily ? {
        'windows' => regsubst($ssl_cert, '\n', "\r\n", 'EMG'),
        default   => $ssl_cert,
      }

      file { $_ssl_cert_path:
        ensure  => file,
        content => $_ssl_cert,
        tag     => 'icinga2::config::file',
      }
    } else {
      $_ssl_cert_path = $ssl_cert_path
    }

    if $ssl_cacert {
      if $ssl_cacert_path {
        $_ssl_cacert_path = $ssl_cacert_path }
      else {
        $_ssl_cacert_path = "${ssl_dir}/InfluxdbWriter_influxdb_ca.crt"
      }

      $_ssl_cacert = $::osfamily ? {
        'windows' => regsubst($ssl_cacert, '\n', "\r\n", 'EMG'),
        default   => $ssl_cacert,
      }

      file { $_ssl_cacert_path:
        ensure  => file,
        content => $_ssl_cacert,
        tag     => 'icinga2::config::file',
      }
    } else {
      $_ssl_cacert_path = $ssl_cacert_path
    }

    $attrs_ssl = {
      ssl_enable  => $enable_ssl,
      ssl_ca_cert => $_ssl_cacert_path,
      ssl_cert    => $_ssl_cert_path,
      ssl_key     => $_ssl_key_path,
    }
  } # enable_ssl
  else {
    $attrs_ssl = { ssl_enable  => $enable_ssl }
  }

  $attrs = {
    host                   => $host,
    port                   => $port,
    database               => $database,
    username               => $username,
    password               => $password,
    host_template          => $host_template,
    service_template       => $service_template,
    enable_send_thresholds => $enable_send_thresholds,
    enable_send_metadata   => $enable_send_metadata,
    flush_interval         => $flush_interval,
    flush_threshold        => $flush_threshold,
    enable_ha              => $enable_ha,
  }

  # create object
  icinga2::object { 'icinga2::object::InfluxdbWriter::influxdb':
    object_name => 'influxdb',
    object_type => 'InfluxdbWriter',
    attrs       => delete_undef_values(merge($attrs, $attrs_ssl)),
    attrs_list  => keys($attrs),
    target      => "${conf_dir}/features-available/influxdb.conf",
    notify      => $_notify,
    order       => 10,
  }

  # import library 'perfdata'
  concat::fragment { 'icinga2::feature::influxdb':
    target  => "${conf_dir}/features-available/influxdb.conf",
    content => "library \"perfdata\"\n\n",
    order   => '05',
  }

  icinga2::feature { 'influxdb':
    ensure => $ensure,
  }
}
