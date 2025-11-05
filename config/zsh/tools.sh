# ~/.config/zsh/tools.sh
# Initialize development tools and shell enhancements

# ZSH syntax highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none

# ZSH autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Java version manager
eval "$(jenv init -)"

# Ruby version manager
eval "$(rbenv init -)"

# Starship prompt
eval "$(starship init zsh)"

# Zoxide (smart cd)
eval "$(zoxide init zsh)"

# FZF fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
