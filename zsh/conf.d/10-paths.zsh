# PATH and environment.

# --- editor ---
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS="-FRSXMi"
export LESSHISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/less/history"
mkdir -p "${LESSHISTFILE:h}"

# --- locale ---
export LANG="${LANG:-en_US.UTF-8}"

# --- XDG ---
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# --- ssh-agent socket (systemd user unit) ---
[[ -n "$XDG_RUNTIME_DIR" ]] && export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# --- gpg-agent: tell gpg which tty to prompt on ---
export GPG_TTY=$TTY

# --- PATH additions ---
typeset -U path PATH fpath
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/.cargo/bin"
  "$HOME/.npm-global/bin"
  "$HOME/go/bin"
  "$HOME/perl5/bin"
  $path
)
export PATH

# --- Perl local::lib ---
if [[ -d "$HOME/perl5" ]]; then
  export PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:$PERL5LIB}"
  export PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:$PERL_LOCAL_LIB_ROOT}"
  export PERL_MB_OPT="--install_base \"$HOME/perl5\""
  export PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"
fi

# --- Oracle Instant Client (auto-pick newest version present) ---
for _oh in /opt/oracle/instantclient_*(N/); do
  export ORACLE_HOME="${_oh%/}"
done
unset _oh
if [[ -n "${ORACLE_HOME:-}" ]]; then
  export NLS_LANG=AMERICAN_CIS.UTF8
  export TNS_ADMIN="$ORACLE_HOME/network/admin"
  export LD_LIBRARY_PATH="$ORACLE_HOME${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
  export DYLD_LIBRARY_PATH="$ORACLE_HOME"
  path+=("$ORACLE_HOME")
fi

# --- man pages colored ---
export MANPAGER="less -R --use-color -Dd+r -Du+b"
# Alternatively, use bat as a pager for `man` and `--help` output:
if command -v bat >/dev/null 2>&1; then
  export MANROFFOPT="-c"
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export BAT_THEME="Solarized (dark)"
  export BAT_STYLE="numbers,changes,header"
fi

# --- Docker / build tools ---
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# --- pip / npm / cargo: keep $HOME tidy ---
export PIP_REQUIRE_VIRTUALENV=true 2>/dev/null
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
export CARGO_HOME="${XDG_DATA_HOME}/cargo"
[[ -d "$CARGO_HOME/bin" ]] && path=("$CARGO_HOME/bin" $path)

# --- fzf: defaults & colors (Solarized Dark) ---
export FZF_DEFAULT_OPTS='
  --height 60% --layout=reverse --border=rounded --info=inline
  --prompt=" "  --pointer="" --marker=""
  --color=fg:#93a1a1,bg:-1,hl:#268bd2
  --color=fg+:#eee8d5,bg+:#073642,hl+:#b58900
  --color=info:#2aa198,prompt:#859900,pointer:#dc322f
  --color=marker:#cb4b16,spinner:#6c71c4,header:#586e75
  --color=border:#586e75,gutter:-1
  --bind=ctrl-d:half-page-down,ctrl-u:half-page-up
  --bind=ctrl-y:preview-up,ctrl-e:preview-down
'
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --exclude node_modules'
fi
if command -v bat >/dev/null 2>&1; then
  export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range=:300 {}' --preview-window=right:60%:wrap"
fi
if command -v eza >/dev/null 2>&1; then
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always --icons {}' --preview-window=right:50%"
fi
