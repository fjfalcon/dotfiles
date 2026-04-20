# Per-tool integrations. Each block is a no-op if the tool isn't installed,
# so this file is safe to ship to any host.

# ---------------------------------------------------------- direnv ----------
# Auto-load .envrc when entering project directories.
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# ----------------------------------------------------------- atuin ----------
# Sqlite-backed history with fuzzy search. Replaces fzf's Ctrl-R.
# Up-arrow stays bound to substring search (see 50-keys.zsh).
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# ------------------------------------------------------------- gh -----------
if command -v gh >/dev/null 2>&1; then
  # Cache completions in fpath dir; regenerate weekly.
  _gh_comp="${ZDOTDIR:-$HOME/.config/zsh}/completions/_gh"
  if [[ ! -f "$_gh_comp" || $(( $(date +%s) - $(stat -c %Y "$_gh_comp" 2>/dev/null || echo 0) )) -gt 604800 ]]; then
    gh completion -s zsh > "$_gh_comp" 2>/dev/null
  fi
  unset _gh_comp
fi

# --------------------------------------------------------- kubectl ----------
if command -v kubectl >/dev/null 2>&1; then
  _kc_comp="${ZDOTDIR:-$HOME/.config/zsh}/completions/_kubectl"
  if [[ ! -f "$_kc_comp" || $(( $(date +%s) - $(stat -c %Y "$_kc_comp" 2>/dev/null || echo 0) )) -gt 604800 ]]; then
    kubectl completion zsh > "$_kc_comp" 2>/dev/null
  fi
  unset _kc_comp
  # Reuse for the `k` alias.
  compdef k=kubectl 2>/dev/null
  compdef q=kubectl 2>/dev/null
fi

# --------------------------------------------------------- docker -----------
# pacman ships completions in /usr/share/zsh/site-functions, no extra setup.

# ------------------------------------------------------ git delta -----------
# Use delta as the default git pager if installed.
if command -v delta >/dev/null 2>&1; then
  export GIT_PAGER='delta'
  export DELTA_PAGER='less -R'
  # Per-repo `git config core.pager delta` still wins; this is the user-wide
  # default (and what `git diff` uses outside of a repo).
fi

# -------------------------------------------------------- thefuck ----------
if command -v thefuck >/dev/null 2>&1; then
  eval "$(thefuck --alias 2>/dev/null)"
fi

# --------------------------------------------------- pkgfile cnf hook ------
# command-not-found suggestions powered by pkgfile (Arch). Loaded once.
if [[ -r /usr/share/doc/pkgfile/command-not-found.zsh ]]; then
  source /usr/share/doc/pkgfile/command-not-found.zsh
fi

# ----------------------------------------------------- terminal title ------
# Show "user@host: cwd" or "user@host: cmd" in the terminal tab/window title.
case $TERM in
  xterm*|alacritty*|tmux*|screen*|rxvt*|foot*)
    _set_term_title() { print -Pn '\e]0;%n@%m: %~\a' }
    _set_term_title_cmd() { print -Pn "\e]0;%n@%m: $1\a" }
    autoload -U add-zsh-hook
    add-zsh-hook precmd _set_term_title
    add-zsh-hook preexec _set_term_title_cmd
    ;;
esac
