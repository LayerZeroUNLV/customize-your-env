#!/usr/bin/env bash
# Copies the workshop Ghostty + Starship configs into place on mac or linux
# Existing configs get backed up with a timestamp, nothing is deleted
# Usage: ./scripts/install.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

log() { printf '\033[1;35m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$1" >&2; }

# Copy src to dest, backing up whatever is already there
install_file() {
  local src="$1" dest="$2"
  if [[ ! -f "$src" ]]; then
    warn "Missing $src, is the repo cloned fully?"
    return 1
  fi
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" ]]; then
    cp "$dest" "$dest.bak-$TIMESTAMP"
    log "Backed up $dest -> $dest.bak-$TIMESTAMP"
  fi
  cp "$src" "$dest"
  log "Installed $dest"
}

# Add the starship init line to the shell rc file if it is not there yet
hook_starship() {
  local shell_name rc_file init_line
  shell_name="$(basename "${SHELL:-bash}")"
  case "$shell_name" in
  bash)
    rc_file="$HOME/.bashrc"
    init_line='eval "$(starship init bash)"'
    ;;
  zsh)
    rc_file="$HOME/.zshrc"
    init_line='eval "$(starship init zsh)"'
    ;;
  fish)
    rc_file="$CONFIG_HOME/fish/config.fish"
    init_line='starship init fish | source'
    ;;
  *)
    warn "Unknown shell '$shell_name', add the starship init line yourself: https://starship.rs/#step-2-set-up-your-shell-to-use-starship"
    return 0
    ;;
  esac
  mkdir -p "$(dirname "$rc_file")"
  touch "$rc_file"
  if grep -qF "starship init" "$rc_file"; then
    log "Starship already hooked in $rc_file"
    return 0
  fi
  printf '\n# Starship prompt\n%s\n' "$init_line" >>"$rc_file"
  log "Added starship init to $rc_file"
}

main() {
  install_file "$REPO_DIR/ghostty/config.ghostty" "$CONFIG_HOME/ghostty/config.ghostty"
  install_file "$REPO_DIR/starship/starship.toml" "$CONFIG_HOME/starship.toml"

  if ! command -v starship >/dev/null 2>&1; then
    warn "starship is not installed yet, see the README install step, then rerun this"
    return 0
  fi
  hook_starship

  if ! command -v ghostty >/dev/null 2>&1; then
    warn "ghostty is not installed yet, the config is in place for when it is"
  fi
  log "Done! Open a new Ghostty window to see it"
}

main "$@"
