# --- ZSH History Configuration ---

# Set the path to the history file
HISTFILE="${ZDOTDIR}/.zsh_history"

# Set the number of commands to keep in memory (session history)
HISTSIZE=10000

# Set the number of commands to save to the history file (long-term)
SAVEHIST=100000

# --- Real-Time & Shared History ---

# 1. Append new history lines to the $HISTFILE, instead of overwriting it
setopt APPEND_HISTORY

# 2. Write to the history file immediately after each command
#    (not just when the shell exits)
setopt INC_APPEND_HISTORY

# 3. Share history between all running shells in real-time.
#    This makes a command run in one terminal available in another instantly.
setopt SHARE_HISTORY

# --- Quality of Life (De-duplication) ---

# 4. Don't record a command if it's an exact duplicate of the previous command
setopt HIST_IGNORE_DUPS

# 5. When writing to the file, delete older duplicate commands
setopt HIST_SAVE_NO_DUPS

# --- End History Configuration ---


