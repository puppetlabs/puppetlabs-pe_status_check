# Self service fact aims to have all chunks reporting as true, this indicates ideal state, any individual chunk reporting false should be alerted on and checked against documentation for next steps
# Use shared logic from PuppetSelfService

Facter.add(:self_service, type: :aggregate) do
  confine kernel: 'Linux'
  confine { Facter.value(:pe_build) }
  require 'puppet'
  require 'yaml'
  require_relative '../shared/puppet_self_service'
  puppet_bin = '/opt/puppetlabs/bin/puppet'

  chunk(:S0001) do
    # Is the Agent Service Running and Enabled
    { S0001: PuppetSelfService.service_running_enabled('puppet') }
  end

  chunk(:S0002) do
    # Is the Pxp-Agent Service Running and Enabled
    { S0002: PuppetSelfService.service_running_enabled('pxp-agent') }
  end

  chunk(:S0003) do
    # check for noop logic flip as false is the desired state
    { S0003: !Puppet.settings['noop'] }
  end

  chunk(:S0004) do
    next unless PuppetSelfService.primary?
    # Is PE and has clienttools covers pe-psql and compilers
    # Check for service status that is not green, potentially need a better way of doing this, or perhaps calling the api directly for each service
    result = Facter::Core::Execution.execute("#{puppet_bin} infrastructure status")
    if result.include?('Unknown') || result.include?('Unreachable')
      { S0004: false }
    else
      { S0004: true }
    end
  end

  chunk(:S0005) do
    next unless File.exist?('/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem') || File.exist?('/etc/puppetlabs/puppetserver/ca/ca_crt.pem')
    raw_ca_cert = if File.exist? '/etc/puppetlabs/puppetserver/ca/ca_crt.pem'
                    File.read '/etc/puppetlabs/puppetserver/ca/ca_crt.pem'
                  else
                    File.read '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem'
                  end
    certificate = OpenSSL::X509::Certificate.new raw_ca_cert
    result = certificate.not_after - Time.now
    { S0005: result > 7_776_000 }
  end

  chunk(:S0007) do
    next unless PuppetSelfService.primary? || PuppetSelfService.replica? || PuppetSelfService.postgres?
    # check postgres data mount has at least 20% free
    pg_version = Facter.value(:pe_postgresql_info)['installed_server_version']
    data_dir = Facter.value(:pe_postgresql_info)['versions'][pg_version].fetch('data_dir', '/opt/puppetlabs/server/data/postgresql')

    { S0007: PuppetSelfService.filesystem_free(data_dir) >= 20 }
  end

  chunk(:S0008) do
    next unless PuppetSelfService.primary? || PuppetSelfService.replica? || PuppetSelfService.compiler? || PuppetSelfService.legacy_compiler?
    # check codedir data mount has at least 20% free
    { S0008: PuppetSelfService.filesystem_free(Puppet.settings['codedir']) >= 20 }
  end

  chunk(:S0009) do
    next unless PuppetSelfService.replica? || PuppetSelfService.compiler? || PuppetSelfService.legacy_compiler? || PuppetSelfService.primary?
    # Is the Pe-puppetsever Service Running and Enabled
    { S0009: PuppetSelfService.service_running_enabled('pe-puppetserver') }
  end

  chunk(:S0010) do
    next unless PuppetSelfService.replica? || PuppetSelfService.compiler? || PuppetSelfService.primary?
    # Is the pe-puppetdb Service Running and Enabled
    { S0010: PuppetSelfService.service_running_enabled('pe-puppetdb') }
  end

  chunk(:S0011) do
    next unless PuppetSelfService.replica? || PuppetSelfService.postgres? || PuppetSelfService.primary?
    # Is the pe-postgres Service Running and Enabled
    postgresversion = PuppetSelfService.pe_postgres_service_name
    { S0011: PuppetSelfService.service_running_enabled(postgresversion.to_s) }
  end

  chunk(:S0012) do
    summary_path = Puppet.settings['lastrunfile']
    next unless File.exist?(summary_path)
    # Did Puppet Produce a report in the last run interval
    lastrunfile = YAML.load_file(summary_path)
    time_lastrun = lastrunfile.dig('time', 'last_run')
    if time_lastrun.nil?
      { S0012: false }
    else
      since_lastrun = Time.now - time_lastrun
      { S0012: since_lastrun.to_i <= Puppet.settings['runinterval'] }
    end
  end

  chunk(:S0013) do
    summary_path = Puppet.settings['lastrunfile']
    next unless File.exist?(summary_path)
    # Did catalog apply successfully on last puppet run
    { S0013: File.open(summary_path).read.include?('catalog_application') }
  end

  chunk(:S0021) do
    # Is there at least 9% memory available
    { S0021: Facter.value(:memory)['system']['capacity'].to_f <= 90 }
  end

  chunk(:S0036) do
    next unless PuppetSelfService.replica? || PuppetSelfService.compiler? || PuppetSelfService.legacy_compiler? || PuppetSelfService.primary?
    str = IO.read('/etc/puppetlabs/puppetserver/conf.d/pe-puppet-server.conf')
    max_queued_requests = str.match(%r{max-queued-requests: (\d+)})
    if max_queued_requests.nil?
      { S0036: true }
    else
      { S0036: max_queued_requests[1].to_i < 150 }
    end
  end
  chunk(:S0030) do
    # check for use_cached_catalog logic flip as false is the desired state
    { S0030: !Puppet.settings['use_cached_catalog'] }
  end
  chunk(:S0033) do
    next unless PuppetSelfService.replica? || PuppetSelfService.compiler? || PuppetSelfService.legacy_compiler? || PuppetSelfService.primary?
    hiera_config_path = Puppet.settings['hiera_config']
    next unless File.exist?(hiera_config_path)
    hiera_config_file = YAML.load_file(hiera_config_path)
    # Is Hiera 5 in use?
    { S0033: hiera_config_file.dig('version') == 5 }
  end
end
