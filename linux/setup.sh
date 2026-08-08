#!/usr/bin/env bash
# Bootstrap the Linux configuration from this checkout.
#
# This script is safe to re-run: package installation, symlinks, and plugin
# checkouts are all idempotent. It intentionally configures only the current
# user; it does not change system-wide editor alternatives.

set -Eeuo pipefail

dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
antibody_version="${ANTIBODY_VERSION:-6.1.1}"
antibody_url="https://github.com/getantibody/antibody/releases/download/v${antibody_version}/antibody_Linux_x86_64.tar.gz"
scmpuff_version="0.7.0"

case "$(uname -m)" in
    x86_64) scmpuff_arch="amd64"; scmpuff_sha256="174c24e7aa672dbd6da97eb518f83482eefddceb7a483a40d297a11cb0cdb362" ;;
    aarch64|arm64) scmpuff_arch="arm64"; scmpuff_sha256="0b7dc2252eccefaec70aef9fe44a13261bab69e2bbd162399bd95ca8983ff502" ;;
    armv7l) scmpuff_arch="armv7"; scmpuff_sha256="7bec4ef29fc9f5c79a2200ab4f899ad336c5eb91c9eb8eaebb0209f7b43258f6" ;;
    *)
        printf 'Unsupported architecture for scmpuff: %s\n' "$(uname -m)" >&2
        exit 1
        ;;
esac
scmpuff_url="https://github.com/mroth/scmpuff/releases/download/v${scmpuff_version}/scmpuff_${scmpuff_version}_linux_${scmpuff_arch}.tar.gz"

require_command() {
    command -v "$1" >/dev/null 2>&1 || {
        printf 'Required command is unavailable after setup: %s\n' "$1" >&2
        exit 1
    }
}

clone_if_missing() {
    local repository=$1 destination=$2

    if [[ -d "$destination/.git" ]]; then
        return
    elif [[ -e "$destination" ]]; then
        printf 'Cannot install %s: %s exists but is not a Git checkout.\n' "$repository" "$destination" >&2
        return 1
    else
        git clone --depth 1 "$repository" "$destination"
    fi
}

install_antibody() {
    local temporary_dir archive binary

    if command -v antibody >/dev/null 2>&1; then
        return
    fi

    temporary_dir="$(mktemp -d)"
    archive="$temporary_dir/antibody.tar.gz"
    trap 'rm -rf "$temporary_dir"' RETURN
    curl --fail --location --silent --show-error "$antibody_url" --output "$archive"
    tar -xzf "$archive" -C "$temporary_dir"
    binary="$(find "$temporary_dir" -type f -name antibody -perm -u+x -print -quit)"
    [[ -n "$binary" ]] || {
        printf 'The Antibody archive did not contain an executable.\n' >&2
        return 1
    }

    mkdir -p "$HOME/.local/bin"
    install -m 0755 "$binary" "$HOME/.local/bin/antibody"
    trap - RETURN
    rm -rf "$temporary_dir"
}

install_scmpuff() {
    local temporary_dir archive binary

    if command -v scmpuff >/dev/null 2>&1; then
        return
    fi

    temporary_dir="$(mktemp -d)"
    archive="$temporary_dir/scmpuff.tar.gz"
    trap 'rm -rf "$temporary_dir"' RETURN
    curl --fail --location --silent --show-error "$scmpuff_url" --output "$archive"
    printf '%s  %s\n' "$scmpuff_sha256" "$archive" | sha256sum --check --status
    tar -xzf "$archive" -C "$temporary_dir"
    binary="$(find "$temporary_dir" -type f -name scmpuff -perm -u+x -print -quit)"
    [[ -n "$binary" ]] || {
        printf 'The scmpuff archive did not contain an executable.\n' >&2
        return 1
    }

    mkdir -p "$HOME/.local/bin"
    install -m 0755 "$binary" "$HOME/.local/bin/scmpuff"
    trap - RETURN
    rm -rf "$temporary_dir"
}

printf '\n==> Installing Linux packages\n'
sudo apt-get update
sudo apt-get install --yes \
    autojump \
    curl \
    fish \
    fzf \
    gh \
    git \
    git-delta \
    git-lfs \
    irssi \
    nano \
    neovim \
    pandoc \
    tmux \
    tree \
    xclip \
    zsh

printf '\n==> Linking dotfiles\n'
"$dotfiles_dir/makesymlinks.sh"

printf '\n==> Installing Antibody and zsh plugins\n'
export PATH="$HOME/.local/bin:$PATH"
install_antibody
require_command antibody
antibody bundle < "$HOME/.zsh_plugins"

printf '\n==> Installing scmpuff\n'
install_scmpuff
require_command scmpuff

printf '\n==> Installing base16 shell\n'
clone_if_missing https://github.com/chriskempson/base16-shell.git "$HOME/.config/base16-shell"

printf '\n==> Installing tmux plugins\n'
clone_if_missing https://github.com/tmux-plugins/tpm.git "$HOME/.tmux/plugins/tpm"
# TPM's command-line installer reads the path from tmux's global environment.
# `run .../tpm` sets this during normal tmux startup; establish it here because
# the bootstrap intentionally runs before the first tmux session. On a fresh
# machine no tmux server exists yet and set-environment would fail, so keep a
# throwaway session alive for the duration of the install.
bootstrap_session_started=0
# A TERM unknown to this host (e.g. xterm-ghostty over ssh) makes tmux refuse
# to start; the bootstrap session doesn't need the real terminal anyway.
if ! infocmp "${TERM:-dumb}" >/dev/null 2>&1; then
    export TERM=xterm-256color
fi
if ! tmux has-session 2>/dev/null; then
    tmux new-session -d -s __dotfiles_bootstrap
    bootstrap_session_started=1
fi
tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.tmux/plugins/"
"$HOME/.tmux/plugins/tpm/bin/install_plugins"
if [[ "$bootstrap_session_started" == 1 ]]; then
    tmux kill-session -t __dotfiles_bootstrap 2>/dev/null || true
fi

printf '\n==> Installing Vim/Neovim plugins\n'
clone_if_missing https://github.com/VundleVim/Vundle.vim.git "$HOME/.vim/bundle/Vundle.vim"
nvim --headless '+PluginInstall' '+qall'

printf '\n==> Installing fish and fish plugins\n'
mkdir -p "$HOME/.config/fish/functions"
if [[ ! -f "$HOME/.config/fish/functions/fundle.fish" ]]; then
    curl --fail --location --silent --show-error \
        https://raw.githubusercontent.com/tuvistavie/fundle/master/functions/fundle.fish \
        --output "$HOME/.config/fish/functions/fundle.fish"
fi
fish -c 'fundle install'

printf '\n==> Setup complete. Start a new shell to load the configuration.\n'
