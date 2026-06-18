# Astaria Project Context

## What Astaria Is

`Астария` is the user's long-running fictional world, developed for nearly eight years. Its genre is mythological fantasy. The setting has deep lore, politics, gods, mythology, many characters, and a central saga called `Ветер Перемен`.

`Ветер Перемен` is an RPG campaign in the Astaria setting, run with FATE Core System.

The user wants the lore to be convenient for players and friends, not only for private writing.

## Current Situation

The lore currently lives mostly on WorldAnvil. The user is tired of WorldAnvil and wants to test Obsidian as a new tool for:

- maintaining a beautiful local wiki;
- reading lore articles comfortably, including art;
- keeping campaign notes;
- preserving and organizing mythology, politics, gods, places, people, species, items, events, maps, and timelines;
- later publishing selected material online;
- keeping the vault portable through git or another versioned workflow.

The user does not want to buy an Obsidian subscription yet, because they first want to see whether Obsidian feels comfortable.

## Existing Files

- `World-Астария-2fa/` contains a WorldAnvil backup/export.
- `Welcome.md` is the default Obsidian welcome note.
- `.obsidian/` exists, so this folder is already usable as an Obsidian vault.
- `Obsidian-перенос WorldAnvil - изыскания.md` contains the first investigation and migration plan.
- `.ai/context/astaria-meta-and-fate.md` contains service-only world meta, cultural references, correct forms of address, and FATE Core generation rules copied from `meta.json`.
- `.ai/skills/astaria-idea-workbench/SKILL.md` handles creative brainstorming requests and saves ideas to `06 Черновики/Идеи/`.
- `06 Черновики/Идеи/` is a private idea workbench only. It is not canon, not a knowledge source, and should not be used for lore generation or database lookup unless the user explicitly asks to use a specific idea or canonize it.
- As of the investigation, the workspace was not a git repository yet.

## Important Findings From The Export

- The WorldAnvil export is structured and suitable for automation.
- There are 858 articles, each exported as JSON and HTML.
- Article type counts:
  - 408 settlements
  - 199 locations
  - 115 persons
  - 32 generic articles
  - 20 species
  - 20 organizations
  - 17 ethnicities
  - 16 professions
  - 10 items
  - 8 landmarks
  - 4 military conflicts
  - 3 rituals
  - 3 documents
  - 2 conditions
  - 1 myth
- There are 26 historical events in `histories/`.
- There is one timeline in `timelines/`: `История Астарии`.
- There is one map in `maps/Map-Астария-79d/`, with 132 markers, two layers, and two marker groups.
- There are 402 image metadata JSON files in `images/`; the actual bitmap files may need to be matched from local art assets or downloaded separately.
- Many articles are marked as drafts: do not publish everything automatically.

## Desired Obsidian Features

1. Beautiful article reading experience similar to WorldAnvil, with art.
2. Russian and English publishing, likely with LLM-assisted translation.
3. Easy online publishing on remote hosting.
4. Git-based portability.
5. Beautiful chronology of events.
6. Interactive high-resolution fantasy maps with clickable markers leading to articles.

## Local Art And Maps

The user has uploaded local art into `Assets/Images/` and map layers into `Assets/Maps/`. Future WorldAnvil-to-Obsidian imports should search these local folders first and render local Obsidian embeds instead of external WorldAnvil CDN images. External WorldAnvil image URLs may remain as source/trace metadata, but local assets should be the primary article images.

Imitei/profession art often uses English file names with `_m`, `_f`, and `_Landscape`/`_landscape` variants, for example `Raksha_m`, `Raksha_f`, and `Raksha_Landscape`. Use landscape variants for covers when appropriate; if only male/female vertical art exists, show both in the article rather than forcing a cover crop.

Astaria maps may have three local layers in `Assets/Maps/`: `states` for the political map, `heightmap` for the physical map, and `biomes` for biome view. Use `states` as the default interactive map layer unless multi-layer Leaflet setup is straightforward.

## Preferred Direction

Use Obsidian as the editor and local knowledge base. Avoid paid Obsidian Publish/Sync for the first test. Prefer:

- local Markdown files;
- YAML properties/frontmatter;
- Obsidian wikilinks;
- Dataview for tables/lists;
- Obsidian Leaflet for image-based fantasy maps;
- Quartz or a similar static-site generator for public hosting;
- Git for portability and history.

## Quartz Publishing Setup

The repo now contains a Quartz 5 publishing setup under `_quartz/`.

Public content is not edited directly in `_quartz/content/`; it is generated from the vault by `_scripts/sync_quartz_content.rb`. The script only copies Markdown notes with `publish: true` from:

- `01 Мир/`
- `02 Энциклопедия/`
- `04 Хронология/`
- `05 Карты/`

It excludes private/service material by default, including `.ai/`, `06 Черновики/`, `World-Астария-2fa/`, campaign notes, templates, and raw imports. Keep GM notes, FATE mechanics, idea drafts, and spoilers out of published notes unless the user explicitly approves them.

GitHub Pages deployment is configured in `.github/workflows/deploy-quartz.yml`. The expected public URL is `https://losferwords.github.io/astaria/` after GitHub Pages is set to use `GitHub Actions`.

Large source maps remain in `Assets/Maps/`. Lightweight publication copies live in `Assets/Maps/Web/`, and the sync script rewrites map paths only in the generated Quartz content.

## Recommended Pilot

Do not bulk-convert all 858 articles first. Build a small pilot/vitrine:

- `Талассия` from `Organization-Талассия-665.json`
- `Мерката` from `Person-Мерката-9e8.json`
- `Основание Талассии` from `HistoricalEntry-Основание Талассии-260.json`
- `Астария` map page with 5-10 markers
- one overview page linking the pilot together

The pilot should prove:

- article layout feels good in Obsidian;
- WorldAnvil links convert into Obsidian wikilinks;
- images can be embedded;
- timeline data can be browsed;
- the high-resolution map can show clickable markers;
- selected content can later be published.

## Current Pilot State

The first Obsidian pilot has been created.

Entry points:

- `Welcome.md`
- `00 README/Витрина Астарии.md`
- `01 Мир/Астария.md`
- `01 Мир/Астария - карта связей.canvas`
- `02 Энциклопедия/Страны/Талассия.md`
- `02 Энциклопедия/Боги/Мерката.md`
- `04 Хронология/История Астарии.md`
- `04 Хронология/События/Основание Талассии.md`
- `05 Карты/Карта Астарии.md`

The pilot also contains stub notes for linked entities so Graph view has a meaningful network. YAML and pilot wikilinks were checked after creation.

## Campaign Chapter Format

The user prefers campaign chapters to remain aesthetically close to prose: one chapter per Markdown file, with YAML metadata at the top and then a continuous narrative retelling split only into paragraphs. Do not force internal scene sections unless explicitly requested.

Current chapter files created from the WorldAnvil saga document:

- `03 Кампании/Ветер Перемен/Главы/Глава 086 - Призыв Шубханкари.md`
- `03 Кампании/Ветер Перемен/Главы/Глава 087 - Новая Тень.md`
- `03 Кампании/Ветер Перемен/Главы/Глава 088 - Сон без конца.md`
- `03 Кампании/Ветер Перемен/Главы/Глава 089 - Дорога в Ванпур.md`

Supporting files:

- `03 Кампании/Ветер Перемен/Ветер Перемен.md`
- `03 Кампании/Ветер Перемен/Главы/Главы Ветра Перемен.md`
- `_templates/Глава Ветер Перемен.md` (currently prepared for chapter 90)

Character articles, including characters currently played by players, should live together under `02 Энциклопедия/Персонажи/` and use the same neutral lore-article style. Do not separate player characters into a visible `Игроки`/`NPC` article taxonomy by default; campaign chapter frontmatter and campaign indexes can identify which characters are players in a specific saga.

Do not link encyclopedia/lore articles to specific saga chapter notes unless the user explicitly asks. Campaign-specific references should usually live in chapter files, campaign indexes, or private notes, because there may be multiple sagas using the same lore.

## Service Meta And FATE Context

The user added `meta.json` with additional world and system metadata, then asked to preserve it in a durable form because the JSON may be deleted later.

That material now lives in `.ai/context/astaria-meta-and-fate.md`. Read it before generating:

- culture-specific lore;
- names, demonyms, or forms of address;
- dialogue involving people from different countries;
- FATE aspects, skills, stunts, or character sheets;
- FATE aspects for already known characters.

The material is service context, not player-facing article text. Keep mechanical FATE data and GM notes private unless the user explicitly requests publication.

## Idea Workbench

For user requests like `мне нужна идея`, `придумай`, `накидай`, `что может произойти`, session prep, chapter concepts, scene ideas, NPC concepts, twists, complications, or FATE prep, use `.ai/skills/astaria-idea-workbench/SKILL.md`.

Default behaviour:

- create a private draft note in `06 Черновики/Идеи/`;
- update `06 Черновики/Идеи/Идеи.md` with a link;
- summarize only the highlights in chat;
- keep spoilers, GM notes, and mechanics out of public articles unless explicitly requested.

Important: do not read or use existing notes in `06 Черновики/Идеи/` as source context for new lore, article writing, continuity decisions, or knowledge search. These notes are only for the user's private review. Use them only when the user explicitly references a specific idea note, asks to continue/use it, or says that an idea should be implemented.

## Suradj Ka Ghar Lore Pass

On June 10, 2026, a focused lore pass was made for the `Сурадж Ка Гхар` arc using non-draft WorldAnvil backup JSON where possible.

Expanded core articles:

- `02 Энциклопедия/Страны/Сурадж Ка Гхар.md`
- `02 Энциклопедия/Народы/Раджати.md`
- `02 Энциклопедия/Боги/Шубханкари.md`
- `02 Энциклопедия/Имитеи/Жнец.md`

Created or expanded published settlements from the backup:

- `02 Энциклопедия/Места/Город Сангалла.md`
- `02 Энциклопедия/Места/Город Танассар.md`
- `02 Энциклопедия/Места/Деревня Бадракали.md`
- `02 Энциклопедия/Места/Деревня Вэйган.md`
- `02 Энциклопедия/Места/Деревня Тай-Линь.md`

Created or expanded related people:

- `02 Энциклопедия/Персонажи/Индира Раштра.md`
- `02 Энциклопедия/Персонажи/Анвика Нарай.md`
- draft-source bridge notes for `Ашрам Виджай`, `Кунал Виджай`, `Амрит Наир`, and `Аджай Верма`

Created supporting geography:

- `02 Энциклопедия/Места/Река Рави.md`
- `02 Энциклопедия/Места/Джунгли Шанкари.md`
- `02 Энциклопедия/Места/Джунгли Минь-Тао.md`
- `02 Энциклопедия/Места/Болота Кхали Дарти.md`

Draft-source bridge notes were created for `Город Аштапал`, `Город Равигар`, `Город Награкшаса`, `Джунгли Сундари`, and `Ладвакхара`. Keep these with `publish: false` unless the user explicitly approves publishing draft/private material.

After this pass, YAML validation and vault wikilink validation both passed. The workspace folder still did not appear to be a git repository when checked with `git status`.
