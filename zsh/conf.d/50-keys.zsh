# Key bindings.

bindkey -e                         # emacs mode (compatible with most plugins)

# --- history search with arrows ---
# The actual bindings live in 30-plugins.zsh inside the
# history-substring-search `atload` block (so the widgets exist before we
# bind them). These two autoloads remain as a fallback for the brief moment
# *before* the async plugin finishes loading.
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^P'   up-line-or-beginning-search
bindkey '^N'   down-line-or-beginning-search

# --- word-by-word with ctrl+arrows ---
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[1;3C' forward-word    # alt+right
bindkey '^[[1;3D' backward-word   # alt+left

# --- ctrl-u: kill from cursor to BoL (more useful than default) ---
bindkey '^U' backward-kill-line

# --- alt-. : insert last argument; alt-, cycles older args ---
bindkey '^[.' insert-last-word

# --- ctrl-x ctrl-e : edit current line in $EDITOR ---
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# --- esc-esc : prefix current command with sudo (or remove it) ---
# OMZP::sudo provides this; just rebind to the more common chord.
bindkey '\e\e' sudo-command-line 2>/dev/null

# --- alt-l : append "| less" to the current command ---
_append_less() { LBUFFER+=" | less" }
zle -N _append_less
bindkey '^[l' _append_less

# --- alt-h : run `man` on the current command word ---
_run_man_for_word() {
  local words=(${(z)BUFFER}) cmd=${words[1]}
  [[ -n "$cmd" ]] && BUFFER="man $cmd" && zle accept-line
}
zle -N _run_man_for_word
bindkey '^[h' _run_man_for_word

# --- ctrl-z : foreground last bg job (single-key suspend toggle) ---
_fg_last() {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER='fg'
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N _fg_last
bindkey '^Z' _fg_last

# --- ctrl-r : history search (fzf already provides one when sourced) ---
# fzf key-bindings.zsh installs ^R; if atuin is enabled in 70-tools.zsh,
# atuin will override this with its own widget — both are nice.
