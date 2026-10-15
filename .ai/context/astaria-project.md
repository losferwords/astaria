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
- `Хронология/` - 28 dated historical records and the readable timeline.
- `Карты/` - the interactive map with 136 markers.
- `Assets/Images/` and `Assets/Maps/` - local visual assets.
- `Идеи/` - private non-canonical brainstorming, excluded from research by default.

`Assets/Images/credits.csv` is a temporary attribution register only for externally authored artwork still used by the project. New and replacement artwork supplied by Maksim is presumed to be his original work and is not listed there. The register contains only `file`, `artist`, and `artist_website`; its intended end state is deletion after the last externally authored image has been replaced.

## Lore Boundaries

- `Энциклопедия/Секреты/` may guide internal consistency and foreshadowing, but its facts must not be exposed in public articles without explicit approval.
- Public lore must preserve Astaria's mythological-fantasy veil. For ordinary readers, humans are one of the world's ordinary humanoid peoples, while the Archeans are only a mysterious, highly developed and vanished ancient civilization of unknown origin.
- Public articles and timeline summaries must never state or imply that the Archeans arrived from another world, were Earth colonists, created the gods in laboratories, or founded the Chthonid civilization from five hundred human settlers. Such truths belong only in `Энциклопедия/Секреты/`, `secret_*` metadata, and private service context.
- When a dated event rests on secret history, present it publicly as the earliest known evidence, an archaeological interpretation, a chronicle, or an in-world legend. Preserve uncertainty instead of reporting hidden scientific explanations as objective history.
- FATE mechanics and GM notes stay private unless the user requests otherwise.
- `Идеи/` is output-only by default and must not be treated as canon.
- Canonical notes use explicit `ready` and `quartz` booleans. `ready` records completion; `quartz` alone controls intentional public synchronization.
- Generic tags are not used. Classification and relationships belong in folders, typed properties, and wikilinks.

## Campaign Chapters

Campaign chapters are continuous third-person narrative retellings with YAML metadata. Keep one chapter per Markdown file, prefer indirect speech over reconstructed quotations, and avoid forced internal scene headings unless requested. Attribute discoveries and theories to the characters who made them, and never present a character's assumption as an established fact. End on the last meaningful event that occurred during play; do not append an authorial summary, repeated list of clues, thematic conclusion, or artificial cliffhanger unless the user explicitly requests one.

Current saga folders:

- `Энциклопедия/Литература/Ветер Перемен/`
- `Энциклопедия/Литература/Зов Бури/`
- `Энциклопедия/Литература/Пока Боги Спят/`

Chapter notes may link to relevant lore. Ordinary encyclopedia articles should not link back to particular chapters by default.

`Зов Бури` is also the debut album of Maksim's power-metal band **Astarian**. Its chapters correspond to the album's songs. The opening song is **The Highlander's Soul** (chapter 1); the former chapter 0, `Before the Storm`, has been folded into its story. Preserve supplied English lyrics verbatim, including repetitions, punctuation, and casing; never translate them into Russian. In these lyrics, **Named** means **Названные**. Introduce each song through engaging, canon-consistent storytelling for readers unfamiliar with Astaria, rather than a list of lore facts or a plot synopsis. Write these song chapters in immersive third-person present tense in both Russian and English, so the reader follows events alongside Kenneth as his journey unfolds. Keep this tense for future songs too. The reusable `[!lyrics]` callout keeps lyrics readable in Obsidian and becomes a mobile-friendly song reader in Quartz.

**Sailing** (chapter 2, 98 NE) is narrated by Rhea Melit aboard the Litei, sailing from Solais towards Amon-Astat. **Keln** in the lyrics is **Кельн**. Its emotional arc moves from the crew's confidence and freedom to Rhea's courteous plea, an urgent demand, fury at Kenneth's inability to stop the storm and his making it worse, and finally acceptance that the ship will sink. Preserve the supplied lyric `Hey, calm down the sea!` and the lowercase opening of `lightning strikes are dazzling bright!`. Rhea's belief that they are doomed during the song does not establish her death; canonical lore records that she survived the wreck.

**The Island** (chapter 3, 98 NE) is narrated by Cassia, the blind Profitis who revives Kenneth on Chthon. Its two choruses have different lyrics: the first asserts her sight and the future she expects, while the second recalls her childhood during the Fall of Chthon. She took no part in that catastrophe. Kenneth's raft changes her visions and opens a possibility she no longer wishes to refuse; they leave together. Treat her original prediction of his death on Chthon as her conviction, not an inevitable fact. Preserve the supplied forms `Blindful children`, `There is no blood in behind.`, `D’ You think it helps you escape?`, and the unresolved final question `Is the Island left behind?`; do not silently correct their English. The ending can carry Cassia's lingering uncertainty without establishing a new curse or claiming that prophecy has lost all value.

**The New Paragon** (chapter 4, spring 99 NE) is narrated by **Persephone Raptis**, who chooses Kenneth as her opponent in the Thanatomachia after his and Cassia's half-year captivity. Prisoners are treated respectfully and can train; killing the challenger grants the captive freedom. Persephone defeats Kenneth, but the attack on Achaeus interrupts her before the final blow, so she does **not** gain his Soul Crystal's power or become a Paragon in this song. `I’m reborn as the new Paragon.` expresses her confidence and anticipation, not a completed initiation. Preserve all **50** supplied lyric lines, including `Day what you should dread…`, `You had lost control`, `Die by hand of mine.`, and the literal hyphens in the bridge. The first two choruses say **`On the tip of my spear.`**; both repetitions in the final chorus say **`At the end of my spear.`**. Keep both complete repetitions of the bridge and the final chorus.

**Call of Thunder** (chapter 7, 100 NE) is narrated by **Cassiopeia Athanatos**. **No Way Home** (chapter 8) takes place in **101 NE**: Cassia does not find Lisandra immediately. **Lament of the Night** (chapter 9) is narrated by **Mercate** and its central scene takes place in **100 NE**, before the saga is composed; later travellers' visits are an explicitly later coda, not the date of Mercate's lament. These narrators and years were specified by the author.

The author has authorized logical estimates of seasons. The current editorial chronology places **Sailing** and **The Island** in autumn 98 NE, the arena and escape in spring 99 NE (after half a year of captivity), the siege, storm and lament in spring 100 NE (allowing several months to earn the sword's cost and another six months to forge it), and Cassia's meeting with Lisandra in spring 101 NE. Chapter 1 spans 79–97 NE; its `season: Весна` refers to Kenneth's initiation in spring 97, not to every event of his childhood. Keep Russian `season` values as `Весна`, `Лето`, `Осень`, or `Зима`, with the corresponding English overlay `Spring`, `Summer`, `Autumn`, or `Winter`, following the existing `Ветер Перемен` convention. Distinguish these estimated seasons from dates or seasons explicitly established by the author or canonical rites.

## Publishing

`Зов Бури` has story sidebars on the saga page and all song chapters. Maintain `characters`, `story_locations`, `narrator` (only when established), `season`, and numeric `year` / optional `endingYear` in chapter metadata, with matching English overlays. The saga page reuses `central_characters` as its cast and spans 79–101 NE. `year_precision: open_end` is available for genuinely unknown later dates; do not use it for No Way Home or the central scene of Lament of the Night, whose years are now established. Sidebar links should not create chapter backlinks in ordinary lore articles.

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

`.ai/context/wind-of-change-brothels.md` records the players' decisions about remote management of Halyk-Byndir, Ui-Djan, and Ulehey metallurgy, including letter verification and the current stage of the enterprises. Read it when continuing those business scenes. `.ai/skills/astaria-business-management/SKILL.md` provides the interactive play workflow and a focused reference for their people and setting.
