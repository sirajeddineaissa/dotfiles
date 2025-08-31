# ~/.dotfiles/zsh/.zshrc

export EDITOR=nvim
export BROWSER=open
export DOTFILES="$HOME/Developer/.dotfiles"

# mise for version management
eval "$(mise activate zsh)"

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# History configuration
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY

# Better directory navigation
setopt AUTO_LIST
setopt AUTO_MENU

# Case-insensitive completion without slowdown
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ~/.zsh/cache

# Skip global compinit for faster startup
skip_global_compinit=1

# Completions with caching for performance
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Lazy load plugins only if they exist
if [[ -f $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
fi

if [[ -f $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Enhanced fzf integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# fzf performance and UX improvements
export FZF_DEFAULT_OPTS='
  --height 40%
  --layout=reverse
  --border
  --preview="[[ -f {} ]] && head -200 {}"
  --preview-window=right:40%:wrap
'

# Colored man pages
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# Aliases
alias dotfiles='cd $DOTFILES'
alias zshconfig='nvim ~/.zshrc'
alias weztermconfig='nvim ~/.config/wezterm/wezterm.lua'

mkcd() { mkdir -p "$1" && cd "$1" }

# Git branch in prompt (simple version)
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
setopt PROMPT_SUBST
PROMPT='%F{blue}%~%f%F{red}${vcs_info_msg_0_}%f $ '
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
