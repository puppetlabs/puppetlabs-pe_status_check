require 'puppet'

# PEStatusCheck - Shared code for pe_status_check facts
module PEStatusCheck
  PUP_PATHS = { puppetlabs_bin: '/opt/puppetlabs/bin',
    puppet_bin:     '/opt/puppetlabs/puppet/bin',
    server_bin:     '/opt/puppetlabs/server/bin',
    server_data:    '/opt/puppetlabs/server/data' }.freeze
  # Gets the resource object by name
  # @param resource [String] The resource type to get
  # @param name [String] The name of the resource
  # @return [Puppet::Resource] The instance of the resource or nil
  def self.get_resource(resource, name)
    name += '.service' if (resource == 'service') && !name.include?('.')
    Puppet::Indirector::Indirection.instance(:resource).find("#{resource}/#{name}")
  end

  # Check if the service is running
  # @param name [String] The name of the service
  # @param service [Puppet::Resource] An optional service resource to use
  # @return [Boolean] True if the service is running
  def self.service_running(name, service = nil)
    service ||= get_resource('service', name)
    return false if service.nil?

    service[:ensure] == :running
  end

  # Check if the service is enabled
  # @param name [String] The name of the service
  # @param service [Puppet::Resource] An optional service resource to use
  # @return [Boolean] True if the service is enabled
  def self.service_enabled(name, service = nil)
    service ||= get_resource('service', name)
    return false if service.nil?

    service[:enable].to_s.casecmp('true').zero?
  end

  # Check if the service is running and enabled
  # @param name [String] The name of the service
  # @param service [Puppet::Resource] An optional service resource to use
  # @return [Boolean] True if the service is running and enabled
  def self.service_running_enabled(name, service = nil)
    service ||= get_resource('service', name)
    return false if service.nil?

    service_running(name, service) and service_enabled(name, service)
  end

  # Return the name of the pe-postgresql service for the current OS
  # @return [String] The name of the pe-postgresql service
  def self.pe_postgres_service_name
    if Facter.value(:os)['family'].eql?('Debian')
      "pe-postgresql#{Facter.value(:pe_postgresql_info)['installed_server_version']}"
    else
      'pe-postgresql'
    end
  end

  # Checks if passed service file exists in correct directory for the OS
  # @return [Boolean] true if file exists
  # @param configfile [String] The name of the pe service to be tested
  def self.service_file_exist?(configfile)
    configdir = if Facter.value(:os)['family'].eql?('RedHat') || Facter.value(:os)['family'].eql?('Suse')
                  '/etc/sysconfig'
                else
                  '/etc/default'
                end
    File.exist?("#{configdir}/#{configfile}")
  end

  # Queries the passed port and endpoint for the status API
  # @return [Hash] Response body of the API call
  # param port [Integer] The status API port to query
  # @param endpoint [String] The status API endpoint to query
  def self.status_check(port, endpoint)
    require 'json'

    host     = Puppet[:certname]
    client   = Puppet.runtime[:http]
    response = client.get(URI(Puppet::Util.uri_encode("https://#{host}:#{port}/status/v1/services/#{endpoint}")))
    status   = JSON.parse(response.body)
    status
  rescue Puppet::HTTP::ResponseError => e
    Facter.debug("fact 'self_service' - HTTP: #{e.response.code} #{e.response.reason}")
  rescue Puppet::HTTP::ConnectionError => e
    Facter.debug("fact 'self_service' - Connection error: #{e.message}")
  rescue Puppet::SSL::SSLError => e
    Facter.debug("fact 'self_service' - SSL error: #{e.message}")
  rescue Puppet::HTTP::HTTPError => e
    Facter.debug("fact 'self_service' - General HTTP error: #{e.message}")
  rescue JSON::ParserError => e
    Facter.debug("fact 'self_service' - Could not parse body for JSON: #{e}")
  end

  # Check if Primary node
  # @return [Boolean] true is primary node
  def self.primary?
    service_file_exist?('pe-puppetserver') &&
      service_file_exist?('pe-orchestration-services') &&
      service_file_exist?('pe-console-services') &&
      service_file_exist?('pe-puppetdb')
  end

  # Check if replica node
  # @return [Boolean]
  def self.replica?
    service_file_exist?('pe-puppetserver') &&
      !service_file_exist?('pe-orchestration-services') &&
      service_file_exist?('pe-console-services') &&
      service_file_exist?('pe-puppetdb')
  end

  # Check if Compiler node
  # @return [Boolean]
  def self.compiler?
    service_file_exist?('pe-puppetserver') &&
      !service_file_exist?('pe-orchestration-services') &&
      !service_file_exist?('pe-console-services') &&
      service_file_exist?('pe-puppetdb')
  end

  # Check if lagacy compiler node
  # @return [Boolean] true
  def self.legacy_compiler?
    service_file_exist?('pe-puppetserver') &&
      !service_file_exist?('pe-orchestration-services') &&
      !service_file_exist?('pe-console-services') &&
      !service_file_exist?('pe-puppetdb')
  end

  # Check if Pe postgres  node
  # @return [Boolean]
  def self.postgres?
    !service_file_exist?('pe-puppetserver') &&
      !service_file_exist?('pe-orchestration-services') &&
      !service_file_exist?('pe-console-services') &&
      !service_file_exist?('pe-puppetdb') &&
      service_file_exist?('pe-pgsql/pe-postgresql')
  end

  # Get the free disk percentage from a path
  # @param name [String] The path on the file system
  # @return [Integer] The percentage of free disk space on the mount
  def self.filesystem_free(path)
    require 'sys/filesystem'

    stat = Sys::Filesystem.stat(path)
    (stat.blocks_available.to_f / stat.blocks.to_f * 100).to_i
  end

  #Get the maximum and current concurrent connections to Postgres
  def self.psql_return_result(sql, psql_options = '')
    command = %(su pe-postgres --shell /bin/bash --command "cd /tmp && #{PUP_PATHS[:server_bin]}/psql #{psql_options} --command \\"#{sql}\\"")
    Facter::Core::Execution.execute(command)
  end

  def self.max_connections
    sql = %(
    SELECT current_setting('max_connections');
  )
    psql_options = '-qtAX'
    psql_return_result(sql, psql_options)
  end

  def self.cur_connections
    sql = %(
    select count(*) used from pg_stat_activity;
  )
    psql_options = '-qtAX'
    psql_return_result(sql, psql_options)
  end

  # This is a generic NET::HTTP function that can be reusable across different API requests
  def self.nethttp_puppet_api(puppetendpoint)
    uri = URI.parse(puppetendpoint.to_s)
    request = Net::HTTP::Get.new(uri)
    request.content_type = 'application/json'
    request.body = JSON.dump({
                               'level' => 'info',
      'timeout' => '2'
                             })

    req_options = {
      use_ssl: uri.scheme == 'https',
      verify_mode: OpenSSL::SSL::VERIFY_NONE,
      # waiting for a max of 2 secs to open connection
      open_timeout: 2,
      # waiting for a max of 2 secs to read response from socket
      read_timeout: 2,
    }

    begin
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      # returns the body of the response

      response.body
    rescue StandardError
      # returns a connection error

      'error'
    end
  end
end
