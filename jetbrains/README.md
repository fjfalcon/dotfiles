# JetBrains IDE theme bootstrap

Drop-in `options/` overrides applied to every detected JetBrains product
(`IntelliJIdea*`, `PyCharm*`, `DataGrip*`, `CLion*`, `GoLand*`, …) by
`install.sh`.

* `laf.xml` — pins the IDE LAF to the **Solarized Dark** theme provided by
  the **Solarized Themes** plugin (`com.4lex4.intellij.solarized`,
  themeId `6a41f0b6-ad89-4fc0-a326-ff52958b07b7`).
* `colors.scheme.xml` — sets the editor colour scheme to `Solarized Dark`.

## Prerequisite

Install the plugin once per IDE (or use **Settings | Plugins | Marketplace**
to install across all JetBrains products):

> Solarized Themes — by 4lex4
> https://plugins.jetbrains.com/plugin/12784-solarized-themes

If the plugin is missing, the IDE will fall back to its bundled default
theme on first launch and silently drop the unknown `themeId`.

## Why copy and not symlink?

Each product owns lots of unrelated state under `options/` (window layout,
recent projects, keymaps). We only want to mirror these two files; the rest
must stay product-local.
