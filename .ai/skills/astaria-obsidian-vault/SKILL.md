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

## Campaign Retellings

- Write played-session chapters as continuous third-person, past-tense narratives unless the user requests another form. Prefer indirect speech over reconstructed quotations.
- Preserve attribution precisely: state who examined an object, reached a conclusion, proposed a theory, or made a decision. Never turn a character's guess, skill result, or interpretation into an objective fact.
- Distinguish established discoveries from suspicions and incomplete theories in the prose itself.
- Do not add a concluding summary, moral, recap of clues, thematic coda, or artificial cliffhanger. The GM reads these chapters aloud before the next session, so end with the last meaningful action, decision, or discovery that actually occurred in play unless the user explicitly requests a literary finale.

## Links

- Use Obsidian wikilinks: `[[Target]]` or `[[Target|visible text]]`.
- Use path-qualified links only when duplicate note titles make them necessary.
- Do not add chapter backlinks to ordinary lore articles unless explicitly requested.
- Check unresolved links after broad changes.

## Images

- Render only local files from `Assets/Images/` and `Assets/Maps/`.
- Use `![[Assets/Images/file.jpg]]` in article bodies.
- Store image properties as wikilinks, for example `cover_image: "[[Assets/Images/file.jpg]]"`.
- Treat every new or replacement artwork supplied by the user as their original work unless they explicitly name another creator.
- Do not add user-created artwork to `Assets/Images/credits.csv`.
- Keep `Assets/Images/credits.csv` only for externally authored artwork still used by the project. Its exact columns are `file,artist,artist_website`; every row must contain all three values. Do not store article links, alt text, descriptions, or other image metadata there.
- When an externally authored image is replaced with the user's original artwork, remove its attribution row. The intended end state is to delete `credits.csv` once no externally authored artwork remains.
- For Imitei art, use paired 9:16 `female_portrait` and `male_portrait` images in the dedicated class-page layout. Do not add or retain `_landscape` covers for Imitei articles.

## Maps

Use Obsidian Leaflet with the political `Assets/Maps/states.png` layer as the default. The main map contains 136 markers and uses `geoY, geoX` order in Leaflet marker rows.

Keep physical and biome layers linked nearby:

- `Assets/Maps/heightmap.png`
- `Assets/Maps/biomes.png`

### Geography For Lore And Travel

Use map positions when describing places, livelihoods, journeys, and scenes. Read `geoX` and `geoY` from place notes when available, and consult the markers in `Карты/Карта Астарии.md`. Match positions to coastlines, roads, rivers, relief, and biomes across the map layers. Use `parent_location`, `country`, territorial articles, and the political layer for regional and state relationships; proximity to a country's label does not establish ownership. A region's marker is an anchor, not its boundary.

The author's scale is **10 canonical coordinate units = 1 km**. `geoX` increases eastward and `geoY` northward. Compute straight-line distance as `sqrt((x2 - x1)^2 + (y2 - y1)^2) / 10` km. A difference of 40 units on one axis is 4 km along that axis; include both axes for the full distance. Mistras and Theonia are approximately 12 km apart.

Distinguish straight-line distance from a road or sea route. Estimate route length from its visible course and account for terrain, crossings, and transport before inferring travel time. Treat the map as schematic: do not infer exact elevations, navigable water, or a large harbour merely from a coastal marker. Separate visible features and author-confirmed biomes from proposed explanations for them.

Crops or screenshots of map regions are allowed for geographic checks. Establish their bounds and scale first. Canonical coordinates use the **7680 × 4320** map space, while the current `heightmap.png` and `biomes.png` rasters are **5760 × 3240**. Check actual image dimensions rather than assuming equal sizes. For a layer of width `W` and height `H`, convert to top-left raster coordinates with `pixelX = geoX * W / 7680` and `pixelY = (4320 - geoY) * H / 4320`. Preserve that conversion when cropping or resizing; screenshot pixels are not canonical map units. Local map analysis may use ordinary raster cropping tools without generating or repainting geography.

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

Site typography is self-hosted: keep `fontOrigin: local` and the bundled Alegreya SC / IBM Plex Mono files and licenses in `_quartz/quartz/static/fonts/`. Use `1rem` for the article body and preserve the author's `--astaria-prose-width: 82ch` when changing fonts. Keep `82ch` as a maximum, not a minimum requirement for displaying the sidebar. Keep the article container at `1170px`, as requested by the author, independently of the prose measure. Above the existing `900px` mobile breakpoint, the text uses the available space up to the sidebar's left margin and keeps that same width below the sidebar. Do not reintroduce a container query that stacks metadata merely because the full maximum prose measure does not fit. On mobile and in search previews, place metadata above the prose. This applies to countries, characters and other lore as well as stories.

## Validation

Before finishing broad changes, verify:

- YAML parses;
- wikilinks resolve or intentional stubs are documented;
- local image embeds point to existing files;
- `Assets/Images/credits.csv`, while it exists, contains only complete external-art attribution rows and exactly the three approved columns;
- map marker count and coordinate order remain correct;
- all 28 timeline records remain discoverable;
- canonical notes have explicit boolean `ready` and `quartz` fields;
- obsolete `status`, `publish`, `draft`, `wip`, and `tags` fields are absent;
- private notes are not published;
- Windows-invalid filename characters are absent;
- Quartz sync succeeds for publishing-related changes.
