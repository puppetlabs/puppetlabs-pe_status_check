# Self service fact aims to have all chunks reporting as true, this indicates ideal state, any individual chunk reporting false should be alerted on and checked against documentation for next steps
require 'puppet'
### TODO now puppet is required, use puppet functions insead of execute shell blocks where possible

Facter.add(:self_service, type: :aggregate) do
  confine kernel: 'Linux'

  chunk(:S0001) do
    # Is the Agent Service Running
    result = Facter::Core::Execution.execute('puppet resource service puppet | grep ensure')
    if result.include?('running')
      { S0001: true }
    else
      { S0001: false }
    end
  end

  chunk(:S0002) do
    # Is the Pxp-Agent Service Running
    result = Facter::Core::Execution.execute('puppet resource service pxp-agent | grep ensure')
    if result.include?('running')
      { S0002: true }
    else
      { S0002: false }
    end
  end

  chunk(:S0003) do
    # check for noop logic flip as false is the desired state
    { S0003: !Puppet.settings['noop'] } if Facter.value(:pe_build)
  end

  chunk(:S0004) do
    if Facter.value(:pe_build) && File.exist?('/etc/puppetlabs/client-tools/services.conf') # Is PE and has client tools installed covers pe-psql only nodes
      # Check for service status that is not green, potentially need a better way of doing this, or perhaps calling the api directly for each service
      result = Facter::Core::Execution.execute('puppet infrastructure status')
      if result.include?('Unknown') || result.include?('Unreachable')
        { S0004: false }
      else
        { S0004: true }
      end
    end
  end

  chunk(:S0005) do
    # Check if the CA expires within 90 days confined to servers where the ca_cert exists
    if File.exist?('/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem') || File.exist?('/etc/puppetlabs/puppetserver/ca/ca_crt.pem') || File.exist?('/opt/puppetlabs/bin/puppet-infrastructure')
      raw_ca_cert = if File.exist? '/etc/puppetlabs/puppetserver/ca/ca_crt.pem'
                      File.read '/etc/puppetlabs/puppetserver/ca/ca_crt.pem'
                    else
                      File.read '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem'
                    end
      certificate = OpenSSL::X509::Certificate.new raw_ca_cert
      result = certificate.not_after - Time.now
      if result > 7_776_000
        { S0005: true }
      else
        { S0005: false }
      end
    end
  end
end
