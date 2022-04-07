# Agent Status Check fact aims to have all chunks reporting as true, indicating ideal state, any individual chunk reporting false should be alerted on and checked against documentation for next steps
# Use shared logic from PEStatusCheck

Facter.add(:agent_status_check, type: :aggregate) do
  confine { !Facter.value(:pe_build) }
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
    next unless Facter.value(:os)['family'] == 'windows' || Facter.value(:os)['family'] == 'Debian' || Facter.value(:os)['family'] == 'RedHat'
    result = if Facter.value(:os)['family'] == 'windows'
               Facter::Core::Execution.execute('netstat -n | findstr /c:"8142"  | findstr /c:"TCP"  | findstr /c:"ESTABLISHED"')
             else
               Facter::Core::Execution.execute('ss -tunp | grep ESTAB | grep 8142 | grep pxp-agent')
             end
    { AS002: !result.empty? }
  rescue Facter::Core::Execution::ExecutionFailure => e
    Facter.warn('agent_status_check.A0002 failed to get socket status')
    Facter.debug(e)
    { AS002: false }
  end
end
