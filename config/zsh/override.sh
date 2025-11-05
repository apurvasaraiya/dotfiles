# ~/.config/zsh/override.sh
# Key binding overrides - switches from vim mode to emacs mode

# Enable emacs key bindings (overrides vim mode from init.sh)
bindkey -e

# Explicitly bind common navigation keys
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

bindkey -v