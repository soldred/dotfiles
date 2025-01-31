export ZSH="$HOME/.oh-my-zsh"

# ZSH_THEME="xiong-chiamiov-plus"
# ZSH_THEME="powerlevel10k/powerlevel10k"
eval "$(starship init zsh)"
# ENABLE_CORRECTION="false"

plugins=(git sudo zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

unsetopt correct
unsetopt correct_all

# bun completions
[ -s "/home/yehorych/.bun/_bun" ] && source "/home/yehorych/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
