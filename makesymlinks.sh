#!/usr/bin/env bash
# Link this checkout's configuration files into the current user's home
# directory. Existing files are moved to a timestamped backup directory.

set -Eeuo pipefail

dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
backup_dir="${DOTFILES_BACKUP_DIR:-$HOME/dotfiles_old/$(date +%Y%m%d-%H%M%S)}"

case "$(uname -s)" in
    Linux) platform_dir="linux" ;;
    Darwin) platform_dir="mac" ;;
    *)
        printf 'Unsupported operating system: %s\n' "$(uname -s)" >&2
        exit 1
        ;;
esac

link_file() {
    local source=$1 destination=$2

    if [[ -e "$destination" || -L "$destination" ]]; then
        if [[ "$destination" -ef "$source" ]]; then
            printf 'Already linked: %s\n' "$destination"
            return
        fi

        mkdir -p "$backup_dir"
        mv "$destination" "$backup_dir/$(basename "$destination")"
        printf 'Backed up %s to %s\n' "$destination" "$backup_dir"
    fi

    mkdir -p "$(dirname "$destination")"
    ln -s "$source" "$destination"
    printf 'Linked %s -> %s\n' "$destination" "$source"
}

for file in tmux.conf bashrc zshrc; do
    link_file "$dotfiles_dir/$platform_dir/$file" "$HOME/.$file"
done

for file in vimrc gitconfig zsh_plugins; do
    link_file "$dotfiles_dir/global/$file" "$HOME/.$file"
done

link_file "$dotfiles_dir/$platform_dir/config.fish" "$HOME/.config/fish/config.fish"
link_file "$dotfiles_dir/global/vimrc" "$HOME/.config/nvim/init.vim"
