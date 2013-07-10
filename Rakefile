require 'puppet-lint/tasks/puppet-lint'
require 'puppetlabs_spec_helper/rake_tasks'
require 'rspec-system/rake_task'

task :default do
  sh %{rake -T}
end

desc "Run rspec-puppet and puppet-lint tasks"
task :ci => [
  :lint,
  :validate,
  :spec,
]

PuppetLint.configuration.ignore_paths = ["vendor/**/*.pp", "spec/**/*.pp"]
PuppetLint.configuration.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"

# Disable puppet-lint checks
PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.send("disable_class_inherits_from_params_class")

# Used by Jenkins to show tests report.
require 'ci/reporter/rake/rspec'
ENV['CI_REPORTS'] = 'reports'

# Invoked by Jenkins to validate manifest syntax
require 'puppet/face'
desc "Perform puppet parser's validation on manifests"
task :validate do
  Puppet::Face[:parser, '0.0.1'].validate(FileList['**/*.pp'].exclude('vendor/**/*.pp', 'spec/**/*.pp').join())
end

