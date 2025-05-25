#!/bin/bash

# System Assessment Script
# Captures current system state for deployment to new user profile

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="$HOME/system-assessment-$TIMESTAMP"
MANIFEST="$OUTPUT_DIR/deployment-manifest.json"

echo "🔍 Starting system assessment..."
mkdir -p "$OUTPUT_DIR"

# Initialize manifest
cat > "$MANIFEST" << 'EOF'
{
  "timestamp": "",
  "hostname": "",
  "os": "",
  "user": "",
  "applications": {},
  "repositories": [],
  "dotfiles": [],
  "directories": [],
  "environment": {}
}
EOF

# Update basic info
jq --arg ts "$TIMESTAMP" \
   --arg host "$(hostname)" \
   --arg os "$(uname -s)" \
   --arg user "$(whoami)" \
   '.timestamp = $ts | .hostname = $host | .os = $os | .user = $user' \
   "$MANIFEST" > "$MANIFEST.tmp" && mv "$MANIFEST.tmp" "$MANIFEST"

echo "📦 Assessing applications..."
./assess-applications.sh "$OUTPUT_DIR"

echo "📁 Discovering repositories..."
./assess-repositories.sh "$OUTPUT_DIR"

echo "🏠 Analyzing filesystem structure..."
./assess-filesystem.sh "$OUTPUT_DIR"

echo "⚙️  Capturing environment..."
./assess-environment.sh "$OUTPUT_DIR"

echo "✅ Assessment complete: $OUTPUT_DIR"
echo "📋 Manifest: $MANIFEST"
echo ""
echo "To deploy to new system:"
echo "  ./deploy-system.sh $OUTPUT_DIR"