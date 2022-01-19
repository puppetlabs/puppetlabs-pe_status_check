# frozen_string_literal: true

require 'spec_helper_acceptance'
# Test Confirms that the agent only fact does not appear on infra components
describe 'check agent_self_service fact is not on infra components' do
  it 'agent_self_service should be empty' do
    expect(host_inventory['facter']['agent_self_service']).to be_nil
  end
end
