# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v1.0.0](https://github.com/puppetlabs/puppetlabs-pe_status_check/tree/v1.0.0) (2022-02-07)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-pe_status_check/compare/v0.2.0...v1.0.0)

### Changed

- Rename Module to pe\_status\_check [\#74](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/74) ([MartyEwings](https://github.com/MartyEwings))

### Added

- Improve documentation [\#69](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/69) ([MartyEwings](https://github.com/MartyEwings))
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

### UNCATEGORIZED PRS; LABEL THEM ON GITHUB

- \(SUP-2918\) Update S0039 to parse server access log [\#73](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/73) ([m0dular](https://github.com/m0dular))
- \(SUP-2945\) Updating S0004 to call the services API [\#68](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/68) ([jordi-garcia](https://github.com/jordi-garcia))
- \(maint\) Stop puppet agent runs during testing [\#67](https://github.com/puppetlabs/puppetlabs-pe_status_check/pull/67) ([jarretlavallee](https://github.com/jarretlavallee))

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
