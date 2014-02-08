require 'puppetlabs_spec_helper/module_spec_helper'

# Added as Puppet 3.0.x was failing rspec tests with 'unknown function validate_array'
fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))
$LOAD_PATH.unshift File.join(fixture_path, 'modules', 'stdlib', 'lib')

shared_context :defaults do
  let(:node) { 'foo.example.tld' }

  let :default_facts do
    {
      :kernel                 => 'Linux',
      :osfamily               => 'RedHat',
      :operatingsystem        => 'CentOS',
      :operatingsystemrelease => '6.4',
      :architecture           => 'x86_64',
      :has_infiniband         => true,
    }
  end
end

at_exit { RSpec::Puppet::Coverage.report! }
