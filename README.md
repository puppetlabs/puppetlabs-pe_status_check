# puppetlabs-pe_status_check

- [puppetlabs-pe_status_check](#puppetlabs-pe_status_check)
  - [Description](#description)
  - [Setup](#setup)
    - [What pe_status_check affects](#what-pe_status_check-affects)
    - [Setup requirements](#setup-requirements)
    - [Beginning with pe_status_check](#beginning-with-pe_status_check)
  - [Usage](#usage)
  - [Reporting Options](#reporting-options)
    - [Class declaration (optional)](#class-declaration-optional)
    - [Ad-hoc Report (Plans)](#ad-hoc-report-plans)
      - [Setup Requirements](#setup-requirements-1)
      - [Running the plans](#running-the-plans)
  - [Reference](#reference)
  - [Fact: pe_status_check](#fact-pe_status_check)
  - [Fact: agent_status_check](#fact-agent_status_check)
  - [How to report an issue or contribute to the module](#how-to-report-an-issue-or-contribute-to-the-module)

## Description

puppetlabs-pe_status_check provides a way to alert the end-user when Puppet Enterprise is not in an ideal state. It uses pre-set indicators and has a simplified output that directs the end-user to next steps for resolution.

Users of the tool have greater ability to provide their own self-service resolutions and shorter incident resolution times with Puppet Support due to higher quality information available to our team.

## Setup

### What pe_status_check affects

This module installs two structured facts named `pe_status_check` and `agent_status_check`. Each fact contains an array of key pairs that output an indicator ID and a Boolean value. The `pe_status_check` fact is confined to only Puppet Enterprise infrastructure agents, and the `agent_status_check` fact is confined to non-infrastructure agent nodes.

### Setup requirements

Enable plug-in sync to deliver required facts for this module.

### Beginning with pe_status_check

This module primarily provides indicators using facts, so installing the module and allowing plug-in sync to occur lets the module start functioning.

## Usage

The facts in this module can be directly consumed by monitoring tools such as Splunk, any element in the structured facts `pe_status_check` or `agent_status_check` reporting as `false` indicates a fault state in Puppet Enterprise. When any element reports as `false`, look up the incident ID in the reference section for next steps.

Alternatively, assigning the `class pe_status_check` to the infrastructure notifies on each Puppet run if any indicator is reporting as `false`.

## Reporting Options

### Class declaration (optional)

To activate the notification functions of this module, classify your Puppet Infrastructure  with the `pe_status_check` class using [your preferred classification method](https://puppet.com/docs/pe/latest/grouping_and_classifying_nodes.html#enable_console_configuration_data). Below is an example using `site.pp`.

```puppet
node 'node.example.com' {
  include pe_status_check
}
```

For maximum coverage, report on all default indicators. However, if you need to  make exceptions for your environment, classify the array parameter `indicator_exclusions` with a list of all the indicators you do not want to report on.

This workflow is not available for the `agent_status_check` fact.

```puppet
class { 'pe_status_check':
  indicator_exclusions             => ['S0001','S0003','S0003','S0004'],
}
```

### Ad-hoc Report (Plans)

The plans, `pe_status_check::infra_summary` and `pe_status_check::agent_summary` summarize the status of each of the checks on target nodes that have the `pe_status_check` or `agent_status_check` fact respectivly, sample output can be seen below:

```json
{
    "nodes": {
        "details": {
            "pe-psql-70aefa-0.region-a.domain.com": {
                "failed_tests_count": 0,
                "passing_tests_count": 13,
                "failed_tests_details": []
            },
            "pe-server-70aefa-0.region-a.domain.com": {
                "failed_tests_count": 1,
                "passing_tests_count": 30,
                "failed_tests_details": [
                    "S0022 Determines if there is a valid Puppet Enterprise license in place at /etc/puppetlabs/license.key on your primary which is not going to expire in the next 90 days"
                ]
            },
            "pe-compiler-70aefa-0.region-a.domain.com": {
                "failed_tests_count": 0,
                "passing_tests_count": 23,
                "failed_tests_details": []
            },
            "pe-compiler-70aefa-1.region-b.domain.com": {
                "failed_tests_count": 0,
                "passing_tests_count": 23,
                "failed_tests_details": []
            }
        },
        "failing": [
            "pe-server-70aefa-0.region-a.domain.com"
        ],
        "passing": [
            "pe-compiler-70aefa-1.region-b.domain.com",
            "pe-compiler-70aefa-0.region-a.domain.com",
            "pe-psql-70aefa-0.region-a.domain.com"
        ]
    },
    "errors": {},
    "status": "failing",
    "failing_node_count": 1,
    "passing_node_count": 3
}
```

#### Setup Requirements

`pe_status_check::infra_summary` and `pe_status_check::agent_summary` utilize [hiera](https://puppet.com/docs/puppet/latest/hiera_intro.html) to lookup test definitions, this requires placing a static hierarchy in your **environment level** [hiera.yaml](https://puppet.com/docs/puppet/latest/hiera_config_yaml_5.html).

```yaml
plan_hierarchy:
  - name: "Static data"
    path: "static.yaml"
    data_hash: yaml_data
```

See the following [documentation](https://puppet.com/docs/bolt/latest/hiera.html#outside-apply-blocks) for further explanation.

#### Running the plans

The `pe_status_check::infra_summary` and `pe_status_check::agent_summary` plans can be run from the [PE console](https://puppet.com/docs/pe/latest/running_plans_from_the_console_.html) or from [the command line](https://puppet.com/docs/pe/latest/running_plans_from_the_command_line.html). Below are some examples of running the plans from the command line. More information on the parameters in the plan can be seen in the [REFERENCE.md](REFERENCE.md).

Example call from the command line to run `pe_status_check::infra_summary` against all infrastructure nodes:

```shell
puppet plan run pe_status_check::infra_summary
```
Example call from the command line to run `pe_status_check::agent_summary` against all regular agent nodes:

```shell
puppet plan run pe_status_check::agent_summary
```

Example call from the command line to run against a set of infrastructure nodes:

```shell
puppet plan run pe_status_check::infra_summary targets=pe-server-70aefa-0.region-a.domain.com,pe-psql-70aefa-0.region-a.domain.com
```

Example call from the command line to exclude indicators for `pe_status_check::infra_summary`:

```shell
puppet plan run pe_status_check::infra_summary -p '{"indicator_exclusions": ["S0001","S0021"]}'
```
Example call from the command line to exclude indicators for `pe_status_check::agent_summary`:

```shell
puppet plan run pe_status_check::agent_summary -p '{"indicator_exclusions": ["AS001","AS002"]}'
```

## Reference

Refer to this section for next steps when any indicator reports a `false`.

## Fact: pe_status_check

| Indicator ID | Description                                                                        | Self-service steps                                                                                                                                                                                                                                                                                                                                                                                                                                                          | What to include in a Support ticket                                                                                                                                                                                                   |
|--------------|------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| S0001        | Determines if the puppet service is running on agents.                                      | Starts the puppet service - `puppet resource service puppet ensure=running`                                                                                                                                                                                                                                                                                                                                                                                                    | If the service fails to start, open a Support ticket referencing S0001, and provide `syslog` and any errors output when attempting to restart the service.                                           |
| S0002        | Determines if the pxp-agent service is running.                                         | Starts the pxp-agent service - `puppet resource service pxp-agent ensure=running`                                                                                                                                                                                                                                                                                                                                                                                                    | If the service fails to start, open a Support ticket referencing S0002, provide `syslog` any errors output when attempting to restart the service, and `/var/log/puppetlabs/pxp-agent/pxp-agent.log` |
| S0003        | Determines if infrastructure components are running in noop.                       | Do not routinely configure noop on PE infrastructure nodes, as it prevents the management of key infrastructure settings. [Disable this setting on infrastructure components.](https://puppet.com/docs/puppet/latest/configuration.html#noop)                                                                                                                                                                                                                       | If you are unable to disable noop or encounter an error when disabling noop, open a Support ticket referencing S0003, and provide any errors output when attempting to change the setting.                                                                |
| S0004        | Determines if the Puppet Server status endpoint is returning any errors.                                  | Execute `puppet infrastructure status`.  Which ever service returns in a state that is not running, examine the logging for that service to indicate the fault.                                                                                                                                                                                                                                                                                         | Open a Support ticket referencing S0004, provide the output of `puppet infrastructure status` and [any service logs associated with the errors](https://puppet.com/docs/pe/latest/what_gets_installed_and_where.html#log_files_installed).                                                                                    |
| S0005        | Determines if certificate authority (CA) cert expires in the next 90 days.                                         | Install the [puppetlabs-ca_extend](https://forge.puppet.com/modules/puppetlabs/ca_extend) module and follow steps to extend the CA cert.                                                                                                                                                                                                                                                                                                                                             | Open a Support ticket referencing S0005 and provide [support script](https://puppet.com/docs/pe/latest/getting_support_for_pe.html#pe_support_script) output from the primary server, and any errors encountered when using the ca_extend module.                                                                |
| S0006        | Determines if Puppet metrics collector is enabled and collecting metrics.                     |Metrics collector is a tool that lets you monitor a PE installation. If it is not enabled, [enable it.](https://puppet.com/docs/pe/latest/getting_support_for_pe.html#puppet_metrics_collector)  | If you have issues enabling metrics, open a ticket referencing S0006 and provide the output of the [support script.](https://puppet.com/docs/pe/latest/getting_support_for_pe.html#pe_support_script)                                   |
| S0007        | Determines if there is at least 20% disk free on the PostgreSQL data partition.           | Determines if growth is slow and expected within the TTL of your data. If there's an unexpected increase, use this article to [troubleshoot PuppetDB](https://support.puppet.com/hc/en-us/articles/360056219974)                                                                                                                                                                                                 | Open a Support ticket referencing S0007 and provide details about large files and folders, rate of growth, and a full [support script](https://puppet.com/docs/pe/latest/getting_support_for_pe.html#pe_support_script) from the affected node.                                                                          |
| S0008        | Determines if there is at least 20% disk free on the codedir data partition.        | This can indicate you are deploying more code from the code repo than there is space for on the infrastructure components, or that something else is consuming space on this partition. Run `puppet config print codedir`, check that codedir partition indicated has enough capacity for the code being deployed, and check that no other outside files are consuming this data mount.                                                                                    |                                                                                                                                                                                                                                       |
| S0009        | Determines if pe-puppetsever service is running and enabled on relevant components. | Checks that the service can be started and enabled by running `puppet resource service pe-puppetserver ensure=running`, examines `/var/log/puppetlabs/puppetserver/puppetserver.log` for failures.                                                                                                                                                                                                                                                                                               | Open a Support ticket referencing S0009 and provide the `/var/log/puppetlabs/puppetserver/puppetserver.log`, showing an unsuccessful startup.                                                                              |
| S0010        | Determines if pe-puppetdb service is running and enabled on relevant components.    | Checks that the service can be started and enabled by running `puppet resource service pe-pupeptdb ensure=running`, examines `/var/log/puppetlabs/puppetdb/puppetdb.log` for failures.                                                                                                                                                                                                                                                                                                         | Open a Support ticket referencing S0010 and provide the `/var/log/puppetlabs/puppetdb/puppetdb.log` log, showing an unsuccessful startup.                                                                                      |
| S0011        | Determines if pe-postgres service is running and enabled on relevant components.    | Checks that the service can be started and enabled by running `puppet resource service pe-postgres ensure=running`, examines `/var/log/puppetlabs/postgresql/<postgresversion>/postgresql-<today>.log` for failures.                                                                                                                                                                                                                                                                           | Open a Support ticket referencing S0011 and provide the `/var/log/puppetlabs/postgresql/<postgresversion>/ postgresql-<today>.log` log, showing an unsuccessful startup                                                        |
| S0012        | Determines if Puppet produced a report during the last run interval.                | [Troubleshoot Puppet run failures.](https://puppet.com/docs/pe/latest/run_puppet_on_nodes.html#troubleshooting_puppet_run_failures)                                                                                                                                                                                                                                                                                                                                                                             | Open a Support ticket referencing S0012 and provide the output of `puppet agent -td > debug.log 2>&1`                                                                                                                             |
| S0013        | Determines if the catalog was successfully applied during the last  Puppet run.              | [Troubleshoot Puppet run failures.](https://puppet.com/docs/pe/latest/run_puppet_on_nodes.html#troubleshooting_puppet_run_failures)                                                                                                                                                                                                                                                                                                                                                                            | Open a Support ticket referencing S0013 and provide the output of `puppet agent -td > debug.log 2>&1`                                                                                                                            |
| S0014        | Determines if anything in the command queue is older than a Puppet run interval.         | This can indicate that the PuppetDB performance is inadequate for incoming requests. Review PuppetDB performance. [Use metrics to pinpoint the issue.](https://support.puppet.com/hc/en-us/articles/231751308)  | Open a Support ticket referencing `S0014` and provide the output of the [support script.](https://puppet.com/docs/pe/latest/getting_support_for_pe.html#pe_support_script)  |
| S0015        | Determines if the infrastructure agent host certificate is expiring in the next 90 days.                                     | Puppet Enterprise has built in functionalilty to regenerate infrastructure certificates, see the following [documentation](https://puppet.com/docs/pe/2021.5/regenerate_certificates.html#regenerate_certificates)  |  If the documented steps fail to resolve your issue, open a support ticket referencing S0015 and provide the error message recieved when running the steps.                                                                               | 
| S0016        | Determines if there are any `OutOfMemory` errors in the `puppetserver` log. | [Increase the Java heap size for that service.](https://support.puppet.com/hc/en-us/articles/360015511413) | Open a Support ticket referencing S0016 and provide [puppet metrics](https://support.puppet.com/hc/en-us/articles/231751308), `/var/log/puppetlabs/puppetserver/puppetserver.log`, and the output of `puppet infra tune`.|
| S0017        | Determines if there are any `OutOfMemory` errors in the `puppetdb` log. | [Increase the Java heap size for that service.](https://support.puppet.com/hc/en-us/articles/360015511413) | Open a Support ticket referencing S0017 and provide [puppet metrics](https://support.puppet.com/hc/en-us/articles/231751308), `/var/log/puppetlabs/puppetdb/puppetdb.log`, and the output of `puppet infra tune`.|
| S0018        | Determines if there are any `OutOfMemory` errors in the `orchestrator` log. | [Increase the Java heap size for that service.](https://support.puppet.com/hc/en-us/articles/360015511413) | Open a Support ticket referencing S0018 and provide [puppet metrics](https://support.puppet.com/hc/en-us/articles/231751308), `/var/log/puppetlabs/orchestration-services/orchestration-services.log`, and output of `puppet infra tune`.|
|S0019|Determines if there are sufficent jRubies available to serve agents.| Insufficent jRuby availability results in queued puppet agents and overall poor system performance. There can be many causes: [Insufficent server tuning for load](https://support.puppet.com/hc/en-us/articles/360013148854), [a thundering herd](https://support.puppet.com/hc/en-us/articles/215729277), and [insufficient system resources for scale.](https://puppet.com/docs/pe/latest/hardware_requirements.html#hardware_requirements) | If self-sevice fails to resolve the issue, open a ticket referencing S0019 and provide a description of actions so far and the output of the [support script.](https://puppet.com/docs/pe/latest/getting_support_for_pe.html#pe_support_script)
|S0021|Determines if free memory is less than 10%.| Ensure your system hardware availablity matches the [recommended configuration](https://puppet.com/docs/pe/latest/hardware_requirements.html#hardware_requirements), note this assumes no third-party software using significant resources, adapt requirements accordingly for third-party requirements. | If you have issues with memory utilization in Puppet Enterprise that is not expected, open a Support ticket, referencing S0021 and provide the output of the [support script](https://puppet.com/docs/pe/latest/getting_support_for_pe.html#pe_support_script)
| S0022        | Determines if there is a valid Puppet Enterprise license in place at `/etc/puppetlabs/license.key` on the primary server which is not expiring in the next 90 days.                | [Get help with Puppet Enterprise license issues](https://support.puppet.com/hc/en-us/articles/360017933313)                                                                                                                                                                                                                                                                                                                                                                              | Open a Support ticket referencing S0022 and provide the output of the following commands `ls -la /etc/puppetlabs/license.key` and `cat /etc/puppetlabs/license.key`. |
| S0024        | Determines if there are files in the puppetdb discard directory newer than 1 week old                       |   Recent files indicate an issue that causes PuppetDB to reject incoming data. Invesitgate Puppetdb logs at the time the data was rejected to find a cause,                                                                                                                                                                                                                   | Open a Support ticket referencing S0024 and provide a copy of the PuppetDB log for the time in question, along with a sample of the most recent file in the following directory `/opt/puppetlabs/server/data/puppetdb/stockpile/discard/`
| S0029        | Determines if number of current connections to Postgresql DB is approaching 90% of the `max_connections` defined.  | To increase the maximum number of connections in postgres, adjust `puppet_enterprise::profile::database::max_connections`. Consider to increase `shared_buffers` if that is the case as each connection consumes RAM.                                                                                                                  | Open a Support ticket referencing S0029 and provide the current and future value for `puppet_enterprise::profile::database::max_connections` and we will assist. 
| S0030        | Determines when infrastructure components have the setting `use_cached_catalog` set to true.                        | Don't configure use_cached_catalog on PE infrastructure nodes. It prevents the management of key infrastructure settings. Disable this setting on all infrastructure components. [See our documentation for more information](https://puppet.com/docs/puppet/latest/configuration.html#use-cached-catalog)                                                                                                                                                                                                                    | If you encounter errors after disabling use_cached_catalog, open a Support ticket referencing S0030 and provide the errors.
| S0031        | Determines if old PE agent packages exist on the primary server. | [Remove the old PE agent packages.](https://support.puppet.com/hc/en-us/articles/4405333422103) |
| S0033        | Determines if Hiera 5 is in use. | Upgrading to Hiera 5 [offers some major advantages](https://puppet.com/docs/puppet/latest/hiera_migrate)                                                                                                                          | If you're having issues upgrading to Hiera 5 or if your global Hiera configuration file was erroneously modified, open a Support ticket referencing S0033. Provide your global Hiera configuration file `puppet config print hiera_config`; the default location is `/etc/puppetlabs/puppet/hiera.yaml`.
| S0034        | Determines if your PE deployment has not been upgraded in the last year.                   |  [Upgrade your PE instance.](https://puppet.com/docs/pe/latest/upgrading_pe.html)                                                                                                                | If you need help upgrading PE, open a ticket and provide your current version and the version you would like to upgrade to (this could be the LTS or STS version of PE). |
| S0035        | Determines if ``puppet module list`` is returning any warnings | If S0035 returns ``false``, i.e., warnings are present, you should run `puppet module list --debug` and resolve the issues shown.  The Puppetfile does NOT include Forge module dependency resolution. You must make sure that you have every module needed for all of your specified modules to run.Please refer to [Managing environment content with a Puppetfile](https://puppet.com/docs/pe/latest/puppetfile.html) for more info on Puppetfile and refer to the specific module page on the forge for further information on specific dependancies                                                                     | If you are unable to remove all the warnings, then please refer to [Get help for supported modules]( https://support.puppet.com/hc/en-us/articles/226771168) and raise a support request
| S0036        | Determines if `max-queued-requests` is set above 150.                       | [The maximum value for `jruby_puppet_max_queued_requests` is 150](https://support.puppet.com/hc/en-us/articles/115003769433)                                                                                    | If you are unable to change the value of `jruby_puppet_max_queued_requests` or encounter an error when changing it, open a Support ticket referencing S0036 and provide any errors output when attempting to change the setting.
| S0038        | Determines whether the number of environments within `$codedir/environments` is less than 100 | Having a large number of code environments can negatively affect Puppet Server performance. [See the Configuring Puppet Server documentation for more information.](https://puppet.com/docs/pe/latest/config_puppetserver.html#configuring_and_tuning_puppet_server)                     | Open a Support ticket referencing S0038 and provide the [support script](https://puppet.com/docs/pe/latest/getting_support_for_pe.html#pe_support_script) output from the primary server.
| S0039        | Determines if Puppets Server has reached its `queue-limit-hit-rate`,and is sending messages to agents. | [Check the  max-queued-requests article for more information.](https://support.puppet.com/hc/en-us/articles/115003769433)                      | Open a Support ticket referencing S0039 and provide the [support script](https://puppet.com/docs/pe/latest/getting_support_for_pe.html#pe_support_script) output from the primary server.
| S0040        | Determines if PE is collecting system metrics.                    | If system metrics are not collected by default, the sysstat package is not installed on the impacted PE infrastructure component. Install the package and set the parameter `puppet_enterprise::enable_system_metrics_collection` to true. [See the documentation.](https://puppet.com/docs/pe/latest/getting_support_for_pe.html#puppet_metrics_collector)                                                                   | After system metrics are configured, you do not see any files in `/var/log/sa` or if the `/var/log/sa` directory does not exist, open a Support ticket.                                                 |
| S0041        | Determines if the pxp broker on a compiler  has an established connection to another pxp broker  | To resolve a connection issue from a compiler to a pcp broker examine the following log `/var/log/puppetlabs/puppetserver/pcp-broker.log` for an explanation, Compilers should be attempting to make a connection to port 8143 on the primary server, ssl can not be terminated on a network appliance and must passthrough directly to the primary server. Ensure the connnection attempt is not to another compiler in the pool            | If unable to make a connection to a broker, raise a ticket with the support team quoting S0041 and attaching the file `/var/log/puppetlabs/puppetserver/pcp-broker.log` along with the conclusions of your investigation so far            |
| S0042        |Determines if the pxp-agent has an established connection to a pxp broker                   | Ensure the pxp-agent service is running. Check S0002 can make that determination. if running check `/var/log/puppetlabs/pxp-agent/pxp-agent.log` for connection issues, first ensuring the agent is connecting to the proper endpoint, for example, a compiler and not the primary. This fact can also be used as a target filter for running tasks, ensuring time is not wasted sending instructions to agents not connected to a broker                   | If unable to make a connection to a broker, raise a ticket with the support team quoting S0042 and attaching the file `/var/log/puppetlabs/pxp-agent/pxp-agent.log` along with the conclusions of your investigation so far             |

## Fact: agent_status_check

| Indicator ID | Description                                                                        | Self-service steps                                                                                                                                                                                                                                                                                                                                                                                                                                                          | What to include in a Support ticket                                                                                                                                                                                                   |
|--------------|------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| AS001        | Determines if the agent host certificate is expiring in the next 90 days.                                     | Puppet Enterprise has a plan built into extend agent certificates. Use a puppet query to find expiring host certificates and pass the node ID to this plan:   `puppet plan run enterprise_tasks::agent_cert_regen agent=$(puppet query 'inventory[certname] { facts.agent_status_check.AS001 = false }' \| jq  -r '.[].certname' \|  paste -sd, -) master=$(puppet config print certname)`  |  If the plan fails to run, open a support ticket referencing AS001 and provide the error message recieved when running the plan.                                                                               | 
| AS002        | Determines if the pxp-agent has an established connection to a pxp broker                                     | Ensure the pxp-agent service is running, if running check `/var/log/puppetlabs/pxp-agent/pxp-agent.log` for connection issues, first ensuring the agent is connecting to the proper endpoint, for example, a compiler and not the primary. This fact can also be used as a target filter for running tasks, ensuring time is not wasted sending instructions to agents not connected to a broker| If unable to make a connection to a broker, raise a ticket with the support team quoting AS002 and attaching the file    `/var/log/puppetlabs/pxp-agent/pxp-agent.log` along with the conclusions of your investigation so far                                                                            | 

## How to report an issue or contribute to the module

If you are a PE user and need support using this module or encounter issues, our Support team is happy to help you. Open a ticket at the [Support Portal](https://support.puppet.com/hc/en-us/requests/new).
 If you have a reproducible bug or are a community user, you can [open an issue directly in the GitHub issues page of the module](https://github.com/puppetlabs/puppetlabs-pe_status_check/issues). We also welcome PR contributions to improve the module. [Please see further details about contributing](https://puppet.com/docs/puppet/latest/contributing.html#contributing_changes_to_module_repositories).
