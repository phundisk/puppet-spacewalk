class spacewalk::repo_client
{
  case $::osfamily {
        'RedHat': {
          case $::operatingsystemrelease {
            /^5/: {
              exec {'setupSpacewalkClientRepo':
                cwd => '/etc/yum.repos.d', 
                path   => "/usr/bin:/usr/sbin:/bin",
                creates => '/etc/yum.repos.d/spacewalk-client.repo',
                command => 'rpm -Uvh http://yum.spacewalkproject.org/2.0-client/RHEL/5/x86_64/spacewalk-client-repo-2.0-3.el5.noarch.rpm'
              }
            }
            /^6/: {
              exec {'setupSpacewalkClientRepo':
                cwd     => '/etc/yum.repos.d', 
                path    => "/usr/bin:/usr/sbin:/bin",
                creates => '/etc/yum.repos.d/spacewalk-client.repo',
                command => 'rpm -Uvh http://yum.spacewalkproject.org/2.0-client/RHEL/6/x86_64/spacewalk-client-repo-2.0-3.el6.noarch.rpm'
              }
              
            }
          } # End OS Release Case
        }
        default: {
            fail("OS family ${::osfamily} not supported")
        } # Since spacewalk is mostly good for just RH type systems, we restrict accordinly.
    } # End case on OS Family
  
}