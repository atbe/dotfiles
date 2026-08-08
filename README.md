# dotfiles

Personal shell, editor, Git, tmux, fish, and k9s configuration for Linux and
macOS. Shared configuration lives in `global`; platform-specific files live
in `linux` and `mac`.

Run `./makesymlinks.sh` to link everything into `$HOME` (use `--dry-run` to
preview). The k9s config (mouse enabled, `NODE` column hidden, pods sorted by
age) lives in `global/k9s` and links to `~/.config/k9s`.

## Linux

From this checkout, run:

```sh
./linux/setup.sh
```

The bootstrap installs the packages used by the Linux configuration, creates
the home-directory symlinks (backing up conflicting files), and initializes
the zsh, tmux, Vim/Neovim, and fish plugin managers. It is safe to re-run.

## macOS

Install Homebrew first, then install the declared packages and extensions:

```sh
brew bundle --file=brew/Brewfile
./makesymlinks.sh
```
