#!/usr/bin/env bash
# Make k9s always open on ALL namespaces for the current kube context.
#
# k9s saves the last-used namespace on exit, so quitting while on "default"
# keeps resetting the landing namespace. This sets the context's k9s config to
# "all" and marks the file read-only so k9s cannot overwrite it.
#
# Usage:
#   ./lock-all-ns.sh            lock the current context to all namespaces
#   ./lock-all-ns.sh --unlock   restore write access (k9s resumes remembering)
#
# Quit k9s before running — the file must not be mid-write.

set -Eeuo pipefail

unlock=false
case "${1:-}" in
    --unlock|-u) unlock=true ;;
    -h|--help) sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    "") ;;
    *) printf 'Unknown argument: %s (try --help)\n' "$1" >&2; exit 2 ;;
esac

ctx="$(kubectl config current-context 2>/dev/null)" || {
    printf 'Could not read current kube context (is kubectl configured?)\n' >&2
    exit 1
}

# k9s stores per-context config under one of these data dirs (XDG on Linux,
# Application Support on macOS). Search both for this context's config.yaml.
search_dirs=(
    "${XDG_DATA_HOME:-$HOME/.local/share}/k9s/clusters"
    "$HOME/Library/Application Support/k9s/clusters"
)

cfg=""
for dir in "${search_dirs[@]}"; do
    [[ -d "$dir" ]] || continue
    cfg="$(find "$dir" -path "*/$ctx/config.yaml" 2>/dev/null | head -1)"
    [[ -n "$cfg" ]] && break
done

if [[ -z "$cfg" ]]; then
    printf 'No k9s config for context "%s".\n' "$ctx" >&2
    printf 'Run k9s once for this context and quit, then re-run this script.\n' >&2
    exit 1
fi

if $unlock; then
    chmod u+w "$cfg"
    printf 'Unlocked: %s\n' "$cfg"
    printf 'k9s will now remember the last-used namespace again.\n'
    exit 0
fi

chmod u+w "$cfg"
# Portable in-place edit: write to a temp file, then move it back.
tmp="$(mktemp)"
sed -e 's/active: default/active: all/' \
    -e 's#active: v1/pods default#active: v1/pods all#' \
    "$cfg" > "$tmp"
cat "$tmp" > "$cfg"
rm -f "$tmp"
chmod a-w "$cfg"

printf 'Locked context "%s" to all namespaces:\n' "$ctx"
grep 'active:' "$cfg"
printf '\nOpen k9s — it now lands on all namespaces. Undo with: %s --unlock\n' "$0"
