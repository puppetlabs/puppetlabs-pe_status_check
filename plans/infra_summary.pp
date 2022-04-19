# @summary Summary report if the state of pe_status check on each node 
#   Uses the facts task to get the current status from each node
#   and produces a summary report in JSON
# @param targets
#   A comma seprated list of FQDN's of Puppet infrastructure agent nodes
# 

plan pe_status_check::infra_summary(TargetSpec $targets) {
  $results = run_task('facts', $targets, '_catch_errors' => true)

  # Filter $results to a subset where at least one of the checks has passed
  $failed_checks = $results.ok_set.filter |$result| {
    $result['pe_status_check'].any |$k, $v| { $v }
  }

  return $failed_checks.map |$node| {
    # Create a hash where the key is the certname and an array of hashes gives counts for passes and fails and the IDS for failed tests
    {
      $node.target.name => { 'Passing Tests Count' => count($node['pe_status_check'].filter |$k, $v| { $v }.keys), 'Failed Test Count' => count ($node['pe_status_check'].filter |$k, $v| { !$v }.keys) ,'Failed Test Details'  => $node['pe_status_check'].filter |$k, $v| { !$v }.keys.map |$items| { lookup("pe_status_check::${items}", String,'hash') } }
    }
  }
}
