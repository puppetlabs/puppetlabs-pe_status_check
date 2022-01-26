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

  # Execute a command line and return the result
  #
  # @param command_line [String] The command line to execute.
  # @param timeout [Integer] Amount of time, in sections, allowed for
  #   the command line to complete. A value of 0 will disable the timeout.
  #
  # @return [String] STDOUT from the command.
  # @return [String] An empty string, if an exception is raised while
  #   executing the command.
  def self.exec_return_result(command_line, timeout = 300)
    options = { timeout: timeout }
    result = Exec.exec_cmd(command_line, **options)

    if result.error.nil?
      result.stdout
    else
      result.error
    end
  end

  # Execute psql queries.
  #
  # @param sql [String] SQL to execute via a psql command.
  # @param psql_options [String] list of options to pass to the psql command.
  #
  # @return (see #exec_return_result)

  def self.psql_return_result(sql, psql_options = '')
    command = %(su pe-postgres --shell /bin/bash --command "cd /tmp && #{PUP_PATHS[:server_bin]}/psql #{psql_options} --command \\"#{sql}\\"")
    exec_return_result(command)
  end

  # Below method to execute the PSQL statement to identify thundering herd
  def self.psql_thundering_herd
    sql = %(
      SELECT date_part('month', start_time) AS month,
      date_part('day', start_time) AS day,
      date_part('hour', start_time) AS hour,
      date_part('minute', start_time) as minute, count(*)
      FROM reports
      WHERE start_time BETWEEN now() - interval '7 days' AND now()
      GROUP BY date_part('month', start_time), date_part('day', start_time), date_part('hour', start_time), date_part('minute', start_time)
      ORDER BY date_part('month', start_time) DESC, date_part('day', start_time) DESC, date_part( 'hour', start_time ) DESC, date_part('minute', start_time) DESC;
    )
    psql_options = '--dbname pe-puppetdb'
    psql_return_result(sql, psql_options)
  end
end

# Execute external commands
module Exec
  # Command Result
  #
  # @param stdout [String] A string containing the standard output
  #   written by the command.
  # @param stderr [String] A string containing the standard error
  #   written by the command.
  # @param status [Integer] An integer representing the exit code of the
  #   command.
  # @param error [String, nil] A string holding an error message if
  #   command execution was not successful.
  Result = Struct.new(:stdout, :stderr, :status, :error)

  # Exception class for failed commands
  class ExecError < StandardError; end

  # Execute a command and return a Result
  #
  # This is basically `Open3.popen3`, but with added logic to time the
  # executed command out if it runs for too long.
  #
  # @param cmd [Array<String>] Command and arguments to execute. Commands
  #  consisting of a single String will cause `Process.spawn` to wrap the
  #  execution in a system shell such as `/bin/sh -c`.
  # @param env [Hash] A hash of environment variables to set
  #   when the command is executed.
  # @param stdin_data [String] A string of standard input to pass
  #   to the executed command. Sould be smaller than 4096 characters.
  # @param timeout [Integer] Number of seconds to allow for command
  #   execution to complete. A value of 0 will disable the timeout.
  #
  # @return [Result] A `Result` object containing the output and status
  #   of the command.
  def self.exec_cmd(*cmd, env: {}, stdin_data: nil, timeout: 300)
    out_r, out_w = IO.pipe
    err_r, err_w = IO.pipe
    env_s = { 'LC_ALL' => 'C', 'LANG' => 'C' }.merge(env)

    input = if stdin_data.nil?
              :close
            else
              # NOTE: Pipe capacity is limited. Probably at least 4096 bytes.
              #       65536 bytes at most.
              in_r, in_w = IO.pipe
              in_w.binmode
              in_w.sync = true

              in_w.write(stdin_data)
              in_w.close

              in_r
            end

    opts = { in: input,
            out: out_w,
            err: err_w }

    pid = Process.spawn(env_s, *cmd, opts)

    [out_w, err_w].each(&:close)
    stdout_reader = Thread.new do
      stdout = out_r.read
      out_r.close
      stdout
    end
    stderr_reader = Thread.new do
      stderr = err_r.read
      err_r.close
      stderr
    end

    deadline = (Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_second) + timeout)
    status = nil

    loop do
      _, status = Process.waitpid2(pid, Process::WNOHANG)
      break if status
      unless timeout.zero?
        raise Timeout::Error if deadline < Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_second)
      end
      # Sleep for a bit so that we don't spin in a tight loop burning
      # CPU on waitpid() syscalls.
      sleep(0.01)
    end

    Result.new(stdout_reader.value, stderr_reader.value, status.to_i, nil)
  rescue Timeout::Error
    Process.kill(:TERM, pid)
    Process.detach(pid)

    Result.new('', '', -1, 'command failed to complete after %{timeout} seconds' %
                { timeout: timeout })
  rescue StandardError => e
    # File not found. Permission denied. Etc.
    Result.new('', '', -1, '%{class}: %{message}' %
                { class: e.class,
                message: e.message })
  end
end
