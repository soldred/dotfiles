if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# --- Zinit ---
export ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    echo "💡 Installing Zinit plugin manager..."
    mkdir -p "$(dirname "$ZINIT_HOME")" && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi








# --- CONFIGURATIONS ---

# --- Zinit plugin manager ---
# Source Zinit if it exists
if [ -f "${ZINIT_HOME}/zinit.zsh" ]; then
    source "${ZINIT_HOME}/zinit.zsh"
else
    print -P "%F{red}Warning: zinit not found at ${ZINIT_HOME}%f"
fi

# --- Exports and History ---
export EDITOR="nvim"
export VISUAL="nvim"

export HISTSIZE=10000
export SAVEHIST=$HISTSIZE
export HISDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# --- Plugins ---
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-completions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::git

# --- Completions ---
autoload -Uz compinit
compinit

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --tree --color=always $realpath'

# --- Aliases and functions ---

if command -v eza &> /dev/null; then
    alias ls='eza --icons'
    alias ll='eza -l --icons'
    alias la='eza -la --icons'
    alias llt='eza -lT --icons'
    alias wtf='eza -la --icons'
fi

if command -v bat &> /dev/null; then
    alias cat='bat --paging=never'
fi

alias c='clear'
alias vim='nvim'

alias please='sudo'
alias install='sudo pacman -S'
alias sorry='sudo pacman -Rs'
alias update='sudo pacman -Syu'

alias fuck='sudo !!'
alias gtfo='exit'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Function
mkcd() { mkdir -p "$1" && cd "$1"; }
bak() { cp "$1" "$1.bak"; }

# --- Shell Integrations ---
if command -v fzf &> /dev/null; then eval "$(fzf --zsh)"; fi
if command -v zoxide &> /dev/null; then eval "$(zoxide init --cmd cd zsh)"; fi
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi
# if command -v oh-my-posh &> /dev/null; then
#  if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
#   eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/config.json)"
#  fi
# fi
