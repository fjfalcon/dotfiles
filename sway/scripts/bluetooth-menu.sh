#!/usr/bin/env bash
# ~/.config/sway/scripts/bluetooth-menu.sh
#
# Fuzzel-driven Bluetooth picker.  Replaces the day-to-day jobs of blueman-
# applet: power toggle, connect/disconnect to a paired device, scan for new
# ones, and (for fresh devices) fire off a basic pair via bluetoothctl.
#
# Right-click in waybar still opens blueman-manager for the heavy stuff
# (audio profile selection, MAP/PBAP/AVRCP toggles, removing devices, etc.).
#
# Layout:                                                  (action handler)
#                                                          ────────────────
#     ▸ disconnect   <connected paired device>             disconnect <mac>
#       <other paired devices, sorted by alias>            connect    <mac>
#   ── Discovered ─────────────────────                    (separator)
#       <unpaired, found via scan>            (new)        pair       <mac>
#   ── Utilities ──────────────────────                    (separator)
#       Scan for new devices (8s)                          scan
#       Disable Bluetooth   /   Enable Bluetooth           power-off / on
#       Open blueman-manager                               manager
#
# Each row carries a hidden tab-delimited "label\tindex"; fuzzel hides the
# index column via --with-nth=1, and we recover the chosen action by
# splitting on \t.

set -uo pipefail

# ----------------------------------------------------------------- icons ---
ICON_BT=$'\uf294'           # 
ICON_HEADSET=$'\uf025'      # 
ICON_KEYBOARD=$'\uf11c'     # 
ICON_MOUSE=$'\uf245'        # 
ICON_PHONE=$'\uf095'        # 
ICON_COMPUTER=$'\uf109'     # 
ICON_SPEAKER=$'\uf028'      # 
ICON_GAMEPAD=$'\uf11b'      # 
ICON_PWR=$'\uf011'          # 
ICON_GEAR=$'\uf013'         # 
ICON_REFRESH=$'\uf021'      # 
ICON_CHECK=$'\uf00c'        # 

notify() { command -v notify-send >/dev/null && notify-send -t 4000 "Bluetooth" "$*" || true; }

# Pick a glyph based on bluez Icon class (man bluetoothctl: device.Icon).
device_icon() {
  case "$1" in
    audio-headset|audio-headphones) printf '%s' "$ICON_HEADSET" ;;
    audio-card|audio-speakers)      printf '%s' "$ICON_SPEAKER" ;;
    input-keyboard)                 printf '%s' "$ICON_KEYBOARD" ;;
    input-mouse|input-tablet)       printf '%s' "$ICON_MOUSE" ;;
    phone)                          printf '%s' "$ICON_PHONE" ;;
    computer)                       printf '%s' "$ICON_COMPUTER" ;;
    input-gaming)                   printf '%s' "$ICON_GAMEPAD" ;;
    *)                              printf '%s' "$ICON_BT" ;;
  esac
}

# Fast-path: if the controller is missing, bail with a notification rather
# than a confusing empty menu.
if ! bluetoothctl show >/dev/null 2>&1; then
  notify "No Bluetooth controller detected"
  exit 1
fi

powered=$(bluetoothctl show | awk '/Powered:/{print $2; exit}')

declare -a tags=()
declare -a labels=()
add_row() { tags+=("$1"); labels+=("$2"); }

if [[ "$powered" != "yes" ]]; then
  add_row "power-on|" "$(printf '%s  Enable Bluetooth' "$ICON_PWR")"
  add_row "manager|"  "$(printf '%s  Open blueman-manager' "$ICON_GEAR")"
else
  # ---- Connected paired devices first (so disconnect is one click) -------
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    mac=$(awk '{print $2}' <<<"$line")
    alias=$(cut -d' ' -f3- <<<"$line")
    icon_name=$(bluetoothctl info "$mac" 2>/dev/null | awk '/Icon:/{print $2; exit}')
    icon=$(device_icon "$icon_name")
    add_row "disconnect|$mac" \
            "$(printf '%s %s  %-30s  ▸ disconnect' "$ICON_CHECK" "$icon" "$alias")"
  done < <(bluetoothctl devices Connected)

  # ---- Other paired devices, alphabetically -------------------------------
  connected_macs=$(bluetoothctl devices Connected | awk '{print $2}' | tr '\n' '|' | sed 's/|$//')
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    mac=$(awk '{print $2}' <<<"$line")
    [[ -n "$connected_macs" && "$mac" =~ ^(${connected_macs})$ ]] && continue
    alias=$(cut -d' ' -f3- <<<"$line")
    icon_name=$(bluetoothctl info "$mac" 2>/dev/null | awk '/Icon:/{print $2; exit}')
    icon=$(device_icon "$icon_name")
    add_row "connect|$mac" \
            "$(printf '   %s  %-30s  ▸ connect' "$icon" "$alias")"
  done < <(bluetoothctl devices Paired | sort -k3)

  # ---- Discovered (unpaired) devices --------------------------------------
  paired_macs=$(bluetoothctl devices Paired | awk '{print $2}' | tr '\n' '|' | sed 's/|$//')
  discovered=()
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    mac=$(awk '{print $2}' <<<"$line")
    [[ -n "$paired_macs" && "$mac" =~ ^(${paired_macs})$ ]] && continue
    alias=$(cut -d' ' -f3- <<<"$line")
    discovered+=("$mac|$alias")
  done < <(bluetoothctl devices)

  if (( ${#discovered[@]} > 0 )); then
    add_row "noop|" "──────────── Discovered ──────"
    for d in "${discovered[@]}"; do
      mac=${d%%|*}
      alias=${d#*|}
      add_row "pair|$mac" \
              "$(printf '   %s  %-30s  (new)' "$ICON_BT" "$alias")"
    done
  fi

  # ---- Utilities ----------------------------------------------------------
  add_row "noop|"     "──────────── Utilities ───────"
  add_row "scan|"     "$(printf '%s  Scan for new devices (8s)' "$ICON_REFRESH")"
  add_row "power-off|" "$(printf '%s  Disable Bluetooth' "$ICON_PWR")"
  add_row "manager|"  "$(printf '%s  Open blueman-manager' "$ICON_GEAR")"
fi

# ----------------------------------------------------------- show menu -----
input=$(for i in "${!labels[@]}"; do printf '%s\t%d\n' "${labels[$i]}" "$i"; done)

picked=$(printf '%s' "$input" \
  | fuzzel --dmenu --prompt='󰂯  ' --width=44 --lines=18 \
           --with-nth=1 --nth-delimiter=$'\t' || true)

[[ -z "$picked" ]] && exit 0

idx=${picked##*$'\t'}
IFS='|' read -r action arg <<< "${tags[$idx]}"

case "$action" in
  connect)
    notify "Connecting to $(bluetoothctl info "$arg" | awk -F': ' '/Alias:/{print $2; exit}')…"
    if bluetoothctl connect "$arg" >/dev/null 2>&1; then
      notify "Connected"
    else
      notify "Failed to connect $arg"
    fi
    ;;
  disconnect)
    bluetoothctl disconnect "$arg" >/dev/null 2>&1 \
      && notify "Disconnected" || notify "Failed to disconnect $arg"
    ;;
  pair)
    # Mark the device trusted so it auto-connects after first pair, then pair
    # and connect.  No PIN agent here — works for "Just Works" devices like
    # most headphones; for PIN-prompt devices, fall back to blueman-manager.
    notify "Pairing $arg — confirm prompt on the device if asked"
    if bluetoothctl --timeout 30 pair "$arg" >/dev/null 2>&1; then
      bluetoothctl trust   "$arg" >/dev/null 2>&1 || true
      bluetoothctl connect "$arg" >/dev/null 2>&1 \
        && notify "Paired and connected" \
        || notify "Paired (not connected — try blueman-manager)"
    else
      notify "Pairing failed — open blueman-manager for PIN-based devices"
    fi
    ;;
  scan)
    notify "Scanning for 8s…"
    bluetoothctl --timeout 8 scan on >/dev/null 2>&1 &
    sleep 8
    exec "$0"          # re-open menu so newly-found devices appear
    ;;
  power-on)
    bluetoothctl power on  >/dev/null && notify "Bluetooth enabled"  || notify "Failed to power on"
    ;;
  power-off)
    bluetoothctl power off >/dev/null && notify "Bluetooth disabled" || notify "Failed to power off"
    ;;
  manager)
    setsid -f blueman-manager >/dev/null 2>&1
    ;;
  noop)
    exec "$0"          # picked a separator — re-open
    ;;
esac
