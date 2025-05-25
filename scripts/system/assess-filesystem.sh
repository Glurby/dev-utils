#!/bin/bash

# Filesystem Structure Analyzer
OUTPUT_DIR="$1"
STRUCTURE_FILE="$OUTPUT_DIR/filesystem-structure.json"

echo "  📁 Analyzing filesystem structure..."

# Initialize structure file
echo '{"dotfiles": [], "important_dirs": [], "custom_scripts": []}' > "$STRUCTURE_FILE"

# Capture dotfiles
echo "    🔧 Capturing dotfiles..."
DOTFILES=()
for dotfile in ~/.*; do
    if [ -f "$dotfile" ] && [[ $(basename "$dotfile") != "." ]] && [[ $(basename "$dotfile") != ".." ]]; then
        filename=$(basename "$dotfile")
        # Skip common files that shouldn't be synced
        if [[ ! "$filename" =~ ^\.DS_Store$|^\.Trash$|^\.CFUserTextEncoding$ ]]; then
            DOTFILES+=("$filename")
            # Copy important dotfiles
            if [[ "$filename" =~ ^\.(zshrc|bashrc|vimrc|gitconfig|ssh)$ ]]; then
                cp "$dotfile" "$OUTPUT_DIR/"
            fi
        fi
    fi
done

# Add dotfiles to JSON
DOTFILES_JSON=$(printf '%s\n' "${DOTFILES[@]}" | jq -R . | jq -s .)
jq --argjson dotfiles "$DOTFILES_JSON" '.dotfiles = $dotfiles' "$STRUCTURE_FILE" > "$STRUCTURE_FILE.tmp" && mv "$STRUCTURE_FILE.tmp" "$STRUCTURE_FILE"

# Identify important directories
echo "    📂 Identifying important directories..."
IMPORTANT_DIRS=(
    "Documents"
    "Desktop" 
    "Downloads"
    "Projects"
    "Code"
    "Development"
    "dev"
    "work"
    "personal"
    ".ssh"
    "dev-utils"
)

EXISTING_DIRS=()
for dir in "${IMPORTANT_DIRS[@]}"; do
    if [ -d "$HOME/$dir" ]; then
        EXISTING_DIRS+=("$dir")
    fi
done

DIRS_JSON=$(printf '%s\n' "${EXISTING_DIRS[@]}" | jq -R . | jq -s .)
jq --argjson dirs "$DIRS_JSON" '.important_dirs = $dirs' "$STRUCTURE_FILE" > "$STRUCTURE_FILE.tmp" && mv "$STRUCTURE_FILE.tmp" "$STRUCTURE_FILE"

# Find custom scripts
echo "    🔨 Finding custom scripts..."
SCRIPT_PATHS=(
    "$HOME/bin"
    "$HOME/.local/bin"
    "$HOME/dev-utils/bin"
    "$HOME/scripts"
)

CUSTOM_SCRIPTS=()
for path in "${SCRIPT_PATHS[@]}"; do
    if [ -d "$path" ]; then
        while IFS= read -r -d '' script; do
            if [ -x "$script" ]; then
                CUSTOM_SCRIPTS+=("$(realpath "$script")")
            fi
        done < <(find "$path" -type f -print0 2>/dev/null)
    fi
done

SCRIPTS_JSON=$(printf '%s\n' "${CUSTOM_SCRIPTS[@]}" | jq -R . | jq -s .)
jq --argjson scripts "$SCRIPTS_JSON" '.custom_scripts = $scripts' "$STRUCTURE_FILE" > "$STRUCTURE_FILE.tmp" && mv "$STRUCTURE_FILE.tmp" "$STRUCTURE_FILE"

echo "  ✅ Filesystem analysis complete"