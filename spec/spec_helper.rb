## This is a nasty collection of rspec-puppet and puppetlabs_spec_helper
## pieces to allow rspec-puppet git master to be used with some useful
## fixture helpers provided by puppetlabs_spec_helper

## rspec-puppet ##
require 'rspec-puppet'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')

  c.default_facts = {
    :osfamily => 'RedHat',
    :operatingsystem => 'CentOS',
    :has_infiniband => true,
  }
end
## END rspec-puppet ##

## puppetlabs_spec_helper ##
ENV['MOCHA_OPTIONS']='skip_integration'

require 'mocha/api'
require 'pathname'
require 'tmpdir'

# Define the main module namespace for use by the helper modules
module PuppetlabsSpec
  # FIXTURE_DIR represents the standard locations of all fixture data. Normally
  # this represents <project>/spec/fixtures. This will be used by the fixtures
  # library to find relative fixture data.
  FIXTURE_DIR = File.join("spec", "fixtures") unless defined?(FIXTURE_DIR)
end

require 'puppetlabs_spec_helper/puppetlabs_spec/files'
require 'puppetlabs_spec_helper/puppetlabs_spec/fixtures'

require 'facter'

RSpec.configure do |config|
  # Include PuppetlabsSpec helpers so they can be called at convenience
  config.extend PuppetlabsSpec::Files
  config.extend PuppetlabsSpec::Fixtures
  config.include PuppetlabsSpec::Fixtures

  # FIXME REVISIT - We may want to delegate to Facter like we do in
  # Puppet::PuppetSpecInitializer.initialize_via_testhelper(config) because
  # this behavior is a duplication of the spec_helper in Facter.
  config.before :each do
    # Ensure that we don't accidentally cache facts and environment between
    # test cases.  This requires each example group to explicitly load the
    # facts being exercised with something like
    # Facter.collection.loader.load(:ipaddress)
    Facter::Util::Loader.any_instance.stubs(:load_all)
    Facter.clear
    Facter.clear_messages
  end

  # This will cleanup any files that were created with tmpdir or tmpfile
   config.after :each do
     PuppetlabsSpec::Files.cleanup
   end
end
## END puppetlabs_spec_helper ##
