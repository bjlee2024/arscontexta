# Obsidian Platform -- Generation Reference

## Overview

The Obsidian platform adapter generates `.obsidian/` configuration alongside the standard arscontexta vault, making it a first-class Obsidian vault with graph view, color-coded spaces, and enhanced frontmatter.

**Conditional on:** `obsidian: true` in `.arscontexta` marker file.

## What Obsidian Platform Generates

### 1. `.obsidian/` Configuration Directory

Generated at Step 15b of `/setup` (after vault marker, before git init).

| File | Purpose | Git Tracked |
|------|---------|-------------|
| `app.json` | Obsidian app settings | Yes |
| `appearance.json` | Theme settings | Yes |
| `graph.json` | Global graph view config (color groups, physics) | Yes |
| `community-plugins.json` | Empty array (user installs manually) | Yes |
| `bookmarks.json` | Saved graph filter presets | Yes |
| `hotkeys.json` | Optional keyboard shortcuts | Yes |
| `workspace.json` | Workspace layout (volatile) | **No** (gitignored) |

Templates live in `platforms/obsidian/configs/` with `{DOMAIN:...}` markers for vocabulary transformation.

### 2. Enhanced Frontmatter Fields

When `obsidian: true`, note templates include additional fields:

```yaml
aliases: []      # Alternative names (Obsidian search/link)
tags: []         # Derived from topics (Obsidian tag filtering)
cssclasses: []   # Note-type CSS class (arscontexta-moc, arscontexta-note, etc.)
```

These are **additive** -- existing fields (description, type, topics, created) are unchanged.

### 3. `.gitignore` Entries

Appended to vault `.gitignore`:

```gitignore
# Obsidian -- volatile files
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/cache
```

### 4. Obsidian CLI Wrapper

`hooks/scripts/obsidian-cli.sh` provides optional `notesmd-cli` integration:
- `rename` -- rename note + update all wiki links across vault
- `frontmatter-set` -- set frontmatter key on a note
- `open` -- output `obsidian://` URI for a note

Falls back gracefully when `notesmd-cli` is not installed.

## Shared Components

Inherits from `platforms/shared/`:
- `skill-blocks/` -- 16 shared skill block definitions (reduce, reflect, etc.)
- `features/` -- Composable feature documentation
- `templates/` -- Shared template documentation

## Template Markers

Config templates use these markers, resolved during `/setup`:

| Marker | Resolved To | Example |
|--------|------------|---------|
| `{DOMAIN:notes}` | Notes folder name from vocabulary | `reflections` |
| `{DOMAIN:self}` | Self space folder | `self` |
| `{DOMAIN:ops}` | Ops space folder | `ops` |
| `{DOMAIN:inbox}` | Inbox folder | `inbox` |
| `{DOMAIN:note_type}` | Note type name | `reflection` |

## Obsidian URI Scheme

All URIs use `obsidian://open?path={absolute_path}` (NOT `vault=` parameter):

```
obsidian://open?path=/absolute/path/to/vault          # Open vault
obsidian://open?path=/absolute/path/to/vault/note.md   # Open specific note
```

The `path` parameter auto-resolves to the correct Obsidian vault.

## Target Obsidian Version

>= 1.4.0 (stable `graph.json` format with `colorGroups` support).

## Platform Characteristics

| Aspect | Detail |
|--------|--------|
| Requires Obsidian running | No (filesystem-first) |
| CLI tool | notesmd-cli (optional) |
| Graph view | Via `.obsidian/graph.json` color groups |
| Backlinks | Native Obsidian feature (no config needed) |
| Plugin recommendations | Documented, not auto-installed |
