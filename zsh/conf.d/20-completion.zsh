# Completion engine + styles. Loaded BEFORE 30-plugins so fzf-tab can pick
# everything up. The actual `compinit` call happens inside zinit's atinit
# hook in 30-plugins.zsh (avoids double-load and is faster).

# --- where to look for completions ---
fpath+=(
  "${ZDOTDIR:-$HOME/.config/zsh}/completions"
  /usr/share/zsh/site-functions
  /usr/local/share/zsh/site-functions
)
mkdir -p "${ZDOTDIR:-$HOME/.config/zsh}/completions"

# --- compinit cache (faster startup) ---
ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
mkdir -p "${ZSH_COMPDUMP:h}"

# --- general completion behaviour ---
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compcache"
zstyle ':completion:*' rehash true
zstyle ':completion:*' menu no                     # let fzf-tab take over
zstyle ':completion:*' verbose yes
zstyle ':completion:*' group-name ''
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:messages'     format '%d'
zstyle ':completion:*:warnings'     format 'no matches: %d'
zstyle ':completion:*:corrections'  format '%d (errors: %e)'

# --- case-insensitive, partial-word, substring matching ---
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

# --- color the completion menu ---
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"

# --- nicer process completion (`kill <Tab>`) ---
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always

# --- ssh / scp host completion from ~/.ssh/config + known_hosts ---
zstyle ':completion:*:(ssh|scp|sftp|rsync):*' hosts off
() {
  local kh=~/.ssh/known_hosts cfg=~/.ssh/config
  local -a hosts
  [[ -r $kh ]]  && hosts+=( ${${${(f)"$(<$kh)"}%%[# ]*}//,/ } )
  [[ -r $cfg ]] && hosts+=( ${(s: :)${(f)"$(<$cfg)"}#Host[[:space:]]} )
  zstyle ':completion:*:hosts' hosts $hosts
}

# --- git: don't sort branches alphabetically (preserve recency) ---
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:git-*:*' tag-order 'common-commands'

# --- man: section grouping ---
zstyle ':completion:*:manuals' separate-sections true

# --- fzf-tab tweaks (the plugin itself loads in 30-plugins.zsh) ---
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' continuous-trigger 'tab'
zstyle ':fzf-tab:*' fzf-flags '--height=70%' '--border=rounded'
zstyle ':fzf-tab:*' show-group full
zstyle ':fzf-tab:*' single-group color header

# previews per command
if command -v eza >/dev/null 2>&1; then
  zstyle ':fzf-tab:complete:cd:*'              fzf-preview 'eza -1 --icons --color=always $realpath'
  zstyle ':fzf-tab:complete:z:*'               fzf-preview 'eza -1 --icons --color=always $realpath'
  zstyle ':fzf-tab:complete:j:*'               fzf-preview 'eza -1 --icons --color=always $realpath'
fi
if command -v bat >/dev/null 2>&1; then
  zstyle ':fzf-tab:complete:(\\|*/|)nvim:*'    fzf-preview 'bat -n --color=always $realpath 2>/dev/null || eza -1 --color=always $realpath'
  zstyle ':fzf-tab:complete:(cat|bat|less):*' fzf-preview 'bat -n --color=always $realpath'
fi
zstyle ':fzf-tab:complete:kill:argument-rest'  fzf-preview 'ps -p $word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:kill:argument-rest'  fzf-flags --preview-window=down:3:wrap
zstyle ':fzf-tab:complete:systemctl-*:*'       fzf-preview 'systemctl status $word'
zstyle ':fzf-tab:complete:(\\|*/|)man:*'       fzf-preview 'man $word | col -b | head -200'
