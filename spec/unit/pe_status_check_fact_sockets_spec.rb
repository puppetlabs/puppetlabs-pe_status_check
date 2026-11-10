# frozen_string_literal: true

require 'spec_helper'
require 'facter'
require_relative '../../lib/shared/pe_status_check'

# Captures the chunks the pe_status_check fact defines so a single chunk can be run in isolation
class FakeFactResolution
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

describe 'pe_status_check socket chunks (S0041/S0042)' do
  let(:resolution) { FakeFactResolution.new }
  let(:role) { 'pe_compiler' }

  before(:each) do
    fake = resolution
    allow(Facter).to receive(:add).with(:pe_status_check, anything) { |*_args, &blk| fake.instance_eval(&blk) }
    allow(Facter).to receive(:value).and_call_original
    allow(Facter).to receive(:value).with('pe_status_check_role').and_return(role)
    load File.expand_path('../../lib/facter/pe_status_check.rb', __dir__)
  end

  def run_chunk(name)
    resolution.instance_exec(&resolution.chunks.fetch(name))
  end

  describe 'S0042' do
    it 'checks the pxp-agent unit against port 8142' do
      expect(PEStatusCheck).to receive(:service_main_pid).with('pxp-agent').and_return(42)
      expect(PEStatusCheck).to receive(:process_connected_to?).with(8142, 42).and_return(true)
      expect(run_chunk(:S0042)).to eq(S0042: true)
    end

    it 'is false when pxp-agent is not running' do
      allow(PEStatusCheck).to receive(:service_main_pid).with('pxp-agent').and_return(nil)
      expect(run_chunk(:S0042)).to eq(S0042: false)
    end

    it 'is false when ss fails' do
      allow(PEStatusCheck).to receive(:service_main_pid).and_return(42)
      allow(PEStatusCheck).to receive(:process_connected_to?).and_raise(Facter::Core::Execution::ExecutionFailure, 'timeout')
      expect(run_chunk(:S0042)).to eq(S0042: false)
    end
  end

  describe 'S0041' do
    it 'checks the pe-puppetserver unit (the broker on compilers) against port 8143' do
      expect(PEStatusCheck).to receive(:service_main_pid).with('pe-puppetserver').and_return(77)
      expect(PEStatusCheck).to receive(:process_connected_to?).with(8143, 77).and_return(true)
      expect(run_chunk(:S0041)).to eq(S0041: true)
    end

    it 'is false when the compiler broker holds no 8143 connection' do
      allow(PEStatusCheck).to receive(:service_main_pid).with('pe-puppetserver').and_return(77)
      allow(PEStatusCheck).to receive(:process_connected_to?).with(8143, 77).and_return(false)
      expect(run_chunk(:S0041)).to eq(S0041: false)
    end

    context 'on a primary' do
      let(:role) { 'primary' }

      it 'does not run' do
        expect(PEStatusCheck).not_to receive(:process_connected_to?)
        expect(run_chunk(:S0041)).to be_nil
      end
    end
  end
end
