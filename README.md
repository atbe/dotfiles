# dotfiles

Personal shell, editor, Git, tmux, and fish configuration for Linux and
macOS. Shared configuration lives in `global`; platform-specific files live
in `linux` and `mac`.

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
