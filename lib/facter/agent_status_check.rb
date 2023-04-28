# Agent Status Check fact aims to have all chunks reporting as true, indicating ideal state, any individual chunk reporting false should be alerted on and checked against documentation for next steps
# Use shared logic from PEStatusCheck
# Disabled by default requires bundled class too create /opt/puppetlabs/puppet/cache/status_check_enable

Facter.add(:agent_status_check, type: :aggregate) do
  confine { !Facter.value(:pe_build) }
  confine { PEStatusCheck.enabled? }
  require 'puppet'

  chunk(:AS001) do
    # Is the hostcert expiring within 90 days
    #
    next unless File.exist?(Puppet.settings['hostcert'])
    raw_hostcert = File.read(Puppet.settings['hostcert'])
    certificate = OpenSSL::X509::Certificate.new raw_hostcert
    result = certificate.not_after - Time.now

    { AS001: result > 7_776_000 }
  end
  chunk(:AS002) do
    # Has the PXP agent establish a connection with a remote Broker
    #
    valid_families = ['windows', 'Debian', 'RedHat', 'Suse']
    next unless valid_families.include?(Facter.value(:os)['family'])
    if Facter.value(:os)['family'] == 'windows'
      result = Facter::Core::Execution.execute('netstat -np tcp', { timeout: PEStatusCheck.facter_timeout })
      { AS002: result.match?(%r{8142\s*ESTABLISHED}) }
    else
      # Obtain all inodes associated with any sockets established outbound to TCP/8142:
      socket_state = Facter::Core::Execution.execute("ss -tone state established '( dport = :8142 )' ", { timeout: PEStatusCheck.facter_timeout })
      socket_matches = Set.new(socket_state.scan(%r{ino:(\d+)}).flatten)

      # Look for the pxp-agent process in the process table:
      cmdline_path = Dir.glob('/proc/[0-9]*/cmdline').find { |path| File.read(path).split("\0").first == '/opt/puppetlabs/puppet/bin/pxp-agent' }

      # If no match was found, then the connection to 8142 is not the pxp-agent process because it is not in the process table:
      if cmdline_path.nil?
        { AS002: false }
      else
        # Find all of the file descriptors associated with pxp-agent which are sockets, and extract just the associated inode number:
        fd_path = File.join(File.dirname(cmdline_path), 'fd', '*')
        pxp_socket_inodes = Set.new(Dir.glob(fd_path).map { |path| File.readlink(path) }.select { |t| t.start_with?('socket:') }.map { |str| str.tr('^0-9', '') })

        { AS002: socket_matches.intersect?(pxp_socket_inodes) }
      end
    end
  rescue Facter::Core::Execution::ExecutionFailure => e
    Facter.warn("agent_status_check.AS002 failed to get socket status: #{e.message}")
    Facter.debug(e.backtrace)
    { AS002: false }
  end
  chunk(:AS003) do
    # certname is configured in section other than [main]
    #
    { AS003: !Puppet.settings.set_in_section?(:certname, :agent) && !Puppet.settings.set_in_section?(:certname, :server) && !Puppet.settings.set_in_section?(:certname, :user) }
  end
  chunk(:AS004) do
    # Is the host copy of the crl expiring in the next 90 days
    hostcrl = Puppet.settings[:hostcrl]
    next unless File.exist?(hostcrl)

    x509_cert = OpenSSL::X509::CRL.new(File.read(hostcrl))
    { AS004: (x509_cert.next_update - Time.now) > 7_776_000 }
  end
  chunk(:AS005) do
    # Did the last Puppet run have any errors or warnings?
    last_run_report = Puppet.settings[:lastrunreport]
    next unless File.exist?(last_run_report)
    begin
      last_run_report_file = YAML.load_file(last_run_report)
      { AS005: last_run_report_file.logs.none? { |l| [:warning, :err].include?(l.level) } }
    rescue Facter::Core::Execution::ExecutionFailure => e
      Facter.warn("agent_status_check.AS005 failed to get last run report: #{e.message}")
      Facter.debug(e.backtrace)
      { AS005: false }
    end
  end
end
