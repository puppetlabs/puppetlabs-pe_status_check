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

    result = if Facter.value(:os)['family'] == 'windows'
               `netstat -n | findstr /c:"8142"  | findstr /c:"TCP"  | findstr /c:"ESTABLISHED"`
             else
               `ss -tunp | grep ESTAB | grep 8142 | grep pxp-agent`
             end

    { AS002: !result.empty? }
  end
end
