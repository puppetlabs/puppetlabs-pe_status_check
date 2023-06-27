# @summary Summary report if the state of agent_status_check on each node
#   Uses the facts task to get the current status from each node
#   and produces a summary report in JSON
# @param targets
#   A comma seprated list of FQDN's of Puppet agent nodes
#   Defaults to using a PuppetDB query to identify nodes
# @param indicator_exclusions
#   List of disabled indicators, place any indicator ids you do not wish to report on in this list
plan pe_status_check::agent_summary(
  Array[String[1]] $indicator_exclusions = [],
  Optional[TargetSpec] $targets          = undef,
) {
  # Query PuppetDB if $targets is not unspecified
  $_targets = if $targets =~ Undef {
    $certnames_or_error = catch_errors() || {
      # NOTE: We use `pe_build` to identify all non-infrastructure nodes that could have `agent_status_check`
      #       This could be changed to `facts.agent_status_check` instead, but could miss some potential failure states
      puppetdb_query('inventory[certname]{ ! certname in fact_contents[certname]{name ~ "pe_build"} }').map |$r| { $r['certname'] }
    }
    if $certnames_or_error =~ Error {
      fail_plan("PuppetDB query failed: ${certnames_or_error}")
    }
    get_targets($certnames_or_error)
  } else {
    get_targets($targets)
  }
  # Validate that hiera lookups are functional
  $hiera_result_or_error = catch_errors() || {
    lookup('pe_status_check.AS001', String)
  }
  if $hiera_result_or_error =~ Error {
    log::warn('Hiera lookups are not functional with plans. See the "Setup Requirements" section of the README')
  }

  # Get the facts from the Targets to use for processing
  $results = without_default_logging() || {
    run_task('facts', $_targets, '_catch_errors' => true)
  }

  # Report on failures while collecting facts
  $fact_task_errors = $results.error_set.ok ? {
    true    => {},
    default => $results.error_set.reduce({}) |$memo, $e| {
      $memo + {
        $e.target.name => $e.error.message
      }
    }
  }

  # Parse the results to identify nodes with the fact
  $agent_status_check_results = $results.ok_set.filter |$r| { $r['agent_status_check'] =~ NotUndef and ! $r['agent_status_check'].empty }
  $missing = $results.ok_set.filter |$r| { $r['agent_status_check'] =~ Undef or $r['agent_status_check'].empty }
  $missing_errors = $missing.reduce({}) |$memo, $r| {
    $memo + {
      $r.target.name => $r['pe_build'] =~ Undef ? {
        false    => 'This plan does not check the status of agent nodes',
        default => 'Missing the \'agent_status_check\' fact'
      }
    }
  }

  # Generate a summary of nodes with passing and failing
  $output_format = {
    'details' => {},
    'passing' => [],
    'failing' => [],
  }
  $node_summary = $agent_status_check_results.reduce($output_format) |$memo, $res| {
    $failing = $res['agent_status_check'].filter |$k, $v| { ! $v and ! ($k in $indicator_exclusions) }
    $passing = $res['agent_status_check'].filter |$k, $v| { $v and ! ($k in $indicator_exclusions) }
    $state = $failing.empty ? {
      true => 'passing',
      default => 'failing'
    }
    $details = {
      $res.target.name => {
        'passing_tests_count' => $passing.length,
        'failed_tests_count'   => $failing.length,
        'failed_tests_details' => $failing.keys.map |$item| {
          unless $hiera_result_or_error =~ Error {
            lookup("pe_status_check.${item}", String)
          }
        },
      },
    }
    $memo + {
      $state => $memo[$state] + [$res.target.name],
      'details' => $memo['details'] + $details,
    }
  }

  $status = ( $node_summary['failing'].empty and $missing.empty and $fact_task_errors.empty ) ? {
    true    => 'passing',
    default => 'failing'
  }

  # Build the output hash
  $return = {
    'nodes'  => $node_summary,
    'errors' => $missing_errors + $fact_task_errors,
    'status' => $status,
    'passing_node_count' => $node_summary['passing'].length,
    'failing_node_count' => $node_summary['failing'].length + $missing.length,
  }
  return $return
}
