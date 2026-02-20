# Feature Block: Obsidian Integration

> Conditional: only included when `obsidian: true` in `.arscontexta`

## Obsidian Integration

This vault is configured as an Obsidian vault. The `.obsidian/` directory contains graph view settings, workspace layout, and plugin recommendations.

### Opening the Vault

```
obsidian://open?path={vault_absolute_path}
```

Use `path=` (absolute filesystem path). Do NOT use `vault=` (which requires the Obsidian vault name).

### Graph View

The graph view is pre-configured with three-space color coding:

| Space | Color | Contains |
|-------|-------|----------|
| `{DOMAIN:self}/` | Blue | Agent persistent mind |
| `{DOMAIN:notes}/` | Green | Knowledge graph (primary view) |
| `{DOMAIN:ops}/` | Amber | Operational coordination |
| `{DOMAIN:inbox}/` | Red | Processing queue |

Use graph bookmarks (Bookmarks pane) for saved filter presets:
- **Knowledge Graph** -- {DOMAIN:notes} space only
- **Full System** -- all spaces visible
- **Orphan Hunt** -- disconnected notes
- **MOC Network** -- topic maps only

### Enhanced Frontmatter

Notes include Obsidian-optimized fields:

- `aliases` -- alternative names for search and `[[` linking
- `tags` -- derived from topics (slugified MOC names), enables tag-based graph filtering
- `cssclasses` -- note-type CSS class (e.g., `arscontexta-moc`, `arscontexta-claim`)

When creating or editing notes, populate these fields:
- **aliases**: title keywords + description phrases that someone might search for
- **tags**: slugify each topic MOC name (e.g., `[[Cognitive Science MOC]]` -> `cognitive-science`)
- **cssclasses**: `arscontexta-{type}` where `{type}` is the note's type field

### Graph Command

`/{DOMAIN:graph} obsidian [preset]` outputs the Obsidian URI and graph context:
- `/{DOMAIN:graph} obsidian knowledge` -- notes space only
- `/{DOMAIN:graph} obsidian full` -- all spaces
- `/{DOMAIN:graph} obsidian orphans` -- orphaned notes
- `/{DOMAIN:graph} obsidian mocs` -- MOC network

### Recommended Plugins

These enhance the arscontexta experience (install manually via Settings > Community plugins):

- **Dataview** -- SQL-like queries over frontmatter (replaces grep-based queries)
- **Graph Analysis** -- PageRank, betweenness centrality for `/graph hubs`
- **Omnisearch** -- full-text + semantic search
- **Strange New Worlds** -- inline backlink counts

### File Management

- `.obsidian/workspace.json` is gitignored (Obsidian rewrites it frequently)
- `.obsidian/graph.json` and other configs are committed (stable settings)
- The `notesmd-cli` tool (optional) provides safe note renaming with automatic wiki-link updates across the vault
