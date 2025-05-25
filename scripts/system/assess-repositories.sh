#!/bin/bash

# Repository Discovery Script
OUTPUT_DIR="$1"
REPOS_FILE="$OUTPUT_DIR/repositories.json"

echo "  📂 Discovering Git repositories..."

# Initialize repos file
echo '[]' > "$REPOS_FILE"

# Common development directories to search
SEARCH_DIRS=(
    "$HOME"
    "$HOME/Documents"
    "$HOME/Desktop"
    "$HOME/Projects"
    "$HOME/Code"
    "$HOME/Development"
    "$HOME/dev"
    "$HOME/work"
    "$HOME/personal"
)

# Find all git repositories
REPOS=()
for dir in "${SEARCH_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "    🔍 Searching $dir..."
        while IFS= read -r -d '' repo; do
            REPO_DIR=$(dirname "$repo")
            
            # Skip if already found (nested repos)
            ALREADY_FOUND=false
            for existing in "${REPOS[@]}"; do
                if [[ "$REPO_DIR" == "$existing"* ]]; then
                    ALREADY_FOUND=true
                    break
                fi
            done
            
            if [ "$ALREADY_FOUND" = false ]; then
                REPOS+=("$REPO_DIR")
                
                # Get repo info
                cd "$REPO_DIR"
                REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
                BRANCH=$(git branch --show-current 2>/dev/null || echo "")
                STATUS=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
                LAST_COMMIT=$(git log -1 --format="%H %s" 2>/dev/null || echo "")
                
                # Add to JSON
                REPO_INFO=$(jq -n \
                    --arg path "$REPO_DIR" \
                    --arg remote "$REMOTE_URL" \
                    --arg branch "$BRANCH" \
                    --arg status "$STATUS" \
                    --arg commit "$LAST_COMMIT" \
                    '{
                        path: $path,
                        remote: $remote,
                        branch: $branch,
                        uncommitted_changes: ($status | tonumber),
                        last_commit: $commit
                    }'
                )
                
                jq --argjson repo "$REPO_INFO" '. += [$repo]' "$REPOS_FILE" > "$REPOS_FILE.tmp" && mv "$REPOS_FILE.tmp" "$REPOS_FILE"
                
                echo "      ✓ Found: $REPO_DIR"
            fi
        done < <(find "$dir" -name ".git" -type d -print0 2>/dev/null)
    fi
done

REPO_COUNT=$(jq length "$REPOS_FILE")
echo "  ✅ Found $REPO_COUNT repositories"