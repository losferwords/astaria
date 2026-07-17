# Astaria Project Context

## Setting

`Астария` is Maksim's long-running mythological fantasy world. It contains ancient civilizations, countries, peoples, gods, Imitei, political conflicts, legends, maps, and several sagas. The central campaign is `Ветер Перемен`, played with FATE Core System.

The Obsidian vault is the primary and self-contained knowledge base. Lore should remain convenient for the author, players, friends, and selective Quartz publication.

## Canonical Structure

- `Энциклопедия/` - canonical lore and literature.
- `Энциклопедия/Бестиарий/` - species and creatures.
- `Энциклопедия/Боги/` - gods.
- `Энциклопедия/Знания/` - concepts, conditions, rituals, and general knowledge.
- `Энциклопедия/Имитеи/` - Imitei traditions and professions.
- `Энциклопедия/Литература/` - sagas and canonical prose.
- `Энциклопедия/Места/` - settlements and geography.
- `Энциклопедия/Народы/` - peoples and cultures.
- `Энциклопедия/Организации/` - cults, circles, and other organizations.
- `Энциклопедия/Персонажи/` - all ordinary characters.
- `Энциклопедия/Предметы/` - notable objects.
- `Энциклопедия/Секреты/` - private GM-only truths and revelations.
- `Энциклопедия/События/` - major conflicts, myths, and event articles.
- `Энциклопедия/Страны/` - states and their core relationships.
- `Энциклопедия/Флора/` - plants.
- `Хронология/` - 26 dated historical records and the readable timeline.
- `Карты/` - the interactive map with 132 markers.
- `Assets/Images/` and `Assets/Maps/` - local visual assets.
- `Идеи/` - private non-canonical brainstorming, excluded from research by default.

Image creator information is retained in `Assets/Images/credits.csv`.

## Lore Boundaries

- `Энциклопедия/Секреты/` may guide internal consistency and foreshadowing, but its facts must not be exposed in public articles without explicit approval.
- FATE mechanics and GM notes stay private unless the user requests otherwise.
- `Идеи/` is output-only by default and must not be treated as canon.
- Canonical notes use explicit `ready` and `quartz` booleans. `ready` records completion; `quartz` alone controls intentional public synchronization.
- Generic tags are not used. Classification and relationships belong in folders, typed properties, and wikilinks.

## Campaign Chapters

Campaign chapters are continuous narrative retellings with YAML metadata. Keep one chapter per Markdown file and avoid forced internal scene headings unless requested.

Current saga folders:

- `Энциклопедия/Литература/Ветер Перемен/`
- `Энциклопедия/Литература/Зов Бури/`
- `Энциклопедия/Литература/Пока Боги Спят/`

Chapter notes may link to relevant lore. Ordinary encyclopedia articles should not link back to particular chapters by default.

## Publishing

Quartz lives in `_quartz/`. `_scripts/sync_quartz_content.rb` copies only intentionally published notes from `Энциклопедия/`, `Хронология/`, and `Карты/`, together with their referenced local assets.

Public paths use English category directories and slugs independently from Russian vault paths. Prefer explicit `public_slug` values for canonical public URLs.

Local checks:

```bash
ruby _scripts/sync_quartz_content.rb
cd _quartz
NODE_OPTIONS=--max-old-space-size=8192 node quartz/bootstrap-cli.mjs build -d content -o public
```

## Service Context

`.ai/context/astaria-meta-and-fate.md` contains cultural references, forms of address, era rules, and FATE generation guidance. Read it before creating culture-sensitive lore, characters, names, demonyms, dialogue, aspects, skills, stunts, or character sheets.
