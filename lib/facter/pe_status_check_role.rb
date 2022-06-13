Facter.add(:pe_status_check_role) do
  confine { Facter.value(:pe_build) }
  require 'puppet'
  require_relative '../shared/pe_status_check'
  setcode do
    classfile = Puppet.settings[:classfile]
    return nil unless File.file?(classfile)

    node_profiles = []
    # Turn the list of infra roles defined in the module constant into a regex we can use with grep()
    profile_regex = %r{^puppet_enterprise::profile::(#{PEStatusCheck.infra_profiles.join('|')})$}

    File.open(classfile).grep(profile_regex) do |profile|
      # Strip the leading 'puppet_enterprise::profile::' from each match
      short_profile = profile.split(':')[-1].chomp
      # Add unique entries to the node_profiles array by doing a bitwise or between it and the current match
      # e.g. `['foo', 'bar'] | ['bar', 'baz']` produces `['foo', 'bar', 'baz']`
      node_profiles |= [short_profile]
    end

    if node_profiles.include?('certificate_authority')
        then 'primary'
    elsif node_profiles.include?('primary_master_replica')
        then 'replica'
      # Use array subtraction to determine if more than one role is present
    elsif (['master', 'puppetdb'] - node_profiles).empty?
        then 'pe_compiler'
    elsif node_profiles.include?('master')
        then 'legacy_compiler'
    elsif node_profiles.include?('database')
        then 'postgres'
    else
      'unknown'
    end
  end
end
