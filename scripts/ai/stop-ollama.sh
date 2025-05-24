#!/bin/bash

# Ollama stop script

echo "🛑 Stopping Ollama..."

# Find and kill Ollama processes
PIDS=$(pgrep -f "ollama serve")

if [ -z "$PIDS" ]; then
    echo "✅ Ollama is not running"
    exit 0
fi

# Kill the processes
echo "🔄 Stopping Ollama server (PID: $PIDS)..."
kill $PIDS

# Wait a moment and check if processes are gone
sleep 2

if pgrep -f "ollama serve" > /dev/null; then
    echo "⚠️  Force killing Ollama..."
    pkill -9 -f "ollama serve"
fi

echo "✅ Ollama stopped successfully"