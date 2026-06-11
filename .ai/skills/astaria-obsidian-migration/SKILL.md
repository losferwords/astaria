---
name: astaria-obsidian-migration
description: "Use when working on the Astaria WorldAnvil-to-Obsidian migration: analyzing the World-Астария-2fa export, designing the Obsidian vault, converting lore articles, preserving links/images/maps/timelines, planning multilingual publishing, Quartz hosting, or git workflow for the Astaria wiki."
---

# Astaria Obsidian Migration

## Core Context

Astaria is a long-running mythological fantasy setting. The user is testing Obsidian as a replacement for WorldAnvil and wants a portable, beautiful lore wiki with campaign notes, bilingual publication, chronology, and interactive fantasy maps.

For richer background, read `.ai/context/astaria-project.md`. For cultural references, correct demonyms/forms of address, and FATE Core generation rules, read `.ai/context/astaria-meta-and-fate.md`. For the first detailed investigation, read `Obsidian-перенос WorldAnvil - изыскания.md`.

## Source Rules

- Treat `World-Астария-2fa/` as immutable source data unless explicitly asked otherwise.
- Prefer JSON over HTML for conversion. HTML is useful for visual comparison only.
- Preserve original WorldAnvil UUIDs as `wa_id`.
- Preserve original URLs as `wa_url` when present.
- Do not assume draft/private material is safe to publish.
- Keep player-facing lore separate from GM/private campaign notes.
- Keep FATE mechanics, hidden GM notes, and private character mechanics out of player-facing article bodies unless the user explicitly asks to expose them.
- Exclude `06 Черновики/Идеи/` from lore/source research by default. It is a private idea workbench, not canon. Use it only when the user explicitly asks to use or canonize a specific idea.

## Preferred Migration Shape

Use a small pilot before bulk import:

1. `Organization-Талассия-665.json`
2. `Person-Мерката-9e8.json`
3. `HistoricalEntry-Основание Талассии-260.json`
4. `Map-Астария-79d.json` plus 5-10 markers
5. an overview page for Astaria

Suggested vault structure:

```text
01 Мир/
02 Энциклопедия/
03 Кампании/Ветер Перемен/
04 Хронология/
05 Карты/
Assets/Images/
Assets/Maps/
_templates/
_scripts/
_source/WorldAnvil/
```

## Article Conversion

For each article JSON:

1. Read `id`, `title`, `templateType`, `category.title`, `tags`, `state`, `isDraft`, `isWip`, `url`, `slug`.
2. Create Markdown with YAML frontmatter:

```yaml
title:
lang: ru
type:
category:
tags: []
wa_id:
wa_url:
wa_slug:
publish: false
draft:
wip:
```

3. Put the main `content` in the Markdown body.
4. Move stable WorldAnvil fields into YAML only when useful for querying.
5. Move long or rare WorldAnvil fields into readable sections.
6. Keep file names human-readable; handle duplicate titles by adding type or short UUID.

Do not add links from encyclopedia/lore articles to specific campaign saga chapters by default. Saga chapter backlinks belong in campaign notes, indexes, Dataview queries, or explicit user-requested cross-references. Add chapter links inside lore articles only when the user explicitly asks for that connection.

## Links

Build an index before converting bodies:

```text
WorldAnvil UUID -> Markdown path
WorldAnvil UUID -> title
```

Convert:

```text
@[visible text](type:uuid)
```

to:

```text
[[Target Note|visible text]]
```

Use path-qualified wikilinks if duplicate names exist.

## Images

WorldAnvil image metadata lives in `World-Астария-2fa/images/*.json`; actual bitmap files may be elsewhere.

Map image ID found during investigation:

- `5066626`
- 7680x4320 PNG
- WorldAnvil filename: `b6c4c019dfc81372c3a51a0e87470579.png`

For articles, map `cover`, `portrait`, `flag`, `gallery`, and `[img:id|...]` to local embeds when possible:

```markdown
![[Assets/Images/file.jpg]]
```

Keep `wa_cover_id`, `wa_portrait_id`, or similar fields if local matching is incomplete.

## Maps

Use Obsidian Leaflet for fantasy image maps, not GIS-first map tools.

The Astaria map export contains one map, 132 markers, two layers, and two marker groups. Markers include `geoX` and `geoY`. Verify coordinate order on the pilot; Leaflet image maps may need `geoY, geoX`.

Example target shape:

```leaflet
id: astaria-world-map
image: [[Assets/Maps/astaria-world-map.png]]
height: 700px
minZoom: -3
maxZoom: 2
defaultZoom: -2
unit: pixels
marker:
  - default, 1358, 2689, [[Город Самаан]]
```

## Timelines

`histories/*.json` contains event data. Convert each event to Markdown with:

```yaml
type: historical-event
year:
month:
day:
endingYear:
category:
significance:
wa_id:
```

Start with Dataview tables and a readable Markdown chronology. Avoid hard dependency on old timeline plugins until the pilot proves they are needed.

## Publishing

For the first test, prefer a free path:

- Obsidian for local editing.
- Git for history and portability.
- Quartz or similar static-site generator for publishing.
- GitHub Pages, Cloudflare Pages, Netlify, or Vercel for hosting.

Use `publish: true` or a similar frontmatter flag to select public pages.

For bilingual content, prefer separate files per language connected by `translation_key` and `translations`, not two languages in one note.

## Validation Checklist

Before calling a migration step done, check:

- source export was not mutated;
- created Markdown opens cleanly in Obsidian;
- YAML is valid;
- links resolve or unresolved links are documented;
- images either render or keep traceable WorldAnvil image IDs;
- draft/private content is not marked for publishing by default;
- map markers are visually checked on a small sample;
- any scripts are repeatable and scoped to generated output.
