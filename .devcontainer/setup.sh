#!/bin/bash
# Post-create setup script for DevPod container
# This script runs after the container is created and installs required tools

set -e

echo "=== DevPod Container Setup ==="

# Source nvm environment (required because postCreateCommand runs before shell init)
export NVM_DIR="/usr/local/share/nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
fi

# Configure npm to use a user-local directory for global packages
# This avoids permission issues with the system nvm installation
NPM_GLOBAL_DIR="$HOME/.npm-global"
mkdir -p "$NPM_GLOBAL_DIR"

# Remove npm user-config values that conflict with nvm, then use env vars instead
if [ -f "$HOME/.npmrc" ]; then
    sed -i '/^prefix\s*=\s*/d;/^globalconfig\s*=\s*/d' "$HOME/.npmrc"
fi

# nvm recommends deleting prefix when present to avoid npm/nvm conflicts
if command -v nvm &> /dev/null; then
    nvm use --delete-prefix --silent >/dev/null 2>&1 || true
fi

export NPM_CONFIG_PREFIX="$NPM_GLOBAL_DIR"
export PATH="$NPM_GLOBAL_DIR/bin:$PATH"

# Persist npm global bin PATH for future shell sessions
if ! grep -q 'npm-global' "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$HOME/.bashrc"
fi

install_apt_package() {
    local package_name="$1"
    local command_name="$2"

    if command -v "$command_name" &> /dev/null; then
        echo "$package_name is already installed"
        return
    fi

    echo "Installing $package_name..."
    if ! sudo apt-get update; then
        echo "apt-get update failed; retrying install with cached package indexes"
    fi

    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$package_name"

    if command -v "$command_name" &> /dev/null; then
        echo "$package_name installed successfully"
    else
        echo "Failed to install $package_name"
        exit 1
    fi
}

# Install tmux (terminal multiplexer)
if ! command -v tmux &> /dev/null; then
    echo "Installing tmux..."
    sudo apt-get update && sudo apt-get install -y tmux
    echo "tmux installed successfully"
else
    echo "tmux is already installed"
fi

# Install uv (fast Python package manager)
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo "uv installed successfully"
else
    echo "uv is already installed"
fi

# Source uv environment
export PATH="$HOME/.local/bin:$PATH"

# Install Python 3.12 via uv (ensures it's available for uv projects)
echo "Installing Python 3.12 via uv..."
uv python install 3.12
echo "Python 3.12 installed"

# Install Claude Code (native installer)
if ! command -v claude &> /dev/null; then
    echo "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
    echo "Claude Code installed successfully"
else
    echo "Claude Code is already installed"
fi

# Install Codex CLI
if ! command -v codex &> /dev/null; then
    echo "Installing Codex CLI..."
    npm install -g @openai/codex --loglevel=error --no-fund --no-audit
    echo "Codex CLI installed successfully"
else
    echo "Codex CLI is already installed"
fi

# Install OpenCode
if ! command -v opencode &> /dev/null; then
    echo "Installing OpenCode..."
    npm install -g opencode-ai --loglevel=error --no-fund --no-audit
    echo "OpenCode installed successfully"
else
    echo "OpenCode is already installed"
fi

# Install Swarmtools (npm package for swarmtools.ai)
if ! command -v swarm &> /dev/null; then
    echo "Installing Swarmtools..."
    npm install -g opencode-swarm-plugin --loglevel=error --no-fund --no-audit
    echo "Swarmtools installed successfully"
else
    echo "Swarmtools is already installed"
fi

# Install ripgrep
install_apt_package "ripgrep" "rg"

# Install Vim
install_apt_package "vim" "vim"

# Configure Vim defaults
ESC=$'\033'
cat > "$HOME/.vimrc" <<EOF
" Non-Vundle stuff

filetype on
autocmd BufRead,BufNewFile *.launch set filetype=xml
autocmd BufRead,BufNewFile *.world set filetype=xml

set background=dark

" Turns on the numbers on the left side
set number

" Makes backspace work as expected.
" To reset this, use the command :set backspace=
set backspace=indent,eol,start

" Lets you use the CTRL+Backspace combo in Insert Mode
:imap <C-H> <C-W>

" Turns on color syntax highlighting
syntax on

" Fixes italics in Gnome terminal
set t_ZH=${ESC}[3m
set t_ZR=${ESC}[23m

" Fixes italics in tmux in Gnome terminal
" Remove these lines if tmux/Vim doesn't work when logging into a remote computer
" See https://medium.com/@dubistkomisch/how-to-actually-get-italics-and-true-colour-to-work-in-iterm-tmux-vim-9ebe55ebc2be
" .terminfo files can be found in ~/.terminfo
let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors

" Changes the tab size in Vim to be 4 spaces instead
" Note that pressing tab will NOT insert a TAB character when this is enabled.
:set tabstop=4
:set shiftwidth=4
:set expandtab

" Preserves indentation when you hit enter. Very useful to not have to indent a ton.
" See also :help smartindent for C-style programs.
:set autoindent

" Changes vertical split so that new window is to the _right_ of current window
set splitright

" Changes horizontal split so that new window is _below_ current window
set splitbelow

" For Vim Markdown, turns off folding by default
set nofoldenable
EOF

echo "Vim configuration written to $HOME/.vimrc"

# Copy shell aliases if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/.bash_aliases" ]; then
    echo "Setting up shell aliases..."
    cp "$SCRIPT_DIR/.bash_aliases" "$HOME/.bash_aliases"
    # Source aliases in .bashrc if not already configured
    if ! grep -q '\.bash_aliases' "$HOME/.bashrc" 2>/dev/null; then
        echo 'if [ -f ~/.bash_aliases ]; then . ~/.bash_aliases; fi' >> "$HOME/.bashrc"
    fi
    echo "Shell aliases configured"
fi

echo "=== Setup Complete ==="
