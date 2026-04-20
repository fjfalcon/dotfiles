#!/usr/bin/env bash
# ~/.config/sway/scripts/vpn-status.sh
#
# Streams JSON state for waybar's custom/vpn module.
#
# Why streaming (`exec` mode) instead of `interval` polling:
#   * State changes are event-driven: the user toggles VPN from our fuzzel
#     menu (or `nmcli con up/down`), and waybar should reflect it instantly,
#     not after a 5s tick.
#   * `nmcli monitor` blocks and prints a line on every NM event (connection
#     activated / deactivated / IP changed) — we just re-emit on each line.
#   * One initial emit on startup so waybar isn't blank between sway login
#     and the first NM event.
#
# Output is one JSON object per line (waybar `return-type: "json"`):
#   {"text": "<profile>", "alt": "on"|"off", "class": "on"|"off", "tooltip": "..."}
#
# `alt` is mapped to format-icons in modules.jsonc; `class` drives colour in
# style.css (#custom-vpn.on / #custom-vpn.off).

set -uo pipefail

emit() {
  # First active vpn-like connection (vpn = OpenVPN/IKEv2/etc., wireguard = WG).
  # We only show one profile in the bar even if several are up — keeps the
  # bar compact; the menu still lists them all.
  local active
  active=$(nmcli -t -f NAME,TYPE,STATE connection show --active 2>/dev/null \
             | awk -F: '$2 ~ /^(vpn|wireguard)$/ && $3=="activated" {print $1; exit}')

  if [[ -n "$active" ]]; then
    # Pull a friendlier tooltip: type + IPv4 of the tunnel device, if any.
    local type ipv4 dev tip
    type=$(nmcli -t -f connection.type connection show "$active" 2>/dev/null | awk -F: '{print $2}')
    dev=$(nmcli -t -f GENERAL.DEVICES connection show "$active" 2>/dev/null | awk -F: '{print $2}')
    ipv4=$(nmcli -t -f IP4.ADDRESS connection show "$active" 2>/dev/null | awk -F: 'NR==1{print $2}')
    tip="VPN: ${active}"
    [[ -n "$type" ]] && tip+=" (${type})"
    [[ -n "$dev"  ]] && tip+=$'\n'"dev: ${dev}"
    [[ -n "$ipv4" ]] && tip+=$'\n'"ip:  ${ipv4}"
    printf '{"text":"%s","alt":"on","class":"on","tooltip":"%s"}\n' \
           "${active}" "${tip//$'\n'/\\n}"
  else
    printf '{"text":"","alt":"off","class":"off","tooltip":"VPN: not connected"}\n'
  fi
}

emit
# Re-emit on every NM event.  If nmcli monitor dies (NetworkManager restart),
# fall back to a 5-second poll so waybar never gets stuck on stale state.
while :; do
  if ! nmcli monitor 2>/dev/null | while read -r _; do emit; done; then
    sleep 5
    emit
  fi
  sleep 1
done
