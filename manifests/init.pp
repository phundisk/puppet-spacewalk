class spacewalk (
  $db_type              = 'postgresql',
  $postgresql_db_name   = 'spaceschema',
  $db_user              = 'spaceuser',
  $db_password          = 'spacepw',
  $postgresql_embedded  = 'true', # This will use the spacewalk postgresql.  Easy install
  $db_host              = 'localhost', # must be localhost for embedded postgresql db setup
  $postgresql_port      = '5432',
  $oracle_port          = '1521',
  $admin_email          = 'root@localhost',
  $configure_apache_ssl = true,
  $ca_cert_password     = 'passcertword',
  $ca_organization      = 'operations',
  $ca_organization_unit = $::fqdn,
  $ca_email_address     = 'root@localhost',
  $ca_city              = 'Boston',
  $ca_state             = 'MA',
  $ca_country_code      = 'US',
  $enable_cobbler       = true, # TFTP Support
){
  
  # ABOUT: This class will setup the spacewalk server.
  # QA: Tested on CentOS 5.4 with Epel repo
  #     Tested on CentOS 6.3 (need some packages from the DAG repository python-netaddr, python-pygments, mod_wsgi, etc)
  #
  # PREREQS:
  # * For RH6, ensure you are using ther Red Hat Optional Server 6 RHN Channel
  # * Ensure using EPEL repos
  #
  # HOW TO USE THIS MODULE:
  # * Declare param class on a host (i.e. "class {'spacewalk':}" ) and overide any variables if needed
  # * Create a DNS name of 'https://spacewalk.DOMAIN' and log into the URL, follow on screen instructions.
  #
  # TROUBLESHOOTING STEPS:
  # * Ensure nothing in listening on any needed ports.  (i.e. 8080, 8009, etc)
  # * rm /tmp/spacewalk.answer file and re-run puppet
  # * /usr/bin/spacewalk-setup-postgresql remove --db spaceschema --user spaceuser
  # 
  # TODO:
  # * Support for Oracle DB in Module
  # * Test on other systems (CentOS 6.X, Fedora, etc)
  # * Enable support with external apache / tomcat puppet modules
    
  include spacewalk::repo_server
  
  # deteremin which db type is defined, oracle/postgresql
  if $spacewalk::db_type == 'postgresql' {
    # Postgresql related stuff
    include spacewalk::postgresql
  }
  elsif $spacewalk::db_type == 'oracle' {
    # NOT YET IMPLEMENTED
    include spacewalk::oracle
  }
  else {
    fail("The db_type of ${spacewalk::db_type} is not valid or not supported.")
  }
  
  # Create an answer file from the param class.  This will be overwritten by the exec (kinda hacky)
  file {'/tmp/spacewalk.answer':
    ensure => present,
    owner => 'root',
    group => 'root',
    replace => false,
    content => template('spacewalk/spacewalk.answer.erb')
  }
  
  # apache config files.  static files for right now
  file {'/etc/httpd/conf.d/zz-spacewalk-www.conf':
    ensure => present,
    owner => 'root',
    group => 'apache',
    mode => '0644',
    source => 'puppet:///modules/spacewalk/zz-spacewalk-www.conf',
    require => Exec['setupSpacewalk'],
  }

  file {'/etc/httpd/conf.d/zz-spacewalk-server.conf':
    ensure => present,
    owner => 'root',
    group => 'apache',
    mode => '0644',
    source => 'puppet:///modules/spacewalk/zz-spacewalk-server.conf',
    require => Exec['setupSpacewalk'],
  }
  
  file {'/etc/httpd/conf.d/zz-spacewalk-server-wsgi.conf':
    ensure => present,
    owner => 'root',
    group => 'apache',
    mode => '0644',
    source => 'puppet:///modules/spacewalk/zz-spacewalk-server-wsgi.conf',
    require => Exec['setupSpacewalk'],
  }
  
  
}