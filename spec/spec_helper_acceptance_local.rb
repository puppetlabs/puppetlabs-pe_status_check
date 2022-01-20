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
  end
end
