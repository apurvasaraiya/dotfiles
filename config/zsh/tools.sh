# ~/.config/zsh/tools.sh
# Initialize development tools and shell enhancements

# ZSH syntax highlighting
if command -v brew &> /dev/null; then
    # macOS with Homebrew
    local zsh_syntax_file="$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    if [[ -f "$zsh_syntax_file" ]]; then
        source "$zsh_syntax_file"
        (( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
        ZSH_HIGHLIGHT_STYLES[path]=none
        ZSH_HIGHLIGHT_STYLES[path_prefix]=none
    fi
elif [[ -f "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    # Linux with manual installation
    source "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    (( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
    ZSH_HIGHLIGHT_STYLES[path]=none
    ZSH_HIGHLIGHT_STYLES[path_prefix]=none
fi

# ZSH autosuggestions
if command -v brew &> /dev/null; then
    # macOS with Homebrew
    local zsh_autosuggestions_file="$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    [[ -f "$zsh_autosuggestions_file" ]] && source "$zsh_autosuggestions_file"
elif [[ -f "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    # Linux with manual installation
    source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Java version manager
command -v jenv &> /dev/null && eval "$(jenv init -)"

# Ruby version manager
command -v rbenv &> /dev/null && eval "$(rbenv init -)"

# Starship prompt
command -v starship &> /dev/null && eval "$(starship init zsh)"

# Zoxide (smart cd)
command -v zoxide &> /dev/null && eval "$(zoxide init zsh)"

# FZF fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
