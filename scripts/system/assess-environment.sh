#!/bin/bash

# Environment Assessment Script
OUTPUT_DIR="$1"
ENV_FILE="$OUTPUT_DIR/environment.json"

echo "  ⚙️  Capturing environment..."

# Initialize environment file
echo '{"shell": "", "path": [], "aliases": [], "functions": [], "variables": []}' > "$ENV_FILE"

# Current shell
SHELL_NAME=$(basename "$SHELL")
jq --arg shell "$SHELL_NAME" '.shell = $shell' "$ENV_FILE" > "$ENV_FILE.tmp" && mv "$ENV_FILE.tmp" "$ENV_FILE"

# PATH components
echo "    🛤️  PATH components..."
IFS=':' read -ra PATH_ARRAY <<< "$PATH"
PATH_JSON=$(printf '%s\n' "${PATH_ARRAY[@]}" | jq -R . | jq -s .)
jq --argjson path "$PATH_JSON" '.path = $path' "$ENV_FILE" > "$ENV_FILE.tmp" && mv "$ENV_FILE.tmp" "$ENV_FILE"

# Export current environment
echo "    📝 Environment variables..."
env > "$OUTPUT_DIR/environment-vars.txt"

# Shell-specific configurations
if [ "$SHELL_NAME" = "zsh" ] && [ -f ~/.zshrc ]; then
    echo "    🐚 ZSH configuration..."
    
    # Extract aliases
    grep "^alias " ~/.zshrc > "$OUTPUT_DIR/aliases.txt" 2>/dev/null || touch "$OUTPUT_DIR/aliases.txt"
    
    # Extract functions (basic detection)
    grep -A 10 "^function\|^[a-zA-Z_][a-zA-Z0-9_]*() {" ~/.zshrc > "$OUTPUT_DIR/functions.txt" 2>/dev/null || touch "$OUTPUT_DIR/functions.txt"
    
    # Extract exports
    grep "^export " ~/.zshrc > "$OUTPUT_DIR/exports.txt" 2>/dev/null || touch "$OUTPUT_DIR/exports.txt"
fi

# Node.js version (if nvm is used)
if [ -f ~/.nvmrc ]; then
    cp ~/.nvmrc "$OUTPUT_DIR/"
fi

# Python version (if pyenv is used)
if [ -f ~/.python-version ]; then
    cp ~/.python-version "$OUTPUT_DIR/"
fi

# Ruby version (if rbenv is used)
if [ -f ~/.ruby-version ]; then
    cp ~/.ruby-version "$OUTPUT_DIR/"
fi

echo "  ✅ Environment capture complete"