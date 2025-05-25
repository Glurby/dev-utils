#!/bin/bash

# Application Assessment Script
OUTPUT_DIR="$1"
APPS_FILE="$OUTPUT_DIR/applications.json"

echo "  📱 Scanning installed applications..."

# Initialize applications file
echo '{"homebrew": [], "npm_global": [], "pip_global": [], "applications": [], "mas": []}' > "$APPS_FILE"

# Homebrew packages
if command -v brew &> /dev/null; then
    echo "    🍺 Homebrew packages..."
    brew list --formula > "$OUTPUT_DIR/brew-formulas.txt"
    brew list --cask > "$OUTPUT_DIR/brew-casks.txt"
    
    # Add to JSON
    FORMULAS=$(brew list --formula | jq -R . | jq -s .)
    CASKS=$(brew list --cask | jq -R . | jq -s .)
    jq --argjson formulas "$FORMULAS" --argjson casks "$CASKS" \
       '.homebrew = {"formulas": $formulas, "casks": $casks}' \
       "$APPS_FILE" > "$APPS_FILE.tmp" && mv "$APPS_FILE.tmp" "$APPS_FILE"
fi

# NPM global packages
if command -v npm &> /dev/null; then
    echo "    📦 NPM global packages..."
    npm list -g --depth=0 --json > "$OUTPUT_DIR/npm-global.json" 2>/dev/null || echo "{}" > "$OUTPUT_DIR/npm-global.json"
fi

# Python pip global packages
if command -v pip &> /dev/null; then
    echo "    🐍 Python pip packages..."
    pip list --format=json > "$OUTPUT_DIR/pip-global.json" 2>/dev/null || echo "[]" > "$OUTPUT_DIR/pip-global.json"
fi

# macOS Applications
echo "    🖥️  macOS Applications..."
find /Applications -maxdepth 1 -name "*.app" -exec basename {} .app \; | sort > "$OUTPUT_DIR/macos-apps.txt"

# Mac App Store apps (if mas is installed)
if command -v mas &> /dev/null; then
    echo "    🏪 Mac App Store apps..."
    mas list > "$OUTPUT_DIR/mas-apps.txt"
fi

echo "  ✅ Applications assessment complete"