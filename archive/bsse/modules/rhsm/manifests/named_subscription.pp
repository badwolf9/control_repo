define rhsm::named_subscription (
  $ensure = 'present',
) {

  $pool = $::rhsm::pool_names[$name]
  if !$pool {
    fail("Cannot find any pool ID matching the name ${name}")
  }

  rh_subscription { $pool:
    ensure => $ensure,
  }
}


