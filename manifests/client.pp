# == Class: spacewalk::client
#
# This class will setup a node to talk to a spacewalk server.  You
# need to provide the activation key that you create within the
# spacewalk UI
#
# === Parameters
#
# [*use_spacewalk_client_repo*]
#   If we should also enable the spacewalk
#   client repositories.  This is not required for a client that
#   registers on a satellite server.
#
#   Default: true
#
# [*spacewalk_fqdn*]
#   FQDN of the spacewalk server.
#
#   Default: spacewalk.${::domain}
#
# [*activation_key*]
#   Activation key need for the registration
#
#   Default: unset
#
# === Examples
#
# class {'spacewalk::client':
#   spacewalk_fqdn => 'spacewalk.local.net',
#   activation_key => '1-d9e796114e1e8ef073b605341ee6580d',
# }

class spacewalk::client (
  $activation_key,
  $spacewalk_fqdn            = "spacewalk.${::domain}",
  $force_registration        = false,
  $use_spacewalk_client_repo = true,
  ) {

  validate_bool($use_spacewalk_client_repo)
  validate_bool($force_registration)

  # spacewalk client packages needed
  $packageList = ['rhn-client-tools','rhn-check', 'rhn-setup', 'm2crypto', 'yum-rhn-plugin']

  package {$packageList:
    ensure  => installed,
  }

  if $use_spacewalk_client_repo == true {
    include spacewalk::repo_client

    Package[$packageList] -> Exec['setupSpacewalkClientRepo']
  }

  # Exec to register with the spacewalk server
  exec {'registerSpacewalk':
    cwd     => '/root',
    path    => '/usr/bin:/usr/sbin:/bin',
    creates => '/etc/sysconfig/rhn/systemid',
    command => "rhnreg_ks --serverUrl=http://$spacewalk_fqdn/XMLRPC --activationkey=$activation_key",
  }

  if $force_registration == true {
    file { 'spacewalk_systemid':
      path   => '/etc/sysconfig/rhn/systemid',
      ensure => absent,
    }

    Exec['registerSpacewalk'] {
      require => [ File['/etc/sysconfig/rhn/systemid'], Package[$packageList] ]
    }
  }
  else {
    Exec['registerSpacewalk'] {
      require => Package[$packageList]
    }
  }
}
