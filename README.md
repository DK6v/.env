# Bash Environment

A portable `bash` environment for Linux: prompt, aliases, helper functions, completions and small scripts, installed into `~/.env` and loaded from `~/.bashrc`.

It is written for **bash 4+ only**. It relies on bash features such as associative arrays, `mapfile` and bash-completion, so it does not work in `zsh`, `fish` or plain `sh`.

## What you get

- A prompt with time, user, host and working directory, and logging helpers (`log-info`, `log-warn`, `log-progress-*`) controlled by `LOG_LEVEL`.
- Aliases for git, networking and the shell (`gs`, `gca`, `ipt-rules`, `dns-flush`, ...).
- A `docker` wrapper with extra commands, all available through tab completion:
  - `docker container logf` – save container logs to a file;
  - `docker container ns` – run a command inside container namespaces;
  - `docker network br` – print the bridge interface name of a network;
  - `docker container ls -1` – list container names only.
- `cert-list` / `cert-info` for X.509 certificates, `pwgen16` for passwords.
- Bash completions for `docker`, `tmux` and the functions above.
- Optional `git` and `tmux` configuration.

Run any extra command with `--help` for details.

## Installation

### From a release (no git or GitHub account needed)

```bash
curl -fsSL https://raw.githubusercontent.com/DK6v/.env/main/install.sh | bash
```

This downloads the latest release into `~/.env`, adds it to `~/.bashrc` and creates `~/.env/bashrc.user` from the template. Run the same command again to update. Options go after `bash -s --`:

- `--version v0.1.0` – install a specific release;
- `--dir DIR` – install somewhere other than `~/.env`;
- `--archive FILE` – install from a downloaded archive (offline);
- `--no-bashrc` – do not touch `~/.bashrc`.

Local changes are safe on update. If any file in `~/.env` was changed, removed or added, the whole directory is moved to `~/.env.<timestamp>` before the new release is installed.

### From git

```bash
git clone https://github.com/DK6v/.env ~/.env
cp ~/.env/bashrc.user.template ~/.env/bashrc.user
```

Then add the following lines to the end of `~/.bashrc`:

```bash
# Common environment
if [ -f ~/.env/bashrc.common ]; then
  . ~/.env/bashrc.common
fi
```

Update with `git -C ~/.env pull`. `install.sh` does not touch a git checkout.

### Personal settings

Put your own settings in `~/.env/bashrc.user`. It is loaded last, is not part of the repository, and is kept when you update.

### git and tmux (optional)

```bash
cp ~/.env/.gitconfig ~/.gitconfig      # then set user.name / user.email
ln -s ~/.env/.tmux.conf ~/.tmux.conf
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Inside `tmux`, press `prefix + I` to install the plugins.

Reload the shell with `source ~/.bashrc`.

## License

This project is distributed under the [MIT License](https://choosealicense.com/licenses/mit/).
