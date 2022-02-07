# frozen_string_literal: true

require 'spec_helper_acceptance'
# Test Confirms that the agent only fact does not appear on infra components
describe 'check agent_status_check fact is not on infra components' do
  it 'agent_status_check should be empty' do
    expect(host_inventory['facter']['agent_status_check']).to be_nil
  end
end
