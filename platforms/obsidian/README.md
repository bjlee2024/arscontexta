# Obsidian Integration for arscontexta

arscontexta vaults are already ~80% Obsidian-compatible by design: wiki links, YAML frontmatter, flat folder structure, and MOC patterns are all native to both systems.

This platform adapter bridges the remaining 20%: `.obsidian/` configuration, graph view color coding, enhanced frontmatter, and optional CLI integration.

## Prerequisites

- **Obsidian** >= 1.4.0 ([obsidian.md](https://obsidian.md))
- **notesmd-cli** (optional) -- `brew install yakitrak/yakitrak/notesmd-cli` or `go install github.com/Yakitrak/notesmd-cli@latest`

## Setup

During `/arscontexta:setup`, select "Yes" when asked about Obsidian integration. This:

1. Sets `obsidian: true` in `.arscontexta` config
2. Generates `.obsidian/` directory with graph settings
3. Adds Obsidian-friendly frontmatter fields to templates
4. Adds `.obsidian/workspace.json` to `.gitignore`

## Opening Your Vault in Obsidian

During `/arscontexta:setup`, you'll choose an existing Obsidian vault or create a new one. The vault is automatically registered with Obsidian, so you can open it directly:

```
obsidian://open?vault=YourVaultName
```

The vault name is stored in `.arscontexta` as `obsidian_vault_name` and used for all URI generation. If you need to change it, edit `.arscontexta` directly or re-run setup.

## Graph View

The generated `graph.json` color-codes the three-space architecture:

| Space | Color | What It Contains |
|-------|-------|-----------------|
| `self/` | Blue | Agent persistent mind |
| `notes/` (domain-named) | Green | Knowledge graph |
| `ops/` | Amber | Operational coordination |
| `inbox/` | Red | Processing queue |

### Graph Presets (via Bookmarks)

4 saved graph filters are available as Obsidian bookmarks:

1. **Knowledge Graph** -- notes space only (the primary view)
2. **Full System** -- all spaces with color coding
3. **Orphan Hunt** -- notes with 0 backlinks
4. **MOC Network** -- MOC-to-MOC connections

Access via: Bookmarks pane > Graph filters

### `/graph obsidian` Command

Use `/graph obsidian [preset]` to get graph view URIs:

```
/graph obsidian knowledge   # Notes space only
/graph obsidian full        # All spaces
/graph obsidian orphans     # Orphaned notes
/graph obsidian mocs        # MOC network
```

## Enhanced Frontmatter

When `obsidian: true`, notes include additional fields:

```yaml
---
description: "Why spreading activation explains wiki-link traversal"
type: claim
topics: ["[[Cognitive Science MOC]]"]
created: 2026-02-20
# Obsidian enhancements
aliases: ["spreading activation", "link traversal model"]
tags: [cognitive-science]
cssclasses: [arscontexta-claim]
---
```

- **aliases** -- alternative names for search and linking
- **tags** -- derived from topics, enables tag-based graph filtering
- **cssclasses** -- CSS class per note type (for custom styling)

## Recommended Plugins

These are recommendations only (not auto-installed):

| Plugin | Why | Synergy |
|--------|-----|---------|
| Dataview | SQL-like queries over frontmatter | Replaces grep-based YAML queries |
| Graph Analysis | PageRank, betweenness centrality | Enhances `/graph hubs` and `/graph bridges` |
| Templater | Template execution | Can source from arscontexta templates/ |
| Omnisearch | Full-text + semantic search | Enhances discovery-first principle |
| Breadcrumbs | Hierarchical navigation | Visualizes MOC hierarchy |
| Strange New Worlds | Inline backlink counts | Makes connection density visible |

## CSS Snippets (Optional)

Create `.obsidian/snippets/arscontexta.css` to style note types:

```css
/* MOC notes -- distinct background */
.arscontexta-moc {
  --background-primary: hsl(210, 30%, 96%);
}

/* Claim notes -- subtle left border */
.arscontexta-claim .markdown-preview-view {
  border-left: 3px solid hsl(150, 50%, 60%);
  padding-left: 1em;
}

/* Session logs -- muted appearance */
.arscontexta-session-log {
  opacity: 0.85;
}
```

Enable via: Settings > Appearance > CSS snippets > Enable `arscontexta`

## Troubleshooting

### Vault not detected by Obsidian
Ensure the vault directory contains `.obsidian/`. If you set up without Obsidian initially, run `/arscontexta:setup` again with Obsidian enabled, or manually create `.obsidian/` from the templates.

### Git conflicts in `.obsidian/`
`workspace.json` is gitignored by default. If you see conflicts in other `.obsidian/` files, these are stable config files that should merge cleanly. Use `git checkout --theirs .obsidian/graph.json` to accept remote changes.

### `notesmd-cli` not found
The CLI is optional. All operations fall back to direct filesystem operations. Install with: `brew install yakitrak/yakitrak/notesmd-cli`

### Graph view shows too many nodes
Use local graph view (Ctrl/Cmd+Shift+G) for focused exploration. The bookmarked presets filter to specific spaces.
