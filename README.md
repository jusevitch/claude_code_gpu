> [!WARNING]
> This template is now deprecated.
> A newer version can be found in the following repository:
>
> https://github.com/jusevitch/agent_devcontainer_gpu 

# AI Coding Agents DevPod Template (GPU Support)

Run AI coding agents safely inside Docker containers using DevPod with GPU support.

AI coding agents are powerful. Running them unconstrained on your computer is risky. This template runs them within Docker containers to mitigate the risk of data loss or corruption from hallucinations.

[DevPod](https://devpod.sh/) is an open source alternative to GitHub Codespaces. It lets you spin up development containers from a `.devcontainer` configuration with a single command.

## Prerequisites

(Skip if you've done this before)

1. [Install Docker](https://docs.docker.com/engine/install/)
2. [Install the NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)
3. [Install DevPod CLI](https://devpod.sh/docs/getting-started/install#install-devpod-cli)
4. Add Docker to DevPod as the default provider:
```bash
devpod provider add docker
devpod provider use docker
```

## Quick Start

1. Clone this repository and `cd` into it
2. Run `devpod up . --ide vscode`

That's it! Claude Code and Codex CLI are automatically installed and ready to use.

## What's Included

### AI Coding Agents
- **Claude Code** - Anthropic's AI coding assistant (auto-installed)
- **Codex CLI** - OpenAI's AI coding assistant (auto-installed)

### Development Tools
- **Python** + **uv** - Python with fast package management
- **Rust** - Full Rust toolchain with rust-analyzer
- **Node.js** - JavaScript runtime
- **Git** + **GitHub CLI** - Version control
- **CUDA 12.8** - GPU support for JAX / Pytorch / etc.

## Using AI Coding Agents

Once the container opens in VS Code:

```bash
# Start Claude Code (recommended for containers)
claude --dangerously-skip-permissions

# Or start with normal permissions
claude

# Start Codex CLI (recommended for containers)
codex --full-auto

# Or start with normal permissions
codex
```

## Customization

Edit `.devcontainer/devcontainer.json` to customize your environment:

- Change the base image (Debian, Fedora, etc.)
- Add/remove language features (Julia, Go, etc.)
- Add VS Code extensions
- Modify the setup script in `.devcontainer/setup.sh`

See [devcontainer features](https://containers.dev/features) for available options.

## How It Works

The `.devcontainer/` folder contains:
- `devcontainer.json` - Container configuration
- `setup.sh` - Post-creation script that installs Claude Code, Codex CLI, and uv

The `.claude/settings.json` file pre-configures Claude Code to bypass permission prompts (safe within containers).

## See Also

* [AI Coding Agents DevPod template (no GPU)](https://github.com/jusevitch/claude_code_devpod)
* [Claude Code DevPod template for Python only](https://github.com/jusevitch/claude_code_python)
* [Claude Code DevPod template for Rust only](https://github.com/jusevitch/claude_code_rust)

## Resources

- [DevPod Documentation](https://devpod.sh/docs)
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Codex CLI Documentation](https://github.com/openai/codex)
- [Devcontainer Features](https://containers.dev/features)
- [Microsoft Devcontainer Images](https://hub.docker.com/r/microsoft/devcontainers)
