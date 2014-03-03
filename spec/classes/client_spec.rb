require 'spec_helper'

describe 'spacewalk::client', :type => :class do

  let :facts do
    {
      :domain   => 'test.com',
      :osfamily => 'RedHat',
      :operatingsystemrelease => '6',
    }
  end

  context 'when use_spacewalk_client_repo is set to true' do

    let :params do
      {
        :force_registration        => false,
        :use_spacewalk_client_repo => true,
        :activation_key            => '12345',
      }
    end

    it do
      should contain_exec('registerSpacewalk').with({
                                                      'cwd'     => '/root',
                                                      'path'    => '/usr/bin:/usr/sbin:/bin',
                                                      'creates' => '/etc/sysconfig/rhn/systemid',
                                                      'command' => "rhnreg_ks --serverUrl=http://spacewalk.test.com/XMLRPC --activationkey=12345",
                                                    })
    end

    it { should contain_class('spacewalk::repo_client')}

    packages = ['rhn-client-tools','rhn-check', 'rhn-setup', 'm2crypto', 'yum-rhn-plugin']
    packages.each do |name|
      it { should contain_package("#{name}").with('ensure' => 'installed') }
      it { should contain_exec('setupSpacewalkClientRepo').that_requires("Package[#{name}]") }
    end
  end

  context 'when use_spacewalk_client_repo is set to false' do
    let :params do
      {
        :force_registration        => false,
        :use_spacewalk_client_repo => false,
        :activation_key            => '12345',
      }
    end

    it do
      should contain_exec('registerSpacewalk').with({
                                                      'cwd'     => '/root',
                                                      'path'    => '/usr/bin:/usr/sbin:/bin',
                                                      'creates' => '/etc/sysconfig/rhn/systemid',
                                                      'command' => "rhnreg_ks --serverUrl=http://spacewalk.test.com/XMLRPC --activationkey=12345",
                                                    })
    end

    it { should_not contain_class('spacewalk::repo_client')}

    packages = ['rhn-client-tools','rhn-check', 'rhn-setup', 'm2crypto', 'yum-rhn-plugin']
    packages.each do |name|
      it { should_not  contain_exec('setupSpacewalkClientRepo').that_requires("Package[#{name}]") }
      it { should contain_package("#{name}").with( 'ensure'  => 'installed') }
    end

  end

  context 'when force_reqistration is true' do
    let :params do
      {
        :force_registration        => true,
        :use_spacewalk_client_repo => false,
        :activation_key            => '12345',
      }
    end

    it do
      should contain_file('spacewalk_systemid').with({
                                                     'ensure' => 'absent',
                                                     'path'   => '/etc/sysconfig/rhn/systemid',
                                                     })
    end

    # it do
    #   should contain_exec('registerSpacewalk').with_require('[File[/etc/sysconfig/rhn/systemid]{:path=>"/etc/sysconfig/rhn/systemid"}, Package[rhn-client-tools]{:name=>"rhn-client-tools"}, Package[rhn-check]{:name=>"rhn-check"}, Package[rhn-setup]{:name=>"rhn-setup"}, Package[m2crypto]{:name=>"m2crypto"}, Package[yum-rhn-plugin]{:name=>"yum-rhn-plugin"}]')
    # end

  end

  context 'when force_reqistration is false' do
    let :params do
      {
        :force_registration        => false,
        :use_spacewalk_client_repo => false,
        :activation_key            => '12345',
      }
    end

    it { should_not contain_file('spacewalk_systemid') }

    # it do
    #   should contain_exec('registerSpacewalk').with_require('[Package[rhn-client-tools]{:name=>"rhn-client-tools"}, Package[rhn-check]{:name=>"rhn-check"}, Package[rhn-setup]{:name=>"rhn-setup"}, Package[m2crypto]{:name=>"m2crypto"}, Package[yum-rhn-plugin]{:name=>"yum-rhn-plugin"}]')
    # end

  end
end
