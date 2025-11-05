# ~/.config/zsh/init.sh
# ZSH initialization - colors, completion, and key bindings

# Colors
autoload -U colors && colors
export CLICOLOR=1
export LSCOLORS=ExGxFxdxCxDxDxxbaDecac # Example color settings

# Basic auto/tab complete
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots) # hidden files

# Vim mode (will be overridden by override.sh if emacs mode is preferred)
bindkey -v
