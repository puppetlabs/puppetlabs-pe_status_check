Facter.add(:pe_status_check_role) do
  confine { Facter.value(:pe_build) }
  setcode do
    require 'puppet'
    require_relative '../shared/pe_status_check'
    classfile = Puppet.settings[:classfile]

    # Turn the list of infra roles defined in the module constant into a regex we can use with grep()
    profile_regex = %r{^puppet_enterprise::profile::(#{PEStatusCheck.infra_profiles.join('|')})$}

    begin
      node_profiles = File.open(classfile).grep(profile_regex) { |profile|
        # Strip the leading 'puppet_enterprise::profile::' from each match
        profile.split(':')[-1].chomp
      }.uniq

      if node_profiles.include?('certificate_authority') && node_profiles.include?('database')
          then 'primary'
      elsif node_profiles.include?('certificate_authority')
          then 'legacy_primary'
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
    rescue StandardError => e
      Facter.debug("Could not resolve 'pe_status_check_role' fact: #{e.message}")
      'unknown'
    end
  end
end
