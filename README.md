# User Environment

This repository contains a set of configuration files for setting up a user environment on Unix-like systems. It allows you to centrally manage shell (`bash`) settings, aliases, environment variables, and custom scripts.

## Repository Structure

- **`bashrc.common`** – The main `bash` configuration file, sourced from your primary `.bashrc`. Contains common settings such as `PATH` adjustments, shell options, and it sources other configuration files.
- **`bashrc.aliases`** – A dedicated file for all shell aliases (e.g., `ll`, `gs`, `dc` for Docker containers). This keeps aliases organized and separate from other settings.
- **`bashrc.script`** – Configuration for non-interactive shells (scripts). Optimizes `bash` behavior when running scripts, for instance, by managing colored output.
- **`bashrc.user.template`** – A template for personal user settings. It's recommended to copy this to `~/.env/bashrc.user` and edit it for your own needs, keeping it separate from the shared configuration.
- **`gitconfig.common`** – Common `git` settings, including preferred editor, formatting options, and other global parameters.
- **`gitconfig.aliases`** – A collection of useful `git` aliases (e.g., `co` for `checkout`, `br` for `branch`).

## Installation

1.  Clone the repository into your home directory:
    ```bash
    git clone https://github.com/DK6v/.env ~/.env
    ```

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

4.  Reload your shell configuration:
    ```bash
    source ~/.bashrc
    ```

## License

This project is distributed under the [MIT License](https://choosealicense.com/licenses/mit/).
