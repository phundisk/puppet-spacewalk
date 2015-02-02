class spacewalk::postgresql (
  $postgresql_embedded = $::spacewalk::postgresql_embedded,
  $disconnected_setup  = $::spacewalk::disconnected_setup,
  $setup_timeout       = $::spacewalk::setup_timeout,
) {
  # Do not call this class directly, call class spacewalk for installation.

  package {'spacewalk-postgresql':
    ensure => installed,
    require     => Exec['setupSpacewalkServerRepo'],
  }

  $external_opts = $postgresql_embedded ? {
    true    => '',
    false   => ' --external-postgresql',
    default => '',
  }

  $disconnected_opts = $disconnected_setup ? {
    true    => ' --disconnected',
    false   => '',
    default => ' --disconnected',
  }

  $command = "spacewalk-setup ${external_opts}${disconnected_opts} --answer-file=/tmp/spacewalk.answer ; spacewalk-service start ; echo 'blank' > /tmp/spacewalk.answer"

  if($postgres_embedded == true) {
    package {'spacewalk-setup-postgresql':
      ensure  => 'present',
      before  => Exec['setupSpacewalk'],
      require => Exec['setupSpacewalkServerRepo'],
    }
  }

  exec {'setupSpacewalk':
    cwd       => '/root',
    path      => '/usr/bin:/usr/sbin:/bin',
    creates   => '/var/www/html/pub/RHN-ORG-TRUSTED-SSL-CERT',
    command   => $command,
    logoutput => on_failure,
    require   => Package['spacewalk-postgresql'],
  }
  # Manage the service?
  # Spacewalk-setup automatically manages the services.
  #
}
