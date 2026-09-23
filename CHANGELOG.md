# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `pwgen16` function — generates a cryptographically secure 16-character password.

### Changed
- Split `bashrc.script` into `bashrc.script` and `bashrc.logging`.
- Remove function exports.

## [0.1.0] - 2026-09-16

### Added
- `dc` shell function with subcommands for Docker container management:
  - `dc ls` — list containers by name.
  - `dc ns` — enter a container namespace and execute a command via `nsenter`.
  - `dc br|bridge` — print the bridge interface name for a Docker network.
  - `dc logf` — save container logs to a file (with `-o`/`--tee`, stdin mode, docker-native options pass-through).
- `cert-list` and `cert-info` functions for inspecting X.509 certificates.
- `install_docker.sh` script for installing Docker Engine on Ubuntu.
- `ip-to-mac` and `wnping` helper scripts in `bin/`.
- Command completions in `bashrc.complete`.
- `.gitconfig` template with `gitconfig.common` and `gitconfig.aliases`.
- `.tmux.conf` configuration.
- `bashrc.user.template` for personal user settings.

### Changed
- Restructured the repository into dedicated config files (`bashrc.common`, `bashrc.aliases`, `bashrc.script`, `bashrc.complete`).
- Refreshed bash color scheme (tput-based `SF_*` variables).
- Fixed invalid `PS1` so bash no longer fails to set the cursor position when selecting the previous command.

### Fixed
- `ip-to-mac` script bug.

[Unreleased]: https://github.com/DK6v/.env/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/DK6v/.env/releases/tag/v0.1.0