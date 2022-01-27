# frozen_string_literal: true

require 'singleton'
require 'serverspec'
require 'puppetlabs_spec_helper/module_spec_helper'
include PuppetLitmus

RSpec.configure do |c|
  c.mock_with :rspec
  c.before :suite do
    # Ensure the metrics collector classes are applied
    pp = <<-PUPPETCODE
    include puppet_metrics_collector
    class {'puppet_metrics_collector::system':
      manage_sysstat => true,
    }
    PUPPETCODE

    PuppetLitmus::PuppetHelpers.apply_manifest(pp)

    # Download the plugins to ensure up-to-date facts
    PuppetLitmus::PuppetHelpers.run_shell('/opt/puppetlabs/bin/puppet plugin download')
    # Put a test PE license in place, set its ownership and permissions
    PuppetLitmus::PuppetHelpers.run_shell('echo -e "#######################\n#  Begin License File #\n#######################\n \n# PUPPET ENTERPRISE LICENSE - test
<<<<<<< HEAD
            \nuuid: test\n \nto: test\n \nnodes: 100\n \nlicense_type: Subscription\n \nsupport_type: PE Premium\n \nstart: 2022-01-01\n \nend: 2025-12-31
            \n#####################\n#  End License File #\n#####################" >> /etc/puppetlabs/license.key')
    PuppetLitmus::PuppetHelpers.run_shell('sudo chown root:root /etc/puppetlabs/license.key')
    PuppetLitmus::PuppetHelpers.run_shell('sudo chmod 644 /etc/puppetlabs/license.key')
    # restarting puppet server to clear jruby stats for S0019
    PuppetLitmus::PuppetHelpers.run_shell('puppet resource service pe-puppetserver ensure=stopped; puppet resource service pe-puppetserver ensure=running')
=======
            \nuuid: ****test****\n \nto: test\n \nnodes: 100\n \nlicense_type: Subscription\n \nsupport_type: PE Premium\n \nstart: 2022-01-01\n \nend: 2025-12-31
            \n#####################\n#  End License File #\n#####################" >> /etc/puppetlabs/license.key')
    PuppetLitmus::PuppetHelpers.run_shell('sudo chown root:root /etc/puppetlabs/license.key')
    PuppetLitmus::PuppetHelpers.run_shell('sudo chmod 644 /etc/puppetlabs/license.key')
>>>>>>> (SUP-2901) License check, tests and readme update
  end
end
