#!/bin/bash
# Loads .env then starts agent-mem0 MCP server.
# Update GOOGLE_API_KEY in .env — this script picks it up automatically.
set -a
source "$(dirname "$0")/.env"
set +a
exec "/Volumes/T7 Shield/Users/Aditya/.local/bin/agent-mem0" serve --project AI-MUSIC-PRODUCTION
