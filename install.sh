#!/bin/bash
set -e

echo "🚀 Installing dotfiles..."

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ macOS only"
    exit 1
fi

if ! xcode-select -p &> /dev/null; then
    echo "📦 Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "⏳ Complete installation and rerun script"
    exit 1
fi

if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "🔧 Installing tools..."
brew install git stow mise neovim fzf zsh-autosuggestions zsh-syntax-highlighting
brew install --cask wezterm

if [ ! -d "$HOME/Developer/.dotfiles" ]; then
    echo "📥 Cloning dotfiles..."
    mkdir -p ~/Developer
    git clone https://github.com/sirajeddineaissa/dotfiles.git ~/Developer/.dotfiles
    cd ~/Developer/.dotfiles
else
    cd ~/Developer/.dotfiles
    git pull
fi

echo "💾 Backing up configs..."
[[ -f ~/.zshrc ]] && mv ~/.zshrc ~/.zshrc.backup
[[ -d ~/.config/wezterm ]] && mv ~/.config/wezterm ~/.config/wezterm.backup
[[ -d ~/.config/nvim ]] && mv ~/.config/nvim ~/.config/nvim.backup

mkdir -p ~/.config/wezterm ~/.config/nvim

echo "🔗 Linking configs..."
stow zsh wezterm nvim

$(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc

echo "⚡ Installing runtimes..."
mise install node@lts python@latest go@latest

echo ""
echo "✅ Done!"
echo ""
echo "🎉 Installed:"
echo "  • Optimized zsh with fzf"
echo "  • WezTerm with custom theme"
echo "  • Neovim configuration"
echo "  • Node.js, Python, Go"
echo ""
echo "🚀 Next: Restart terminal and open WezTerm"
