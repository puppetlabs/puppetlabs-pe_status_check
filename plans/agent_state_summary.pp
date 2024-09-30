#
# @summary provides an overview of all Puppet agents and their error states
#
# @param runinterval the runinterval for the Puppet Agent in minutes. We consider latest reports that are older than runinterval as unresponsive
# @param log_healthy_nodes optionally return all healthy nodes, not only the unhealthy
# @param log_unhealthy_nodes optionally hide unhealthy nodes
#
# @author Tim Meusel <tim@bastelfreak.de>
#
plan pe_status_check::agent_state_summary (
  Integer[0] $runinterval = 30,
  Boolean $log_healthy_nodes = false,
  Boolean $log_unhealthy_nodes = true,
){
  # a list of all nodes and their latest catalog state
  $nodes = puppetdb_query('nodes[certname,latest_report_noop,latest_report_corrective_change,cached_catalog_status,latest_report_status,report_timestamp]{}')
  $fqdns = $nodes.map |$node| { $node['certname'] }

  # check if the last catalog is older than X minutes
  $current_timestamp = Integer(Timestamp().strftime('%s'))
  $runinterval_seconds = $runinterval * 60
  $unresponsive = $nodes.map |$node| {
    $old_timestamp = Integer(Timestamp($node['report_timestamp']).strftime('%s'))
    if ($current_timestamp - $old_timestamp) >= $runinterval_seconds {
      $node['certname']
    }
  }.filter |$node| { $node =~ NotUndef }

  # all nodes that delivered a report in time
  $responsive = $fqdns - $unresponsive

  # all nodes that used noop for the last catalog
  $noop = $nodes.map |$node| { if ($node['latest_report_noop'] == true){ $node['certname'] } }.filter |$node| { $node =~ NotUndef }

  # all nodes that reported corrective changes
  $corrective_changes = $nodes.map |$node| { if ($node['latest_report_corrective_change'] == true){ $node['certname'] } }.filter |$node| { $node =~ NotUndef }

  # all nodes that used a cached catalog on the last run
  # explicitly check if `cached_catalog_status` is set, will be null on nodes without a catalog
  $used_cached_catalog = $nodes.map |$node| { if ($node['cached_catalog_status'] and $node['cached_catalog_status'] != 'not_used'){ $node['certname'] } }.filter |$node| { $node =~ NotUndef }

  # all nodes with failed resources in the last report
  $failed = $nodes.map |$node| { if ($node['latest_report_status'] == 'failed'){ $node['certname'] } }.filter |$node| { $node =~ NotUndef }

  # all nodes with changes in the last report
  $changed = $nodes.map |$node| { if ($node['latest_report_status'] == 'changed'){ $node['certname'] } }.filter |$node| { $node =~ NotUndef }

  # all nodes that aren't healthy in any form
  $unhealthy = [$noop, $corrective_changes, $used_cached_catalog, $failed, $changed, $unresponsive].flatten.unique

  # all healthy nodes
  $healthy = $fqdns - $unhealthy

  $data = if $log_unhealthy_nodes {
    {
      'noop'                => $noop,
      'corrective_changes'  => $corrective_changes,
      'used_cached_catalog' => $used_cached_catalog,
      'failed'              => $failed,
      'changed'             => $changed,
      'unresponsive'        => $unresponsive,
      'responsive'          => $responsive,
      'unhealthy'           => $unhealthy,
      'unhealthy_counter'   => $unhealthy.count,
      'healthy_counter'     => $healthy.count,
      'total_counter'       => $fqdns.count,
    }
  } else {
    {
      'unhealthy_counter' => $unhealthy.count,
      'healthy_counter'   => $healthy.count,
      'total_counter'     => $fqdns.count,
    }
  }

  return if $log_healthy_nodes {
    $data + { 'healthy' => $healthy }
  } else {
    $data
  }
}
