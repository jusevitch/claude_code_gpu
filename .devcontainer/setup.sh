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
npm config set prefix "$NPM_GLOBAL_DIR"
export PATH="$NPM_GLOBAL_DIR/bin:$PATH"

# Persist the PATH for future shell sessions
if ! grep -q 'npm-global' "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$HOME/.bashrc"
fi

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

# Install Claude Code
# Using --loglevel=error to reduce output and avoid TTY issues
if ! command -v claude &> /dev/null; then
    echo "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code --loglevel=error --no-fund --no-audit
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
