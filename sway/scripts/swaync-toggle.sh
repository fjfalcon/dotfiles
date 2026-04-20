#!/usr/bin/env bash
# swaync-toggle — open swaync's control center on whichever sway output is
# focused right now, then toggle (or pass through any other swaync-client
# command).
#
# Usage:
#   swaync-toggle                 toggle the control center on focused monitor
#   swaync-toggle --close-all     forward arbitrary args to swaync-client
set -euo pipefail

# Resolve target monitor in priority order:
#   1. --output NAME / -o NAME  explicit flag
#   2. first non-flag arg if it looks like an output name (e.g. "DP-1")
#   3. WAYBAR_OUTPUT_NAME       (waybar exec context — not on-click, but free)
#   4. swaymsg focused output   (hotkey invocations)
target=""
args=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output) target="$2"; shift 2 ;;
        *)           args+=("$1"); shift ;;
    esac
done

if [[ -z "$target" && ${#args[@]} -gt 0 && "${args[0]}" =~ ^[A-Za-z0-9_-]+-[0-9]+$ ]]; then
    target="${args[0]}"
    args=("${args[@]:1}")
fi

if [[ -z "$target" ]]; then
    target="${WAYBAR_OUTPUT_NAME:-}"
fi

if [[ -z "$target" ]]; then
    target=$(swaymsg -t get_outputs --raw 2>/dev/null \
               | jq -r '.[] | select(.focused).name' \
               | head -n1)
fi

if [[ -n "$target" ]]; then
    # Re-target both the popup notifications and the control center.
    swaync-client --change-cc-monitor   "$target" >/dev/null 2>&1 || true
    swaync-client --change-noti-monitor "$target" >/dev/null 2>&1 || true
fi

if [[ ${#args[@]} -eq 0 ]]; then
    exec swaync-client --toggle-panel --skip-wait
else
    exec swaync-client "${args[@]}" --skip-wait
fi
