require 'puppet'

# PuppetSelfService - Shared code for Puppet Self Service facts
module PuppetSelfService
  # Gets the resource object by name
  # @param resource [String] The resource type to get
  # @param name [String] The name of the resource
  # @return [Puppet::Type] The instance of the resource or nil
  def self.get_resource(resource, name)
    if resource == 'service'
      Puppet::Type.type(resource.to_sym).instances.find { |s| s.name.split('.').first == name }
    else
      Puppet::Type.type(resource.to_sym).instances.find { |s| s.name == name }
    end
  end

  # Check if the service is running
  # @param name [String] The name of the service
  # @param service [Puppet::Type::Service] An optional service resource to use
  # @return [Boolean] True if the service is running
  def self.service_running(name, service = nil)
    service ||= get_resource('service', name)
    return false if service.nil?

    service.to_resource[:ensure] == :running
  end

  # Check if the service is enabled
  # @param name [String] The name of the service
  # @param service [Puppet::Type::Service] An optional service resource to use
  # @return [Boolean] True if the service is enabled
  def self.service_enabled(name, service = nil)
    service ||= get_resource('service', name)
    return false if service.nil?

    service.to_resource[:enable].to_s.casecmp('true').zero?
  end

  # Check if the service is running and enabled
  # @param name [String] The name of the service
  # @param service [Puppet::Type::Service] An optional service resource to use
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

  def self.curlpuppetAPI(curl_host,curl_port,curl_API,curl_DB,curl_header,curl_query)

    
    curl_command = '/opt/puppetlabs/puppet/bin/curl -sk https://' + curl_host + ':' + curl_port + curl_API +  curl_DB + '   \
    -X POST   -H ' + curl_header + '  \
    --cert   $(puppet config print hostcert)   \
    --key    $(puppet config print hostprivkey)   \
    --cacert $(puppet config print localcacert) \
    ' + curl_query + ''

    # Using '' to ensure that the output is contained within the function and it is not pass to the console
    
    exec_curl_command = `#{curl_command}`
    
  end

  # This is used to illustrate a connection to the puppetdb API to obtain active nodes.
  # This is for demo purposes at the moment and orchestration API authentication is
  # RBAC only. This self-service test has turned out to be impossible due to the limitation
  # that this module has to operate without RBAC tokens.

  # This function uses a generic https API call to PE with certificate based authentication
  # The variables below can be updated at will to connect to any PE endpoint by blanking any
  # unnecessary variable/s


  def self.activenodes_vs_orchnodes?

    # Variable names self explanatory use empty spaces if not used

    curl_host = "localhost"
    curl_port = "8081"
    curl_API = "/pdb/query/v4"
    curl_DB = "/nodes"

    # "curl_header" variable contains a trailing space

    curl_header = '"Content-Type:application/json" '

    # "curl_query" shows an example to parse the output of the puppetdb query

    curl_query = '-d \'{"query":["extract", [["function","count"],"deactivated"],["null?", "deactivated", true],["group_by", "deactivated"]]}\' | tr { "\n" | tr , "\n" | tr } "\n" | grep "count" | awk  -F":" \'{print $2}\''

    active_nodes = PuppetSelfService.curlpuppetAPI(curl_host,curl_port,curl_API,curl_DB,curl_header,curl_query) 

    # Using XXXX for active_nodes.to_i == XXXX as a proof of concept for this module
    
    return active_nodes.to_i == XXXX

  end

end
