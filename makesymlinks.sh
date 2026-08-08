#!/usr/bin/env bash
# Symlink this checkout's configuration into $HOME.
#
# Each mapping is "repo_path -> home_path". Existing real files are moved to a
# timestamped backup dir before linking; correct links are left untouched, so
# the script is safe to re-run.
#
# Usage:
#   ./makesymlinks.sh            link everything for this OS
#   ./makesymlinks.sh --dry-run  show what would change, touch nothing
#   ./makesymlinks.sh -h         this help

set -Eeuo pipefail

dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
backup_dir="${DOTFILES_BACKUP_DIR:-$HOME/dotfiles_old/$(date +%Y%m%d-%H%M%S)}"
dry_run=false

case "${1:-}" in
    -n|--dry-run) dry_run=true ;;
    -h|--help) sed -n '2,11p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    "") ;;
    *) printf 'Unknown argument: %s (try --help)\n' "$1" >&2; exit 2 ;;
esac

case "$(uname -s)" in
    Linux)  platform="linux" ;;
    Darwin) platform="mac" ;;
    *) printf 'Unsupported operating system: %s\n' "$(uname -s)" >&2; exit 1 ;;
esac

# Terminal colors (only when stdout is a tty).
if [[ -t 1 ]]; then
    c_ok=$'\e[32m'; c_skip=$'\e[2m'; c_warn=$'\e[33m'; c_reset=$'\e[0m'
else
    c_ok=""; c_skip=""; c_warn=""; c_reset=""
fi

# Mappings: "repo-relative source : $HOME-relative destination".
# $platform expands to linux/mac so per-OS files share one table.
links=(
    "$platform/tmux.conf         : .tmux.conf"
    "$platform/bashrc            : .bashrc"
    "$platform/zshrc             : .zshrc"
    "$platform/config.fish       : .config/fish/config.fish"
    "global/vimrc                : .vimrc"
    "global/vimrc                : .config/nvim/init.vim"
    "global/gitconfig            : .gitconfig"
    "global/zsh_plugins          : .zsh_plugins"
    "global/k9s/config.yaml      : .config/k9s/config.yaml"
    "global/k9s/views.yaml       : .config/k9s/views.yaml"
)

linked=0 skipped=0 backed_up=0

link_file() {
    local source="$dotfiles_dir/$1" destination="$HOME/$2"

    if [[ ! -e "$source" ]]; then
        printf '%smissing source, skipping: %s%s\n' "$c_warn" "$1" "$c_reset" >&2
        return
    fi

    if [[ "$destination" -ef "$source" ]]; then
        printf '%s  ok  %s%s\n' "$c_skip" "$2" "$c_reset"
        skipped=$((skipped+1)); return
    fi

    if $dry_run; then
        printf '%s plan %s -> %s%s\n' "$c_ok" "$2" "$1" "$c_reset"
        linked=$((linked+1)); return
    fi

    if [[ -e "$destination" || -L "$destination" ]]; then
        mkdir -p "$backup_dir"
        mv "$destination" "$backup_dir/"
        printf '%s back %s -> %s%s\n' "$c_warn" "$2" "$backup_dir" "$c_reset"
        backed_up=$((backed_up+1))
    fi

    mkdir -p "$(dirname "$destination")"
    ln -s "$source" "$destination"
    printf '%s link %s -> %s%s\n' "$c_ok" "$2" "$1" "$c_reset"
    linked=$((linked+1))
}

printf 'Platform: %s   Dry run: %s\n\n' "$platform" "$dry_run"

for entry in "${links[@]}"; do
    src="${entry%%:*}"; dst="${entry##*:}"
    # trim the alignment whitespace
    link_file "${src// /}" "${dst// /}"
done

printf '\nDone: %d linked, %d already ok, %d backed up.\n' "$linked" "$skipped" "$backed_up"

# Best-effort: pin k9s to all namespaces for the current kube context. This is
# per-cluster state (not a symlink), so it can only run once k9s has a config
# for the context. Never fails the overall run.
lock_k9s() {
    [[ -x "$dotfiles_dir/global/k9s/lock-all-ns.sh" ]] || return 0
    command -v kubectl >/dev/null 2>&1 || return 0
    if $dry_run; then
        printf '\n%s plan k9s: pin current context to all namespaces%s\n' "$c_ok" "$c_reset"
        return 0
    fi
    printf '\n'
    "$dotfiles_dir/global/k9s/lock-all-ns.sh" || \
        printf '%s(k9s all-namespace pin skipped — run global/k9s/lock-all-ns.sh after k9s has used the context)%s\n' "$c_skip" "$c_reset"
}
lock_k9s

$dry_run && printf 'Dry run — nothing changed.\n'
exit 0
