# ~/.config/zsh/env.sh
# Environment variables and tool-specific configurations

# Go configuration
export GOPATH=$(go env GOPATH)

# Zoxide data directory
export _ZO_DATA_DIR="${HOME}/.config/zoxide"

# Local binaries
export PATH="$HOME/.local/bin:$PATH"

# Load Rust/Cargo environment if available
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
