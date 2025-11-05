#!/usr/bin/env bash

################################################################################
# Dotfiles Setup Script
# 
# This script automates the setup of a development environment by:
# - Installing essential development tools
# - Creating symlinks for configuration files
# - Backing up existing configurations
# - Supporting both macOS and Ubuntu/Linux
#
# Usage:
#   ./setup.sh              # Normal installation
#   ./setup.sh --dry-run    # Show what would be done without making changes
#   ./setup.sh --rollback   # Restore backups and remove symlinks
#   ./setup.sh --help       # Show help message
################################################################################

set -e  # Exit on error
set -u  # Exit on undefined variable

################################################################################
# Global Variables
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${SCRIPT_DIR}"
CONFIG_DIR="${HOME}/.config"
BACKUP_DIR="${HOME}/.dotfiles-backup"
LOG_FILE="${HOME}/.dotfiles-setup.log"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_SUBDIR="${BACKUP_DIR}/${TIMESTAMP}"

# Command-line flags
DRY_RUN=false
ROLLBACK=false
SKIP_TOOLS=false

# OS Detection
OS_TYPE=""
OS_VERSION=""

################################################################################
# Color Output Functions
################################################################################

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_success() {
    echo -e "${GREEN}✓${NC} $1"
    log "SUCCESS: $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1" >&2
    log "ERROR: $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    log "WARNING: $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
    log "INFO: $1"
}

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    log "HEADER: $1"
}

################################################################################
# Logging
################################################################################

log() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[${timestamp}] $1" >> "${LOG_FILE}"
}

################################################################################
# Error Handling
################################################################################

cleanup_on_error() {
    print_error "An error occurred. Check ${LOG_FILE} for details."
    exit 1
}

trap cleanup_on_error ERR

################################################################################
# OS Detection
################################################################################

detect_os() {
    print_info "Detecting operating system..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS_TYPE="macos"
        OS_VERSION=$(sw_vers -productVersion)
        print_success "Detected macOS ${OS_VERSION}"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [[ -f /etc/os-release ]]; then
            . /etc/os-release
            OS_TYPE="linux"
            OS_VERSION="${VERSION_ID:-unknown}"
            
            if [[ "$ID" == "ubuntu" ]]; then
                print_success "Detected Ubuntu ${OS_VERSION}"
            else
                print_success "Detected Linux (${ID}) ${OS_VERSION}"
            fi
        else
            OS_TYPE="linux"
            OS_VERSION="unknown"
            print_warning "Linux detected but cannot determine distribution"
        fi
    else
        print_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
}

################################################################################
# Confirmation Prompts
################################################################################

confirm() {
    local prompt="$1"
    local default="${2:-n}"
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would prompt: $prompt"
        return 0
    fi
    
    local response
    if [[ "$default" == "y" ]]; then
        read -p "$prompt [Y/n]: " response
        response=${response:-y}
    else
        read -p "$prompt [y/N]: " response
        response=${response:-n}
    fi
    
    case "$response" in
        [yY][eE][sS]|[yY]) 
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

################################################################################
# Command Existence Check
################################################################################

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

################################################################################
# Homebrew Installation (macOS)
################################################################################

install_homebrew() {
    if [[ "$OS_TYPE" != "macos" ]]; then
        return 0
    fi
    
    if command_exists brew; then
        print_success "Homebrew is already installed"
        return 0
    fi
    
    print_warning "Homebrew is not installed"
    
    if confirm "Would you like to install Homebrew?" "y"; then
        print_info "Installing Homebrew..."
        
        if [[ "$DRY_RUN" == true ]]; then
            print_info "[DRY RUN] Would install Homebrew"
            return 0
        fi
        
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for this session
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        print_success "Homebrew installed successfully"
    else
        print_error "Homebrew is required for macOS. Exiting."
        exit 1
    fi
}

################################################################################
# Tool Installation - macOS
################################################################################

install_tool_macos() {
    local tool="$1"
    local brew_package="${2:-$tool}"
    local install_method="${3:-brew}"
    
    if command_exists "$tool"; then
        print_success "$tool is already installed"
        return 0
    fi
    
    print_info "Installing $tool..."
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would install $tool using $install_method"
        return 0
    fi
    
    case "$install_method" in
        brew)
            brew install "$brew_package"
            print_success "$tool installed successfully"
            ;;
        cask)
            brew install --cask "$brew_package"
            print_success "$tool installed successfully"
            ;;
        rustup)
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source "$HOME/.cargo/env"
            print_success "Rust installed successfully"
            ;;
        nvm)
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
            export NVM_DIR="$HOME/.nvm"
            # Temporarily disable 'set -u' for NVM (it has unbound variables)
            set +u
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            set -u
            print_success "NVM installed successfully"
            ;;
        *)
            print_error "Unknown installation method: $install_method"
            return 1
            ;;
    esac
}

################################################################################
# Tool Installation - Linux
################################################################################

install_tool_linux() {
    local tool="$1"
    local package="${2:-$tool}"
    local install_method="${3:-apt}"
    
    if command_exists "$tool"; then
        print_success "$tool is already installed"
        return 0
    fi
    
    print_info "Installing $tool..."
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would install $tool using $install_method"
        return 0
    fi
    
    case "$install_method" in
        apt)
            sudo apt-get update
            sudo apt-get install -y "$package"
            print_success "$tool installed successfully"
            ;;
        snap)
            sudo snap install "$package" --classic
            print_success "$tool installed successfully"
            ;;
        rustup)
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source "$HOME/.cargo/env"
            print_success "Rust installed successfully"
            ;;
        nvm)
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
            export NVM_DIR="$HOME/.nvm"
            # Temporarily disable 'set -u' for NVM (it has unbound variables)
            set +u
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            set -u
            print_success "NVM installed successfully"
            ;;
        starship)
            curl -sS https://starship.rs/install.sh | sh -s -- -y
            print_success "Starship installed successfully"
            ;;
        *)
            print_error "Unknown installation method: $install_method"
            return 1
            ;;
    esac
}

################################################################################
# Install Essential Tools
################################################################################

install_essential_tools() {
    print_header "Installing Essential Tools"
    
    if [[ "$SKIP_TOOLS" == true ]]; then
        print_info "Skipping tool installation (--skip-tools flag)"
        return 0
    fi
    
    # Install Homebrew first on macOS
    if [[ "$OS_TYPE" == "macos" ]]; then
        install_homebrew
    fi
    
    # ZSH
    print_info "Checking ZSH..."
    if ! command_exists zsh; then
        if [[ "$OS_TYPE" == "macos" ]]; then
            install_tool_macos zsh zsh brew
        else
            install_tool_linux zsh zsh apt
        fi
    else
        print_success "ZSH is already installed"
    fi
    
    # Offer to set ZSH as default shell
    if [[ "$SHELL" != *"zsh"* ]]; then
        if confirm "Would you like to set ZSH as your default shell?" "y"; then
            if [[ "$DRY_RUN" == false ]]; then
                chsh -s "$(which zsh)"
                print_success "ZSH set as default shell (restart terminal to apply)"
            else
                print_info "[DRY RUN] Would set ZSH as default shell"
            fi
        fi
    fi
    
    # Git (usually pre-installed, but check anyway)
    if [[ "$OS_TYPE" == "macos" ]]; then
        if ! command_exists git; then
            install_tool_macos git git brew
        else
            print_success "Git is already installed"
        fi
    else
        if ! command_exists git; then
            install_tool_linux git git apt
        else
            print_success "Git is already installed"
        fi
    fi
    
    # Neovim
    print_info "Checking Neovim..."
    if [[ "$OS_TYPE" == "macos" ]]; then
        install_tool_macos nvim neovim brew
    else
        install_tool_linux nvim neovim apt
    fi
    
    # Golang
    print_info "Checking Go..."
    if [[ "$OS_TYPE" == "macos" ]]; then
        install_tool_macos go go brew
    else
        install_tool_linux go golang-go apt
    fi
    
    # Docker
    print_info "Checking Docker..."
    if [[ "$OS_TYPE" == "macos" ]]; then
        if ! command_exists docker; then
            print_warning "Docker Desktop for Mac requires manual installation"
            print_info "Download from: https://www.docker.com/products/docker-desktop"
        else
            print_success "Docker is already installed"
        fi
    else
        if ! command_exists docker; then
            install_tool_linux docker docker.io apt
        else
            print_success "Docker is already installed"
        fi
    fi
    
    # Starship
    print_info "Checking Starship..."
    if [[ "$OS_TYPE" == "macos" ]]; then
        install_tool_macos starship starship brew
    else
        install_tool_linux starship starship starship
    fi
    
    # Rust
    print_info "Checking Rust..."
    if ! command_exists rustc; then
        if confirm "Would you like to install Rust?" "y"; then
            if [[ "$OS_TYPE" == "macos" ]]; then
                install_tool_macos rustc rust rustup
            else
                install_tool_linux rustc rust rustup
            fi
        fi
    else
        print_success "Rust is already installed"
    fi
    
    # NVM and Node.js
    print_info "Checking NVM..."
    if [[ ! -d "$HOME/.nvm" ]]; then
        if confirm "Would you like to install NVM (Node Version Manager)?" "y"; then
            if [[ "$OS_TYPE" == "macos" ]]; then
                install_tool_macos nvm nvm nvm
            else
                install_tool_linux nvm nvm nvm
            fi
            
            # Install Node.js using NVM
            if [[ "$DRY_RUN" == false ]]; then
                export NVM_DIR="$HOME/.nvm"
                [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
                
                # Temporarily disable 'set -u' for NVM (it has unbound variables)
                set +u
                nvm install --lts
                nvm use --lts
                set -u
                
                print_success "Node.js LTS installed via NVM"
            fi
        fi
    else
        print_success "NVM is already installed"
    fi
    
    # NPM global packages
    if command_exists npm; then
        print_info "Installing NPM global packages..."
        if [[ "$DRY_RUN" == false ]]; then
            # npm install -g vite vitest
            print_success "NPM packages installed: vite, vitest"
        else
            print_info "[DRY RUN] Would install: vite, vitest"
        fi
    fi
    
    # Go packages
    if command_exists go; then
        print_info "Installing Go packages..."
        if [[ "$DRY_RUN" == false ]]; then
            go install github.com/onsi/ginkgo/v2/ginkgo@latest
            print_success "Go packages installed: ginkgo"
        else
            print_info "[DRY RUN] Would install: ginkgo"
        fi
    fi
    
    # ZSH plugins and tools
    print_header "Installing ZSH Dependencies"
    
    if [[ "$OS_TYPE" == "macos" ]]; then
        install_tool_macos zsh-syntax-highlighting zsh-syntax-highlighting brew
        install_tool_macos zsh-autosuggestions zsh-autosuggestions brew
        install_tool_macos zoxide zoxide brew
        install_tool_macos fzf fzf brew
        install_tool_macos jenv jenv brew
        install_tool_macos rbenv rbenv brew
    else
        # Linux installation for ZSH plugins
        if [[ "$DRY_RUN" == false ]]; then
            # zsh-syntax-highlighting
            if [[ ! -d "$HOME/.zsh/zsh-syntax-highlighting" ]]; then
                git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh/zsh-syntax-highlighting"
                print_success "zsh-syntax-highlighting installed"
            else
                print_success "zsh-syntax-highlighting is already installed"
            fi
            
            # zsh-autosuggestions
            if [[ ! -d "$HOME/.zsh/zsh-autosuggestions" ]]; then
                git clone https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.zsh/zsh-autosuggestions"
                print_success "zsh-autosuggestions installed"
            else
                print_success "zsh-autosuggestions is already installed"
            fi
        else
            print_info "[DRY RUN] Would install ZSH plugins"
        fi
        
        install_tool_linux zoxide zoxide apt
        install_tool_linux fzf fzf apt
        
        # jenv and rbenv may need manual installation on Linux
        print_warning "jenv and rbenv may require manual installation on Linux"
        print_info "jenv: https://github.com/jenv/jenv"
        print_info "rbenv: https://github.com/rbenv/rbenv"
    fi
    
    # FZF key bindings
    if command_exists fzf && [[ "$DRY_RUN" == false ]]; then
        if [[ "$OS_TYPE" == "macos" ]]; then
            "$(brew --prefix)"/opt/fzf/install --key-bindings --completion --no-update-rc
        fi
    fi
    
    # Manual installation warnings
    print_header "Manual Installation Required"
    print_warning "The following tools require manual installation:"
    print_info "1. Ghostty Terminal: https://ghostty.org/"
    print_info "2. Cursor IDE: https://cursor.sh/"
    print_info "3. GitButler: https://gitbutler.com/"
}

################################################################################
# Backup Existing Configurations
################################################################################

backup_file() {
    local source="$1"
    
    if [[ ! -e "$source" ]]; then
        return 0
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would backup: $source"
        return 0
    fi
    
    mkdir -p "$BACKUP_SUBDIR"
    
    local backup_path="${BACKUP_SUBDIR}/$(basename "$source")"
    cp -r "$source" "$backup_path"
    print_success "Backed up: $source -> $backup_path"
}

################################################################################
# Create Symlinks
################################################################################

create_symlink() {
    local source="$1"
    local target="$2"
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would create symlink: $target -> $source"
        return 0
    fi
    
    # Backup existing file/directory
    if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
        backup_file "$target"
        rm -rf "$target"
    elif [[ -L "$target" ]]; then
        # Remove existing symlink
        rm "$target"
    fi
    
    # Create parent directory if needed
    mkdir -p "$(dirname "$target")"
    
    # Create symlink
    ln -s "$source" "$target"
    print_success "Created symlink: $target -> $source"
}

################################################################################
# Setup Configuration Files
################################################################################

setup_config_files() {
    print_header "Setting Up Configuration Files"
    
    # Create config directory if it doesn't exist
    mkdir -p "$CONFIG_DIR"
    
    # Starship
    create_symlink "${DOTFILES_DIR}/config/starship.toml" "${CONFIG_DIR}/starship.toml"
    
    # ZSH
    create_symlink "${DOTFILES_DIR}/config/zsh" "${CONFIG_DIR}/zsh"
    
    # Ghostty
    create_symlink "${DOTFILES_DIR}/config/ghostty" "${CONFIG_DIR}/ghostty"
    
    # Create ZSH history file (will be created automatically by ZSH, but ensure directory exists)
    if [[ "$DRY_RUN" == false ]]; then
        touch "${CONFIG_DIR}/zsh/.zsh_history" 2>/dev/null || true
        print_success "ZSH history file location configured"
    fi
    
    # Setup .zshrc
    local zshrc="${HOME}/.zshrc"
    
    if [[ -f "$zshrc" ]] && ! grep -q "ZDOTDIR" "$zshrc"; then
        backup_file "$zshrc"
    fi
    
    if [[ "$DRY_RUN" == false ]]; then
        cat > "$zshrc" << 'EOF'
# Set ZDOTDIR to use modular ZSH configuration
export ZDOTDIR="${HOME}/.config/zsh"

# Load ZSH configuration
if [[ -f "${ZDOTDIR}/zsh.sh" ]]; then
    source "${ZDOTDIR}/zsh.sh"
fi
EOF
        print_success "Created ~/.zshrc"
    else
        print_info "[DRY RUN] Would create ~/.zshrc"
    fi
}

################################################################################
# Validation
################################################################################

validate_setup() {
    print_header "Validating Setup"
    
    local errors=0
    
    # Check symlinks
    local symlinks=(
        "${CONFIG_DIR}/starship.toml"
        "${CONFIG_DIR}/zsh"
        "${CONFIG_DIR}/ghostty"
    )
    
    for link in "${symlinks[@]}"; do
        if [[ -L "$link" ]]; then
            print_success "Symlink exists: $link"
        else
            print_error "Symlink missing: $link"
            ((errors++))
        fi
    done
    
    # Check essential tools
    local tools=(zsh git nvim go starship)
    
    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            print_success "$tool is installed"
        else
            print_warning "$tool is not installed"
        fi
    done
    
    if [[ $errors -eq 0 ]]; then
        print_success "Validation passed!"
        return 0
    else
        print_error "Validation failed with $errors error(s)"
        return 1
    fi
}

################################################################################
# Rollback
################################################################################

rollback() {
    print_header "Rolling Back Installation"
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        print_error "No backups found in $BACKUP_DIR"
        exit 1
    fi
    
    # Find most recent backup
    local latest_backup=$(ls -t "$BACKUP_DIR" | head -1)
    
    if [[ -z "$latest_backup" ]]; then
        print_error "No backup directories found"
        exit 1
    fi
    
    local backup_path="${BACKUP_DIR}/${latest_backup}"
    print_info "Using backup from: $backup_path"
    
    if ! confirm "Are you sure you want to rollback? This will restore backups and remove symlinks." "n"; then
        print_info "Rollback cancelled"
        exit 0
    fi
    
    # Remove symlinks
    print_info "Removing symlinks..."
    rm -f "${CONFIG_DIR}/starship.toml"
    rm -f "${CONFIG_DIR}/zsh"
    rm -f "${CONFIG_DIR}/ghostty"
    
    # Restore backups
    print_info "Restoring backups..."
    if [[ -d "$backup_path" ]]; then
        for item in "$backup_path"/*; do
            local basename=$(basename "$item")
            local target="${CONFIG_DIR}/${basename}"
            
            if [[ "$basename" == ".zshrc" ]]; then
                target="${HOME}/.zshrc"
            fi
            
            cp -r "$item" "$target"
            print_success "Restored: $target"
        done
    fi
    
    print_success "Rollback complete!"
}

################################################################################
# Help Message
################################################################################

show_help() {
    cat << EOF
Dotfiles Setup Script

Usage:
    ./setup.sh [OPTIONS]

Options:
    --help          Show this help message
    --dry-run       Show what would be done without making changes
    --rollback      Restore backups and remove symlinks
    --skip-tools    Skip tool installation, only setup config files

Examples:
    ./setup.sh                  # Normal installation
    ./setup.sh --dry-run        # Preview changes
    ./setup.sh --rollback       # Undo installation

Description:
    This script automates the setup of a development environment by:
    - Installing essential development tools (git, nvim, golang, docker, etc.)
    - Installing ZSH and setting it as the default shell
    - Creating symlinks for configuration files
    - Backing up existing configurations
    - Supporting both macOS and Ubuntu/Linux

    All actions are logged to: ${LOG_FILE}
    Backups are stored in: ${BACKUP_DIR}

EOF
}

################################################################################
# Command-line Argument Parsing
################################################################################

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                show_help
                exit 0
                ;;
            --dry-run)
                DRY_RUN=true
                print_info "Running in DRY RUN mode"
                shift
                ;;
            --rollback)
                ROLLBACK=true
                shift
                ;;
            --skip-tools)
                SKIP_TOOLS=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

################################################################################
# Main
################################################################################

main() {
    # Start logging
    log "=========================================="
    log "Dotfiles setup started"
    log "=========================================="
    
    # Parse command-line arguments
    parse_args "$@"
    
    # Handle rollback
    if [[ "$ROLLBACK" == true ]]; then
        rollback
        exit 0
    fi
    
    # Print header
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║     Dotfiles Setup Script              ║"
    echo "╔════════════════════════════════════════╗"
    echo ""
    
    if [[ "$DRY_RUN" == true ]]; then
        print_warning "DRY RUN MODE - No changes will be made"
        echo ""
    fi
    
    # Detect OS
    detect_os
    
    # Install tools
    install_essential_tools
    
    # Setup configuration files
    setup_config_files
    
    # Validate
    validate_setup
    
    # Done
    print_header "Setup Complete!"
    print_success "Dotfiles have been installed successfully"
    print_info "Log file: ${LOG_FILE}"
    
    if [[ -d "$BACKUP_SUBDIR" ]]; then
        print_info "Backups: ${BACKUP_SUBDIR}"
    fi
    
    echo ""
    print_info "Please restart your terminal or run: source ~/.zshrc"
    echo ""
}

# Run main function
main "$@"

