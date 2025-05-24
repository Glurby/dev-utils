#!/bin/bash

# Ollama startup script

echo "🚀 Starting Ollama..."

# Check if Ollama is already running
if pgrep -f "ollama serve" > /dev/null; then
    echo "✅ Ollama is already running"
    echo "📍 Server: http://127.0.0.1:11434"
    exit 0
fi

# Start Ollama server in background
echo "🔄 Starting Ollama server..."
nohup ollama serve > /tmp/ollama.log 2>&1 &

# Wait for server to start
echo "⏳ Waiting for server to start..."
sleep 3

# Check if server is responding
if curl -s http://127.0.0.1:11434 > /dev/null; then
    echo "✅ Ollama server started successfully"
    echo "📍 Server: http://127.0.0.1:11434"
    echo "📝 Logs: /tmp/ollama.log"
    echo ""
    echo "Available commands:"
    echo "  ollama pull <model>    # Download a model"
    echo "  ollama run <model>     # Run a model"
    echo "  ollama list            # List installed models"
else
    echo "❌ Failed to start Ollama server"
    echo "📝 Check logs: /tmp/ollama.log"
    exit 1
fi