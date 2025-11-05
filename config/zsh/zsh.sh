# ~/.config/zsh/zsh.sh
# Main ZSH configuration loader - sources all modular configuration files
# This file should be sourced from ~/.zshrc

# Source scripts and tools in order
source ${ZDOTDIR}/init.sh      # Initialize ZSH (colors, completion, vim mode)
source ${ZDOTDIR}/history.sh   # History configuration
source ${ZDOTDIR}/git.sh       # Git aliases and functions
source ${ZDOTDIR}/alias.sh     # Shell aliases
source ${ZDOTDIR}/env.sh       # Environment variables (must be before path.sh for GOPATH)
source ${ZDOTDIR}/path.sh      # PATH configuration (uses GOPATH from env.sh)
source ${ZDOTDIR}/tools.sh     # Tool initialization (starship, zoxide, etc.)
source ${ZDOTDIR}/override.sh  # Key binding overrides
