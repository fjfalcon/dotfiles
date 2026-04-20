# Plugins via zinit. Almost everything is loaded with `wait/lucid` so the
# first prompt appears in <100ms after the initial bootstrap.

# --- Powerlevel10k theme (sync, must run before the first prompt) ---
# Prefer the Arch package (already byte-compiled, fastest); fall back to
# zinit-managed clone for portability.
if [[ -r /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
else
  zinit ice depth=1
  zinit light romkatv/powerlevel10k
fi

# --- annexes / OMZ libs ---
zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

# OMZ libs + curated plugins (pulled per-file, no full oh-my-zsh install)
zinit wait lucid for \
  OMZL::git.zsh \
  OMZL::completion.zsh \
  OMZL::history.zsh \
  OMZL::key-bindings.zsh \
  OMZL::theme-and-appearance.zsh \
  OMZP::git \
  OMZP::sudo \
  OMZP::extract \
  OMZP::colored-man-pages \
  OMZP::command-not-found

# --- completion definitions (huge collection) ---
# `blockf` prevents zsh-completions from changing fpath in unexpected ways.
zinit wait lucid blockf for \
  zsh-users/zsh-completions

# --- syntax + suggestions + history-substring-search ---
# Load order matters:
#   1. fast-syntax-highlighting (with compinit replay in atinit)
#   2. zsh-autosuggestions
#   3. history-substring-search — bindings happen in its `atload` so the
#      widgets exist by the time we touch them; otherwise syntax-highlighting
#      complains "unhandled ZLE widget 'history-substring-search-*'".
zinit wait lucid for \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
  atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
  atload'
    bindkey "^[[A" history-substring-search-up
    bindkey "^[[B" history-substring-search-down
    bindkey "^P"   history-substring-search-up
    bindkey "^N"   history-substring-search-down
    bindkey -M vicmd "k" history-substring-search-up
    bindkey -M vicmd "j" history-substring-search-down
  ' \
    zsh-users/zsh-history-substring-search

# Solarized-friendly autosuggest color (base01)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#586e75'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# history-substring-search highlight (Solarized)
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=#073642,fg=#b58900,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=#dc322f,fg=#fdf6e3'

# --- fzf-tab (load AFTER syntax-highlighting, AFTER compinit replay) ---
zinit wait lucid for \
  Aloxaf/fzf-tab

# --- forgit: git through fzf. Disable its short aliases so it doesn't
#     stomp on `ga`, `gd`, `glo`, `gi`, `gcb` defined in 40-aliases.zsh.
#     Functions are still available as `forgit::add`, `forgit::diff`, etc.,
#     so we re-expose them under our own short names below.
forgit_no_aliases=1
zinit wait lucid for \
  wfxr/forgit
# fzf-flavored variants — never collide with the plain git aliases.
alias gfa='forgit::add'
alias gfd='forgit::diff'
alias gfl='forgit::log'
alias gfb='forgit::checkout::branch'
alias gfco='forgit::checkout::file'
alias gfst='forgit::stash::show'
alias gfri='forgit::rebase'
alias gfi='forgit::ignore'

# --- alias-tips: nudge when you type the long form of an existing alias ---
zinit wait lucid as"program" pick"alias-tips.py" for \
  djui/alias-tips

# --- zoxide if installed (smarter `cd`) ---
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd j zsh)"
elif [[ -r /usr/share/z/z.sh ]]; then
  source /usr/share/z/z.sh
fi

# --- system fzf shell integration (Ctrl-T / Ctrl-R / Alt-C) ---
[[ -r /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
[[ -r /usr/share/fzf/completion.zsh ]]   && source /usr/share/fzf/completion.zsh
