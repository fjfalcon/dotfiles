# Aliases. Secrets-bearing and host-only ones live in private.zsh.

# --- pbcopy/pbpaste shims (Wayland) ---
if command -v wl-copy >/dev/null 2>&1; then
  alias pbcopy='wl-copy'
  alias pbpaste='wl-paste'
elif command -v xclip >/dev/null 2>&1; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi

# --- modern coreutils replacements (only if installed) ---
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -l --icons --group-directories-first --git'
  alias la='eza -la --icons --group-directories-first --git'
  alias lt='eza --tree --level=2 --icons'
  alias ltt='eza --tree --level=3 --icons'
else
  alias ll='ls -lh'
  alias la='ls -lha'
fi
command -v bat   >/dev/null 2>&1 && alias cat='bat --paging=never' && alias batp='bat --plain'
command -v dust  >/dev/null 2>&1 && alias dux='dust'        # leave `du` alone
command -v duf   >/dev/null 2>&1 && alias dfx='duf'         # leave `df` alone
command -v procs >/dev/null 2>&1 && alias psx='procs'       # leave `ps` alone
command -v btop  >/dev/null 2>&1 && alias top='btop' && alias htop='btop'
# rg replaces grep only inside our convenience `hgrep`; plain `grep` stays.

# --- editor ---
alias v='nvim'
alias nv='nvim'
alias vim='nvim'
alias vi='nvim'
alias nvs='cd ~/.config/nvim && nvim'        # edit nvim config
alias zshrc='nvim ~/.config/zsh/zshrc'
alias zshc='nvim ~/.config/zsh/conf.d/'
alias swayrc='nvim ~/.config/sway/config'
alias waybarrc='nvim ~/.config/waybar/config.jsonc'

# --- reload helpers ---
alias reload='exec zsh -l'
alias swayreload='swaymsg reload'
alias barreload='pkill -SIGUSR2 waybar'

# --- git (kept from old zshrc + a few extras) ---
alias g='git'
alias gs='git status -sb'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate -n 30'
alias glo='git log --oneline --graph --decorate --all'
alias ga='git add'
alias gap='git add -p'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull --rebase --autostash'
alias gst='git stash'
alias gsp='git stash pop'
alias gca='git commit -am'
alias gcm='git commit -m'
alias gcam='git commit -a --amend --no-edit'
alias gcamr='git commit -a --amend --no-edit && git review'
alias gcom='git fetch && git checkout origin/master'
alias grom='git rebase origin/master'
alias gri='git rebase -i'
alias gwip='git add -A && git commit -m "wip" --no-verify'
alias gunwip='git reset HEAD~1'
command -v lazygit >/dev/null 2>&1 && alias lg='lazygit'

# --- systemd / pacman quality of life (Arch) ---
alias sc='sudo systemctl'
alias scu='systemctl --user'
alias jc='journalctl'
alias jcu='journalctl --user'
alias jcb='sudo journalctl -b -e'
alias pacs='pacman -Ss'                       # search
alias pacq='pacman -Qs'                       # query installed
alias paci='sudo pacman -S'
alias pacr='sudo pacman -Rns'
alias pacu='sudo pacman -Syu'
alias pacorphan='pacman -Qtdq | ifne sudo pacman -Rns -'
alias pacclean='paccache -rk2 && paccache -ruk0'
alias paclog='tail -f /var/log/pacman.log'

# --- navigation: project shortcuts ---
# Host- and work-specific project paths live in private.zsh.
alias dev='cd ~/dev'
alias dotfiles='cd ~/dev/dotfiles'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# --- Oracle sqlplus with rlwrap if available ---
if command -v rlwrap >/dev/null 2>&1 && [[ -x /opt/oracle/instantclient_21_4/sqlplus ]]; then
  alias sqlplus='rlwrap /opt/oracle/instantclient_21_4/sqlplus'
fi

# --- kubernetes ---
# Cluster-specific contexts, wrapper-tool aliases and token helpers live in
# private.zsh — they reveal internal infra naming.
alias k='kubectl'

# --- screenshots ---
alias rmscrot='rm -rf ~/scrot/*'
alias scrot-last='ls -t ~/scrot/*.png 2>/dev/null | head -1'

# --- network helpers ---
alias myip='curl -s https://ifconfig.me; echo'
alias localip='ip -brief -color address'
alias ports='ss -tulnp'                       # listening sockets
alias ping='ping -c 5'
alias wget='wget -c'                          # always continue

# --- misc ---
alias :q='exit'
alias :wq='exit'
alias path='echo -e ${PATH//:/\\n}'
alias fpath='echo -e ${(F)fpath}'
alias h='history -i 1 | tail -50'
alias hgrep='history -i 1 | rg --color=always'
alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'                             # only confirms for >3 files
alias ip='ip --color=auto'
alias diff='diff --color=auto'
alias ssha='ssh-add ~/.ssh/id_ed25519 ~/.ssh/id_rsa(N) 2>/dev/null'

# --- weather / cheatsheets (uses curl) ---
alias weather='curl -s "wttr.in/Moscow?lang=ru&M&format=v2"'
alias cheat='f(){ curl -s "cheat.sh/$*" }; f'
