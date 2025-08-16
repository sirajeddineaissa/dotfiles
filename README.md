# dotfiles

My macOS development environment. Fast shell, modern terminal, clean editor setup.

## What's included

- **zsh** - Optimized config with autosuggestions and syntax highlighting
- **WezTerm** - Terminal with native macOS controls and custom theme
- **Neovim** - Text editor config
- **mise** - Version manager
- **fzf** - Fuzzy finder for files and command history

## Install

One command installs everything:

```bash
curl -fsSL https://raw.githubusercontent.com/sirajeddineaissa/dotfiles/main/install.sh | bash
```

This will:
- Install Homebrew and required tools
- Clone this repo to `~/Developer/.dotfiles`
- Link configs using GNU Stow
- Set up shell plugins and key bindings
- Install latest Node.js, Python, and Go (script can be customized)
