#!/bin/bash

# Ensure required environment variables are set
if [[ -z "$SOLANA_WALLET" || -z "$RAM_SIZE" || -z "$DISK_SIZE" || -z "$CACHE_DIR" ]]; then
  echo "Error: One or more environment variables are missing!"
  exit 1
fi

# Run the application with the correct environment variables
exec ./pop --ram="$RAM_SIZE" --pubKey="$SOLANA_WALLET" --max-disk="$DISK_SIZE" --cache-dir="$CACHE_DIR"
