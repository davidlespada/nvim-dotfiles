# nvim-dotfiles (CachyOS)

Minimal Neovim config with `lazy.nvim`, `tokyonight` + `treesitter`.

## Fresh install on CachyOS / Arch

```bash
sudo pacman -S --needed neovim git ripgrep gcc tree-sitter-cli
# backup existing config if any
[ -d ~/.config/nvim ] && mv ~/.config/nvim ~/nvim-backup-$(date +%Y%m%d)
git clone https://github.com/davidlespada/nvim-dotfiles.git ~/.config/nvim
nvim  # lazy.nvim bootstraps automatically, then :Lazy sync
```

Or after cloning, run:

```bash
./install.sh
```

## Layout

```
init.lua
lazy-lock.json
lua/daboio/plugins/init.lua       -> tokyonight
lua/daboio/plugins/treesitter.lua -> treesitter (lua, python)
```

## Update plugins / lockfile

Inside nvim: `:Lazy update`, then commit the changed `lazy-lock.json`.

## Restore old full config

Previous full config (LSP, cmp, telescope, etc.) is preserved in branch:

```bash
git checkout backup/2026-10-05-full-config
```
