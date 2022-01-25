# puppetlabs-self_service


- [puppetlabs-self_service](#puppetlabs-self_service)
  - [Description](#description)
  - [Setup](#setup)
    - [What self_service affects](#what-self_service-affects)
    - [Setup Requirements](#setup-requirements)
    - [Beginning with self_service](#beginning-with-self_service)
  - [Usage](#usage)
    - [Class Delcaration *Optional.*](#class-delcaration-optional)
  - [Reference](#reference)
  - [Limitations](#limitations)
  - [Development](#development)

## Description

puppetlabs-self_service aims to provide a mechnism to alert the end-user when Puppet Enterprise is not in an ideal state.
It uses pre-set indicators and has a simplified output that directs the end-user to next steps for resolution.

Users of the tool should expect greater ability to provide the self served resolutions, as well as shorter incident resolution times with Puppet Enterprise Support due to higher quality information available to support cases.


## Setup

### What self_service affects

This module installs a structured fact named self_service, which contains an array of key pairs tha simply output an indicator ID and a boolean value. 

### Setup Requirements

Plugin-Sync should be enabled to deliver the facts this module requires

### Beginning with self_service

puppetlabs-self_service primarly provides the indicators by means of facts so installing the module and allowing plugin sync to occur will allow the module to start functioning

## Usage


The Facts contained in this module can be used for direct consumption by monitoring tools such as Splunk, any element in the structured fact `self_service` reporting as "false" indicates a fault state in Puppet Enterprise.
When any of the elements reports as false, the incident ID should be looked up in the reference section for next steps

Alternativly assigning the class self_service to the infrastructure  Will "Notify" on Each Puppet run if any of the indicators are in a fault state.

### Class Delcaration *Optional.*

To activate the notification functions of this module, classify your Puppet Infrastructure  with the self_service class using your preferred classification method. Below is an example using site.pp.

```
node 'node.example.com' {
  include self_service
}
```

While the entirity of the default indictors should be reported on for maximum coverage, it may be nessary to make exceptions for your particular environment.
to do this classify the array parameter indicator_exclusions with an list of all indicators you do not want to report on.

```
class { 'self_service':
  indicator_exclusions             => ['S0001','S0003','S0003','S0004'],
}
```


## Reference

This section should be referred to for next steps when any indicator reports a fault

| Indicator ID | Description                                                                        | Self Service Steps                                                                                                                                                                                                                                                                                                                                                                                                                                                          | What to Include in a Support Ticket                                                                                                                                                                                                   |
|--------------|------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| S0001        | Determines if Puppet agent Service is running                                      | Start the puppet agent - `puppet resource service puppet ensure=running`                                                                                                                                                                                                                                                                                                                                                                                                    | If the Puppet agent fails to start with the self service step raise a support case quoting reference S0001 and providing syslog and any error output when attempting to restart the service                                           |
| S0002        | Determines if pxp-agent Service is running                                         | Start the pxp-agent - `puppet resource service pxp-agent ensure=running`                                                                                                                                                                                                                                                                                                                                                                                                    | If the Pxp-agent fails to start with the self service step raise a support case quoting reference S0002 and providing syslog, any error output when attempting to restart the service and /var/log/puppetlabs/pxp-agent/pxp-agent.log |
| S0003        | Determines if Infrastructure components are running in NOOP                        | Noop should not be routinely configured on PE infrastructure nodes as it prevents the management of key infrastructure settings. Please disable this setting on any infrastructure component https://puppet.com/docs/puppet/7/configuration.html#noop                                                                                                                                                                                                                       | If you are unable, or encounter an error when disabling noop, raise a support case quoting reference S0003 and any errors output when attempting to change the setting                                                                |
| S0004        | Determines if infrastructure status is not green                                   | Run the command `puppet infrastructure status` on your primary node, note any services showing in an error state and examine the corresponding service logs for potential causes                                                                                                                                                                                                                                                                                            | Raise a support case quoting reference S0004 along with the output of puppet infrastructure status and any service logs associated with the errors                                                                                    |
| S0005        | Determines if CA expires within 90 days                                            | Install the following module https://forge.puppet.com/modules/puppetlabs/ca_extend and follow the documentation to extend the CA                                                                                                                                                                                                                                                                                                                                            | Raise a support case quoting reference S0005 together with the support script output from the primary node, and any errors encountered when using the ca_extend module                                                                |
| S0006        |                      | |                                         |
| S0007        | Determines if there is at least 20% disk free on postgres Data partition           | Determine if the growth is slow and expected within the TTL of your data, unexpected increase can be due to error states this article should be consulted https://support.puppet.com/hc/en-us/articles/360056219974-Troubleshoot-PuppetDB-pe-puppetdb-in-Puppet-Enterprise                                                                                                                                                                                                  | Raise a support case quoting reference S0007 detailing the files and folders and rate of growth, along with a full support script from the node in question                                                                           |
| S0008        | Determines if there is at least 20% disk free on the Codedir Data Partition        | This can indicate you are deploying more code from the code repo than there is space for on the infrastructure components, or something else is consuming space on this partition. Check the mount that the directory indicated by `puppet config print codedir` resides has enough capacity for the code being deployed, and check no other outside files are consuming this data mount                                                                                    |                                                                                                                                                                                                                                       |
| S0009        | Determines if Pe-puppetsever Service is Running and Enabled on relevant components | Check the Service can be started and enabled  `puppet resource service pe-puppetserver ensure=running` examing /var/log/puppetlabs/puppetserver/puppetserver.log for failures                                                                                                                                                                                                                                                                                               | Raise a support case quoting reference S0009 along with the log below, showing an unsuccessful startup /var/log/puppetlabs/puppetserver/puppetserver.log                                                                              |
| S0010        | Determines if Pe-puppetdb Service is Running and Enabled on relevant components    | Check the Service can be started and enabled   `puppet resource service pe-pupeptdb ensure=running`  examing /var/log/puppetlabs/puppetdb/puppetdb.log for failures                                                                                                                                                                                                                                                                                                         | Raise a support case quoting reference S0010 along with the log below, showing an unsuccessful startup /var/log/puppetlabs/puppetdb/puppetdb.log                                                                                      |
| S0011        | Determines if Pe-postgres Service is Running and Enabled on relevant components    | Check the Service can be started and enabled   `puppet resource service pe-postgres ensure=running`  examing /var/log/puppetlabs/postgresql/<postgresversion>/postgresql-<today>.log for failures                                                                                                                                                                                                                                                                           | Raise a support case quoting reference S0011 along with the log below, showing an unsuccessful startup /var/log/puppetlabs/postgresql/<postgresversion>/ postgresql-<today>.log                                                       |
| S0012        | Determines if Puppet produced a report within the last run interval                | https://puppet.com/docs/pe/2021.4/run_puppet_on_nodes.html#troubleshooting_puppet_run_failures                                                                                                                                                                                                                                                                                                                                                                              | Raise a support case quoting reference S0012 along with the output of `puppet agent -td > debug.log 2>&1`                                                                                                                             |
| S0013        | Determines if a catalog successfully applied on Puppet Agent Last run              | https://puppet.com/docs/pe/2021.4/run_puppet_on_nodes.html#troubleshooting_puppet_run_failures                                                                                                                                                                                                                                                                                                                                                                              | Raise a support case quoting reference S0013 along with the output of  `puppet agent -td > debug.log 2>&1`
| S0033        | Determines if modern Hiera 5 is in use | Upgrading to Hiera 5 offers some major advantages https://puppet.com/docs/puppet/7/hiera_migrate                                                                                                                           | If you're running into issues upgrading to Hiera 5 or believe your Global Hiera configuration file was erroneously modified, raise a support case quoting reference S0033. Provide your Global Hiera Configuration file `puppet config print hiera_config`; the default location is `/etc/puppetlabs/puppet/hiera.yaml`. 
| S0036        | Determines if max-queued-requests is set above 150                       | The maximum value for jruby_puppet_max_queued_requests is 150                (https://support.puppet.com/hc/en-us/articles/115003769433)                                                                      | If you are unable, or encounter an error when changing the value of jruby_puppet_max_queued_requests, raise a support case quoting reference S0036 and any errors output when attempting to change the setting  
S0030        | Determines when infrastructure components that run with the setting use_cached_catalog are set to true                        | Don't configure use_cached_catalog on PE infrastructure nodes. It prevents the management of key infrastructure settings. Disable this setting on any infrastructure component. See: https://puppet.com/docs/puppet/7/configuration.html#use-cached-catalog                                                                                                                                                                                                                       | Submit a support case when you encounter an error after disabling use_cached_catalog. Reference S0030 and include output errors that appeared when you attempted to change the setting                                                    |

## Limitations


## Development


