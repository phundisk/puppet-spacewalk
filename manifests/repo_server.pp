class spacewalk::repo_server
{
    case $::osfamily {
        'RedHat': {
          case $::operatingsystemrelease {
            /^5/: {
              exec {'setupSpacewalkServerRepo':
                cwd => '/etc/yum.repos.d', 
                path   => "/usr/bin:/usr/sbin:/bin",
                creates => '/etc/yum.repos.d/spacewalk.repo',
                command => 'rpm -Uvh http://yum.spacewalkproject.org/2.0/RHEL/5/x86_64/spacewalk-repo-2.0-3.el5.noarch.rpm'
              }
            }
            /^6/: {
              exec {'setupSpacewalkServerRepo':
                cwd     => '/etc/yum.repos.d', 
                path    => "/usr/bin:/usr/sbin:/bin",
                creates => '/etc/yum.repos.d/spacewalk.repo',
                command => 'rpm -Uvh http://yum.spacewalkproject.org/2.0/RHEL/6/x86_64/spacewalk-repo-2.0-3.el6.noarch.rpm'
              }
              
              file {'/etc/yum.repos.d/jpackage-generic.repo':
                ensure => present,
                owner  => 'root',
                group  => 'root',
                mode   => '0644',
                source => 'puppet:///modules/spacewalk/jpackage-generic.repo',
              }
              
            }
          } # End OS Release Case
        }
        default: {
            fail("OS family ${::osfamily} not supported")
        } # Since spacewalk is mostly good for just RH type systems, we restrict accordinly.
    } # End case on OS Family
}