# tmux clipboard over Mosh

This makes tmux mouse highlight/copy update the local macOS clipboard when the client connects with Mosh 1.4+.

## Why it needs an override

Mosh parses OSC 52 instead of acting as a raw byte stream. It rejects the empty clipboard selection target that tmux normally emits (`OSC 52 ;;…`). Force the standard clipboard target (`c`) in tmux's `Ms` capability.

`%p1` must remain in the capability. Although its expansion is intentionally empty at that position, tmux's `tparm` expansion fails when `%p2` is used without consuming `%p1`.

```tmux
set -s set-clipboard on
set -as terminal-overrides ",*:Ms=\E]52;c%p1%s;%p2%s\007"
set -g allow-passthrough on
```

Keep native tmux mouse handling enabled:

```tmux
set -g mouse on
```

Do not replace the `Ms` string with `Ms=\E]52;c;%p2%s\007`; tmux may log `could not expand Ms` and no clipboard sequence will be emitted.

## Apply without ending sessions

After updating the configuration file, apply the server options and then detach and reattach the client once. The `Ms` capability is determined when a client attaches.

```sh
tmux set -s set-clipboard on
tmux set -s terminal-overrides ',*:Ms=\E]52;c%p1%s;%p2%s\007'
tmux set -g allow-passthrough on
```

```sh
tmux detach-client -t /dev/ttysXXX
# In the mosh shell:
tmux attach -t <session>
```

Test in a plain shell pane: full-screen applications that capture mouse input do not trigger tmux copy mode. Both the Mosh client and `mosh-server` must be version 1.4.0 or newer.
