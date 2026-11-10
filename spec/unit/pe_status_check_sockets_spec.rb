# frozen_string_literal: true

require 'spec_helper'
require 'facter'
require_relative '../../lib/shared/pe_status_check'

describe PEStatusCheck do
  let(:ss_output) do
    <<~SS
      Netid State Recv-Q Send-Q Local Address:Port Peer Address:Port Process
      tcp ESTAB 0 0 10.0.0.1:41000 10.0.0.2:8142 timer:(keepalive,1min,0) ino:111111 sk:1
      tcp ESTAB 0 0 10.0.0.1:41002 10.0.0.3:8142 timer:(keepalive,1min,0) ino:222222 sk:2
    SS
  end

  describe '.established_socket_inodes' do
    it 'queries TCP only and does not ask ss to map processes' do
      expect(Facter::Core::Execution).to receive(:execute) do |cmd, _opts|
        flags = cmd.split[1]
        expect(flags).to match(%r{\A-[a-z]*t})
        expect(flags).not_to include('p')
        expect(cmd).to include('dport = :8142')
        ss_output
      end
      expect(described_class.established_socket_inodes(8142)).to eq(Set.new(['111111', '222222']))
    end
  end

  describe '.process_socket_inodes' do
    it 'returns only socket inodes and tolerates vanished fds' do
      allow(Dir).to receive(:glob).with('/proc/42/fd/*').and_return(['/proc/42/fd/3', '/proc/42/fd/4', '/proc/42/fd/5'])
      allow(File).to receive(:readlink).with('/proc/42/fd/3').and_return('socket:[111111]')
      allow(File).to receive(:readlink).with('/proc/42/fd/4').and_return('/var/log/x.log')
      allow(File).to receive(:readlink).with('/proc/42/fd/5').and_raise(Errno::ENOENT)
      expect(described_class.process_socket_inodes(42)).to eq(Set.new(['111111']))
    end
  end

  describe '.service_main_pid' do
    it 'returns the PID of a running unit' do
      allow(Facter::Core::Execution).to receive(:execute).with(%r{systemctl show .*pxp-agent\.service}, anything).and_return("1234\n")
      expect(described_class.service_main_pid('pxp-agent')).to eq(1234)
    end

    it 'returns nil when the unit is not running' do
      allow(Facter::Core::Execution).to receive(:execute).and_return("0\n")
      expect(described_class.service_main_pid('pxp-agent')).to be_nil
    end
  end

  describe '.process_connected_to?' do
    it 'is true when the process owns one of the connection inodes' do
      allow(described_class).to receive(:established_socket_inodes).with(8142).and_return(Set.new(['111111']))
      allow(described_class).to receive(:process_socket_inodes).with(42).and_return(Set.new(['111111', '999']))
      expect(described_class.process_connected_to?(8142, 42)).to be true
    end

    it 'is false when another process owns the connection' do
      allow(described_class).to receive(:established_socket_inodes).and_return(Set.new(['111111']))
      allow(described_class).to receive(:process_socket_inodes).and_return(Set.new(['999']))
      expect(described_class.process_connected_to?(8142, 42)).to be false
    end

    it 'is false without a PID' do
      expect(Facter::Core::Execution).not_to receive(:execute)
      expect(described_class.process_connected_to?(8142, nil)).to be false
    end
  end
end
