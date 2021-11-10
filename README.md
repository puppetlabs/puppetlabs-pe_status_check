# puppetlabs-self_service


1. [Description](#description)
1. [Setup - The basics of getting started with self_service](#setup)
    * [What self_service affects](#what-self_service-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with self_service](#beginning-with-self_service)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - what to do when a indicator repors a fault](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

puppetlabs-self_service aims to provide a mechnism to alert the end-user when Puppet Enterprise is not in an ideal state.
It uses a pre-set indicators and has a simplified output that directs the end-user to next steps for resolution.

Users of the tool should expect greater ability to provide the self served resolutions, as well as shorter incident resolution times with Puppet Enterprise Support due to higher quality information available to support cases.


## Setup

### What self_service affects

This module installs a structured fact named self_service, which contains an array of key pairs tha simply output an indicator ID and a boolean value. 

### Setup Requirements

Plugin-Sync should be enabled to deliver the facts this module requires

### Beginning with self_service

puppetlabs-self_service is primarly provides the indicators by means of facts so installing the module and allowing plugin sync to occur will allow the module to start functioning

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
to do this classify the array parameter exclude_self_service_indicators with an list of all indicators you do not want to report on.

```
class { 'self_service':
  exclude_self_service_indicators             => ['S0001','S0003','S0003','S0004'],
}
```


## Reference

This section should be referred to for next steps when any indicator reports a fault

| Indicator ID | Indicator Purpose                                           | Self Service Steps                                                                                                                             | What to Include in a Support Ticket                                                                                                                                                                                                    |
|--------------|-------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| S0001        | Determines if Puppet agent Service is running               | Start the puppet agent  - `puppet resource service puppet ensure=running`                                                                      | If the Puppet agent fails to start with the self service step raise a support case quoting reference S0001 and providing syslog  and any error output when attempting to restart the service                                           |
| S0002        | Determines if  pxp-agent Service is running                 | Start the pxp-agent - `puppet resource service pxp-agent ensure=running`                                                                       | If the Pxp-agent fails to start with the self service step raise a support case quoting reference S0001 and providing syslog, any error output when attempting to restart the service and  /var/log/puppetlabs/pxp-agent/pxp-agent.log |
| S0003        | Determines if Infrastructure components are running in NOOP | Following this documentation to disable [noop](https://puppet.com/docs/puppet/7/configuration.html#noop)                                       |                                                                                                                                                                                                                                        |
| S0004        | Determines if infrastructure status is not green            | Run `puppet infrastructure status` note any services showing in an error state and examine the corresponding service logs for potential causes | raise a support case quoting reference S0004 along with the output of `puppet infrastructure status`  and any service logs associated with the errors                                                                                  |
| S0005        | Determines if CA expires within 90 days                     | Install the following module https://forge.puppet.com/modules/puppetlabs/ca_extend and follow the documentation to extend the CA               |                                                                                                                                                                                                                                        |
| S0006        |                                                             |                                                                                                                                                |                                                                                                                                                                                                                                        |
| S0007        |                                                             |                                                                                                                                                |                                                                                                                                                                                                                                        |
| S0008        |                                                             |                                                                                                                                                |                                                                                                                                                                                                                                        |



## Limitations


## Development


