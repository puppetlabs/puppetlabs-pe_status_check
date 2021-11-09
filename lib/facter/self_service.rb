# Self service fact aims to have all chunks reporting as true, this indicates ideal state, any individual chunk reporting false should be alerted on and checked against documentation for next steps
# TODO confine each fact to an appropriate running platform

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
    confine is_pe: true
    # check for noop logic flip as false is the desired statea
    result = Facter::Core::Execution.execute('puppet config print noop')
    if result.include?('false')
      { S0003: true }
    else
      { S0003: false }
    end
  end

  chunk(:S0004) do
    confine is_pe: true
    # Check for status that is not gree, potentially need a better way of doing this, or perhaps calling the api directly for each service
    result = Facter::Core::Execution.execute('puppet infrastructure status')
    if result.include?('Unknown') || result.include?('Unreachable')
      { S0004: false }
    else
      { S0004: true }
    end
  end

  chunk(:S0005) do
    confine do
      File.exist? '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem' or File.exist? '/etc/puppetlabs/puppetserver/ca/ca_crt.pem'
    end
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
