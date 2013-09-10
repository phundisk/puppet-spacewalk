Puppet Module for Spacewalk
============================

Basic usage
-----------

To install Spacewalk server

    class {'spacewalk':  
    db_password => 'secretpassword', # if not set, default pw will be used
    }

To install Spacewalk client

    class {'spacewalk::client':
    spacewalk_fqdn => 'spacewalk.local.net',
    activation_key => '1-d9e796114e1e8ef073b605341ee6580d',
    }

--------------------------------------------------

ABOUT
-----------
  This class will setup the spacewalk server.

QA
-----------
  Tested on CentOS 5.4 with Epel repo
  Tested on CentOS 6.3 (need some packages from the DAG repository python-netaddr, python-pygments, mod_wsgi, etc)

PREREQS
-----------
  For RH6, ensure you are using ther Red Hat Optional Server 6 RHN Channel
  Ensure using EPEL repos

HOW TO USE THIS MODULE
-----------
  Declare param class on a host (i.e. "class {'spacewalk':}" ) and overide any variables if needed
  Create a DNS name of 'https://spacewalk.DOMAIN' and log into the URL, follow on screen instructions.

TROUBLESHOOTING STEPS
-----------
  Ensure nothing in listening on any needed ports.  (i.e. 8080, 8009, etc)
  rm /tmp/spacewalk.answer file and re-run puppet
  /usr/bin/spacewalk-setup-postgresql remove --db spaceschema --user spaceuser
 
TODO
-----------
  Support for Oracle DB in Module
  Test on other systems (CentOS 6.X, Fedora, etc)
  Enable support with external apache / tomcat puppet modules