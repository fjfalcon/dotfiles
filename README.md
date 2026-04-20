# dotfiles

Personal Arch + Sway setup. Solarized Dark across the stack, JetBrainsMono
Nerd Font everywhere, modular zsh on zinit.

## What's inside

| Path                    | Purpose |
|-------------------------|---------|
| `sway/`                 | Sway WM config + screenshot pipeline + cheatsheet (`Mod+F1`) |
| `swaylock/`             | Lock screen — Solarized Dark, blur + clock |
| `waybar/`               | Top bar — workspaces, language, network, audio, CPU/RAM/temp, clock |
| `alacritty/`            | Terminal — Solarized Dark, JetBrainsMono Nerd Font |
| `dunst/`                | Notifications — Solarized Dark, modern format |
| `fuzzel/`               | App launcher (replaces bemenu) |
| `fontconfig/`           | Font defaults — JetBrainsMono mono / Inter UI / Noto fallback |
| `zsh/`                  | Modular zsh on **zinit**, p10k prompt, conf.d/ fragments |
| `nvim/`                 | lazy.nvim config |
| `i3/`, `i3status-rust/` | Legacy i3 fallback (kept for parity) |
| `vim/`, `ideavimrc`     | Vim + IdeaVim |
| `xdg-desktop-portal/`   | Portal selection for Sway |
| `applications/`         | `.desktop` entries for bare scripts (so fuzzel sees them) |
| `install.sh`            | Idempotent symlink bootstrap |
| `packages.txt`          | Packages installed via `pacman` |

## Install on a fresh machine

```sh
sudo pacman -S git base-devel
git clone <this repo> ~/dev/dotfiles
cd ~/dev/dotfiles
./install.sh --packages   # installs missing pacman packages too
```

Subsequent runs:

```sh
./install.sh              # only fix missing/broken symlinks
./install.sh --dry-run    # show what would change
./install.sh --force      # overwrite symlinks pointing elsewhere
```

The script is idempotent. Anything already present in `~/.config/` is moved
to `dotfiles/backup/<timestamp>/` before being replaced — never destroyed.

## After install

1. **Secrets file** (gitignored):

   ```sh
   cp zsh/private.zsh.example ~/.config/zsh/private.zsh
   $EDITOR ~/.config/zsh/private.zsh
   chmod 600 ~/.config/zsh/private.zsh
   ```

   Put VPN passwords, work-only aliases, API tokens here. Never in `zsh/conf.d/`.

2. **First zsh launch** clones zinit + plugins (~3-5s once, then sub-100ms).

3. **Reload sway** to pick up changes:

   ```sh
   swaymsg reload
   ```

4. **Wallpapers** are referenced from `~/wallpaper/`. Edit `sway/config`
   `output * bg` lines if you keep them elsewhere or want a solid color:

   ```
   output * bg #002b36 solid_color
   ```

## Sway shortcuts

`Mod+F1` opens the in-config cheatsheet (`sway/cheatsheet.txt`). Highlights:

| Shortcut             | Action |
|----------------------|--------|
| `Mod+Return`         | terminal |
| `Mod+d` / `Mod+Shift+d` | launcher (fuzzel) / run binary |
| `Mod+e` / `Mod+b`    | files / browser |
| `Mod+Shift+s` / `Print` | screenshot region / full |
| `Mod+Ctrl+Print`     | region → swappy editor |
| `Mod+F12`            | lock now |
| `Mod+Tab`            | last workspace |
| `Mod+r`              | resize mode |
| `Mod+g`              | gromit-mpx mode |

Idle timeline: lock @ 10 min → displays off @ 12 min → wake on input.

## zsh layout

```
~/.zshrc                   -> zsh/zshrc          (entry, p10k instant-prompt, zinit boot)
~/.p10k.zsh                -> zsh/p10k.zsh
~/.config/zsh/             -> zsh/
              conf.d/00-options.zsh   shell options + history
              conf.d/10-paths.zsh     PATH, exports, fzf colors
              conf.d/30-plugins.zsh   zinit plugin loads
              conf.d/40-aliases.zsh   public aliases (git, k8s contexts, eza)
              conf.d/50-keys.zsh      keybindings
              private.zsh             gitignored — secrets, work-only aliases
```

Plugins via zinit (all `wait/lucid` for fast startup):

- `OMZP::git`, `OMZP::sudo`, `OMZP::extract`, `OMZP::colored-man-pages`
- `zsh-users/zsh-completions`
- `zdharma-continuum/fast-syntax-highlighting`
- `zsh-users/zsh-autosuggestions`
- `Aloxaf/fzf-tab`
- `zoxide` (or fallback `z`)

## Theme

Solarized Dark base, accents:

| Color  | Hex       | Used for |
|--------|-----------|----------|
| base03 | `#002b36` | terminal/bar background |
| base02 | `#073642` | module backgrounds |
| blue   | `#268bd2` | focused, clock, selection |
| cyan   | `#2aa198` | window title, CPU |
| green  | `#859900` | RAM, success state |
| yellow | `#b58900` | volume, sway mode |
| red    | `#dc322f` | urgent, errors |
| orange | `#cb4b16` | screenshare indicator |
