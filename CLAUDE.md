# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles repo for `zsh`/`bash`, `vim`, and `tmux`, shared across macOS and Linux machines. There is no
build/test/lint tooling — changes are verified by sourcing the shell config or opening vim/tmux.

## Installation flow

`setup.sh <macos|linux>` is the entry point:

1. Clones Vundle (`~/.vim/bundle/Vundle.vim`) and, on first run, installs oh-my-zsh plus the
   `mkgilbert` theme and `zsh-syntax-highlighting` plugin.
2. Picks `tmux.conf` or `tmux.conf.old` depending on the installed tmux version (`< 2.1` uses the old config).
3. Symlinks `tmux.conf`, `bashrc`, `vimrc`, `zshrc`, `gitignore` from the repo root to `~/.<name>` (skips a target
   that's already a symlink; moves an existing real file aside to `.original` first).
4. On macOS, also symlinks everything under `macos/hammerspoon/` to `~/.hammerspoon/`.
5. Sets `git config --global core.excludesfile` to the symlinked `~/.gitignore`.
6. Installs Eternal Terminal (`et`) via the OS-appropriate package manager.
7. Installs Rust via `rustup` (skipped if `cargo` is already present), then installs `cargo-binstall`, `fd-find`,
   and `ripgrep` via `cargo`/`cargo binstall` (each skipped if already installed).
8. Installs Node.js >= 24 (via NodeSource on Ubuntu/Debian, Homebrew on macOS) if not already present, then
   installs the `claude` CLI and `@opengsd/gsd-core` (Claude Code's "Git. Ship. Done." skill/command set) globally.
   Skipped if `~/.claude/gsd-core` already exists.
9. Installs `herdr` (skipped if already on `PATH`) — on macOS via Homebrew, including a fixup for herdr's
   background `brew services` launchd agent, which doesn't inherit Homebrew's `PATH` by default and so
   can't find `node`/`python`/etc. when plugins shell out to them. Linux has no automatic install path yet
   and just prints manual install instructions. Then symlinks `config/herdr/config.toml` to
   `~/.config/herdr/config.toml` and `config/herdr/plugins/cloudmanic.herdr-plus/` to
   `~/.config/herdr/plugins/config/cloudmanic.herdr-plus` (same skip-if-symlinked /
   move-existing-to-`.original` behavior as the other symlink steps), then installs herdr's plugins
   (`herdr plugin install <owner>/<repo>`, skipped per-plugin if already listed by `herdr plugin list`)
   — this step no-ops if `herdr` isn't on `PATH`.

Re-running `setup.sh` is safe/idempotent for the symlink step; it will not clobber unrelated existing files.

## Machine-specific config split

`zshrc` and `bashrc` at the repo root are the shared entry points that get symlinked to `~/.zshrc` / `~/.bashrc`.
Each one resolves its own symlink target at runtime (walks `readlink` until it's not a symlink) to find the real
`REPODIR`, detects OS via `uname` (`Darwin` → `macos`, else `linux`), and sources the matching
`linux/{zshrc,bashrc}` or `macos/{zshrc,bashrc}` file from that same repo checkout.

This means: shared settings (history options, `PATH`, pyenv, starship prompt, ansible vars, the `clush` noglob
alias, Claude Code's `NODE_EXTRA_CA_CERTS`) live in the top-level `zshrc`/`bashrc`. OS-specific bits (colored `ls`
aliases, `LS_COLORS`/`LSCOLORS`) live in `linux/` or `macos/`. When adding a new setting, put it in the top-level
file unless it's genuinely OS-dependent, and note the ordering constraint below.

**Ordering constraint:** in `zshrc`, `eval "$(starship init zsh)"` must remain the very last line for shell
startup performance — don't add lines after it.

## vim

`vimrc` uses Vundle (`vundle#begin`/`vundle#end`) for plugin management — plugins are declared as `Plugin '...'`
lines between those calls, not installed via a package manager. After editing the plugin list, the user must run
`:PluginInstall` from inside vim (setup.sh does not do this automatically). `linux/vim_install.sh` is a standalone
root/sudo script for building vim from source with extra interpreters on RHEL/CentOS-family systems (`yum`); it's
unrelated to the Vundle plugin list and only needed if the system vim is too old.

## Adding a new dotfile to be symlinked

If you add a new file that should be installed to `$HOME`, add it to the `for f in ...` loop in `setup.sh` — files
aren't auto-discovered. Nested-directory configs (e.g. `macos/hammerspoon/`, `config/herdr/`) instead get their own
dedicated symlink block in `setup.sh`, following the same skip-if-symlinked / move-existing-to-`.original` pattern.
