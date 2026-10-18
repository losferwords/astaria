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

`Зов Бури` is also the debut album of Maksim's power-metal band **Astarian**. Its chapters correspond to the album's songs. The opening song is **The Highlander's Soul** (chapter 1); the former chapter 0, `Before the Storm`, has been folded into its story. Preserve supplied English lyrics verbatim, including repetitions, punctuation, and casing; never translate them into Russian. In these lyrics, **Named** means **Названные**. Introduce each song through engaging, canon-consistent storytelling for readers unfamiliar with Astaria, rather than a list of lore facts or a plot synopsis. Write these song chapters in immersive third-person present tense in both Russian and English, so the reader follows events alongside Kenneth as his journey unfolds. Keep this tense for future songs too. The reusable `[!lyrics]` callout keeps lyrics readable in Obsidian and becomes a mobile-friendly song reader in Quartz. Exclude its generated `.astaria-lyrics` sections from punctuation normalization so the published lyrics retain the supplied characters too.

**Sailing** (chapter 2, 98 NE) is narrated by Rhea Melit aboard the Litei, sailing from Solais towards Amon-Astat. **Keln** in the lyrics is **Кельн**. Its emotional arc moves from the crew's confidence and freedom to Rhea's courteous plea, an urgent demand, fury at Kenneth's inability to stop the storm and his making it worse, and finally acceptance that the ship will sink. Preserve the supplied lyric `Hey, calm down the sea!` and the lowercase opening of `lightning strikes are dazzling bright!`. Rhea's belief that they are doomed during the song does not establish her death; canonical lore records that she survived the wreck.

**The Island** (chapter 3, 98 NE) is narrated by Cassia, the blind Profitis who revives Kenneth on Chthon. Its two choruses have different lyrics: the first asserts her sight and the future she expects, while the second recalls her childhood during the Fall of Chthon. She took no part in that catastrophe. Kenneth's raft changes her visions and opens a possibility she no longer wishes to refuse; they leave together. Treat her original prediction of his death on Chthon as her conviction, not an inevitable fact. Preserve the supplied forms `Blindful children`, `There is no blood in behind.`, `D’ You think it helps you escape?`, and the unresolved final question `Is the Island left behind?`; do not silently correct their English. The ending can carry Cassia's lingering uncertainty without establishing a new curse or claiming that prophecy has lost all value.

**The New Paragon** (chapter 4, spring 99 NE) is narrated by **Persephone Raptis**, who chooses Kenneth as her opponent in the Thanatomachia after his and Cassia's half-year captivity. Prisoners are treated respectfully and can train; killing the challenger grants the captive freedom. Persephone defeats Kenneth, but the attack on Achaeus interrupts her before the final blow, so she does **not** gain his Soul Crystal's power or become a Paragon in this song. `I’m reborn as the new Paragon.` expresses her confidence and anticipation, not a completed initiation. Preserve all **50** supplied lyric lines, including `Day what you should dread…`, `You had lost control`, `Die by hand of mine.`, and the literal hyphens in the bridge. The first two choruses say **`On the tip of my spear.`**; both repetitions in the final chorus say **`At the end of my spear.`**. Keep both complete repetitions of the bridge and the final chorus.

**The Priestess** (chapter 5, spring 99 NE) is narrated by **Shani-Hat-Su**. Weave her canonical life during the drought into the song's prayer and the journey with Kenneth: the reed farm by the lower Hapi, her mother's death from hunger, fishing and market life in Waset, giving two fish to a hungry child, entering the Sun's temple, tending the dying, the caravan attacked near Khesus, captivity in Achaeus, healing Kenneth, recognition of her brother Ramat, his fire at a granary and their escape towards Tiza. Shani's reproach and fear of dawn do not establish Ast as the drought's actual cause. Verse 3 turns to the Highlander for hope, while the final chorus still addresses the Sun: do not make her abandon Ast, deify Kenneth or receive a promise that he will save the country. She resumes temple studies in Tiza as Kenneth and Cassia continue to Atafet. Preserve all **34** supplied lyric lines and all three choruses; keep `You're the one we trust!`, `Pray you for salvation`, the straight apostrophe in `We're afraid of the dawn!`, the ASCII hyphen after `Sun`, the en dash after `war`, and all **seven** non-breaking spaces supplied as `&#xA0;`. Keep the chorus line breaks between `to` / `Dust.` and `pouring` / `Down.`.

**No Mercy for Thirsty** (chapter 6, spring 100 NE) is narrated by **Rhea Melit**. Use this exact song title in both locales; keep the existing public slug `chapter-006-no-mercy-for-the-thirsty`. Rhea survives the Litei's sinking but loses her ship and crew. She agrees to help defend Atafet in exchange for materials and support for a new ship and crew. The city is inside the mountain; its siege takes place at the entrance fortifications, not at an invented harbour. Kenneth trains soldiers at the academy and Cassia tends drought victims to earn the sword's cost, followed by six months of forging. In the song, Rhea first rallies wounded defenders, then breaks away from her command in an improvised attempt to kill Persephone. Rhea becomes wounded and surrounded; Persephone has not yet become a Paragon. Do not establish Persephone's death, a victory for Rhea, her capture or her death from the lyrics; the song leaves that fight unresolved. The first pre-chorus addresses others' wounds; the second acknowledges Rhea's own bleeding. Her kopis and rare Thalassian gunpowder pistol fit Navarch equipment, without implying widespread firearms. Gilas is the attacking army, not the Thirsty rebels. Preserve all **32** supplied lines, both distinct pre-choruses and both repetitions of the final chorus, the capital `Head`, the straight apostrophe in `it's` alongside curly apostrophes elsewhere, and the one non-breaking space supplied after `Mountain lords led me towards` as `&#xA0;`.

**Call of Thunder** (chapter 7, spring 100 NE) is narrated by **Cassiopeia Athanatos**. The album's climax brings Kenneth's new sword, his choice of rain over further killing, the two-day ascent and the summoning of northern storms together with Cassia's love. Her first bridge promises to follow him; in the outro she chooses to leave in a desperate attempt to change his fate, remembering how his raft changed her visions on Chthon. The glowing sword, burned hands, completed rite and Kenneth dying of exhaustion in her arms belong explicitly to **her vision**, not to an observed death. In the present, she leaves while he is still alive and the rite continues. Removing herself is a hope, not an established law of prophecy or proof that he survives. Preserve the storm's public consequences and negotiated peace while leaving Kenneth's actual fate unknown. Keep all **49** supplied lyric lines, both different bridges, the single six-line chorus and all twelve outro lines. Preserve `d’you`, `‘bove`, `on the rite you shall through`, `Of course, he chose a rain`, `may peace will prevail`, `(Call of Thunder)`, the straight apostrophe in `We're`, the en dash in `Hands are burned – can’t carry on.`, the ASCII hyphen in the final line, and the one non-breaking space supplied after `prevail` as `&#xA0;`.

**No Way Home** (chapter 8, spring **101 NE**) returns to **Lisandra mac Rayne's** voice. Cassia does not find her immediately after the storm; she believes Kenneth dead because he no longer appears in her new visions, not because she witnesses his death. She stays in Erwin for several days, then leaves for an unknown destination. Write the chapter as a tragic, intimate return to the mother and home of The Highlander's Soul: pride, longing, repeated hope and grief coexist. Do not soften the loss with a promised reunion or present Kenneth's death as a confirmed fact. The Prophet's nocturnal visits are depicted through Lisandra's dreams and the remembered account of Cassia; do not establish new physical visits, a magical dream link or prophetic powers for Lisandra. Thoughts of a better place or continued wandering are a grieving mother's possibilities, not established afterlife lore. Lisandra preserves and shares her son's story through the Thunder Clans; the saga takes shape in Solais, without bringing him home. Preserve all **44** original lyric lines, including the **18-line final chorus** in three stanzas of **4, 8 and 6** lines. Keep the irregular forms `This life full of loneliness,`, `By nights the Prophet visits me,`, `Maybe he’s in better place,`, all curly quotation marks and outside punctuation, the final `“No way… No way… Back home!”.`, both closing `No way back home…` lines and the one non-breaking space supplied after `I should write the story of his way,` as `&#xA0;`.

**Lament of The Night** (chapter 9, spring **100 NE**) must keep its speaker unidentified in public. The author's later revision supersedes the earlier request to show the narrator: omit the chapter's public `narrator` field and Mercate's name from its cast, prose and links, and omit her from the saga's public cast. Her identity belongs only in the author-only guardrail below. Use the author's supplied title casing without changing the existing public slug. Its central scene precedes the saga's composition; later travellers' visits are an explicitly later coda. Keep the public epilogue short, mystical and inconclusive: Kenneth's body and sword are not found, and conflicting second-hand rumours suggest someone weeps on Atafet, without identifying the voice or establishing a reliable witness. The author removed the entire explanatory passage from `В Lament of The Night звучит...` to the lyrics; do not restore a song analysis, a decoded hint, an explicit note about hope or a closing interpretation. Do not retain the former explicit sighting of an immense wandering shadow or stage a witnessed divine visit, bargain or transformation. Let the unaltered lyrics, especially `My child, forgotten, apprised` / `Shadow`, carry the clues; public prose, sidebars, summaries and links must not explain them or disclose Kenneth's fate. Preserve all **34** supplied lines in **four** sections (Verse 1, Chorus, Verse 2, Chorus), with the final chorus in **8 + 2** line stanzas rather than an invented Outro. Keep the standalone lines `Shadow` and `World`, `My child, forgotten, apprised`, `I'm blessing way for you.`, the curly apostrophe in `Don’t`, the straight apostrophe in `I'm`, all ellipses, and the single non-breaking space supplied after `Help me to darken the whole` as `&#xA0;`.

**Author-only guardrail for Lament of The Night; never export to public content:** **Mercate** is the song's speaker, but the author explicitly wants readers to infer this from the lyrics rather than see her identified. The author confirms Kenneth becomes a **Shadow** and will have a future role. Becoming a Shadow means unquestioning obedience to Mercate's will; the second chance is a bargain whose implications become clear after the transformation. Her ultimate aims remain **undecided**: averting the Hour of Twilight, hastening it for power, or pursuing another design are open possibilities, not established lore. Do not resolve them, add magical mechanics, or turn the song's eternal-night allusion into a confirmed divine plan. The fact of Kenneth's transformation already belongs to secret canon; this service note records the author's publishing constraint, not a new public revelation.

The author has authorized logical estimates of seasons. The current editorial chronology places **Sailing** and **The Island** in autumn 98 NE, the arena and escape in spring 99 NE (after half a year of captivity), the siege, storm and lament in spring 100 NE (allowing several months to earn the sword's cost and another six months to forge it), and Cassia's meeting with Lisandra in spring 101 NE. Chapter 1 spans 79–97 NE; its `season: Весна` refers to Kenneth's initiation in spring 97, not to every event of his childhood. Keep Russian `season` values as `Весна`, `Лето`, `Осень`, or `Зима`, with the corresponding English overlay `Spring`, `Summer`, `Autumn`, or `Winter`, following the existing `Ветер Перемен` convention. Distinguish these estimated seasons from dates or seasons explicitly established by the author or canonical rites.

## Publishing

`Зов Бури` has story sidebars on the saga page and all song chapters. Maintain `characters`, `story_locations`, `narrator` (only when established and intended for public disclosure; omit it for Lament of The Night), `season`, and numeric `year` / optional `endingYear` in chapter metadata, with matching English overlays. The saga page reuses `central_characters` as its cast and spans 79–101 NE. `year_precision: open_end` is available for genuinely unknown later dates; do not use it for No Way Home or the central scene of Lament of the Night, whose years are now established. Sidebar links should not create chapter backlinks in ordinary lore articles.

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
