require 'spec_helper'

describe 'spacewalk::channel', :type => :define do

  context 'when adding a channel' do

    context 'without specifing parameters' do
      let(:title) { 'mychannel' }

      it do
        should contain_exec('mychannel').with({
                                                'command' => 'spacewalk-channel -a -c mychannel -u puppet -p supersecret',
                                                'path'    => ["/usr/bin", "/usr/sbin", "/bin", ],
                                                'unless'  => 'yum -C repolist enabled 2>/dev/null | grep -qw mychannel',
                                              })
      end

      it { should_not contain_exec('mychannel_channel_key')}

    end

    context 'parameter username and password ' do
      let(:title) { 'mychannel' }

      let :params do
        {
          :username => 'user',
          :password => 'secret',
        }
      end

      it do
        should contain_exec('mychannel').with({
                                                'command' => 'spacewalk-channel -a -c mychannel -u user -p secret',
                                                'path'    => ["/usr/bin", "/usr/sbin", "/bin", ],
                                                'unless'  => 'yum -C repolist enabled 2>/dev/null | grep -qw mychannel',
                                              })
      end

      it { should_not contain_exec('mychannel_channel_key')}

    end


    context 'with channel name set' do
      let(:title) { 'mychannel' }

      let :params do
        {
          :username => 'user',
          :password => 'secret',
          :channel  => 'testchannel',
        }
      end

      it do
        should contain_exec('mychannel').with({
                                                'command' => 'spacewalk-channel -a -c testchannel -u user -p secret',
                                                'path'    => ["/usr/bin", "/usr/sbin", "/bin", ],
                                                'unless'  => 'yum -C repolist enabled 2>/dev/null | grep -qw testchannel',
                                              })
      end

      it { should_not contain_exec('mychannel_channel_key')}

    end

    context 'with channel_key and channel_key_uri specified' do
      let(:title) { 'mychannel' }

      let :params do
        {
          :username        => 'user',
          :password        => 'secret',
          :channel_key_id  => 'abcd123',
          :channel_key_uri => 'http://test/test.key',
        }
      end

      it do
        should contain_exec('mychannel').with({
                                                'command' => 'spacewalk-channel -a -c mychannel -u user -p secret',
                                                'path'    => ["/usr/bin", "/usr/sbin", "/bin", ],
                                                'unless'  => 'yum -C repolist enabled 2>/dev/null | grep -qw mychannel',
                                              })
      end

      it do
        should contain_exec('mychannel_channel_key').with({
                                                'command' => 'rpm --import http://test/test.key',
                                                'path'    => ["/bin", "/usr/bin", ],
                                                'unless'  => "rpm -qa --nosignature --nodigest --qf '%{VERSION}\n' gpg-pubkey|grep -q abcd123",
                                              })
      end
    end
  end

  context 'when removing a channel' do

    context 'without specifing an explicit channel name' do
      let(:title) { 'mychannel' }

      let :params do
        {
          :username => 'user',
          :password => 'secret',
          :ensure   => 'absent',
        }
      end

      it do
        should contain_exec('mychannel').with({
                                                'command' => 'spacewalk-channel -r -c mychannel -u user -p secret',
                                                'path'    => ["/usr/bin", "/usr/sbin", "/bin", ],
                                                'onlyif'  => 'yum -C repolist enabled 2>/dev/null | grep -qw mychannel',
                                              })
      end

      it { should_not contain_exec('mychannel_channel_key_delete')}
    end

    context 'with channel name set' do
      let(:title) { 'mychannel' }

      let :params do
        {
          :username => 'user',
          :password => 'secret',
          :channel  => 'testchannel',
          :ensure   => 'absent',
        }
      end

      it do
        should contain_exec('mychannel').with({
                                                'command' => 'spacewalk-channel -r -c testchannel -u user -p secret',
                                                'path'    => ["/usr/bin", "/usr/sbin", "/bin", ],
                                                'onlyif'  => 'yum -C repolist enabled 2>/dev/null | grep -qw testchannel',
                                              })
      end

      it { should_not contain_exec('testchhannel_channel_key_delete')}

    end

    context 'with channel_key and channel_key_uri specified' do
      let(:title) { 'mychannel' }

      let :params do
        {
          :ensure          => 'absent',
          :username        => 'user',
          :password        => 'secret',
          :channel_key_id  => 'abcd123',
          :channel_key_uri => 'http://test/test.key',
        }
      end

      it do
        should contain_exec('mychannel').with({
                                                'command' => 'spacewalk-channel -r -c mychannel -u user -p secret',
                                                'path'    => ["/usr/bin", "/usr/sbin", "/bin", ],
                                                'onlyif'  => 'yum -C repolist enabled 2>/dev/null | grep -qw mychannel',
                                              })
      end

      it do
        should contain_exec('mychannel_channel_key_delete').with({
                                                'command' => 'rpm -e --allmatches gpg-pubkey-abcd123',
                                                'path'    => ["/bin", "/usr/bin", ],
                                                'onlyif'  => "rpm -qa --nosignature --nodigest --qf '%{VERSION}\n' gpg-pubkey|grep -q abcd123",
                                              })
      end
    end
  end

end
