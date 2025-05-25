#!/bin/bash

# System Deployment Script
# Restores system state from assessment onto fresh macOS user profile

ASSESSMENT_DIR="$1"
MANIFEST="$ASSESSMENT_DIR/deployment-manifest.json"

if [ -z "$ASSESSMENT_DIR" ] || [ ! -d "$ASSESSMENT_DIR" ]; then
    echo "❌ Usage: $0 <assessment-directory>"
    echo "📋 This script migrates your development environment to a fresh macOS user profile"
    exit 1
fi

echo "🚀 Starting fresh macOS setup deployment from: $ASSESSMENT_DIR"
echo "📱 This will install applications, repositories, and configurations"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is designed for macOS only"
    exit 1
fi

# Ensure we have essential tools first
echo "🔧 Installing essential prerequisites..."

# Install Xcode Command Line Tools (includes git)
if ! xcode-select -p &> /dev/null; then
    echo "⚙️  Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "⏳ Please complete Xcode Command Line Tools installation and re-run this script"
    exit 1
fi

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for current session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# Install jq for JSON processing
if ! command -v jq &> /dev/null; then
    echo "🔧 Installing jq..."
    brew install jq
fi

# Ensure curl is available (should be built-in on macOS)
if ! command -v curl &> /dev/null; then
    echo "🌐 Installing curl..."
    brew install curl
fi

# Step 1: Install Homebrew packages (dependencies for other tools)
echo "📦 Phase 1: Installing Homebrew packages..."
if [ -f "$ASSESSMENT_DIR/brew-formulas.txt" ]; then
    echo "  📋 Installing formulas..."
    while read -r formula; do
        if [ -n "$formula" ]; then
            echo "    ⬇️  Installing $formula..."
            brew install "$formula" || echo "    ⚠️  Failed to install $formula"
        fi
    done < "$ASSESSMENT_DIR/brew-formulas.txt"
fi

if [ -f "$ASSESSMENT_DIR/brew-casks.txt" ]; then
    echo "  🖥️  Installing applications..."
    while read -r cask; do
        if [ -n "$cask" ]; then
            echo "    ⬇️  Installing $cask..."
            brew install --cask "$cask" || echo "    ⚠️  Failed to install $cask"
        fi
    done < "$ASSESSMENT_DIR/brew-casks.txt"
fi

# Step 2: Install Node.js packages (after Node.js is installed via Homebrew)
echo "📦 Phase 2: Installing Node.js packages..."
if [ -f "$ASSESSMENT_DIR/npm-global.json" ]; then
    if command -v npm &> /dev/null; then
        echo "  📋 Installing NPM global packages..."
        jq -r '.dependencies | keys[]' "$ASSESSMENT_DIR/npm-global.json" 2>/dev/null | while read -r package; do
            if [ -n "$package" ]; then
                echo "    ⬇️  Installing $package..."
                npm install -g "$package" || echo "    ⚠️  Failed to install $package"
            fi
        done
    else
        echo "  ⚠️  Node.js not found, skipping NPM packages"
    fi
fi

# Step 3: Install Python packages (after Python is installed)
echo "📦 Phase 3: Installing Python packages..."
if [ -f "$ASSESSMENT_DIR/pip-global.json" ]; then
    if command -v pip3 &> /dev/null; then
        echo "  📋 Installing Python packages..."
        jq -r '.[].name' "$ASSESSMENT_DIR/pip-global.json" 2>/dev/null | while read -r package; do
            if [ -n "$package" ]; then
                echo "    ⬇️  Installing $package..."
                pip3 install "$package" || echo "    ⚠️  Failed to install $package"
            fi
        done
    else
        echo "  ⚠️  Python pip not found, skipping Python packages"
    fi
fi

# Restore dotfiles
echo "🔧 Restoring dotfiles..."
for dotfile in "$ASSESSMENT_DIR"/.*; do
    if [ -f "$dotfile" ]; then
        filename=$(basename "$dotfile")
        if [[ "$filename" =~ ^\.(zshrc|bashrc|vimrc|gitconfig)$ ]]; then
            echo "  ✓ Restoring $filename"
            cp "$dotfile" ~/
        fi
    fi
done

# Create important directories
echo "📁 Creating directory structure..."
if [ -f "$ASSESSMENT_DIR/filesystem-structure.json" ]; then
    jq -r '.important_dirs[]' "$ASSESSMENT_DIR/filesystem-structure.json" 2>/dev/null | while read -r dir; do
        [ -n "$dir" ] && mkdir -p "$HOME/$dir" && echo "  ✓ Created ~/$dir"
    done
fi

# Clone repositories (interactive)
echo "📂 Repository restoration..."
if [ -f "$ASSESSMENT_DIR/repositories.json" ]; then
    echo "Found repositories to clone. Review the list:"
    jq -r '.[] | "\(.path) <- \(.remote)"' "$ASSESSMENT_DIR/repositories.json" 2>/dev/null
    echo ""
    read -p "Clone all repositories? (y/N): " clone_all
    
    if [[ "$clone_all" =~ ^[Yy]$ ]]; then
        jq -c '.[]' "$ASSESSMENT_DIR/repositories.json" 2>/dev/null | while read -r repo; do
            remote=$(echo "$repo" | jq -r '.remote')
            original_path=$(echo "$repo" | jq -r '.path')
            
            if [ -n "$remote" ] && [ "$remote" != "" ]; then
                new_path="$HOME/$(basename "$original_path")"
                echo "  🔄 Cloning $remote -> $new_path"
                git clone "$remote" "$new_path"
            fi
        done
    fi
fi

# Final setup steps
echo "🏁 Final setup steps..."

# Update shell configuration to include Homebrew path
SHELL_RC="$HOME/.zshrc"
if [[ "$SHELL" == *"bash"* ]]; then
    SHELL_RC="$HOME/.bashrc"
fi

# Add Homebrew to shell profile if not already there
if [[ -f "/opt/homebrew/bin/brew" ]] && ! grep -q "/opt/homebrew/bin/brew" "$SHELL_RC" 2>/dev/null; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$SHELL_RC"
fi

# Create summary report
echo ""
echo "✅ Fresh macOS deployment complete!"
echo "📊 Summary:"
echo "  🍺 Homebrew: $(brew list | wc -l | tr -d ' ') packages installed"
echo "  📦 Applications: Check /Applications folder"
echo "  🔧 Dotfiles: Restored to home directory"
echo "  📁 Directories: Created important folders"
echo ""
echo "🔄 Next steps:"
echo "  1. Restart your terminal: source $SHELL_RC"
echo "  2. Review cloned repositories"
echo "  3. Configure any application-specific settings"
echo "  4. Set up SSH keys for Git repositories"
echo ""
echo "🚀 Your development environment is ready!"