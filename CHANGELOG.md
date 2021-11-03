# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v4.1.0](https://github.com/voxpupuli/puppet-gitlab_ci_runner/tree/v4.1.0) (2021-11-04)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab_ci_runner/compare/v4.0.0...v4.1.0)

**Implemented enhancements:**

- Make session\_server section configurable [\#132](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/132) ([baurmatt](https://github.com/baurmatt))

**Merged pull requests:**

- Add puppet-lint-param-docs [\#121](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/121) ([bastelfreak](https://github.com/bastelfreak))

## [v4.0.0](https://github.com/voxpupuli/puppet-gitlab_ci_runner/tree/v4.0.0) (2021-08-26)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab_ci_runner/compare/v3.0.0...v4.0.0)

Version 4.0.0 is a new major release of this module.  It has many improvements but also significant breaking changes that you should read about and test before deploying into a production environment.  Specifically Puppet 6 is required, your code will probably need updating and existing runners will reregister.
The [README ](https://github.com/voxpupuli/puppet-gitlab_ci_runner/blob/383db3524e7cd3eac13755da251ef1871290f941/README.md#upgrading-from-version-3)has further details.

Huge thanks to all our contributors and especially to [Matthias Baur](https://github.com/baurmatt) for his excellent contributions to this release.

**Breaking changes:**

- Drop RHEL/CentOS 6 and Amazon Linux Support [\#118](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/118)
- Deprecate support for Debian 8 and Ubuntu 16.04 \(and add support for Ubuntu 20.04\) [\#114](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/114) ([alexjfisher](https://github.com/alexjfisher))
- Add support for registration by leveraging a "Deferred" function [\#107](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/107) ([baurmatt](https://github.com/baurmatt))
- Move to concat for config.toml [\#75](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/75) ([baurmatt](https://github.com/baurmatt))

**Implemented enhancements:**

- Support Puppet 7 [\#116](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/116) ([alexjfisher](https://github.com/alexjfisher))
- Add runner registration proxy support [\#109](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/109) ([alexjfisher](https://github.com/alexjfisher))
- Allow `hkp://` style URLs for `repo_keyserver` URL [\#102](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/102) ([hp197](https://github.com/hp197))

**Fixed bugs:**

- Fix runner unregistering [\#111](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/111) ([alexjfisher](https://github.com/alexjfisher))
- Fix unregistering runner with `ensure => absent` [\#110](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/110) ([alexjfisher](https://github.com/alexjfisher))

**Closed issues:**

- Get acceptance tests setup and running [\#20](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/20)

**Merged pull requests:**

- Allow up-to-date dependencies [\#117](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/117) ([smortex](https://github.com/smortex))
- Update README with upgrade information [\#115](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/115) ([alexjfisher](https://github.com/alexjfisher))
- Update module dependencies [\#112](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/112) ([alexjfisher](https://github.com/alexjfisher))
- Fix typos in README.md [\#94](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/94) ([nikitasg](https://github.com/nikitasg))

## [v3.0.0](https://github.com/voxpupuli/puppet-gitlab_ci_runner/tree/v3.0.0) (2020-09-15)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab_ci_runner/compare/v2.1.0...v3.0.0)

**Breaking changes:**

- Make manage\_docker optional and include the docker module if used [\#80](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/80) ([baurmatt](https://github.com/baurmatt))

**Implemented enhancements:**

- Allow management of check\_interval config setting [\#91](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/91) ([tuxmea](https://github.com/tuxmea))
- Add support for CentOS 8, Debian 10 [\#87](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/87) ([dhoppe](https://github.com/dhoppe))

**Merged pull requests:**

- Fix CI problems [\#89](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/89) ([carljohnstone](https://github.com/carljohnstone))
- Switch from Ubuntu Trusty to Ubuntu Focal [\#88](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/88) ([carljohnstone](https://github.com/carljohnstone))
- Use voxpupuli-acceptance [\#83](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/83) ([ekohl](https://github.com/ekohl))

## [v2.1.0](https://github.com/voxpupuli/puppet-gitlab_ci_runner/tree/v2.1.0) (2020-04-07)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab_ci_runner/compare/v2.0.0...v2.1.0)

**Implemented enhancements:**

- Use new gitlab gpg keys for package management [\#84](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/84) ([dhoppe](https://github.com/dhoppe))

**Closed issues:**

- Release new version [\#58](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/58)

## [v2.0.0](https://github.com/voxpupuli/puppet-gitlab_ci_runner/tree/v2.0.0) (2020-02-06)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab_ci_runner/compare/v1.0.0...v2.0.0)

**Breaking changes:**

- Completely refactor gitlab\_ci\_runner::runner [\#74](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/74) ([baurmatt](https://github.com/baurmatt))
- drop Ubuntu support [\#60](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/60) ([bastelfreak](https://github.com/bastelfreak))
- modulesync 2.7.0 and drop puppet 4 [\#39](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/39) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Module should manage build\_dir and cache\_dir [\#33](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/33)
- Add bolt task to register/unregister a runner [\#73](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/73) ([baurmatt](https://github.com/baurmatt))
- Add Amazon Linux support \(RedHat OS Family\) [\#70](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/70) ([bFekete](https://github.com/bFekete))
- Add listen\_address parameter [\#65](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/65) ([baurmatt](https://github.com/baurmatt))
- Add custom repo [\#48](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/48) ([lupintrd](https://github.com/lupintrd))
- Add support for current releases [\#41](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/41) ([dhoppe](https://github.com/dhoppe))
- Fix xz dependency on RedHat systems [\#40](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/40) ([smortex](https://github.com/smortex))

**Fixed bugs:**

- Multiple tags in tag-list are ignored only last is respected [\#37](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/37)
- The package `xz-utils` is `xz` on CentOS [\#25](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/25)
- Fix bugs which got introduced by to runner.pp refactoring [\#76](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/76) ([baurmatt](https://github.com/baurmatt))
- Fix runner name in unregister command [\#57](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/57) ([dcasella](https://github.com/dcasella))
-  Use '=' to avoid errors while joining cmd options+values [\#31](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/31) ([ajcollett](https://github.com/ajcollett))

**Closed issues:**

- registration\_token containing undescore gets modified [\#61](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/61)
- /etc/gitlab-runner/config.toml must exist [\#35](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/35)
- Metrics server and Session listen address' [\#26](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/26)

**Merged pull requests:**

- Extract resources out of init.pp [\#72](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/72) ([baurmatt](https://github.com/baurmatt))
- Allow puppetlabs/stdlib 6.x [\#71](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/71) ([dhoppe](https://github.com/dhoppe))
- Switch to puppet-strings for documentation [\#64](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/64) ([baurmatt](https://github.com/baurmatt))
- Use grep with --fixed-strings to avoid issues with some characters in the runner's names [\#63](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/63) ([Farfaday](https://github.com/Farfaday))
- Extend documentation in README with example tags [\#59](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/59) ([jacksgt](https://github.com/jacksgt))
- add limitations about the runner configurations [\#56](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/56) ([thde](https://github.com/thde))
- ensure config exists [\#53](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/53) ([thde](https://github.com/thde))
- Added suport for configuring sentry\_dsn [\#44](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/44) ([schewara](https://github.com/schewara))
- Allow ensure =\> "present" for runners [\#36](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/36) ([evhan](https://github.com/evhan))
- allow build\_dir and cache\_dir to be managed [\#34](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/34) ([slmagus](https://github.com/slmagus))

## [v1.0.0](https://github.com/voxpupuli/puppet-gitlab_ci_runner/tree/v1.0.0) (2018-11-21)

[Full Changelog](https://github.com/voxpupuli/puppet-gitlab_ci_runner/compare/a499e3dab7578847be6bba12baba63168b077bfa...v1.0.0)

This is the first release of `puppet/gitlab_ci_runner`.  The functionality in this module was previously part of [puppet/gitlab](https://github.com/voxpupuli/puppet-gitlab)

**Fixed bugs:**

- Fix \(un-\)registering runner with similar names [\#22](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/22) ([elkangaroo](https://github.com/elkangaroo))

**Closed issues:**

- Import cirunner code from voxpupuli/puppet-gitlab module [\#12](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/12)
- remove `apt` from dependencies  [\#4](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/4)
- Update license in metadata.json and add LiCENSE file [\#3](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/3)
- Update ruby version in Dockerfile [\#2](https://github.com/voxpupuli/puppet-gitlab_ci_runner/issues/2)

**Merged pull requests:**

- modulesync 2.1.0 and allow puppet 6.x [\#23](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/23) ([bastelfreak](https://github.com/bastelfreak))
- allow puppetlabs/stdlib 5.x [\#19](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/19) ([bastelfreak](https://github.com/bastelfreak))
- initial import of puppet code [\#13](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/13) ([LongLiveCHIEF](https://github.com/LongLiveCHIEF))
- remove apt from metadata.json dependencies [\#10](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/10) ([LongLiveCHIEF](https://github.com/LongLiveCHIEF))
- Update ruby version in dockerfile [\#8](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/8) ([LongLiveCHIEF](https://github.com/LongLiveCHIEF))
- fix module name in metadata.json [\#6](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/6) ([LongLiveCHIEF](https://github.com/LongLiveCHIEF))
- update licensing information [\#5](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/5) ([LongLiveCHIEF](https://github.com/LongLiveCHIEF))
- modulesync setup [\#1](https://github.com/voxpupuli/puppet-gitlab_ci_runner/pull/1) ([LongLiveCHIEF](https://github.com/LongLiveCHIEF))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
