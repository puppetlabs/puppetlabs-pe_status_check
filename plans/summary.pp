plan pe_status_check::summary(TargetSpec $targets) {
  $results = run_task('facts', $targets, '_catch_errors' => true)

  # Filter $results to a subset where at least one of the checks has failed
  $failed_checks = $results.ok_set.filter |$result| {
    $result['pe_status_check'].any |$k, $v| { !$v }
  }

  return $failed_checks.map |$node| {
    # Create a hash where the key is the certname and the value is an array of failed checks
    {
      $node.target.name => $node['pe_status_check'].filter |$k, $v| { !$v }.keys
    }

  }
}
