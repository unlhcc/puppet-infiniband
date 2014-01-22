require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppetlabs_spec_helper/rake_tasks'
require 'rspec-system/rake_task'

task :default do
  sh %{rake -T}
end

desc "Run puppet-syntax, puppet-lint and rspec-puppet tasks"
task :ci => [:syntax, :lint, :spec]

PuppetLint.configuration.ignore_paths = ["vendor/**/*.pp", "spec/**/*.pp"]
PuppetLint.configuration.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"

# Disable puppet-lint checks
PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.send("disable_class_inherits_from_params_class")

# Ignore files outside this module
PuppetLint.configuration.ignore_paths = ["pkg/**/*.pp", "vendor/**/*.pp", "spec/**/*.pp"]
PuppetSyntax.exclude_paths = ["pkg/**/*.pp", "vendor/**/*.pp", "spec/**/*.pp"]

# Used by Jenkins to show tests report.
require 'ci/reporter/rake/rspec'
ENV['CI_REPORTS'] = 'reports'
