# Dev Utils

Personal utility repository for scripts, tools, and configuration management.

## Quick Start

1. Add to PATH: `export PATH="$HOME/dev-utils/bin:$PATH"`
2. Source your shell: `source ~/.zshrc`
3. Run utilities: `start-ollama`, `stop-ollama`

## Structure

- **scripts/** - Organized utility scripts by category
- **templates/** - Reusable code templates and boilerplate
- **configs/** - Shared configuration files
- **docs/** - Documentation and guidelines
- **bin/** - Symlinks for PATH access

## Available Scripts

### AI/ML
- `start-ollama` - Start Ollama server
- `stop-ollama` - Stop Ollama server

### System Migration
- `assess-system` - Capture complete system state for migration
- `deploy-system` - Deploy system state to fresh macOS user profile

#### Fresh macOS Migration
Complete development environment migration to new machines:

1. **Source machine**: `assess-system` → creates timestamped assessment
2. **Transfer**: Copy assessment folder to new machine
3. **Target machine**: `deploy-system <assessment-folder>` → restores everything

**What gets migrated:**
- Homebrew packages and applications
- NPM and Python global packages  
- Git repositories with remotes
- Dotfiles and shell configuration
- Directory structure and custom scripts

See [Fresh macOS Migration Guide](docs/setup/fresh-macos-migration.md) for detailed instructions.

## Adding New Scripts

1. Place script in appropriate `scripts/` subdirectory
2. Make executable: `chmod +x script-name`
3. Create symlink: `ln -sf ~/dev-utils/scripts/category/script-name ~/dev-utils/bin/script-name`
4. Document in this README