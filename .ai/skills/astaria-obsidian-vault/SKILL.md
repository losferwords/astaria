---
name: astaria-obsidian-vault
description: "Use when maintaining the Astaria Obsidian vault: lore articles, structure, wikilinks, local images, interactive maps, chronology, multilingual publishing, Quartz, validation, or git workflow."
---

# Astaria Obsidian Vault

## Context

Astaria is a long-running mythological fantasy setting maintained as a self-contained Obsidian knowledge base.

Read `.ai/context/astaria-project.md` for project structure. Read `.ai/context/astaria-meta-and-fate.md` for cultural forms, chronology rules, and FATE mechanics when relevant.

## Source Hierarchy

1. Canonical lore in `Энциклопедия/`.
2. Historical records in `Хронология/`.
3. Map notes and markers in `Карты/`.
4. Service-only guidance in `.ai/context/`.
5. A specific file from `Идеи/` only when the user explicitly requests it.

Never use `Идеи/` as general lore context. Keep `Энциклопедия/Секреты/` private and do not expose its revelations in public articles without explicit approval.

## Article Shape

Use compact, queryable YAML without provenance fields:

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

`ready` means the article is complete enough to be treated as finished. Local artwork is the usual completion criterion, but an article may be deliberately accepted without it. `quartz` controls public synchronization independently.

Do not add generic or workflow tags. Use folders, `type`, `category`, dedicated properties, and wikilinks for facts and relationships. Add only properties that carry useful lore, querying, publishing, or workflow meaning. Prefer a readable section over obscure metadata.

Correct obvious spelling, punctuation, and rushed phrasing while preserving facts, continuity, and authorial intent.

## Links

- Use Obsidian wikilinks: `[[Target]]` or `[[Target|visible text]]`.
- Use path-qualified links only when duplicate note titles make them necessary.
- Do not add chapter backlinks to ordinary lore articles unless explicitly requested.
- Check unresolved links after broad changes.

## Images

- Render only local files from `Assets/Images/` and `Assets/Maps/`.
- Use `![[Assets/Images/file.jpg]]` in article bodies.
- Store image properties as wikilinks, for example `cover_image: "[[Assets/Images/file.jpg]]"`.
- Keep creator attribution in `Assets/Images/credits.csv`.
- For Imitei art, use paired 9:16 `female_portrait` and `male_portrait` images in the dedicated class-page layout. Do not add or retain `_landscape` covers for Imitei articles.

## Maps

Use Obsidian Leaflet with the political `Assets/Maps/states.png` layer as the default. The main map contains 132 markers and uses `geoY, geoX` order in Leaflet marker rows.

Keep physical and biome layers linked nearby:

- `Assets/Maps/heightmap.png`
- `Assets/Maps/biomes.png`

## Chronology

Historical notes use numeric `year` and optional `endingYear`, plus:

```yaml
timeline: true
timeline_category:
significance:
```

Display negative years as `ХЭ` and non-negative years as `НЭ`. The main chronology combines notes from `Хронология/События/` and timeline-enabled articles in `Энциклопедия/События/`.

## Characters

Keep all ordinary characters in `Энциклопедия/Персонажи/`. Follow `.ai/context/astaria-meta-and-fate.md` for required fields, ages, culture, and private FATE blocks.

## Publishing

`_scripts/sync_quartz_content.rb` generates `_quartz/content/` from notes with `quartz: true`. Never edit generated content as the source of truth.

Keep secrets, private mechanics, brainstorming, and notes with `quartz: false` out of the public build. The Secrets directory is denied even if a note is marked `quartz: true` by mistake.

## Validation

Before finishing broad changes, verify:

- YAML parses;
- wikilinks resolve or intentional stubs are documented;
- local image embeds point to existing files;
- map marker count and coordinate order remain correct;
- all 26 timeline records remain discoverable;
- canonical notes have explicit boolean `ready` and `quartz` fields;
- obsolete `status`, `publish`, `draft`, `wip`, and `tags` fields are absent;
- private notes are not published;
- Windows-invalid filename characters are absent;
- Quartz sync succeeds for publishing-related changes.
