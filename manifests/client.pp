class spacewalk::client (
  $spacewalk_fqdn      =   "spacewalk.$::domain",
  $activation_key # this must be set
) {
  # This class will setup a node to talk to a spacewalk server.
  # You need to provide the activation key that you create within the spacewalk UI
  #
  # class {'spacewalk::client':
  #   spacewalk_fqdn => 'spacewalk.local.net',
  #   activation_key => '1-d9e796114e1e8ef073b605341ee6580d',
  # }
    
  include spacewalk::repo_client
  
  # spacewalk client packages needed
  $packageList = ['rhn-client-tools','rhn-check', 'rhn-setup', 'm2crypto', 'yum-rhn-plugin']
  
  package {$packageList:
    ensure => installed,
    require => Exec['setupSpacewalkClientRepo'],
  }
  
  # Exec to register with the spacewalk server
  exec {'registerSpacewalk':
    cwd => '/root',
    path => '/usr/bin:/usr/sbin:/bin',
    creates => '/etc/sysconfig/rhn/systemid',
    command => "rhnreg_ks --serverUrl=http://$spacewalk_fqdn/XMLRPC --activationkey=$activation_key",
    require => Package[$packageList],
  }
  
  
}