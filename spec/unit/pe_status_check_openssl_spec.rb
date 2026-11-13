# frozen_string_literal: true

require 'spec_helper'
require 'facter'
require_relative '../../lib/shared/pe_status_check'

# Captures the chunks a fact defines so a single chunk can be run in isolation
class FakeOpensslFactResolution
  attr_reader :chunks

  def initialize
    @chunks = {}
  end

  def confine(*_args, &_block); end

  def require(*_args); end

  def chunk(name, &block)
    @chunks[name] = block
  end
end

# Puppet Server's JRuby on FIPS cannot load openssl (PE-45614 / MODULES-12083).
# The facts must still load there and skip the checks that need real crypto.
describe 'pe_status_check without openssl' do
  describe 'PEStatusCheck.load_openssl' do
    it 'is true when openssl loads' do
      expect(PEStatusCheck.load_openssl).to be(true)
    end

    it 'is false instead of raising when JRuby cannot load the openssl extension' do
      allow(PEStatusCheck).to receive(:require).with('openssl')
                                               .and_raise(NameError, 'cannot load (ext) (org.jruby.ext.openssl.OpenSSL)')
      expect(PEStatusCheck.load_openssl).to be(false)
    end

    it 'is false instead of raising on a LoadError' do
      allow(PEStatusCheck).to receive(:require).with('openssl').and_raise(LoadError)
      expect(PEStatusCheck.load_openssl).to be(false)
    end
  end

  it 'does not warn when the shared file is loaded a second time' do
    # Agents can load it from both the modulepath and the pluginsync cache
    shared = File.expand_path('../../lib/shared/pe_status_check.rb', __dir__)
    expect { load shared }.not_to output(%r{already initialized constant}).to_stderr
  end

  it 'reports openssl as available on MRI' do
    expect(PEStatusCheck.openssl_available?).to be(true)
  end

  context 'when openssl is unavailable' do
    let(:resolution) { FakeOpensslFactResolution.new }

    before(:each) do
      allow(PEStatusCheck).to receive(:openssl_available?).and_return(false)
      # If a guarded chunk ever reached OpenSSL, these would fail the example
      allow(OpenSSL::X509::Certificate).to receive(:new).and_raise('OpenSSL::X509::Certificate used without openssl')
      allow(OpenSSL::X509::CRL).to receive(:new).and_raise('OpenSSL::X509::CRL used without openssl')
      allow(OpenSSL::PKey::RSA).to receive(:new).and_raise('OpenSSL::PKey::RSA used without openssl')
      allow(File).to receive(:exist?).and_call_original
      allow(Facter).to receive(:value).and_call_original
      allow(Facter).to receive(:value).with('pe_status_check_role').and_return('primary')
    end

    def run_chunk(name)
      resolution.instance_exec(&resolution.chunks.fetch(name))
    end

    it 'http_get returns false without building an SSL client' do
      expect(Net::HTTP).not_to receive(:new)
      expect(PEStatusCheck.http_get('/status/v1/services', 8140, 'primary.example.com')).to be(false)
    end

    describe 'the pe_status_check fact' do
      before(:each) do
        fake = resolution
        allow(Facter).to receive(:add).with(:pe_status_check, anything) { |*_args, &blk| fake.instance_eval(&blk) }
        load File.expand_path('../../lib/facter/pe_status_check.rb', __dir__)
      end

      [:S0005, :S0015, :S0023, :S0025].each do |name|
        it "skips #{name}" do
          allow(File).to receive(:exist?).with(anything).and_return(true)
          expect(run_chunk(name)).to be_nil
        end
      end
    end

    describe 'the agent_status_check fact' do
      before(:each) do
        fake = resolution
        allow(Facter).to receive(:add).with(:agent_status_check, anything) { |*_args, &blk| fake.instance_eval(&blk) }
        load File.expand_path('../../lib/facter/agent_status_check.rb', __dir__)
      end

      [:AS001, :AS004].each do |name|
        it "skips #{name}" do
          allow(File).to receive(:exist?).with(anything).and_return(true)
          expect(run_chunk(name)).to be_nil
        end
      end
    end
  end
end
