class spacewalk::absent{
  # This will remove most stuff related to spacewalk server. 
  # 
  
  file {'/tmp/spacewalk.answer':
    ensure => absent,
  }

  file {'/etc/httpd/conf.d/zz-spacewalk-www.conf':
    ensure => absent
  }

  file {'/etc/httpd/conf.d/zz-spacewalk-server.conf':
    ensure => absent,
  }
  
  file {'/etc/httpd/conf.d/zz-spacewalk-server-wsgi.conf':
    ensure => absent,
  }
  
  package {'spacewalk-postgresql':
    ensure => absent,
  }
  
  package {'spacewalk-setup-postgresql':
    ensure      => absent
  }
  
  file {'/var/spacewalk':
    ensure => absent,
  }

}