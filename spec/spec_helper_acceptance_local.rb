# frozen_string_literal: true

require 'singleton'
require 'serverspec'
require 'puppetlabs_spec_helper/module_spec_helper'
include PuppetLitmus

RSpec.configure do |c|
  c.mock_with :rspec
  c.before :suite do
    # Download the plugins to ensure up-to-date facts
    PuppetLitmus::PuppetHelpers.run_shell('/opt/puppetlabs/bin/puppet plugin download')
    # Put a test PE license in place
    PuppetLitmus::PuppetHelpers.run_shell('echo -e "#######################\n#  Begin License File #\n#######################\n \n# PUPPET ENTERPRISE LICENSE - test
      \nuuid: ****test****\n \nto: test\n \nnodes: 100\n \nlicense_type: Subscription\n \nsupport_type: PE Premium\n \nstart: 2022-01-31\n \nend: 2022-12-31
      \n#####################\n#  End License File #\n#####################" >> /etc/puppetlabs/license.key')
  end
end
