# AI Coding Agents DevPod Template (GPU Support)

This is a template repository for running AI coding agents in DevPod containers with GPU support.

## Project Structure

- `.devcontainer/devcontainer.json` - Container configuration
- `.devcontainer/setup.sh` - Post-creation setup script (installs Claude Code, Codex CLI, and uv)
- `.claude/settings.json` - Claude Code settings (bypasses permissions in container)

## Development

To test changes to the devcontainer configuration:

```bash
devpod up . --ide vscode
```

## Included Tools

### AI Coding Agents
- Claude Code (Anthropic) - installed via [native installer](https://claude.ai/install.sh)
- Codex CLI (OpenAI)

### Development Tools
- Node.js (for Codex CLI)
- Python + uv
- Rust + rust-analyzer
- Git + GitHub CLI
- CUDA 12.8 (GPU support)
