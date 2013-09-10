class spacewalk::postgresql{
  # Do not call this class directly, call class spacewalk for installation.
  
  package {'spacewalk-postgresql':
    ensure => installed,
    require     => Exec['setupSpacewalkServerRepo'],
  }
    
  if $spacewalk::postgresql_embedded == 'true' {
    # Setup the related postgresql package, service, and initiate the DB
    package {'spacewalk-setup-postgresql':
      ensure      => installed,
      require     => Exec['setupSpacewalkServerRepo'],
    }
    exec {'setupSpacewalk':
      cwd => '/root',
      path => '/usr/bin:/usr/sbin:/bin',
      creates => '/var/www/html/pub/RHN-ORG-TRUSTED-SSL-CERT',
      command => 'spacewalk-setup --disconnected --answer-file=/tmp/spacewalk.answer; spacewalk-service start; echo "blank" > /tmp/spacewalk.answer',
      require => Package['spacewalk-postgresql'],
    }
  }
  else {
    # This is assuming you have another postgresql db somewhere
    # and you have overiden it properly in the parameterized class
    exec {'setupSpacewalk':
      cwd => '/root',
      path => '/usr/bin:/usr/sbin:/bin',
      creates => '/var/www/html/pub/RHN-ORG-TRUSTED-SSL-CERT',
      command => 'spacewalk-setup --disconnected --external-db --answer-file=/tmp/spacewalk.answer; spacewalk-service start; echo "blank" > /tmp/spacewalk.answer',
      require => Package['spacewalk-postgresql'],
    }
  }

  # Manage the service?
  # Spacewalk-setup automatically manages the services.
  #
  
}