require 'puppet'
require 'json'
require 'net/http'
require 'openssl'

# PEStatusCheck - Shared code for pe_status_check facts
module PEStatusCheck
  module_function

  # Gets the resource object by name
  # @param resource [String] The resource type to get
  # @param name [String] The name of the resource
  # @return [Puppet::Resource] The instance of the resource or nil
  def get_resource(resource, name)
    name += '.service' if (resource == 'service') && !name.include?('.')
    Puppet::Indirector::Indirection.instance(:resource).find("#{resource}/#{name}")
  end

  # checks puppetlabs.services.ca.certificate-authority-service/certificate-authority-service  exists in puppetserver bootstrap
  def ca_bootstrap?
    return true if File.exist?('/etc/puppetlabs/puppetserver/bootstrap.cfg') && File.foreach('/etc/puppetlabs/puppetserver/bootstrap.cfg').grep(%r{certificate-authority-service}).any?
  end

  # Check if the service is running
  # @param name [String] The name of the service
  # @param service [Puppet::Resource] An optional service resource to use
  # @return [Boolean] True if the service is running
  def service_running(name, service = nil)
    service ||= get_resource('service', name)
    return false if service.nil?

    service[:ensure] == :running
  end

  # Check if the service is enabled
  # @param name [String] The name of the service
  # @param service [Puppet::Resource] An optional service resource to use
  # @return [Boolean] True if the service is enabled
  def service_enabled(name, service = nil)
    service ||= get_resource('service', name)
    return false if service.nil?

    service[:enable].to_s.casecmp('true').zero?
  end

  # Check if the service is running and enabled
  # @param name [String] The name of the service
  # @param service [Puppet::Resource] An optional service resource to use
  # @return [Boolean] True if the service is running and enabled
  def service_running_enabled(name, service = nil)
    service ||= get_resource('service', name)
    return false if service.nil?

    service_running(name, service) and service_enabled(name, service)
  end

  # Return the name of the pe-postgresql service for the current OS
  # @return [String] The name of the pe-postgresql service
  def pe_postgres_service_name
    if Facter.value(:os)['family'].eql?('Debian')
      "pe-postgresql#{Facter.value(:pe_postgresql_info)['installed_server_version']}"
    else
      'pe-postgresql'
    end
  end

  # Checks if passed service file exists in correct directory for the OS
  # @return [Boolean] true if file exists
  # @param configfile [String] The name of the pe service to be tested
  def service_file_exist?(configfile)
    configdir = if Facter.value(:os)['family'].eql?('RedHat') || Facter.value(:os)['family'].eql?('Suse')
                  '/etc/sysconfig'
                else
                  '/etc/default'
                end
    File.exist?("#{configdir}/#{configfile}")
  end

  # Module method to make a GET request to an api specified by path and port params
  # @return [Hash] Response body of the API call
  # @param path [String] The API path to query.  Should include a '/' prefix and query parameters
  # @param port [Integer] The port to use
  # @param host [String] The FQDN to use in making the connection.  Defaults to the Puppet certname
  def http_get(path, port, host = Puppet[:certname])
    # Use an instance variable to only create an SSLContext once
    @ssl_context ||= Puppet::SSL::SSLContext.new(
      cacerts: Puppet[:localcacert],
      private_key: OpenSSL::PKey::RSA.new(File.read(Puppet[:hostprivkey])),
      client_cert: OpenSSL::X509::Certificate.new(File.open(Puppet[:hostcert])),
    )

    client = Net::HTTP.new(host, port)
    # The main reason to use this approach is to set open and read timeouts to a small value
    # Puppet's HTTP client does not allow access to these
    client.open_timeout = 2
    client.read_timeout = 2
    client.use_ssl = true
    client.verify_mode = OpenSSL::SSL::VERIFY_PEER
    client.cert = @ssl_context.client_cert
    client.key = @ssl_context.private_key
    client.ca_file = @ssl_context.cacerts

    response = client.request_get(Puppet::Util.uri_encode(path))
    if response.is_a? Net::HTTPSuccess
      JSON.parse(response.body)
    else
      false
    end
  rescue StandardError => e
    Facter.warn("Error in fact 'pe_status_check' when querying #{path}: #{e.message}")
    Facter.debug(e.backtrace)
    false
  end

  # Check if Primary node
  # @return [Boolean] true is primary node
  def primary?
    service_file_exist?('pe-puppetserver') &&
      service_file_exist?('pe-orchestration-services') &&
      service_file_exist?('pe-console-services') &&
      service_file_exist?('pe-puppetdb') &&
      ca_bootstrap?
  end

  # Check if replica node
  # @return [Boolean]
  def replica?
    service_file_exist?('pe-puppetserver') &&
      service_file_exist?('pe-console-services') &&
      service_file_exist?('pe-puppetdb') &&
      !ca_bootstrap?
  end

  # Check if Compiler node
  # @return [Boolean]
  def compiler?
    service_file_exist?('pe-puppetserver') &&
      !service_file_exist?('pe-orchestration-services') &&
      !service_file_exist?('pe-console-services') &&
      service_file_exist?('pe-puppetdb')
  end

  # Check if lagacy compiler node
  # @return [Boolean] true
  def legacy_compiler?
    service_file_exist?('pe-puppetserver') &&
      !service_file_exist?('pe-orchestration-services') &&
      !service_file_exist?('pe-console-services') &&
      !service_file_exist?('pe-puppetdb')
  end

  # Check if Pe postgres  node
  # @return [Boolean]
  def postgres?
    !service_file_exist?('pe-puppetserver') &&
      !service_file_exist?('pe-orchestration-services') &&
      !service_file_exist?('pe-console-services') &&
      !service_file_exist?('pe-puppetdb') &&
      service_file_exist?('pe-pgsql/pe-postgresql')
  end

  # Get the free disk percentage from a path
  # @param name [String] The path on the file system
  # @return [Integer] The percentage of free disk space on the mount
  def filesystem_free(path)
    require 'sys/filesystem'

    stat = Sys::Filesystem.stat(path)
    (stat.blocks_available.to_f / stat.blocks.to_f * 100).to_i
  end
end
