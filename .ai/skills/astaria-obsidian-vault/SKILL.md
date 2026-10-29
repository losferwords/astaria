---
name: astaria-obsidian-vault
description: Maintain Astaria canonical articles, Obsidian links and metadata, local images, maps, chronology, bilingual Quartz publication, site layout and local browser checks.
---

# Astaria Obsidian Vault

Follow `.ai/AGENTS.md` for source boundaries, workflow routing and git checks. Use [project context](../../context/astaria-project.md) for structure and public lore boundaries; read [world context](../../context/astaria-world.md) when culture, eras or physical limits affect the task.

## Article shape and links

Use compact, queryable frontmatter without provenance fields:

```yaml
---
title:
aliases: []
lang: ru
type:
category:
related: []
ready: false
quartz: false
---
```

`ready` records completeness; a local artwork is usual but not mandatory. `quartz` independently controls intentional publication. Do not add obsolete `status`, `publish`, `draft`, `wip` or `tags` fields. Prefer meaningful properties and readable prose to speculative metadata.

Use `[[Target]]` or `[[Target|visible text]]`; qualify the path only for duplicate titles. Do not create category pages merely to list other notes; use folders, links or Dataview. Do not add saga-chapter backlinks to ordinary lore articles unless requested.

## Canonical prose and characters

Played-session retellings use continuous third-person past-tense prose, with indirect speech where appropriate. Attribute observations, guesses and discoveries to whoever made them. Do not turn a character's inference into established truth or add a recap, moral, explanation of the song, or invented cliffhanger after the last meaningful action. Avoid scene headings that the retelling does not need.

`Зов Бури` uses its own [present-tense song and lyric rules](../../context/call-of-thunder.md). Read them before editing or translating that saga; preserve supplied lyrics verbatim.

All ordinary characters belong in `Энциклопедия/Персонажи/`, without a public player/NPC split. For creation or profile completion, read [character fields](references/characters.md). For mechanics, use [Astaria Fate Core](../astaria-fate-core/SKILL.md).

## Images

- Render local files from `Assets/Images/` or `Assets/Maps/`: `![[Assets/Images/file.jpg]]` in prose, `cover_image: "[[Assets/Images/file.jpg]]"` in properties.
- Treat supplied new or replacement art as the user's original work unless another creator is named. Do not add it to `Assets/Images/credits.csv`.
- Keep `credits.csv` only for external art still used: exactly `file,artist,artist_website`, with all three values per row. Remove a replaced external work's row; delete the register when none remain. Do not store article links, alt text or descriptions there.
- Imitei class pages use paired 9:16 `female_portrait` and `male_portrait` art, not `_landscape` covers.
- For asset cleanup, check notes, translations, config and code: landing-page images and localized map layers can be used without ordinary article embeds. Attribute-only or historical export mentions do not by themselves prove active use. Respect the authorized scope of `Идеи/` checks.

## Maps and chronology

For markers, geographic reasoning, travel distances or map crops, read [maps.md](references/maps.md). It specifies `geoY, geoX`, coordinate-to-raster conversion and the author’s scale. Derive current counts from the source map.

Timeline records use numeric `year`, optional `endingYear`, `timeline: true`, `timeline_category` and `significance`. Display negative years as `ХЭ`, non-negative as `НЭ`. The main chronology combines `Хронология/События/` and timeline-enabled `Энциклопедия/События/` notes; verify affected records remain discoverable rather than enforcing a frozen total.

## Quartz

For publication, public relationship changes, site layout or local browser checks, read [quartz.md](references/quartz.md). It owns multilingual commands, generated-tree boundaries, derived reverse relationships, typography constraints and the standalone Playwright workflow for Codex in VS Code. Keep ordinary lore edits in canonical source notes.

## Validation

Choose checks relevant to the changed material: YAML and explicit booleans; affected wikilinks and local embeds; attribution rows when changed; coordinate order and marker targets when maps change; timeline discovery when dates change; privacy and spoiler fields when public relationships change; portable filenames for new files. Run synchronization/build validation for publication work as described in the Quartz reference. Do not audit every timeline or rebuild the site for a narrow unrelated edit.
