# Before using this config make sure you have install the following packages:
# zsh git eza bat fzf zoxide starship neovim
# --- For 'extract' function (optional) ---
# Fedora: sudo dnf install unrar p7zip-plugins
# Ubuntu: sudo apt install unrar p7zip-full
# Arch:   sudo pacman -S unrar p7zip

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

# --- Plugins (Optimized) ---
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-completions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search

zinit snippet OMZP::sudo
zinit snippet OMZP::git

# --- Completions ---
autoload -Uz compinit
local zcompdump_path="$HOME/.config/zsh/.zcompdump"
if [[ ! -f "$zcompdump_path" || "$zcompdump_path" -ot "$HOME/.config/zsh/.zshrc" ]]; then
    compinit -i -d "$zcompdump_path"
else
    compinit -C -i -d "$zcompdump_path"
fi

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --tree --color=always $realpath'

# --- Aliases and functions ---

if command -v eza &> /dev/null; then
    alias ls='eza --icons'
    alias lsl='eza -l --icons'
    alias lsa='eza -la --icons'
    alias lst='eza -T --icons'
    alias lslt='eza -lT --icons'
    alias wtf='eza -la --icons'
fi

if command -v bat &> /dev/null; then
    alias cat='bat --paging=never'
fi

alias c='clear'
alias vim='nvim'

alias please='sudo'
# NOTE: I'm still distrohopping from time to time, so...
if command -v dnf &> /dev/null; then
    # Fedora
    alias install='sudo dnf install'
    alias sorry='sudo dnf remove'
    alias update='sudo dnf upgrade --refresh -y'
elif command -v apt &> /dev/null; then
    # Ubuntu / Debian
    alias install='sudo apt install'
    alias sorry='sudo apt remove'
    alias update='sudo apt update && sudo apt upgrade -y'
elif command -v pacman &> /dev/null; then
    # Arch Linux
    alias install='sudo pacman -S'
    alias sorry='sudo pacman -Rns'
    alias update='sudo pacman -Syu'
fi
# alias install='sudo dnf install'
# alias sorry='sudo dnf remove'
# alias update='sudo dnf update --refresh -y'

alias fuck='sudo $(fc -ln -1)'
alias gtfo='exit'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias zcfg="nvim ~/.config/zsh/.zshrc"
alias zsrc="source ~/.config/zsh/.zshrc"

# Function
mkcd() { mkdir -p "$1" && cd "$1"; }
bak() { mv "$1" "$1.bak"; }
unbak() { mv "$1.bak" "$1"; }

extract() {
    if [ -z "$1" ]; then
        echo "Usage: extract <file>"
        return 1
    fi
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.tar.xz)  tar xf "$1"  ;;
            *.bz2)     bunzip2 "$1" ;;
            *.gz)      gunzip "$1"  ;;
            *.tar)     tar xf "$1"  ;;
            *.tbz2)    tar xjf "$1" ;;
            *.tgz)     tar xzf "$1" ;;
            *.zip)     unzip "$1"   ;;
            *.Z)       uncompress "$1" ;;
            *.rar)     unrar x "$1" ;;
            *.7z)      7z x "$1"    ;;
            *)         echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# --- Shell Integrations ---
local cache_dir="$HOME/.config/zsh/cache"
mkdir -p "$cache_dir"

cache_init_script() {
    local cmd_name="$1"
    local init_cmd="$2"
    local cache_file="$cache_dir/${cmd_name}_init.zsh"
    local cmd_path
    if ! cmd_path="$(command -v "$cmd_name")"; then return 1; fi
    if [[ ! -f "$cache_file" || "$cmd_path" -nt "$cache_file" ]]; then
        eval "$init_cmd" > "$cache_file"
    fi
    source "$cache_file"
}

cache_init_script "starship" "starship init zsh"
cache_init_script "zoxide" "zoxide init --cmd cd zsh"
cache_init_script "fzf" "fzf --zsh"

unset -f cache_init_script
