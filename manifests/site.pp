require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $luser,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::home}/homebrew/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::luser}"
  ]
}

File {
  group => 'staff',
  owner => $luser
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => Class['git']
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx
  include mongodb


  include ruby::1_9_3

  # common, useful packages
  package {
    [
      'ag',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }

  # include some provided versions
  include nodejs::v0_10
  include nodejs::v0_8_8

  # install any arbitrary nodejs version
  nodejs { 'v0.10.1': }

  class { 'nodejs::global': version => 'v0.10.0' }

  # install some npm modules
  # Yeoman tools
  nodejs::module { 'yo': node_version => 'v0.10' }
  nodejs::module { 'grunt-cli': node_version => 'v0.10' }
  nodejs::module { 'bower': node_version => 'v0.10' }

  include phantomjs
}

require ruby::1_9_3_p194
# Set the global default ruby (auto-installs it if it can)
class { 'ruby::global':
  version => '1.9.3'
}

ruby::gem { "bundler for ${version}":
  gem     => 'bundler',
  ruby    => $version,
  version => '~> 1.2.0'
}

