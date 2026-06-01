# Unitial

Automatically initialize the environment for Unix-like operating systems!

## Introduction

Unitial is a shell scripts and a collection of configurations designed to set up a productive environment for Unix-like operating systems. Although not fully tested, it should work on FreeBSD, most Linux distributions, and macOS. Feel free to fork, contribute via pull requests, and provide feedback, but please retain the author information. Questions and suggestions are welcome.

## Requirements

- FreeBSD: No additional requirements; please use the built-in `fetch` command.
- Other Unix environments: Ensure `curl` or `wget` is installed so that the installation script can download other files properly.

## Installation

One-line bootstrap (no git required):

```sh
curl -Lo- https://github.com/LeaYeh/Unitial/raw/master/setup.sh | bash
```

With `wget`:

```sh
wget -O- https://github.com/LeaYeh/Unitial/raw/master/setup.sh | bash
```

FreeBSD (no `curl`/`wget`):

```sh
fetch -o- https://github.com/LeaYeh/Unitial/raw/master/setup.sh | bash
```

If you have git and want symlinks to the live repo instead of downloaded copies:

```sh
git clone https://github.com/LeaYeh/Unitial.git ~/unitial
UNITIAL_DIR=~/unitial bash ~/unitial/setup.sh
```

The setup script will also clone [LeaYeh/skills](https://github.com/LeaYeh/skills) to `~/skills` and install `~/.local/bin/update-claude` for day-to-day updates.

## Updating Claude Code configuration

After the initial setup, run this on any machine to pull the latest Claude settings, skills, and commands:

```sh
update-claude
```

To also update Unitial at the same time:

```sh
UNITIAL_DIR=~/unitial update-claude
# or
update-claude --unitial-dir ~/unitial
```

## What's in it?

- Shell configurations (Bash, tcsh, csh, zsh):
  - Auto completion
  - Useful aliases
  - Keymap issue fixes for many users (note: BASH is the primary shell, and zsh is used less often, so bash features are more comprehensive)
- Vim: Useful settings, status bar, and comfortable color scheme
- Git: Helpful aliases and settings, gitignore (global), auto-completion, diff-highlight
- SSH: Valuable settings, including optimization for X11 forwarding, TCPKeepalive, compression, and multiplexing!
- irssi: Connection info for OFTC and Freenode, channel config example
- tmux: Informative status bar including average load, color adjustment
- Others:
  - aria2c: Optimized download settings for improved performance and user experience
  - wget: Enhanced download reliability, user agent configuration, and retry options
  - curl: Improved connection handling, user agent customization, and retry strategies
  - tig: Personalized colors and line graphics for better readability
  - w3m: Tailored colors and appearance for an enhanced browsing experience
  - php_cs: Custom PHP-CS-Fixer rules for consistent coding style
  - markdownlint: Configured Markdown linting rules for better writing quality
  - editorconfig: Consistent coding styles across different file types
  - lftp: Debugging options and user agent customization for better file transfers
  - gtab: Fine-tuned input method settings for efficient text input
  - inputrc: User-friendly keybindings for readline
  - xinputrc: Input method settings (commented out by default) for potential customization
  - hadolint: Linter rules for Dockerfiles
  - Claude Code: Global preferences (CLAUDE.md) and settings (settings.json) for Claude Code CLI
