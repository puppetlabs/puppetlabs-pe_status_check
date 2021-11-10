# @summary This class should be enabled if you wish Puppet to notify when self_service indicators are not at optimal values
#
# When this class is enabled, when any of the indicators in the self_service fact are false puppet will notify of this, individual tests can be disabled by removing them from the self_service_indicators parameter
#
# @example
#   include self_service
# @param [Array[String]] self_service_indicators
#  List of enabled self service indicators, remove any unwanted indicators from this array
class self_service(

  Array[String] $exclude_self_service_indicators = ['S0001'],
)
  {

$negatives = $facts['self_service'].filter | $k, $v | { $v == false and ! ($k in $exclude_self_service_indicators) }

$negatives.each |$indicator, $_v| {
notify {"${indicator} is at fault, please refer to documentation for required action":}
}
}
