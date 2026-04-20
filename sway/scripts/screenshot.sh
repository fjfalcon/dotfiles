#!/usr/bin/env bash
# Sway screenshot pipeline.
#   region   slurp -> grim -> wl-copy + save  (Mod+Shift+s)
#   full     all outputs                       (Print)
#   window   active window                     (Mod+Shift+Print)
#   edit     region -> swappy                  (Mod+Ctrl+Print)
#   _osd_vol / _osd_bri  notify with wireplumber/brightnessctl values
set -euo pipefail

OUT_DIR="${HOME}/scrot"
mkdir -p "$OUT_DIR"
TS=$(date +%Y-%m-%d-%H%M%S)
FILE="$OUT_DIR/$TS.png"

notify() {
    notify-send -a screenshot -t 4000 -i "$2" "$1" "${3:-}"
}

case "${1:-region}" in
  region)
    geom=$(slurp -d -c '#268bd2ff' -b '#00000033' -w 2) || exit 0
    grim -g "$geom" - | tee "$FILE" | wl-copy
    notify "Screenshot saved" "$FILE" "$(basename "$FILE") copied to clipboard"
    ;;
  full)
    grim - | tee "$FILE" | wl-copy
    notify "Screenshot saved" "$FILE" "$(basename "$FILE") copied to clipboard"
    ;;
  window)
    geom=$(swaymsg -t get_tree | jq -r '
      .. | select(.focused? and .pid) | "\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)"' | head -1)
    grim -g "$geom" - | tee "$FILE" | wl-copy
    notify "Window shot saved" "$FILE" "$(basename "$FILE") copied to clipboard"
    ;;
  edit)
    geom=$(slurp -d -c '#268bd2ff' -b '#00000033' -w 2) || exit 0
    grim -g "$geom" - | swappy -f -
    ;;
  _osd_vol)
    info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || echo 'Volume: ?')
    muted=""
    [[ "$info" == *MUTED* ]] && muted=" (muted)"
    pct=$(awk '{printf "%d", $2*100}' <<<"$info" 2>/dev/null || echo 0)
    notify-send -a volume -t 1500 -h string:x-canonical-private-synchronous:volume \
      -h "int:value:${pct}" "Volume${muted}" "${pct}%"
    ;;
  _osd_bri)
    pct=$(brightnessctl -m | awk -F, '{gsub("%","",$4); print $4}')
    notify-send -a brightness -t 1500 -h string:x-canonical-private-synchronous:brightness \
      -h "int:value:${pct}" "Brightness" "${pct}%"
    ;;
  *)
    echo "usage: $0 [region|full|window|edit|_osd_vol|_osd_bri]" >&2
    exit 2
    ;;
esac
