# pe_status_check fact aims to have all chunks reporting as true, this indicates ideal state, any individual chunk reporting false should be alerted on and checked against documentation for next steps
# Use shared logic from PEStatusCheck

Facter.add(:pe_status_check, type: :aggregate) do
  confine kernel: 'Linux'
  confine { Facter.value(:pe_build) }
  require 'puppet'
  require 'yaml'
  require_relative '../shared/pe_status_check'

  chunk(:S0001) do
    # Is the Agent Service Running and Enabled
    { S0001: PEStatusCheck.service_running_enabled('puppet') }
  end

  chunk(:S0002) do
    # Is the Pxp-Agent Service Running and Enabled
    { S0002: PEStatusCheck.service_running_enabled('pxp-agent') }
  end

  chunk(:S0003) do
    # check for noop logic flip as false is the desired state
    { S0003: !Puppet.settings['noop'] }
  end

  chunk(:S0004) do
    # Is PE and has clienttools covers pe-psql and compilers
    # Check for service status that is not green, potentially need a better way of doing this, or perhaps calling the api directly for each service

    next unless PEStatusCheck.primary? || PEStatusCheck.replica? || PEStatusCheck.compiler? || PEStatusCheck.legacy_compiler?

    response = PEStatusCheck.http_get('/status/v1/services', 8140)
    if response
      # In the reponse, keys are the names of the services and values are a hash of its properties
      # We can check that all are in 'running' state to see if all are ok
      all_running = response.values.all? do |service|
        service['state'] == 'running'
      end
      { S0004: all_running }
    else
      { S0004: false }
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

  chunk(:S0006) do
    next unless PEStatusCheck.primary?
    # Is puppet_metrics_collector running
    { S0006: PEStatusCheck.service_running_enabled('puppet_puppetserver-metrics.timer') }
  end

  chunk(:S0007) do
    next unless PEStatusCheck.primary? || PEStatusCheck.replica? || PEStatusCheck.postgres?
    # check postgres data mount has at least 20% free
    pg_version = Facter.value(:pe_postgresql_info)['installed_server_version']
    data_dir = Facter.value(:pe_postgresql_info)['versions'][pg_version].fetch('data_dir', '/opt/puppetlabs/server/data/postgresql')

    { S0007: PEStatusCheck.filesystem_free(data_dir) >= 20 }
  end

  chunk(:S0008) do
    next unless PEStatusCheck.primary? || PEStatusCheck.replica? || PEStatusCheck.compiler? || PEStatusCheck.legacy_compiler?
    # check codedir data mount has at least 20% free
    { S0008: PEStatusCheck.filesystem_free(Puppet.settings['codedir']) >= 20 }
  end

  chunk(:S0009) do
    next unless PEStatusCheck.replica? || PEStatusCheck.compiler? || PEStatusCheck.legacy_compiler? || PEStatusCheck.primary?
    # Is the Pe-puppetsever Service Running and Enabled
    { S0009: PEStatusCheck.service_running_enabled('pe-puppetserver') }
  end

  chunk(:S0010) do
    next unless PEStatusCheck.replica? || PEStatusCheck.compiler? || PEStatusCheck.primary?
    # Is the pe-puppetdb Service Running and Enabled
    { S0010: PEStatusCheck.service_running_enabled('pe-puppetdb') }
  end

  chunk(:S0011) do
    next unless PEStatusCheck.replica? || PEStatusCheck.postgres? || PEStatusCheck.primary?
    # Is the pe-postgres Service Running and Enabled
    postgresversion = PEStatusCheck.pe_postgres_service_name
    { S0011: PEStatusCheck.service_running_enabled(postgresversion.to_s) }
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

  chunk(:S0014) do
    time_now = Time.now - Puppet.settings['runinterval']
    res = Dir.glob('/opt/puppetlabs/server/data/puppetdb/stockpile/cmd/q/*').find { |f| time_now.to_i > File.mtime(f).to_i }
    { S0014: res.nil? }
  end

  chunk(:S0016) do
    # Puppetserver
    next unless PEStatusCheck.primary? || PEStatusCheck.compiler? || PEStatusCheck.legacy_compiler? || PEStatusCheck.replica?
    time_now = Time.now - Puppet.settings['runinterval']
    log_path = File.dirname(Puppet.settings['logdir'].to_s) + '/puppetserver/'
    error_pid_log = Dir.glob(log_path + '*_err_pid*.log').find { |f| time_now.to_i < File.mtime(f).to_i }
    if error_pid_log.nil?
      log_file = log_path + 'puppetserver.log'
      search_for_error = `tail -n 250 #{log_file} | grep 'java.lang.OutOfMemoryError'`
      { S0016: search_for_error.empty? }
    else
      { S0016: false }
    end
  end

  chunk(:S0017) do
    # PuppetDB
    next unless PEStatusCheck.primary? || PEStatusCheck.compiler?
    time_now = Time.now - Puppet.settings['runinterval']
    log_path = File.dirname(Puppet.settings['logdir'].to_s) + '/puppetdb/'
    error_pid_log = Dir.glob(log_path + '*_err_pid*.log').find { |f| time_now.to_i < File.mtime(f).to_i }
    if error_pid_log.nil?
      log_file = log_path + 'puppetdb.log'
      search_for_error = `tail -n 250 #{log_file} | grep 'java.lang.OutOfMemoryError'`
      { S0017: search_for_error.empty? }
    else
      { S0017: false }
    end
  end

  chunk(:S0018) do
    # Orchestrator
    next unless PEStatusCheck.primary?
    time_now = Time.now - Puppet.settings['runinterval']
    log_path = File.dirname(Puppet.settings['logdir'].to_s) + '/orchestration-services/'
    error_pid_log = Dir.glob(log_path + '*_err_pid*.log').find { |f| time_now.to_i < File.mtime(f).to_i }
    if error_pid_log.nil?
      log_file = log_path + 'orchestration-services.log'
      search_for_error = `tail -n 250 #{log_file} | grep 'java.lang.OutOfMemoryError'`
      { S0018: search_for_error.empty? }
    else
      { S0018: false }
    end
  end

  chunk(:S0019) do
    next unless PEStatusCheck.primary? || PEStatusCheck.replica? || PEStatusCheck.compiler? || PEStatusCheck.legacy_compiler?
    response = PEStatusCheck.http_get('/status/v1/services/pe-jruby-metrics?level=debug', 8140)
    if response
      free_jrubies = response.dig('status', 'experimental', 'metrics', 'average-free-jrubies')
      { S0019: free_jrubies >= 0.9 }
    else
      { S0019: false }
    end
  end

  chunk(:S0021) do
    # Is there at least 9% memory available
    { S0021: Facter.value(:memory)['system']['capacity'].to_f <= 90 }
  end

  chunk(:S0022) do
    # Is there a valid license present, which does not expire in 90 days
    # Also takes into account if the license is perpetual
    next unless PEStatusCheck.primary?
    validity = true # true by default
    if File.file?('/etc/puppetlabs/license.key')
      license_type = File.readlines('/etc/puppetlabs/license.key').grep(%r{license_type:}).to_s
      unless license_type.include? 'Perpetual'
        require 'date'
        start_date = Date.parse(File.readlines('/etc/puppetlabs/license.key').grep(%r{start:}).to_s)
        end_date = Date.parse(File.readlines('/etc/puppetlabs/license.key').grep(%r{end:}).to_s)
        today_date = Date.today
        daysexp = (end_date - today_date).to_i
        validity = (today_date >= start_date) && (today_date <= end_date) && (daysexp >= 90) ? true : false
      end
    else
      validity = false
    end
    { S0022: validity }
  end

  chunk(:S0024) do
    next unless PEStatusCheck.primary? || PEStatusCheck.replica? || PEStatusCheck.compiler?

    # Check discard directory. Newest file should not be less than a run interval old. Recent files indicate an issue that causes PuppetDB to reject incoming data.
    newestfile = Dir.glob('/opt/puppetlabs/server/data/puppetdb/stockpile/discard/*.*').max_by { |f| File.mtime(f) }
    # get the timestamp for the most recent file
    if newestfile
      newestfile_time = File.mtime(newestfile)
      #  Newest file should be older than 2 run intervals
      { S0024: newestfile_time <= (Time.now - (Puppet.settings['runinterval'] * 2)).utc }
    #  Should return true if the file is older than two runintervals, or folder is empty, and false if sooner than two run intervals
    else
      { S0024: true }
    end
  end

  chunk(:S0030) do
    # check for use_cached_catalog logic flip as false is the desired state
    { S0030: !Puppet.settings['use_cached_catalog'] }
  end

  chunk(:S0031) do
    # check for Old pe_repo versions have been cleaned up
    next unless PEStatusCheck.primary?
    pe_version = Facter.value(:pe_server_version)
    packages_dir = '/opt/puppetlabs/server/data/packages/public'
    no_old_packages = true
    # Guard against current version. On database node the 'current' symlink doesn't exist
    if Dir.exist?(packages_dir)
      current_ver = if File.exist?("#{packages_dir}/current") && File.symlink?("#{packages_dir}/current")
                      File.basename(File.readlink("#{packages_dir}/current"))
                    else
                      pe_version
                    end
      version = Gem::Version.new(pe_version)
      Dir.chdir(packages_dir) do
        Dir.glob('*').select { |f| f.match(%r{\A\d+\.\d+\.\d+}) }.each do |dir|
          if File.directory?(dir) && dir != current_ver && (Gem::Version.new(dir) < version)
            no_old_packages = false
          end
        end
      end
    end
    { S0031: no_old_packages }
  end

  chunk(:S0033) do
    next unless PEStatusCheck.replica? || PEStatusCheck.compiler? || PEStatusCheck.legacy_compiler? || PEStatusCheck.primary?
    hiera_config_path = Puppet.settings['hiera_config']
    next unless File.exist?(hiera_config_path)
    hiera_config_file = YAML.load_file(hiera_config_path)
    # Is Hiera 5 in use?
    { S0033: hiera_config_file.dig('version') == 5 }
  end

  chunk(:S0036) do
    next unless PEStatusCheck.replica? || PEStatusCheck.compiler? || PEStatusCheck.legacy_compiler? || PEStatusCheck.primary?
    str = IO.read('/etc/puppetlabs/puppetserver/conf.d/pe-puppet-server.conf')
    max_queued_requests = str.match(%r{max-queued-requests: (\d+)})
    if max_queued_requests.nil?
      { S0036: true }
    else
      { S0036: max_queued_requests[1].to_i < 150 }
    end
  end

  chunk(:S0040) do
    # Is puppet_metrics_collector::system configured
    { S0040: PEStatusCheck.service_running_enabled('puppet_system_processes-metrics.timer') }
  end

  chunk(:S0034) do
    next unless PEStatusCheck.primary?
    # PE has not been upgraded / updated in 1 year
    # It was decided not to include infra components as this was deemed unecessary as they should align with the primary.

    # gets the file for the most recent upgrade output
    last_upgrade_file = '/opt/puppetlabs/server/pe_build'
    next unless File.exist?(last_upgrade_file)
    # get the timestamp for the most recent upgrade
    last_upgrade_time = File.mtime(last_upgrade_file)

    # last upgrade was sooner than 1 year ago
    { S0034: last_upgrade_time >= (Time.now - 31_536_000).utc }
  end
  chunk(:S0039) do
    # PuppetServer
    next unless PEStatusCheck.primary? || PEStatusCheck.replica? || PEStatusCheck.compiler? || PEStatusCheck.legacy_compiler?
    logfile = File.dirname(Puppet.settings['logdir'].to_s) + '/puppetserver/puppetserver-access.log'
    apache_regex = %r{^(\S+) \S+ (\S+) (?<time>\[([^\]]+)\]) "([A-Z]+) ([^ "]+)? HTTP/[0-9.]+" (?<status>[0-9]{3})}

    has_503 = File.foreach(logfile).any? do |line|
      match = line.match(apache_regex)
      next unless match && match[:time] && match[:status]

      time = Time.strptime(match[:time], '[%d/%b/%Y:%H:%M:%S %Z]')
      since_lastrun = Time.now - time
      current = since_lastrun.to_i <= Puppet.settings['runinterval']

      match[:status] == '503' and current
    end

    { S0039: !has_503 }
  end
end
