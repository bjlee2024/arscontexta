#!/bin/bash
# Ars Contexta — Obsidian Vault Discovery
# Discovers registered Obsidian vaults from obsidian.json config.
# Usage: obsidian-vaults.sh {list|register|find-config}
#
# Obsidian stores vault registry in:
#   Linux:  ~/.config/obsidian/obsidian.json
#   macOS:  ~/Library/Application Support/obsidian/obsidian.json
#   Snap:   ~/snap/obsidian/current/.config/obsidian/obsidian.json
#   Flatpak: ~/.var/app/md.obsidian.Obsidian/config/obsidian/obsidian.json

set -e

# Find obsidian.json config file
find_obsidian_config() {
  local candidates=(
    "$HOME/.config/obsidian/obsidian.json"
    "$HOME/Library/Application Support/obsidian/obsidian.json"
    "$HOME/snap/obsidian/current/.config/obsidian/obsidian.json"
    "$HOME/.var/app/md.obsidian.Obsidian/config/obsidian/obsidian.json"
  )
  for candidate in "${candidates[@]}"; do
    if [ -f "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done
  # Try snap versioned paths
  local snap_latest
  snap_latest=$(ls -1d "$HOME/snap/obsidian"/[0-9]*/.config/obsidian/obsidian.json 2>/dev/null | sort -t/ -k6 -n | tail -1)
  if [ -n "$snap_latest" ] && [ -f "$snap_latest" ]; then
    echo "$snap_latest"
    return 0
  fi
  return 1
}

OPERATION="${1:-list}"
shift 2>/dev/null || true

case "$OPERATION" in
  find-config)
    # Output the path to obsidian.json if found
    CONFIG=$(find_obsidian_config) || { echo "NOT_FOUND"; exit 1; }
    echo "$CONFIG"
    ;;

  list)
    # List all registered vaults as: NAME\tPATH\tID
    CONFIG=$(find_obsidian_config) || { echo "No Obsidian config found." >&2; exit 1; }
    if ! command -v jq &>/dev/null; then
      echo "jq required for vault discovery. Install: sudo apt install jq" >&2
      exit 1
    fi
    jq -r '.vaults | to_entries[] | "\(.value.path | split("/") | last)\t\(.value.path)\t\(.key)"' "$CONFIG" 2>/dev/null
    ;;

  register)
    # Register a vault path with Obsidian
    # Usage: obsidian-vaults.sh register /absolute/path/to/vault
    VAULT_PATH="$1"
    if [ -z "$VAULT_PATH" ]; then
      echo "Usage: obsidian-vaults.sh register /absolute/path/to/vault" >&2
      exit 1
    fi
    # Resolve to absolute path
    VAULT_PATH="$(cd "$VAULT_PATH" 2>/dev/null && pwd)" || { echo "Path does not exist: $1" >&2; exit 1; }
    CONFIG=$(find_obsidian_config) || { echo "No Obsidian config found." >&2; exit 1; }
    if ! command -v jq &>/dev/null; then
      echo "jq required for vault registration. Install: sudo apt install jq" >&2
      exit 1
    fi
    # Check if already registered
    EXISTING=$(jq -r --arg path "$VAULT_PATH" '.vaults | to_entries[] | select(.value.path == $path) | .key' "$CONFIG" 2>/dev/null)
    if [ -n "$EXISTING" ]; then
      VAULT_NAME=$(basename "$VAULT_PATH")
      echo "$VAULT_NAME"
      exit 0
    fi
    # Generate a vault ID (16 hex chars, matching Obsidian's format)
    VAULT_ID=$(head -c 8 /dev/urandom | xxd -p)
    TIMESTAMP=$(date +%s)000
    # Add vault entry to obsidian.json
    jq --arg id "$VAULT_ID" --arg path "$VAULT_PATH" --arg ts "$TIMESTAMP" \
      '.vaults[$id] = {"path": $path, "ts": ($ts | tonumber)}' \
      "$CONFIG" > "${CONFIG}.tmp" && mv "${CONFIG}.tmp" "$CONFIG"
    VAULT_NAME=$(basename "$VAULT_PATH")
    echo "$VAULT_NAME"
    ;;

  *)
    echo "Ars Contexta — Obsidian Vault Discovery" >&2
    echo "" >&2
    echo "Usage: obsidian-vaults.sh {list|register|find-config}" >&2
    echo "" >&2
    echo "Commands:" >&2
    echo "  list                    List registered Obsidian vaults (NAME PATH ID)" >&2
    echo "  register /path/to/vault Register a vault with Obsidian" >&2
    echo "  find-config             Output path to obsidian.json" >&2
    exit 1
    ;;
esac
