# Shell options + history.

# --- history ---
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=200000
SAVEHIST=200000
mkdir -p "${HISTFILE:h}"

setopt EXTENDED_HISTORY        # write timestamps to histfile
setopt HIST_EXPIRE_DUPS_FIRST  # drop dup entries first when trimming
setopt HIST_IGNORE_DUPS        # don't store consecutive dups
setopt HIST_IGNORE_ALL_DUPS    # remove older dup entries from history
setopt HIST_IGNORE_SPACE       # ignore commands starting with space
setopt HIST_FIND_NO_DUPS       # no dups during interactive search
setopt HIST_REDUCE_BLANKS      # collapse whitespace before saving
setopt HIST_VERIFY             # show !! before executing
setopt SHARE_HISTORY           # share between sessions
setopt INC_APPEND_HISTORY      # write immediately, not on shell exit
setopt HIST_FCNTL_LOCK         # safer concurrent writes (zsh 5.1+)

# --- directory navigation ---
setopt AUTO_CD                 # `myproject` -> `cd myproject`
setopt AUTO_PUSHD              # cd pushes onto the dirstack
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt PUSHD_TO_HOME
DIRSTACKSIZE=20

# --- globbing / completion behaviour ---
setopt EXTENDED_GLOB
setopt NO_CASE_GLOB
setopt NUMERIC_GLOB_SORT
setopt GLOB_DOTS               # `*` matches dotfiles too
setopt GLOB_STAR_SHORT         # `**.c` instead of `**/*.c`
setopt INTERACTIVE_COMMENTS    # allow `# comment` in interactive shell
setopt LONG_LIST_JOBS
setopt MULTIOS                 # `cmd >a >b` writes to both
setopt NOTIFY                  # report bg job status immediately
setopt RC_QUOTES               # '' inside '...' becomes a literal '

# --- safety / quality of life ---
setopt NO_BEEP
setopt NO_FLOW_CONTROL         # frees ctrl-s
setopt PROMPT_SUBST
unsetopt CORRECT               # avoid annoying autocorrect prompts
unsetopt NOMATCH               # don't error on glob with no matches (e.g. `scp host:*.txt .`)

# --- word boundaries: treat /, ., -, _ as word separators ---
# Default WORDCHARS keeps these inside words, which makes Alt-b/f and
# Ctrl-w awkward in paths and kebab-case identifiers.
WORDCHARS='*?[]~&;!#$%^(){}<>'

# --- reporting ---
REPORTTIME=10                  # auto-print "user/sys/cpu" for cmds >10s
TIMEFMT=$'\n%J\n  user: %U  sys: %S  cpu: %P  total: %*Es'
