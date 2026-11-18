#!/usr/bin/env bash
# Puts your Ghostty + Starship configs back to how they were before install.sh
# Uses the record install.sh made on its first run, so it restores your old
# config or removes the workshop one if you had none. Current files are kept
# as *.reset-<timestamp>
# Usage: ./scripts/reset.sh
set -euo pipefail

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
HOOK_COMMENT="# Starship prompt"

log() { printf '\033[1;35m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$1" >&2; }

# Restore one config file to its pre-workshop state
reset_file() {
  local dest="$1"
  local has_record=false
  if [[ -e "$dest.original" || -e "$dest.original-none" ]]; then
    has_record=true
  fi
  if [[ "$has_record" == false ]]; then
    if [[ -e "$dest" ]]; then
      warn "No install record for $dest, leaving it alone. Older backups (if any) are at $dest.bak-*"
    fi
    return 0
  fi
  # Keep whatever you have now in case you want your tweaks back
  if [[ -e "$dest" ]]; then
    cp "$dest" "$dest.reset-$TIMESTAMP"
    log "Saved current $dest -> $dest.reset-$TIMESTAMP"
  fi
  if [[ -e "$dest.original" ]]; then
    mv "$dest.original" "$dest"
    log "Restored your original $dest"
    return 0
  fi
  rm -f "$dest" "$dest.original-none"
  log "Removed $dest, you had no config there before the workshop"
}

# Remove the two lines install.sh appended to an rc file
unhook_starship() {
  local rc_file="$1" tmp_file
  if [[ ! -f "$rc_file" ]] || ! grep -qxF "$HOOK_COMMENT" "$rc_file"; then
    return 0
  fi
  cp "$rc_file" "$rc_file.reset-$TIMESTAMP"
  tmp_file="$(mktemp)"
  # Skip the hook comment and the starship init line right after it
  awk -v marker="$HOOK_COMMENT" '
    pending_blank && $0 != marker { print ""; pending_blank = 0 }
    $0 == "" { pending_blank = 1; next }
    $0 == marker { pending_blank = 0; skip = 1; next }
    skip && /starship init/ { skip = 0; next }
    { skip = 0; print }
    END { if (pending_blank) print "" }
  ' "$rc_file" >"$tmp_file"
  cat "$tmp_file" >"$rc_file"
  rm -f "$tmp_file"
  log "Removed the starship hook from $rc_file (old copy at $rc_file.reset-$TIMESTAMP)"
}

main() {
  reset_file "$CONFIG_HOME/ghostty/config.ghostty"
  reset_file "$CONFIG_HOME/starship.toml"

  unhook_starship "$HOME/.bashrc"
  unhook_starship "$HOME/.zshrc"
  unhook_starship "$CONFIG_HOME/fish/config.fish"

  log "Done! Open a new terminal window to see the original look"
  log "Fonts and installed apps were left alone, uninstall those yourself if you want"
}

main "$@"
