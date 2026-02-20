#!/bin/bash
# Ars Contexta — Obsidian CLI Wrapper
# Uses notesmd-cli if available, falls back to direct filesystem operations.
# Usage: obsidian-cli.sh {rename|frontmatter-set|open|uri|vaults|register} [args...]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
READ_CONFIG="$SCRIPT_DIR/read_config.sh"

# Check if Obsidian integration is enabled
if [ "$(bash "$READ_CONFIG" "obsidian" "false")" != "true" ]; then
  exit 0
fi

VAULT_PATH="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VAULT_NAME="$(bash "$READ_CONFIG" "obsidian_vault_name" "")"
HAS_CLI=false

if command -v notesmd-cli &>/dev/null; then
  HAS_CLI=true
fi

# Build obsidian:// URI: prefer vault= (registered), fall back to path=
build_vault_uri() {
  if [ -n "$VAULT_NAME" ]; then
    echo "obsidian://open?vault=$(echo "$VAULT_NAME" | sed 's/ /%20/g')"
  else
    echo "obsidian://open?path=${VAULT_PATH}"
  fi
}

build_note_uri() {
  local note="$1"
  if [ -n "$VAULT_NAME" ]; then
    echo "obsidian://open?vault=$(echo "$VAULT_NAME" | sed 's/ /%20/g')&file=$(echo "$note" | sed 's/ /%20/g')"
  else
    echo "obsidian://open?path=${VAULT_PATH}/${note}.md"
  fi
}

OPERATION="$1"
shift

case "$OPERATION" in
  rename)
    # Rename a note and update all wiki links across the vault
    # Usage: obsidian-cli.sh rename "old title" "new title"
    OLD_TITLE="$1"
    NEW_TITLE="$2"
    if [ -z "$OLD_TITLE" ] || [ -z "$NEW_TITLE" ]; then
      echo "Usage: obsidian-cli.sh rename \"old title\" \"new title\"" >&2
      exit 1
    fi
    if [ "$HAS_CLI" = true ]; then
      notesmd-cli rename "$OLD_TITLE" "$NEW_TITLE" --vault "$VAULT_PATH"
    else
      echo "WARN: notesmd-cli not found. Manual rename required — wiki links will not be auto-updated." >&2
      echo "Install: brew install yakitrak/yakitrak/notesmd-cli" >&2
      exit 1
    fi
    ;;

  frontmatter-set)
    # Set a frontmatter key on a note
    # Usage: obsidian-cli.sh frontmatter-set "note title" key value
    NOTE="$1"
    KEY="$2"
    VALUE="$3"
    if [ -z "$NOTE" ] || [ -z "$KEY" ] || [ -z "$VALUE" ]; then
      echo "Usage: obsidian-cli.sh frontmatter-set \"note title\" key value" >&2
      exit 1
    fi
    if [ "$HAS_CLI" = true ]; then
      notesmd-cli frontmatter set "$NOTE" --vault "$VAULT_PATH" --key "$KEY" --value "$VALUE"
    else
      echo "WARN: notesmd-cli not found. Frontmatter must be edited manually." >&2
      exit 1
    fi
    ;;

  open)
    # Open a note or vault in Obsidian via URI scheme
    # Usage: obsidian-cli.sh open ["note title"]
    NOTE="$1"
    if [ -n "$NOTE" ]; then
      build_note_uri "$NOTE"
    else
      build_vault_uri
    fi
    ;;

  uri)
    # Output the vault URI (for embedding in docs/output)
    # Usage: obsidian-cli.sh uri
    build_vault_uri
    ;;

  vaults)
    # List registered Obsidian vaults
    # Usage: obsidian-cli.sh vaults
    bash "$SCRIPT_DIR/obsidian-vaults.sh" list
    ;;

  register)
    # Register current vault with Obsidian
    # Usage: obsidian-cli.sh register [path]
    REG_PATH="${1:-$VAULT_PATH}"
    bash "$SCRIPT_DIR/obsidian-vaults.sh" register "$REG_PATH"
    ;;

  *)
    echo "Ars Contexta Obsidian CLI Wrapper" >&2
    echo "" >&2
    echo "Usage: obsidian-cli.sh {rename|frontmatter-set|open|uri|vaults|register} [args...]" >&2
    echo "" >&2
    echo "Commands:" >&2
    echo "  rename \"old\" \"new\"              Rename note + update all wiki links" >&2
    echo "  frontmatter-set \"note\" key val  Set frontmatter field" >&2
    echo "  open [\"note title\"]             Output obsidian:// URI to open note/vault" >&2
    echo "  uri                             Output vault obsidian:// URI" >&2
    echo "  vaults                          List registered Obsidian vaults" >&2
    echo "  register [path]                 Register vault with Obsidian" >&2
    echo "" >&2
    echo "Requires: notesmd-cli (rename, frontmatter-set)" >&2
    echo "Install:  brew install yakitrak/yakitrak/notesmd-cli" >&2
    exit 1
    ;;
esac
