# DBeaver Solarized Dark

Eclipse-style preference files copied into the active DBeaver workspace
(`~/.local/share/DBeaverData/workspace6/.metadata/.plugins/org.eclipse.core.runtime/.settings/`)
by `install.sh`.

| File                                          | What it does                                                  |
|-----------------------------------------------|---------------------------------------------------------------|
| `org.eclipse.e4.ui.css.swt.theme.prefs`       | switches Eclipse SWT theme to **Dark**                        |
| `org.eclipse.ui.workbench.prefs`              | tab background/foreground colours (Solarized base02/blue)     |
| `org.eclipse.ui.editors.prefs`                | generic text-editor background/selection (Solarized base03)   |
| `org.jkiss.dbeaver.ui.editors.sql.prefs`      | SQL syntax-highlight palette (keywords, strings, types, …)    |

Solarized RGB values are inlined (no external import). Adjust to taste.

## Why copy and not symlink?

DBeaver rewrites these `.prefs` files on every shutdown, so symlinks would
be silently replaced. The installer copies on first run and backs up any
pre-existing version into `backup/`.

## Apply later

Re-run `./install.sh` after launching DBeaver at least once (so the
workspace dir exists). The script skips silently otherwise and prints a
warning.
