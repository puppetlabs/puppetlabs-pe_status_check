# frozen_string_literal: true

require 'spec_helper'

describe 'pe_status_check' do
  let(:hiera_config) { 'hiera.yaml' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end

  context 'Reporting' do
    let(:facts) do
      { pe_status_check: { 'S0001' => false } }
    end
    let(:message) { 'S0001 is at fault. The indicator S0001 Determines if Puppet agent Service is running, refer to documentation for required action' }

    it 'on a negative indicator' do
      is_expected.to contain_notify('pe_status_check S0001').with_message(message)
    end
  end
end
