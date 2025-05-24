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

## Adding New Scripts

1. Place script in appropriate `scripts/` subdirectory
2. Make executable: `chmod +x script-name`
3. Create symlink: `ln -sf ~/dev-utils/scripts/category/script-name ~/dev-utils/bin/script-name`
4. Document in this README