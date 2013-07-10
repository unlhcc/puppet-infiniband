source "https://rubygems.org"

group :development, :test do
  gem 'rake'
  # Temporary until rpsec-puppet 2.0 is released
  gem 'rspec-puppet', :git => 'git://github.com/rodjek/rspec-puppet.git', :ref => '36812b3', :require => false
  gem 'puppetlabs_spec_helper', :require => false
  gem 'puppet-lint'
  gem 'travis-lint'
  gem 'rspec-system-puppet', '~>2.0.0'
  gem 'ci_reporter'
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end