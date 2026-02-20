#!/bin/bash
# Ars Contexta — Schema Enforcement Hook
# Validates notes in the knowledge space have required fields.
# Runs as PostToolUse hook on Write events.
# Receives tool input as JSON on stdin.

# Only run in Ars Contexta vaults
GUARD_DIR="$(cd "$(dirname "$0")" && pwd)"
if ! "$GUARD_DIR/vaultguard.sh"; then
  cat > /dev/null  # drain stdin
  exit 0
fi

# Read JSON from stdin
INPUT=$(cat)

# Extract file path (requires jq)
if command -v jq &>/dev/null; then
  FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
else
  # Fallback: try to extract with grep/sed if jq unavailable
  FILE=$(echo "$INPUT" | grep -o '"file_path":"[^"]*"' | head -1 | sed 's/"file_path":"//;s/"//')
fi

# Early exit if no file path
[ -z "$FILE" ] && exit 0
[ ! -f "$FILE" ] && exit 0

# Only validate notes in the knowledge space
case "$FILE" in
  */notes/*|*thinking/*)
    WARNS=""
    if ! head -20 "$FILE" | grep -q "^description:"; then
      WARNS="${WARNS}Missing description field. "
    fi
    if ! head -20 "$FILE" | grep -q "^topics:"; then
      WARNS="${WARNS}Missing topics field. "
    fi
    if ! head -1 "$FILE" | grep -q "^---$"; then
      WARNS="${WARNS}Missing YAML frontmatter. "
    fi
    # Obsidian-specific field warnings (advisory only)
    READ_CONFIG="$GUARD_DIR/read_config.sh"
    if [ "$(bash "$READ_CONFIG" "obsidian" "false")" = "true" ]; then
      OBS_WARNS=""
      if ! head -20 "$FILE" | grep -q "^aliases:"; then
        OBS_WARNS="${OBS_WARNS}Missing aliases field (Obsidian search). "
      fi
      if head -20 "$FILE" | grep -q "^type:" && ! head -20 "$FILE" | grep -q "^cssclasses:"; then
        OBS_WARNS="${OBS_WARNS}Missing cssclasses field (Obsidian styling). "
      fi
      if [ -n "$OBS_WARNS" ]; then
        WARNS="${WARNS}[Obsidian] ${OBS_WARNS}"
      fi
    fi

    if [ -n "$WARNS" ]; then
      FILENAME=$(basename "$FILE" .md)
      echo "{\"additionalContext\": \"Schema warnings for $FILENAME: $WARNS\"}"
    fi
    ;;
esac

exit 0
