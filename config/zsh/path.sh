# ~/.config/zsh/path.sh
# PATH configuration for various tools and binaries

# Homebrew - detect Apple Silicon vs Intel Mac
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  # Apple Silicon Mac
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
  # Intel Mac
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Go binaries
export PATH=${PATH}:${HOME}/bin
export PATH=${PATH}:${GOPATH}/bin

# Custom development binaries
export PATH="${PATH}:${HOME}/dev/bin"
