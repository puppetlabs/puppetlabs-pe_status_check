# @summary This class should be enabled if you wish Puppet to notify when pe_status_check indicators are not at optimal values
#
# When this class is enabled, when any of the indicators in the pe_status_check fact are false puppet will notify of this,
#  individual tests can be disabled by adding the ID to the indicator_exclusions parameter
#
# @example
#   include pe_status_check
# @param [[Array][String]] indicator_exclusions
#  List of disabled indicators, place any indicator ids you do not wish to report on in this list
# @param [Hash] checks
#  Hash containing a descriptiong for each key indicator
class pe_status_check (
  # Provided by module data
  Hash $checks,
  Array[String[1]] $indicator_exclusions = [],
) {
  $negatives = getvar('facts.pe_status_check', []).filter | $k, $v | { $v == false and ! ($k in $indicator_exclusions) }

  $negatives.each |$indicator, $_v| {
    $msg = $checks[$indicator]
    notify { "pe_status_check ${indicator}":
      message => "${indicator} is at fault. The indicator ${indicator} ${msg}, refer to documentation for required action",
    }
  }
}
