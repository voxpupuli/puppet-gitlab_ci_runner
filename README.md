# Gitlab-CI runner module for Puppet

[![Build Status](https://github.com/voxpupuli/puppet-gitlab_ci_runner/workflows/CI/badge.svg)](https://github.com/voxpupuli/puppet-gitlab_ci_runner/actions?query=workflow%3ACI)
[![Release](https://github.com/voxpupuli/puppet-gitlab_ci_runner/actions/workflows/release.yml/badge.svg)](https://github.com/voxpupuli/puppet-gitlab_ci_runner/actions/workflows/release.yml)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/gitlab_ci_runner.svg)](https://forge.puppetlabs.com/puppet/gitlab_ci_runner)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/gitlab_ci_runner.svg)](https://forge.puppetlabs.com/puppet/gitlab_ci_runner)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/gitlab_ci_runner.svg)](https://forge.puppetlabs.com/puppet/gitlab_ci_runner)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/gitlab_ci_runner.svg)](https://forge.puppetlabs.com/puppet/gitlab_ci_runner)
[![puppetmodule.info docs](http://www.puppetmodule.info/images/badge.png)](http://www.puppetmodule.info/m/puppet-gitlab_ci_runner)
[![Apache-2 License](https://img.shields.io/github/license/voxpupuli/puppet-gitlab_ci_runner.svg)](LICENSE)

#### Table of Contents

1. [Overview](#overview)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Upgrading from version 3](#upgrading-from-version-3)
1. [License](#license)

## Overview

This module installs and configures the Gitlab CI Runner Package or nodes.

## Usage

Here is an example how to configure Gitlab CI runners using Hiera:

To use the Gitlab CI runners it is required to have the [puppetlabs/docker](https://forge.puppetlabs.com/puppetlabs/docker) module.

`$manage_docker` can be set to false if docker is managed externally.

```yaml
gitlab_ci_runner::concurrent: 4

gitlab_ci_runner::check_interval: 4

gitlab_ci_runner::metrics_server: "localhost:8888"

gitlab_ci_runner::manage_docker: true

gitlab_ci_runner::config_path: "/etc/gitlab-runner/config.toml"

gitlab_ci_runner::runners:
  test_runner1:{}
  test_runner2:{}
  test_runner3:
    url: "https://git.alternative.org/ci"
    registration-token: "abcdef1234567890"
    tag-list: "aws,docker,example-tag"
    ca_file: "/etc/pki/cert/foo.pem"

gitlab_ci_runner::runner_defaults:
  url: "https://git.example.com/ci"
  registration-token: "1234567890abcdef"
  executor: "docker"
  docker:
    image: "ubuntu:focal"
```

To unregister a specific runner you may use `ensure` param:

```yaml
gitlab_ci_runner::runners:
  test_runner1:{}
  test_runner2:{}
  test_runner3:
    url: "https://git.alternative.org/ci"
    registration-token: "abcdef1234567890"
    ensure: absent
```

## Upgrading from version 3

Version 4 of this module introduces some big changes.
Puppet 6 or above is now **required** as the module now makes use of [Deferred Functions](https://puppet.com/docs/puppet/6/deferring_functions.html) when registering a runner.

Previously the `gitlab_ci_runner::runner:config` was only used when a runner was registered.
The configuration was used as the arguments to the runner `register` command, which would write the configuration file after registering with the gitlab server.
Puppet did not manage this file directly.

The module now manages the configuration file properly.
That means, it's now possible to update most configuration settings *after* the initial registration, and more advanced configurations are supported.

:warning: When upgrading, your runners will be **re-registered**.

When upgrading to version 4 you may need to update some of your manifests accordingly.
For example:

```puppet
class { 'gitlab_ci_runner':
  # [...]
  runners => {
    'my_runner' => {
      'url'                => 'https://gitlab.com/ci',
      'registration-token' => 'abcdef1234567890',
      'docker-image'       => 'ubuntu:focal',
    },
  },
}
```

would need to be converted to:

```puppet
class { 'gitlab_ci_runner':
  # [...]
  runners => {
    'my_runner' => {
      'url'                => 'https://gitlab.com',
      'registration-token' => 'abcdef1234567890',
      'docker'             => {
        'image' => 'ubuntu:focal',
      },
    },
  },
}
```

Configuration keys that are specific to registration, (such as `registration-token`, `run_untagged` etc.) are **not** written to the runner's configuration file, but are automatically extracted and used during registration only.
Changing these after registration has no affect.

## Limitations

The Gitlab CI runner installation is at the moment only tested on:
* CentOS 7/8
* Debian 10/11
* Ubuntu 18.04/20.04/22.04

For the current list of tested and support operating systems, please checkout the metadata.json file.

It is currently not possible to alter registration specific configuration settings after a runner is registered.

## License

[lib/puppet_x/gitlab/dumper.rb](lib/puppet_x/gitlab/dumper.rb) is licensed under MIT. All other code is licensed under Apache 2.0.
