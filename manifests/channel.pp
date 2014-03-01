# == Class: spacewalk::channel
#
# Subscribe/Unsubscribe to spacewalk/satellite channels
#
# === Parameters
#
# [*channel*]
#   The name of the channel to subscribe
#
#   Default is the $title of the defined type.
#
# [*username*]
#   Username for the satellite.
#
# [*password*]
#   Password for the satellite user.
#
# [*ensure*]
#   Ensure that the system is subscribed (ensure =>
#   'present') or unsubscribed (ensure => 'absent') to
#   a particular channel. This also adds or removes the channel
#   key if specified.
#
#   Default is 'present'.
#
# [*channel_key_uri*]
#   URI to a gpg key we need to import for this channel.
#
#   Default is unset, so no channel key is added
#
# [*channel_key_id*]
#   The gpg key id used for this channel. We need this
#   so we can check if this particular key is already present
#   in the rpm database.
#
#   Default is unset.
#
# === Examples
#
#  spacewalk::channel { 'rhel-x86_64-server-6':
#    user     => 'username',
#    password => 'secret',
#  }
#
# === Authors
#
# Toni Schmidbauer <toni@stderr.at>
#
# === Copyright
#
# Copyright 2014 Toni Schmidbauer
#
define spacewalk::channel(
  $password        = 'supersecret',
  $username        = 'puppet',
  $channel         = $title,
  $ensure          = 'present',
  $channel_key_uri = '',
  $channel_key_id  = '',
  ) {

  if $channel_key_uri == '' and $channel_key_id != '' {
    fail("if you specify a channel_key_id, a channel_key is also required!")
  }

  if $channel_key_id == '' and $channel_key_uri != '' {
    fail("if you specify a channel_key_uri, a channel_key_id is also required!")
  }

  if $ensure == 'present' {
    $channel_option = '-a'

    exec { $title:
      command => "spacewalk-channel ${channel_option} -c ${channel} -u ${username} -p ${password}",
      path    => ['/usr/bin', '/usr/sbin', '/bin', ],
      unless  => "yum -C repolist enabled 2>/dev/null | grep -qw ${channel}",
    }

    if $channel_key_id != '' and $channel_key_uri != '' {
      exec { "${$title}_channel_key":
        command => "rpm --import ${channel_key_uri}",
        path    => ['/bin', '/usr/bin', ],
        unless  => "rpm -qa --nosignature --nodigest --qf '%{VERSION}\n' gpg-pubkey|grep -q ${channel_key_id}",
      }

      Exec[$title] -> Exec["${title}_channel_key"]
    }
  }
  elsif $ensure == 'absent' {
    $channel_option = '-r'

    exec { $title:
      command => "spacewalk-channel ${channel_option} -c ${channel} -u ${username} -p ${password}",
      path    => ['/usr/bin', '/usr/sbin', '/bin', ],
      onlyif  => "yum -C repolist enabled 2>/dev/null | grep -qw ${channel}",
    }

    if $channel_key_id != '' and $channel_key_uri != '' {
      exec { "${$title}_channel_key_delete":
        command => "rpm -e --allmatches gpg-pubkey-${channel_key_id}",
        path    => ['/bin', '/usr/bin', ],
        onlyif  => "rpm -qa --nosignature --nodigest --qf '%{VERSION}\n' gpg-pubkey|grep -q ${channel_key_id}",
      }

      Exec[$title] -> Exec["${title}_channel_key_delete"]
    }
  }
  else {
    fail("Unsupported value for option ensure: $ensure, has to be 'present' or 'absent'")
  }
}
