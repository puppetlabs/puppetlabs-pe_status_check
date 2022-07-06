# Agent Status Check fact aims to have all chunks reporting as true, indicating ideal state, any individual chunk reporting false should be alerted on and checked against documentation for next steps
# Use shared logic from PEStatusCheck
# Disabled by default requires bundled class too create /opt/puppetlabs/puppet/cache/status_check_enable

Facter.add(:agent_status_check, type: :aggregate) do
  confine { !Facter.value(:pe_build) }
  next unless File.exist?('/opt/puppetlabs/puppet/cache/state/status_check_enable')
  require 'puppet'

  chunk(:AS001) do
    # Is the hostcert expiring within 90 days
    #
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
    result = if Facter.value(:os)['family'] == 'windows'
               Facter::Core::Execution.execute('netstat -n | findstr /c:"8142"  | findstr /c:"TCP"  | findstr /c:"ESTABLISHED"',
                                               { timeout: PEStatusCheck.facter_timeout })
             else
               Facter::Core::Execution.execute('ss -tunp | grep ESTAB | grep 8142 | grep pxp-agent',
                                               { timeout: PEStatusCheck.facter_timeout })
             end
    { AS002: !result.empty? }
  rescue Facter::Core::Execution::ExecutionFailure => e
    Facter.warn("agent_status_check.AS002 failed to get socket status: #{e.message}")
    Facter.debug(e.backtrace)
    { AS002: false }
  end
end
