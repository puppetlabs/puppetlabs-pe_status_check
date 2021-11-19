# frozen_string_literal: true

require 'spec_helper_acceptance'

# Tests Self_service class for default behaviours, no notification on all facts passing
# Ensures default PE deployment passes all test cases
describe 'self_service class' do
  context 'activates module default parameters' do
    it 'applies the class with default parameters' do
      pp = <<-MANIFEST
        include self_service
        MANIFEST
      idempotent_apply(pp)
    end
    # Test Confirms all facts are false which is another indicator the class is performing correctly
    describe 'check no self_service fact is false' do
      it 'if idempotent all facts should be true' do
        expect(host_inventory['facter']['self_service']['S0001']).to eq true
        expect(host_inventory['facter']['self_service']['S0002']).to eq true
        expect(host_inventory['facter']['self_service']['S0003']).to eq true
        expect(host_inventory['facter']['self_service']['S0004']).to eq true
        expect(host_inventory['facter']['self_service']['S0005']).to eq true
        expect(host_inventory['facter']['self_service']['S0006']).to eq true
        expect(host_inventory['facter']['self_service']['S0007']).to eq true
        expect(host_inventory['facter']['self_service']['S0008']).to eq true
      end
    end

    # Test Confirms nofifications are working as expected, appearing if a fact is set to false, and not triggering
    # if the same fact is placed in the indicator_exclusions parameter
    # This test also serves as confirmation fact S0001 is working Correctly
    describe 'check notifications work as expected' do
      it 'if S0001 reports false notify with message' do
        pp = <<-MANIFEST
        include self_service
        MANIFEST
        run_shell('puppet resource service puppet ensure=stopped')
        result = run_shell('facter -p self_service.S0001')
        output = apply_manifest(pp).stdout
        expect(output).to match('Notice: S0001 is at fault, please refer to documentation for required action')
        expect(result.stdout).to match(%r{false})
      end
      it 'if in the exclude list a parameter should not notify' do
        ppp = <<-MANIFEST
        class {'self_service':
            indicator_exclusions => ['S0001'],
            }
        MANIFEST
        idempotent_apply(ppp)
        run_shell('puppet resource service puppet ensure=running')
      end
    end

    # Each facts failing condition should be set and the output of the facts tested
    describe 'check all facts report false in the proper conditions' do
      it 'if S0002 conditions for false are met' do
        run_shell('puppet resource service pxp-agent ensure=stopped')
        result = run_shell('facter -p self_service.S0002')
        expect(result.stdout).to match(%r{false})
      end
      it 'if S0003 conditions for false are met' do
        run_shell('puppet config set noop true', expect_failures: false)
        result = run_shell('facter -p self_service.S0003')
        expect(result.stdout).to match(%r{false})
        run_shell('puppet config set noop false', expect_failures: false)
      end
      it 'if S0004 conditions for false are met' do
        run_shell('puppet resource service pe-orchestration-services  ensure=stopped')
        result = run_shell('facter -p self_service.S0004')
        expect(result.stdout).to match(%r{false})
        run_shell('puppet resource service pe-orchestration-services  ensure=running')
      end

      it 'if S0006 conditions for false are met' do
        run_shell('mkdir -p /etc/puppetlabs/facter/facts.d/;echo \'{"load_averages": {"15m": 20.5}}\' > /etc/puppetlabs/facter/facts.d/load_averages.json')
        result = run_shell('facter -p self_service.S0006')
        expect(result.stdout).to match(%r{false})
        run_shell('rm -f /etc/puppetlabs/facter/facts.d/load_averages.json')
      end

      it 'if S0007 and S0008 conditions for false are met' do
        run_shell('fallocate -l $(($(facter -p mountpoints.\'/\'.available_bytes)-1073741824)) /largefile.txt')
        result = run_shell('facter -p self_service.S0007')
        expect(result.stdout).to match(%r{false})
        result = run_shell('facter -p self_service.S0008')
        expect(result.stdout).to match(%r{false})
        run_shell('rm -rf  /largefile.txt')
      end
    end
  end
end
