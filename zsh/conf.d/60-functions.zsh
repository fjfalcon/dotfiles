# Helper functions. Anything that needs arguments or branching belongs here
# rather than as an alias.

# ---------------------------------------------------------- filesystem ------

# mkcd <dir>  : mkdir -p && cd
mkcd() { mkdir -p -- "$1" && cd -- "$1" || return; }

# take <repo|dir>  : git clone (or mkdir) and cd into it
take() {
  if [[ "$1" =~ '^(https?://|git@|ssh://)' ]]; then
    git clone --depth=1 -- "$1" || return
    local d=${${1##*/}%.git}
    cd -- "$d"
  else
    mkcd "$1"
  fi
}

# cdf  : cd to the directory containing a file picked via fzf
cdf() {
  local file
  file=$(fzf) || return
  cd -- "${file:h}"
}

# cpf <file>  : copy absolute file path to clipboard
cpf() {
  local p; p=${1:-$PWD}
  print -rn -- "${p:A}" | pbcopy && echo "copied: ${p:A}"
}

# backup <file>  : foo.txt -> foo.txt.YYYYMMDD-HHMMSS.bak
backup() {
  for f in "$@"; do
    cp -a -- "$f" "${f}.$(date +%Y%m%d-%H%M%S).bak" || return
    echo "backed up $f"
  done
}

# extract is provided by OMZP::extract — kept as a fallback if the plugin
# isn't loaded yet.
if ! typeset -f extract >/dev/null; then
  extract() {
    [[ -f "$1" ]] || { echo "extract: '$1' is not a file"; return 1 }
    case "$1" in
      *.tar.bz2|*.tbz2) tar xjf "$1" ;;
      *.tar.gz|*.tgz)   tar xzf "$1" ;;
      *.tar.xz|*.txz)   tar xJf "$1" ;;
      *.tar.zst)        tar --use-compress-program=unzstd -xf "$1" ;;
      *.tar)            tar xf  "$1" ;;
      *.zip)            unzip   "$1" ;;
      *.rar)            unrar x "$1" ;;
      *.7z)             7z x    "$1" ;;
      *.gz)             gunzip  "$1" ;;
      *.bz2)            bunzip2 "$1" ;;
      *.xz)             unxz    "$1" ;;
      *.zst)            unzstd  "$1" ;;
      *)                echo "extract: unknown archive type: $1"; return 1 ;;
    esac
  }
fi

# ------------------------------------------------------------ network -------

# killport <port>  : kill the process listening on a TCP port
killport() {
  local port=$1
  [[ -z $port ]] && { echo "usage: killport <port>"; return 1 }
  local pids
  pids=$(ss -ltnp "sport = :$port" 2>/dev/null | awk -F'pid=' 'NR>1 {split($2,a,","); print a[1]}' | sort -u)
  if [[ -z $pids ]]; then echo "nothing listening on :$port"; return 1; fi
  echo "$pids" | xargs -r -I{} sh -c 'echo "killing pid {}"; kill {}'
}

# serve [port]  : http server in $PWD (python3) — default port 8000
serve() {
  local port=${1:-8000}
  echo "serving $PWD at http://localhost:$port"
  python3 -m http.server "$port"
}

# json <url>  : pretty-print JSON from URL with jq
json() { curl -sSL "$1" | jq .; }

# pingfast <host>  : tight ping with stats
pingfast() { ping -c 10 -i 0.2 "$1"; }

# ----------------------------------------------------------- processes ------

# fkill  : pick processes via fzf and kill them
fkill() {
  local pids
  pids=$(ps -eo pid,user,comm,args --no-headers \
    | awk '{printf "%-7s %-10s %s\n",$1,$2,substr($0,index($0,$3))}' \
    | fzf --multi --header='select processes to kill' --preview 'echo {}' \
    | awk '{print $1}')
  [[ -n $pids ]] && echo "$pids" | xargs -r kill -${1:-15}
}

# ------------------------------------------------------------- git ----------

# fco  : fzf checkout branch
fco() {
  local b
  b=$(git branch --all --color=always | grep -v HEAD \
       | fzf --ansi --header='select branch to checkout' \
       | sed -E 's/^[* ]+//;s|^remotes/[^/]+/||') || return
  git checkout -- "$b"
}

# fcoc : fzf checkout commit
fcoc() {
  local c
  c=$(git log --oneline --color=always | fzf --ansi --header='select commit') || return
  git checkout "${c%% *}"
}

# fshow : fzf-browse git log with diff preview
fshow() {
  git log --graph --color=always \
    --format='%C(auto)%h %s %C(blue)%cr %C(dim)%an' "$@" \
  | fzf --ansi --no-sort --reverse --tiebreak=index \
        --preview 'echo {} | grep -o "[a-f0-9]\{7,\}" | head -1 | xargs -I@ git show --color=always @ | delta' \
        --bind 'enter:execute(echo {} | grep -o "[a-f0-9]\{7,\}" | head -1 | xargs -I@ sh -c "git show --color=always @ | delta | less -R")'
}

# gitignore <lang ...>  : write .gitignore from gitignore.io
gi() {
  curl -sLw "\n" "https://www.toptal.com/developers/gitignore/api/${(j:,:)@}"
}

# ----------------------------------------------------------- search/edit ----

# rgv <pattern>  : ripgrep + fzf preview, enter opens in $EDITOR at line
rgv() {
  local result
  result=$(rg --color=always --line-number --no-heading --smart-case "${@:-}" \
    | fzf --ansi --delimiter=':' --preview='bat --color=always {1} --highlight-line {2}' \
          --preview-window='right,60%,+{2}/2') || return
  ${EDITOR:-nvim} "${result%%:*}" "+${${result#*:}%%:*}"
}

# fe  : fzf find file, open in $EDITOR
fe() {
  local f
  f=$(fzf --preview 'bat --color=always {} 2>/dev/null || cat {}') && ${EDITOR:-nvim} "$f"
}

# ------------------------------------------------------------ misc ----------

# weather2 <city>  : graphical wttr.in (default Moscow)
weather2() { curl -s "wttr.in/${1:-Moscow}?lang=ru&M"; }

# pkginfo <pkg>  : pacman details + size
pkginfo() {
  pacman -Si "$1" 2>/dev/null || pacman -Qi "$1"
}

# pkgsize  : top 30 installed packages by size
pkgsize() {
  pacman -Qi | awk '/^Name/{n=$3} /^Installed Size/{print $4 $5"\t"n}' \
    | sort -hr | head -30
}

# uniport <PORT>  : show what owns a TCP port
uniport() { ss -tulnp "sport = :${1:?usage: uniport PORT}"; }

# manc <cmd>  : `man -P "less +/^DESCRIPTION"` — jump straight to description
manc() { man -P "less +/^DESCRIPTION" "$@"; }

# dotsync  : push live config changes to the dotfiles repo
dotsync() {
  local repo=~/dev/dotfiles
  [[ -d $repo ]] || { echo "no $repo"; return 1 }
  for d in alacritty dunst fontconfig fuzzel sway swaylock waybar zsh xdg-desktop-portal; do
    if [[ -d ~/.config/$d ]]; then
      rm -rf "$repo/$d"
      cp -a ~/.config/$d "$repo/$d"
      echo "synced $d"
    fi
  done
  rm -f "$repo/zsh/private.zsh"
  ( cd "$repo" && git status -s )
}
