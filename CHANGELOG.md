# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `install.sh` — installs or updates the environment from a GitHub release archive (no git or GitHub account needed); if files were changed locally, the previous installation is moved to `~/.env.<timestamp>`.
- `pwgen16` function — generates a cryptographically secure 16-character password.
- Command completions moved into `bashrc.complete.d` directory.
- Added `tmux` command completions.
- Release workflow checks that the tag matches `ENV_VERSION` in `version.env`.
- `docker` wrapper function with extra commands, completed together with the native docker completion:
  - `docker container logf` (was `dc logf`),
  - `docker container ns|namespace` (was `dc ns`),
  - `docker network br|bridge` (was `dc br`),
  - `-1` option for `docker container ls` — list container names only (was `dc ls`).

### Changed
- Split `bashrc.script` into `bashrc.script` and `bashrc.logging`.
- Remove function exports.
- `log-*-raw` functions filter by `LOG_LEVEL` the same way as other log functions.
- The repository root is no longer added to `PATH` (only `bin/`).

### Removed
- `dc` function and its completion; use `docker container ...` instead (`dc ls` -> `docker container ls -1`).

### Fixed
- `ip-to-mac` and `wnping` failed after function exports were removed.
- `wnping`: arguments with spaces, `-s` without a value, unknown `log-warning` call.
- `gtls.sh` handles file names with spaces and renamed files.
- `tmux` completion: global options with/without values, `display-message`, `confirm`.
- `SF_CLEAR` is defined for the tput color scheme; ascii scheme no longer embeds prompt-only `\[ \]`.
- Duplicate "Source file" message for `bashrc.user`.
- Release workflow: tag input is passed via environment instead of inline interpolation.

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