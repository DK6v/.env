# User Environment

This repository contains a set of configuration files for setting up a user environment on Unix-like systems. It allows you to centrally manage shell (`bash`) settings, aliases, environment variables, and custom scripts.

## Repository Structure

- **`bashrc.common`** – The main `bash` configuration file, sourced from your primary `.bashrc`. Adds `bin/` to `PATH`, sets the prompt and sources the other configuration files.
- **`bashrc.logging`** – Color scheme (`SF_*` variables), result codes and logging functions (`log-info`, `log-warn`, `log-progress-*`, ...) filtered by `LOG_LEVEL`. Also sourced by the scripts in `bin/`.
- **`bashrc.aliases`** – Shell aliases (e.g., `ll`, `gs`, `ipt-rules`).
- **`bashrc.docker`** – A `docker` wrapper with extra commands: `docker container logf` (save logs to a file), `docker container ns` (run a command in container namespaces), `docker network br` (bridge interface name), and the `-1` option for `docker container ls` (names only). Run with `--help` for details.
- **`bashrc.certs`** – `cert-list` and `cert-info` functions for inspecting X.509 certificates.
- **`bashrc.script`** – Helper functions such as `pwgen16`.
- **`bashrc.complete.d/`** – Bash completions for `docker` (native completion plus the extra commands), `cert-*` and `tmux`.
- **`bashrc.user.template`** – A template for personal user settings. It's recommended to copy this to `~/.env/bashrc.user` and edit it for your own needs, keeping it separate from the shared configuration.
- **`bin/`** – Scripts: `gtls.sh` (list files by git status), `ip-to-mac`, `wnping` (`nping` wrapper), `install_docker.sh`.
- **`.gitconfig`** – A `~/.gitconfig` template that includes `gitconfig.common`.
- **`gitconfig.common`** – Common `git` settings, including preferred editor, diff/merge tool and other global parameters.
- **`gitconfig.aliases`** – A collection of useful `git` aliases (e.g., `co` for `checkout`, `br` for `branch`).
- **`.tmux.conf`** – `tmux` configuration (mouse, vi copy mode, plugins via TPM).
- **`version.env`** – The released version (`ENV_VERSION`), see `CHANGELOG.md`.

## Installation

### From a release (no git or GitHub account needed)

```bash
curl -fsSL https://raw.githubusercontent.com/DK6v/.env/main/install.sh | bash
```

This downloads the latest release archive into `~/.env`, adds it to `~/.bashrc` and creates `bashrc.user` from the template. Run the same command again to update. Options (pass them after `bash -s --`):

- `--version v0.1.0` – install a specific release;
- `--dir DIR` – install somewhere other than `~/.env`;
- `--archive FILE` – install from a downloaded archive (offline);
- `--no-bashrc` – do not touch `~/.bashrc`.

Local changes are safe on update. `install.sh` records the checksum of every installed file in `~/.env/.install-manifest`. If any file in `~/.env` was changed, removed or added, the whole directory is moved to `~/.env.<timestamp>` before the new release is installed. Otherwise it is simply replaced. Put personal settings in `bashrc.user`: it is carried over to the new installation.

### From git

1.  Clone the repository into your home directory:
    ```bash
    git clone https://github.com/DK6v/.env ~/.env
    ```
    Update with `git -C ~/.env pull`. `install.sh` does not update a git checkout.

2.  Add the following lines to the end of your `~/.bashrc` file to source the main configuration:
    ```bash
    # Common environment
    if [ -f ~/.env/bashrc.common ]; then
      . ~/.env/bashrc.common
    fi
    ```

3.  (Optional) Create and configure your personal settings file by copying the template:
    ```bash
    cp ~/.env/bashrc.user.template ~/.env/bashrc.user
    ```

### Optional

4.  (Optional) Use the `git` and `tmux` configuration:
    ```bash
    cp ~/.env/.gitconfig ~/.gitconfig      # then set user.name / user.email
    ln -s ~/.env/.tmux.conf ~/.tmux.conf
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    ```
    Inside `tmux`, press `prefix + I` to install the plugins.

5.  Reload your shell configuration:
    ```bash
    source ~/.bashrc
    ```

## License

This project is distributed under the [MIT License](https://choosealicense.com/licenses/mit/).
