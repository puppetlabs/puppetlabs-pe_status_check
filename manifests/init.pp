# @summary This class should be enabled if you wish Puppet to notify when self_service indicators are not at optimal values
#
# When this class is enabled, when any of the indicators in the self_service fact are false puppet will notify of this,
#  individual tests can be disabled by adding the ID to the indicator_exclusions parameter
#
# @example
#   include self_service
# @param [Array[String]] indicator_exclusions
#  List of disabled indicators, place any indicator ids you do not wish to report on in this list
class self_service (
  Array[String[1]] $indicator_exclusions = [],
) {
  $negatives = $facts['self_service'].filter | $k, $v | { $v == false and ! ($k in $indicator_exclusions) }

  $negatives.each |$indicator, $_v| {
    notify { "Self Service ${indicator}":
      message => "${indicator} is at fault, please refer to documentation for required action",
    }
  }
}
