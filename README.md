# Dotfiles

A comprehensive dotfiles repository for quickly setting up a consistent development environment across macOS and Linux systems. This repository includes shell configurations (ZSH), terminal settings (Ghostty), prompt customization (Starship), and an automated setup script that installs essential development tools.

## Features

- 🚀 **One-Command Setup** - Automated installation of tools and configuration
- 🔄 **Cross-Platform** - Works on both macOS and Ubuntu/Linux
- 🔒 **Safe & Reversible** - Automatic backups and rollback capability
- 🎨 **Modern Shell Experience** - ZSH with syntax highlighting, autosuggestions, and more
- 📦 **Essential Dev Tools** - Installs nvim, golang, docker, starship, rust, and more
- 🧩 **Modular Configuration** - Easy to customize and extend

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Run the setup script
./setup.sh

# Or preview what would be done first
./setup.sh --dry-run
```

After installation, restart your terminal or run:
```bash
source ~/.zshrc
```

## What's Included

### Configuration Files

- **Starship** (`config/starship.toml`) - Modern, fast prompt with Git integration
- **ZSH** (`config/zsh/`) - Modular shell configuration
  - `alias.sh` - Shell aliases
  - `env.sh` - Environment variables
  - `git.sh` - Git aliases and functions (Oh My Zsh style)
  - `history.sh` - History configuration with real-time sharing
  - `init.sh` - ZSH initialization (colors, completion)
  - `override.sh` - Key binding overrides (emacs mode)
  - `path.sh` - PATH configuration
  - `tools.sh` - Tool initialization (starship, zoxide, fzf, etc.)
  - `zsh.sh` - Main loader that sources all modules
- **Ghostty** (`config/ghostty/config`) - Terminal emulator configuration

### Installed Tools

The setup script installs the following tools:

#### Essential Development Tools
- **ZSH** - Modern shell with powerful features
- **Git** - Version control (usually pre-installed)
- **Neovim** - Modern Vim-based text editor
- **Golang** - Go programming language
- **Docker** - Container platform
- **Starship** - Cross-shell prompt
- **Rust** - Systems programming language (optional)

#### Node.js Ecosystem
- **NVM** - Node Version Manager
- **Node.js** - JavaScript runtime (LTS via NVM)
- **npm** - Node package manager
- **vite** - Frontend build tool
- **vitest** - Testing framework

#### Go Packages
- **ginkgo** - BDD testing framework for Go

#### Shell Enhancements
- **zsh-syntax-highlighting** - Fish-like syntax highlighting
- **zsh-autosuggestions** - Fish-like autosuggestions
- **zoxide** - Smarter cd command
- **fzf** - Fuzzy finder
- **jenv** - Java version manager
- **rbenv** - Ruby version manager

#### Manual Installation Required
These tools require manual installation:
- **Ghostty** - Modern terminal emulator ([ghostty.org](https://ghostty.org/))
- **Cursor** - AI-powered code editor ([cursor.sh](https://cursor.sh/))
- **GitButler** - Git client ([gitbutler.com](https://gitbutler.com/))

## Setup Script Usage

### Basic Commands

```bash
# Normal installation
./setup.sh

# Preview changes without making them
./setup.sh --dry-run

# Restore previous configuration
./setup.sh --rollback

# Skip tool installation, only setup config files
./setup.sh --skip-tools

# Show help
./setup.sh --help
```

### What the Setup Script Does

1. **Detects OS** - Identifies macOS or Linux distribution
2. **Installs Homebrew** - On macOS, installs if not present
3. **Installs Tools** - Installs all essential development tools
4. **Creates Backups** - Backs up existing configurations to `~/.dotfiles-backup/`
5. **Creates Symlinks** - Links config files from repo to `~/.config/`
6. **Configures ZSH** - Sets up `.zshrc` to load modular configuration
7. **Validates Setup** - Checks that everything is installed correctly
8. **Logs Everything** - All actions logged to `~/.dotfiles-setup.log`

## Configuration File Details

### Starship (`config/starship.toml`)

Configures the Starship prompt with:
- Current directory with truncation
- Git branch and status indicators
- Language version displays (Go, Node, Ruby)
- Command duration for slow commands
- Success/failure status indicators

**Customization:** Edit `config/starship.toml` to modify prompt appearance. See [Starship docs](https://starship.rs/config/) for options.

### ZSH Configuration

#### `alias.sh` - Shell Aliases
Simple command shortcuts. Add your own aliases here.

```bash
alias ll="ls -l"
alias la="ls -a"
```

#### `env.sh` - Environment Variables
Exports environment variables for various tools.

```bash
export GOPATH=$(go env GOPATH)
export _ZO_DATA_DIR="${HOME}/.config/zoxide"
```

#### `git.sh` - Git Aliases and Functions
Comprehensive Git aliases based on Oh My Zsh git plugin. Includes shortcuts like:
- `gst` - git status
- `gco` - git checkout
- `gcm` - git checkout main
- `gp` - git push
- `gl` - git pull
- And 100+ more...

#### `history.sh` - History Configuration
Configures ZSH history with:
- Real-time history sharing between terminals
- Deduplication
- 100,000 commands saved
- History file at `~/.config/zsh/.zsh_history`

#### `init.sh` - ZSH Initialization
Sets up colors, completion, and vim mode (overridden by `override.sh`).

#### `override.sh` - Key Binding Overrides
Switches from vim mode to emacs mode for familiar key bindings:
- `Ctrl+A` - Beginning of line
- `Ctrl+E` - End of line

#### `path.sh` - PATH Configuration
Manages PATH for various tools. Automatically detects:
- Homebrew location (Apple Silicon vs Intel Mac)
- Go binaries
- Custom dev binaries

#### `tools.sh` - Tool Initialization
Initializes shell enhancements:
- Syntax highlighting
- Autosuggestions
- jenv (Java)
- rbenv (Ruby)
- Starship prompt
- Zoxide (smart cd)
- FZF (fuzzy finder)

#### `zsh.sh` - Main Loader
Sources all other configuration files in the correct order. This is loaded by `~/.zshrc`.

### Ghostty (`config/ghostty/config`)

Terminal emulator configuration with:
- FiraCode Nerd Font
- Nvim Dark theme
- Custom padding and window settings
- macOS-specific transparent titlebar

## Customization Guide

### Adding New Aliases

Edit `config/zsh/alias.sh`:
```bash
alias myalias="my command"
```

### Adding Environment Variables

Edit `config/zsh/env.sh`:
```bash
export MY_VAR="value"
```

### Changing the Prompt

Edit `config/starship.toml`. For example, to change directory color:
```toml
[directory]
style = "bold yellow"  # Change from cyan to yellow
```

### Adding New Tools to PATH

Edit `config/zsh/path.sh`:
```bash
export PATH="${PATH}:${HOME}/my/custom/path"
```

### Modifying Git Aliases

Edit `config/zsh/git.sh` to add or modify git aliases:
```bash
alias gmy='git my-custom-command'
```

### Changing Key Bindings

Edit `config/zsh/override.sh`:
```bash
bindkey '^R' my-custom-function
```

## Platform-Specific Notes

### macOS

- **Homebrew Location**: Automatically detects Apple Silicon (`/opt/homebrew`) vs Intel (`/usr/local`)
- **Docker**: Docker Desktop requires manual installation from [docker.com](https://www.docker.com/products/docker-desktop)
- **Permissions**: May require password for `chsh` (changing default shell)

### Linux (Ubuntu)

- **Package Manager**: Uses `apt` for most packages
- **ZSH Plugins**: Installed via git clone instead of Homebrew
- **jenv/rbenv**: May require manual installation
- **Docker**: Installed via `apt` as `docker.io`

### Both Platforms

- **NVM**: Installed via curl script, not package manager
- **Rust**: Installed via rustup
- **Starship**: Uses native installer on Linux, Homebrew on macOS

## Troubleshooting

### ZSH Configuration Not Loading

**Problem**: After installation, ZSH configuration doesn't load.

**Solution**:
```bash
# Check if ZDOTDIR is set
echo $ZDOTDIR

# Manually source the configuration
source ~/.zshrc

# Check for errors
zsh -xv
```

### Symlinks Not Created

**Problem**: Config files aren't linked properly.

**Solution**:
```bash
# Check if symlinks exist
ls -la ~/.config/starship.toml
ls -la ~/.config/zsh

# Manually create symlinks
ln -s ~/.dotfiles/config/starship.toml ~/.config/starship.toml
ln -s ~/.dotfiles/config/zsh ~/.config/zsh
```

### Homebrew Not Found (macOS)

**Problem**: `brew: command not found` after installation.

**Solution**:
```bash
# Add Homebrew to PATH for current session
# Apple Silicon:
eval "$(/opt/homebrew/bin/brew shellenv)"

# Intel Mac:
eval "$(/usr/local/bin/brew shellenv)"

# Then restart terminal
```

### Tools Not Installing

**Problem**: Setup script fails to install tools.

**Solution**:
```bash
# Check the log file
cat ~/.dotfiles-setup.log

# Try dry-run to see what would happen
./setup.sh --dry-run

# Install specific tool manually
brew install <tool>  # macOS
sudo apt install <tool>  # Linux
```

### Permission Denied Errors

**Problem**: Permission errors during setup.

**Solution**:
```bash
# Make sure script is executable
chmod +x setup.sh

# Some operations require sudo (Linux)
# The script will prompt when needed

# Check file ownership
ls -la ~/.config
```

### History Not Saving

**Problem**: Command history isn't persisting between sessions.

**Solution**:
```bash
# Check history file location
echo $HISTFILE

# Ensure directory exists
mkdir -p ~/.config/zsh

# Check history file permissions
ls -la ~/.config/zsh/.zsh_history

# Manually create if needed
touch ~/.config/zsh/.zsh_history
```

### Starship Prompt Not Showing

**Problem**: Prompt looks plain, Starship not loading.

**Solution**:
```bash
# Check if starship is installed
which starship

# Check if it's initialized in tools.sh
grep starship ~/.config/zsh/tools.sh

# Manually test starship
starship init zsh
```

### FZF Key Bindings Not Working

**Problem**: `Ctrl+R` and other FZF shortcuts don't work.

**Solution**:
```bash
# Check if fzf is installed
which fzf

# Check if fzf.zsh exists
ls -la ~/.fzf.zsh

# Reinstall fzf key bindings (macOS)
$(brew --prefix)/opt/fzf/install
```

## Backup and Rollback

### Backups

All existing configurations are automatically backed up before being modified:

- **Location**: `~/.dotfiles-backup/<timestamp>/`
- **Contents**: Original config files and directories
- **Automatic**: Created during `./setup.sh` execution

### Rollback

To restore your previous configuration:

```bash
./setup.sh --rollback
```

This will:
1. Remove all symlinks created by the setup
2. Restore files from the most recent backup
3. Require confirmation before proceeding

### Manual Backup

To manually backup before making changes:

```bash
cp -r ~/.config/zsh ~/.config/zsh.backup
cp ~/.zshrc ~/.zshrc.backup
```

## Logs

All setup actions are logged to `~/.dotfiles-setup.log` with timestamps. Check this file if something goes wrong:

```bash
# View recent log entries
tail -50 ~/.dotfiles-setup.log

# Search for errors
grep ERROR ~/.dotfiles-setup.log
```

## Uninstallation

To completely remove the dotfiles setup:

```bash
# 1. Rollback to restore original configs
./setup.sh --rollback

# 2. Remove the dotfiles directory
rm -rf ~/.dotfiles

# 3. (Optional) Remove installed tools
# This depends on your preference - tools like nvim, go, etc. may be useful to keep
```

## Contributing

Feel free to fork this repository and customize it for your own needs. If you find bugs or have suggestions, please open an issue.

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Acknowledgments

- Git aliases based on [Oh My Zsh git plugin](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git)
- Inspired by various dotfiles repositories in the community
- [Starship](https://starship.rs/) for the amazing prompt
- [Ghostty](https://ghostty.org/) for the modern terminal emulator

## Resources

- [Starship Documentation](https://starship.rs/config/)
- [ZSH Documentation](https://zsh.sourceforge.io/Doc/)
- [Oh My Zsh](https://ohmyz.sh/)
- [Homebrew](https://brew.sh/)
- [NVM](https://github.com/nvm-sh/nvm)
- [FZF](https://github.com/junegunn/fzf)

---

**Happy Coding! 🚀**
