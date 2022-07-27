# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v2.3.0](https://github.com/puppetlabs/puppetlabs-pe_status_check/tree/v2.3.0) (2022-07-27)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-pe_status_check/compare/v2.2.0...v2.3.0)

### Added

- \(SUP-3362\) add CRL expiration check [\#149](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/149) ([MartyEwings](https://github.com/MartyEwings))

### Fixed

- \(SUP-3491\) Cast free\_jrubies value to float [\#151](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/151) ([m0dular](https://github.com/m0dular))

## [v2.2.0](https://github.com/puppetlabs/puppetlabs-pe_status_check/tree/v2.2.0) (2022-07-15)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-pe_status_check/compare/v2.1.1...v2.2.0)

### Added

- \(Sup-3465\) check for certname in incorrect configuration section [\#147](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/147) ([MartyEwings](https://github.com/MartyEwings))

## [v2.1.1](https://github.com/puppetlabs/puppetlabs-pe_status_check/tree/v2.1.1) (2022-07-11)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-pe_status_check/compare/v2.1.0...v2.1.1)

### Fixed

- \(SUP-3452\) Handle hostcert path missing [\#145](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/145) ([MartyEwings](https://github.com/MartyEwings))

## [v2.1.0](https://github.com/puppetlabs/puppetlabs-pe_status_check/tree/v2.1.0) (2022-07-08)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-pe_status_check/compare/v2.0.2...v2.1.0)

### Added

- \(SUP-3450\) make agent\_status\_check collection optional [\#141](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/141) ([MartyEwings](https://github.com/MartyEwings))
- \(SUP-3426\) Use shorter timeout for facter execute [\#139](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/139) ([m0dular](https://github.com/m0dular))
- \(SUP-3400\)\(SUP-3401\)\(SUP-3402\) Update Readme to explain facts further [\#137](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/137) ([MartyEwings](https://github.com/MartyEwings))

### Fixed

- SUP-3457 get\_resource error handling [\#143](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/143) ([m0dular](https://github.com/m0dular))
- \(SUP-3442\) Update ss commands so timeout kills the process [\#142](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/142) ([elainemccloskey](https://github.com/elainemccloskey))

## [v2.0.2](https://github.com/puppetlabs/puppetlabs-pe_status_check/tree/v2.0.2) (2022-06-17)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-pe_status_check/compare/v2.0.1...v2.0.2)

### Fixed

- SUP-3398 legacy primary support [\#135](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/135) ([MartyEwings](https://github.com/MartyEwings))

## [v2.0.1](https://github.com/puppetlabs/puppetlabs-pe_status_check/tree/v2.0.1) (2022-06-14)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-pe_status_check/compare/v2.0.0...v2.0.1)

### Fixed

- \(SUP-3381\) Add error handling to role fact [\#132](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/132) ([m0dular](https://github.com/m0dular))

## [v2.0.0](https://github.com/puppetlabs/puppetlabs-pe_status_check/tree/v2.0.0) (2022-06-13)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-pe_status_check/compare/v1.5.0...v2.0.0)

### Changed

- \(SUP-3315\) Use cached state to determine node role [\#99](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/99) ([m0dular](https://github.com/m0dular))

## [v1.5.0](https://github.com/puppetlabs/puppetlabs-pe_status_check/tree/v1.5.0) (2022-05-27)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-pe_status_check/compare/v1.4.0...v1.5.0)

### Added

- \(SUP-3285\) Update readme for S0035 [\#129](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/129) ([elainemccloskey](https://github.com/elainemccloskey))

## [v1.4.0](https://github.com/puppetlabs/puppetlabs-pe_status_check/tree/v1.4.0) (2022-04-29)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-pe_status_check/compare/v1.3.0...v1.4.0)

### Added

- \(SUP-3230\) Check for the expiry date of the host cert on infrastructure [\#123](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/123) ([MartyEwings](https://github.com/MartyEwings))
- \(SUP-3229\) Summary Plan for agents [\#122](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/122) ([MartyEwings](https://github.com/MartyEwings))
- \(SUP-3005\) Update plan output format [\#117](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/117) ([jarretlavallee](https://github.com/jarretlavallee))
- Add Suse support to AS002 [\#115](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/115) ([seanmil](https://github.com/seanmil))
- \(SUP-3005\) Add Plan for Reporting on Infrastructure [\#114](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/114) ([MartyEwings](https://github.com/MartyEwings))
- \(SUP-2914\) Verify that 'puppet module list' output is without Warnings  [\#43](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/43) ([gavindidrichsen](https://github.com/gavindidrichsen))

## [v1.3.0](https://github.com/puppetlabs/puppetlabs-pe_status_check/tree/v1.3.0) (2022-04-07)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-pe_status_check/compare/v1.2.0...v1.3.0)

### Added

- \(SUP-3150\) Broker TCP Checks for infra components [\#109](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/109) ([MartyEwings](https://github.com/MartyEwings))
- \(SUP-3121\) Agent connection to pxp broker [\#106](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/106) ([MartyEwings](https://github.com/MartyEwings))
- \(SUP-2917\) Add indicator S0038 to check number of environments that are present in $codedir/environments [\#105](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/105) ([taikaa](https://github.com/taikaa))
- \(SUP-2908\) check current connections to Postgres less than 90% defined maximum [\#104](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/104) ([sandrajiang](https://github.com/sandrajiang))

### Fixed

- \(SUP-3180\) Rescue a loaderror when checking filesystem [\#111](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/111) ([jarretlavallee](https://github.com/jarretlavallee))
- \(SUP-3101\) Add exception handling and Facter warnings for license\_type and end date that do not exist or are invalid. Fact no longer resolves to true as a catchall. Change license\_type and end\_date variable assignments to first item of array rather than converting entire array to a string. Update spec test. [\#103](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/103) ([taikaa](https://github.com/taikaa))
- \(SUP-3122\) Fix PSQL node detection in 2021.5 [\#98](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/98) ([MartyEwings](https://github.com/MartyEwings))

## [v1.2.0](https://github.com/puppetlabs/puppetlabs-pe_status_check/tree/v1.2.0) (2022-03-23)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-pe_status_check/compare/v1.1.0...v1.2.0)

### Added

- \(SUP-2903\) Check for new items in discard Directory [\#92](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/92) ([MartyEwings](https://github.com/MartyEwings))

### Fixed

- Check for non-nil match in S0039 [\#94](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/94) ([m0dular](https://github.com/m0dular))
- \(SUP-3116\) Fix replica Detection in 2021.5 [\#93](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/93) ([MartyEwings](https://github.com/MartyEwings))
- \(SUP-3099\) Only Alert on 503 messages sent in last run interval [\#91](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/91) ([elainemccloskey](https://github.com/elainemccloskey))

## [v1.1.0](https://github.com/puppetlabs/puppetlabs-pe_status_check/tree/v1.1.0) (2022-02-24)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-pe_status_check/compare/v1.0.0...v1.1.0)

### Added

- Change to Use 'module\_function' instead of `self` [\#83](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/83) ([m0dular](https://github.com/m0dular))
- Standardize net http [\#82](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/82) ([m0dular](https://github.com/m0dular))

## [v1.0.0](https://github.com/puppetlabs/puppetlabs-pe_status_check/tree/v1.0.0) (2022-02-08)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-pe_status_check/compare/v0.2.0...v1.0.0)

### Changed

- Rename Module to pe\_status\_check [\#74](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/74) ([MartyEwings](https://github.com/MartyEwings))

### Added

- Adds Details to Warning Messages [\#76](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/76) ([MartyEwings](https://github.com/MartyEwings))
- Improve documentation [\#69](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/69) ([MartyEwings](https://github.com/MartyEwings))
- \(SUP-2945\) Updating S0004 to call the services API [\#68](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/68) ([jordi-garcia](https://github.com/jordi-garcia))
- \(SUP-2892\) - No recent OOM errors logged in any JVM [\#58](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/58) ([BartoszBlizniak](https://github.com/BartoszBlizniak))
- \(SUP-2890\) - Check command queue depth [\#56](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/56) ([BartoszBlizniak](https://github.com/BartoszBlizniak))
- \(SUP-2901\) License check, tests and readme update [\#51](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/51) ([pgrant87](https://github.com/pgrant87))
- \(SUP-2896\) Check Avg Free JRubies [\#50](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/50) ([coreymbe](https://github.com/coreymbe))
- \(SUP-2910\) Check if older packages are still available to pe\_repo [\#47](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/47) ([asselvakumar](https://github.com/asselvakumar))
- \(SUP-2918\) Check If Puppet Server is sending 503s to agents [\#44](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/44) ([kksubbu72](https://github.com/kksubbu72))
- \(SUP-2946\) Check Metrics Collector is enabled [\#41](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/41) ([MartyEwings](https://github.com/MartyEwings))
- \(SUP-2913\) Puppet not updated for more than a year [\#38](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/38) ([gmcgrillan](https://github.com/gmcgrillan))
- \(SUP-2912\) Added S0033 to check if Global Hiera is Hiera 5, added tests, updated README [\#35](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/35) ([taikaa](https://github.com/taikaa))
- Adding Agent only Fact check for expiring host cert [\#32](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/32) ([MartyEwings](https://github.com/MartyEwings))
- \(SUP-2919\) - is puppet\_metrics\_collector::system configured [\#29](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/29) ([tcwest23](https://github.com/tcwest23))
- \(SUP-2915\) Check if max-queued-requests is configured to above 150 [\#28](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/28) ([elainemccloskey](https://github.com/elainemccloskey))
- \(SUP-2909\) Check that use\_cached\_catalog setting is false [\#27](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/27) ([elainemccloskey](https://github.com/elainemccloskey))

### Fixed

- Add confinement to S0036 [\#36](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/36) ([elainemccloskey](https://github.com/elainemccloskey))

## [v0.2.0](https://github.com/puppetlabs/puppetlabs-pe_status_check/tree/v0.2.0) (2022-01-11)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-pe_status_check/compare/v0.1.0...v0.2.0)

### Added

- \(SUP-2898\) Available Memory on the platform is less than 10% [\#18](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/18) ([MartyEwings](https://github.com/MartyEwings))

## [v0.1.0](https://github.com/puppetlabs/puppetlabs-pe_status_check/tree/v0.1.0) (2021-12-14)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-pe_status_check/compare/f6d5d880a989fad41190a0df43e8dc0a34713df2...v0.1.0)

### Added

- \(SUP-2862\) Basic Readme for version 0.1.0 [\#13](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/13) ([MartyEwings](https://github.com/MartyEwings))
- \(SUP-2861\) Puppet Agent Health Checks [\#12](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/12) ([MartyEwings](https://github.com/MartyEwings))
- Adds a filesystem free method [\#9](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/9) ([jarretlavallee](https://github.com/jarretlavallee))
- Adds in PE node confinement types and more status checks [\#8](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/8) ([MartyEwings](https://github.com/MartyEwings))
- Adds additional indicators [\#5](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/5) ([MartyEwings](https://github.com/MartyEwings))
- \(maint\) Move service logic to a module [\#3](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/3) ([jarretlavallee](https://github.com/jarretlavallee))

### Fixed

- \(fix\) Do not filter on Undef [\#10](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/10) ([jarretlavallee](https://github.com/jarretlavallee))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
