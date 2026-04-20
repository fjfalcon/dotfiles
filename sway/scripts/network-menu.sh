#!/usr/bin/env bash
# ~/.config/sway/scripts/network-menu.sh
#
# Fuzzel-driven network manager: toggles WireGuard / OpenVPN profiles and
# connects to Wi-Fi networks via NetworkManager.  Bound to waybar's
# `network` module on-click (see ~/.config/waybar/modules.jsonc).
#
# Right-click in waybar still opens nm-connection-editor for advanced edits;
# this script only needs to handle the two flows the user actually does
# day-to-day:
#   * pick a Wi-Fi SSID (with password prompt for new ones)
#   * toggle a saved VPN/WireGuard tunnel up or down
#
# Notes on UX choices:
#   * Single flat list (active VPNs at the very top so they're easy to
#     disconnect, then inactive VPNs, then Wi-Fi sorted by signal, then
#     utilities).  fuzzel's fuzzy matcher does the rest.
#   * Each row carries a hidden tab-delimited "tag\tlabel"; --with-nth=2 hides
#     the tag from view, --index gives us the chosen row back without having
#     to parse the visible text.
#   * Password prompt uses `fuzzel --password` so what you type stays masked.

set -euo pipefail

# ---------------------------------------------------------------- icons ----
# Nerd Font / Font Awesome glyphs — match the ones already used in waybar.
ICON_WIFI=$'\uf1eb'      # 
ICON_LOCK=$'\uf023'      # 
ICON_VPN_ON=$'\uf00c'    #  (check)
ICON_VPN_OFF=$'\uf0ac'   #  (globe)
ICON_PWR=$'\uf011'       # 
ICON_GEAR=$'\uf013'      # 
ICON_REFRESH=$'\uf021'   # 

WIFI_DEV=$(nmcli -t -f DEVICE,TYPE device status | awk -F: '$2=="wifi"{print $1; exit}')

notify() { command -v notify-send >/dev/null && notify-send -t 4000 "Network" "$*" || true; }

# Signal-strength bar (0..100 → 4 levels of block glyphs).
sig_bars() {
  local s=${1:-0}
  if   (( s >= 75 )); then printf '▂▄▆█'
  elif (( s >= 50 )); then printf '▂▄▆_'
  elif (( s >= 25 )); then printf '▂▄__'
  else                     printf '▂___'
  fi
}

# ----- menu assembly --------------------------------------------------------
# tags[]   : machine-readable "action|arg" per row
# labels[] : visible text per row (UTF-8, may contain spaces)
declare -a tags=()
declare -a labels=()

add_row() {
  # $1 = action|arg, $2 = visible label
  tags+=("$1")
  labels+=("$2")
}

# 1) Active VPN-like connections first — quickest path is "I want to drop the VPN".
while IFS=: read -r name type state; do
  case "$type" in
    vpn|wireguard)
      [[ "$state" == "activated" ]] && \
        add_row "vpn-down|$name" \
                "$(printf '%s  %-28s  ▸ disconnect' "$ICON_VPN_ON" "$name")"
      ;;
  esac
done < <(nmcli -t -f NAME,TYPE,STATE connection show)

# 2) Inactive VPN profiles.
while IFS=: read -r name type state; do
  case "$type" in
    vpn|wireguard)
      [[ "$state" != "activated" ]] && \
        add_row "vpn-up|$name" \
                "$(printf '%s  %-28s  ▸ connect (%s)' "$ICON_VPN_OFF" "$name" "$type")"
      ;;
  esac
done < <(nmcli -t -f NAME,TYPE,STATE connection show)

# 3) Wi-Fi list, dedup by SSID (NM lists every BSSID otherwise), strongest first.
if [[ -n "$WIFI_DEV" ]]; then
  add_row "noop|" "──────────── Wi-Fi ────────────"
  while IFS=$'\t' read -r in_use ssid signal sec; do
    [[ -z "$ssid" ]] && continue
    local_icon="$ICON_WIFI"
    [[ -n "$sec" && "$sec" != "--" ]] && local_icon="$ICON_LOCK"
    marker=' '
    [[ "$in_use" == "*" ]] && marker='*'
    bars=$(sig_bars "$signal")
    add_row "wifi|$ssid" \
            "$(printf '%s %s %-28s %s  %s' "$local_icon" "$marker" "$ssid" "$bars" "${sec:-open}")"
  done < <(nmcli -t --escape no -f IN-USE,SSID,SIGNAL,SECURITY device wifi list ifname "$WIFI_DEV" \
            | awk -F: 'NF>=4 && $2!=""{print $1"\t"$2"\t"$3"\t"$4}' \
            | sort -t$'\t' -k3 -n -r \
            | awk -F'\t' '!seen[$2]++')
fi

# 4) Utilities.
add_row "noop|" "──────────── Utilities ────────"
if nmcli -t -f WIFI radio | grep -q '^enabled$'; then
  add_row "wifi-off|" "$(printf '%s  Disable Wi-Fi' "$ICON_PWR")"
else
  add_row "wifi-on|"  "$(printf '%s  Enable Wi-Fi'  "$ICON_PWR")"
fi
add_row "rescan|" "$(printf '%s  Rescan Wi-Fi networks' "$ICON_REFRESH")"
add_row "editor|" "$(printf '%s  Edit connections (nm-connection-editor)' "$ICON_GEAR")"

# ----- show the menu -------------------------------------------------------
# We feed fuzzel "<label>\t<index>" so we can recover the original index even
# after fuzzel sorts/filters the list.
input=$(for i in "${!labels[@]}"; do printf '%s\t%d\n' "${labels[$i]}" "$i"; done)

picked=$(printf '%s' "$input" \
  | fuzzel --dmenu --prompt='󰖩  ' --width=46 --lines=18 \
           --with-nth=1 --nth-delimiter=$'\t' || true)

[[ -z "$picked" ]] && exit 0

# `picked` is the full original line ("label\tindex") — extract the index.
idx=${picked##*$'\t'}
IFS='|' read -r action arg <<< "${tags[$idx]}"

# ----- action handlers -----------------------------------------------------
case "$action" in
  vpn-up)
    nmcli connection up   "$arg" >/dev/null && notify "VPN $arg up"   || notify "Failed to bring $arg up" ;;
  vpn-down)
    nmcli connection down "$arg" >/dev/null && notify "VPN $arg down" || notify "Failed to bring $arg down" ;;
  wifi)
    # Saved profile? Just bring it up.
    if nmcli -t -f NAME connection show | grep -Fxq "$arg"; then
      nmcli connection up "$arg" >/dev/null && notify "Wi-Fi: $arg" || notify "Failed: $arg"
      exit 0
    fi
    # Otherwise scan its security setting.
    sec=$(nmcli -t -f SSID,SECURITY device wifi list ifname "$WIFI_DEV" \
            | awk -F: -v s="$arg" '$1==s{print $2; exit}')
    if [[ -z "$sec" || "$sec" == "--" ]]; then
      nmcli device wifi connect "$arg" ifname "$WIFI_DEV" >/dev/null \
        && notify "Wi-Fi: $arg" || notify "Failed: $arg"
    else
      pw=$(printf '' | fuzzel --dmenu --password \
              --prompt="$arg ▸ password: " --width=40 --lines=0 || true)
      [[ -z "$pw" ]] && exit 0
      nmcli device wifi connect "$arg" password "$pw" ifname "$WIFI_DEV" >/dev/null \
        && notify "Wi-Fi: $arg" || notify "Failed: $arg"
    fi
    ;;
  wifi-on)  nmcli radio wifi on  ;;
  wifi-off) nmcli radio wifi off ;;
  rescan)   nmcli device wifi rescan ifname "$WIFI_DEV" >/dev/null 2>&1 || true ;;
  editor)   setsid -f nm-connection-editor >/dev/null 2>&1 ;;
  noop)     exec "$0" ;;          # re-open menu if user picked a separator
esac
