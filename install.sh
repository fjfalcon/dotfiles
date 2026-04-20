#!/usr/bin/env bash
# Idempotent dotfiles installer.
#
#   ./install.sh             create symlinks (existing files moved to backup/)
#   ./install.sh --packages  also pacman -S --needed packages.txt
#   ./install.sh --dry-run   print what would happen
#   ./install.sh --force     overwrite existing symlinks pointing elsewhere
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME:?HOME not set}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME_DIR/.config}"
BACKUP_DIR="$DOTFILES/backup/$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0
DO_PACKAGES=0
FORCE=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --packages) DO_PACKAGES=1 ;;
    --force) FORCE=1 ;;
    -h|--help)
      sed -n '2,8p' "$0"; exit 0 ;;
    *) echo "Unknown flag: $arg" >&2; exit 2 ;;
  esac
done

c_red()    { printf '\033[31m%s\033[0m' "$*"; }
c_green()  { printf '\033[32m%s\033[0m' "$*"; }
c_yellow() { printf '\033[33m%s\033[0m' "$*"; }
c_blue()   { printf '\033[34m%s\033[0m' "$*"; }
c_dim()    { printf '\033[2m%s\033[0m' "$*"; }

log()  { printf '%s %s\n' "$(c_blue '==>')" "$*"; }
warn() { printf '%s %s\n' "$(c_yellow 'warn:')" "$*" >&2; }
err()  { printf '%s %s\n' "$(c_red 'err:')" "$*" >&2; }

run() {
  if (( DRY_RUN )); then
    printf '  %s %s\n' "$(c_dim 'dry')" "$*"
  else
    "$@"
  fi
}

ensure_backup_dir() {
  [[ -d "$BACKUP_DIR" ]] && return
  run mkdir -p "$BACKUP_DIR"
}

# link <source-in-repo> <target-in-home>
link() {
  local src="$1" target="$2"
  local rel
  rel="${src#"$DOTFILES/"}"

  if [[ ! -e "$src" ]]; then
    warn "source missing: $rel"
    return
  fi

  # Already correct symlink?
  if [[ -L "$target" ]]; then
    local current
    current="$(readlink -f "$target" || true)"
    if [[ "$current" == "$src" ]]; then
      printf '  %s %s\n' "$(c_dim 'ok ')" "$target"
      return
    fi
    if (( ! FORCE )); then
      warn "$target -> $current (use --force to replace)"
      return
    fi
    ensure_backup_dir
    run mv "$target" "$BACKUP_DIR/"
  elif [[ -e "$target" ]]; then
    ensure_backup_dir
    run mv "$target" "$BACKUP_DIR/"
  fi

  run mkdir -p "$(dirname "$target")"
  run ln -s "$src" "$target"
  printf '  %s %s -> %s\n' "$(c_green 'link')" "$target" "$rel"
}

install_packages() {
  if ! command -v pacman >/dev/null 2>&1; then
    warn "pacman not found — skipping --packages"
    return
  fi
  log "installing missing packages from packages.txt"
  local pkgs
  # shellcheck disable=SC2002
  pkgs=$(grep -vE '^[[:space:]]*(#|$)' "$DOTFILES/packages.txt" | xargs)
  if (( DRY_RUN )); then
    printf '  %s sudo pacman -S --needed %s\n' "$(c_dim 'dry')" "$pkgs"
  else
    sudo pacman -S --needed -- $pkgs
  fi
}

main() {
  log "dotfiles: $DOTFILES"
  log "config:   $CONFIG_DIR"
  (( DRY_RUN )) && log "$(c_yellow 'DRY RUN — no changes will be made')"

  # ~/.config/<name> -> repo/<name>
  for name in \
      alacritty dunst fontconfig fuzzel \
      i3 i3status-rust nvim \
      sway swaylock swaync waybar \
      xdg-desktop-portal xdg-desktop-portal-wlr
  do
    [[ -d "$DOTFILES/$name" ]] && link "$DOTFILES/$name" "$CONFIG_DIR/$name"
  done

  # zsh: full ~/.config/zsh dir + ~/.zshrc + ~/.p10k.zsh
  if [[ -d "$DOTFILES/zsh" ]]; then
    link "$DOTFILES/zsh"          "$CONFIG_DIR/zsh"
    link "$DOTFILES/zsh/zshrc"    "$HOME_DIR/.zshrc"
    [[ -f "$DOTFILES/zsh/p10k.zsh" ]] && link "$DOTFILES/zsh/p10k.zsh" "$HOME_DIR/.p10k.zsh"
  fi

  # vim
  [[ -f "$DOTFILES/vim/vimrc" ]] && link "$DOTFILES/vim/vimrc" "$HOME_DIR/.vimrc"

  # ftplugin (legacy nvim ftplugin override)
  [[ -d "$DOTFILES/ftplugin" ]] && link "$DOTFILES/ftplugin" "$CONFIG_DIR/nvim-ftplugin-extra"

  # ideavimrc
  [[ -f "$DOTFILES/ideavimrc" ]] && link "$DOTFILES/ideavimrc" "$HOME_DIR/.ideavimrc"

  # XDG MIME defaults
  [[ -f "$DOTFILES/mimeapps.list" ]] && link "$DOTFILES/mimeapps.list" "$CONFIG_DIR/mimeapps.list"

  # PipeWire screencast tuning (drop-in under conf.d)
  if [[ -f "$DOTFILES/pipewire/30-screencast.conf" ]]; then
    run mkdir -p "$CONFIG_DIR/pipewire/pipewire.conf.d"
    link "$DOTFILES/pipewire/30-screencast.conf" \
         "$CONFIG_DIR/pipewire/pipewire.conf.d/30-screencast.conf"
  fi

  # Firefox user.js — applied to whichever default-release profile exists.
  # We do NOT symlink (Firefox rewrites prefs.js next to user.js); copy with
  # backup of any existing one.
  if [[ -f "$DOTFILES/firefox/user.js" ]]; then
    for ff_profile in "$HOME_DIR"/.mozilla/firefox/*.default-release; do
      [[ -d "$ff_profile" ]] || continue
      if [[ -f "$ff_profile/user.js" ]]; then
        ensure_backup_dir
        run cp "$ff_profile/user.js" "$BACKUP_DIR/firefox-user.js"
      fi
      run cp "$DOTFILES/firefox/user.js" "$ff_profile/user.js"
      printf '  %s %s/user.js\n' "$(c_green 'copy')" "$ff_profile"
    done
  fi

  # Cursor IDE — settings.json + keybindings.json under ~/.config/Cursor/User
  if [[ -d "$DOTFILES/cursor" ]]; then
    run mkdir -p "$CONFIG_DIR/Cursor/User"
    [[ -f "$DOTFILES/cursor/settings.json" ]]    && link "$DOTFILES/cursor/settings.json"    "$CONFIG_DIR/Cursor/User/settings.json"
    [[ -f "$DOTFILES/cursor/keybindings.json" ]] && link "$DOTFILES/cursor/keybindings.json" "$CONFIG_DIR/Cursor/User/keybindings.json"
  fi

  # JetBrains IDEs — apply Solarized Dark theme + colour scheme to every
  # detected product version under ~/.config/JetBrains/<Product><Version>.
  # Files are *copied* (not symlinked) because each product owns lots of other
  # state in options/ that we do not want to mirror.
  if [[ -d "$DOTFILES/jetbrains" ]]; then
    shopt -s nullglob
    for product in "$CONFIG_DIR"/JetBrains/*/; do
      # Skip non-product dirs like Fleet, Toolbox, *-backup, etc.
      base="$(basename "$product")"
      case "$base" in
        IntelliJIdea*|PyCharm*|DataGrip*|CLion*|GoLand*|RustRover*|WebStorm*|PhpStorm*|RubyMine*|AndroidStudio*|Rider*|AquaCode*) ;;
        *) continue ;;
      esac
      run mkdir -p "$product/options"
      for f in laf.xml colors.scheme.xml; do
        [[ -f "$DOTFILES/jetbrains/$f" ]] || continue
        if [[ -f "$product/options/$f" ]]; then
          ensure_backup_dir
          run cp "$product/options/$f" "$BACKUP_DIR/$(basename "$product")-$f"
        fi
        run cp "$DOTFILES/jetbrains/$f" "$product/options/$f"
        printf '  %s %s/options/%s\n' "$(c_green 'copy')" "$product" "$f"
      done
    done
    shopt -u nullglob
  fi

  # DBeaver — Eclipse-based settings live in workspace prefs.  Same rationale
  # as JetBrains: copy individual prefs files into the workspace so the rest
  # of the workspace state stays untouched.
  if [[ -d "$DOTFILES/dbeaver" ]]; then
    dbeaver_settings="$HOME_DIR/.local/share/DBeaverData/workspace6/.metadata/.plugins/org.eclipse.core.runtime/.settings"
    if [[ -d "$(dirname "$dbeaver_settings")" ]]; then
      run mkdir -p "$dbeaver_settings"
      for f in "$DOTFILES"/dbeaver/*.prefs; do
        [[ -f "$f" ]] || continue
        target="$dbeaver_settings/$(basename "$f")"
        if [[ -f "$target" ]]; then
          ensure_backup_dir
          run cp "$target" "$BACKUP_DIR/dbeaver-$(basename "$f")"
        fi
        run cp "$f" "$target"
        printf '  %s %s\n' "$(c_green 'copy')" "$target"
      done
    else
      warn "DBeaver workspace not found — launch DBeaver once, then re-run install.sh"
    fi
  fi

  # ~/.local/bin scripts
  if [[ -d "$DOTFILES/bin" ]]; then
    run mkdir -p "$HOME_DIR/.local/bin"
    for f in "$DOTFILES"/bin/*; do
      [[ -f "$f" && -x "$f" ]] && link "$f" "$HOME_DIR/.local/bin/${f##*/}"
    done
  fi

  # ~/.local/share/applications — .desktop entries for binaries that ship
  # without one (e.g. /usr/bin/chromiump, /usr/local/bin/hs). Needed so
  # fuzzel (Mod+d) picks them up.
  if [[ -d "$DOTFILES/applications" ]]; then
    run mkdir -p "$HOME_DIR/.local/share/applications"
    shopt -s nullglob
    for f in "$DOTFILES"/applications/*.desktop; do
      link "$f" "$HOME_DIR/.local/share/applications/${f##*/}"
    done
    shopt -u nullglob
    if command -v update-desktop-database >/dev/null 2>&1; then
      run update-desktop-database -q "$HOME_DIR/.local/share/applications" || true
    fi
  fi

  if [[ -d "$BACKUP_DIR" ]]; then
    log "backed up replaced files to: $BACKUP_DIR"
  fi

  if (( DO_PACKAGES )); then
    install_packages
  fi

  log "$(c_green 'done')"
  if [[ ! -f "$DOTFILES/zsh/private.zsh" && -f "$DOTFILES/zsh/private.zsh.example" ]]; then
    warn "create zsh/private.zsh from zsh/private.zsh.example for secrets"
  fi
}

main "$@"
