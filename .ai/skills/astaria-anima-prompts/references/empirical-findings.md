# Empirical findings from Astaria prompt examples

Read this reference when revising an existing prompt or artwork, matching one of the established visual families, designing a male character or city, or explaining why an Anima result succeeded or failed.

The source corpus is `.ai/context/art-prompt-examples.md`: 28 Positive/Negative prompt pairs with the user's own result notes. The corresponding local images were inspected under `Assets/Images/` on 2026-08-27.

## What the corpus establishes

- The user's DaSiWa-Anima workflow responds well to hybrid prompts: tag-like identity and anatomy followed by short natural-language composition and setting blocks.
- All examples share `masterpiece, best quality, score_9, score_8`; most also share a long technical Negative. Preserve these as checkpoint-tested conventions unless the user asks to experiment.
- Consistent family anchors work. Obitelj uses white/red/green linen and embroidery, birch, wheat, wood, earth, and protective warmth. Amato uses black/grey/orange or sakura pink, layered Japanese clothing, blindfolds, katana, wind, mist, lanterns, islands, and bays. Gilas uses bronze/red/white, spear and shield, marble, wheat, cypress, disciplined posture, and coastal terrain.
- Concrete props and relationships outperform abstract mood labels. A lantern in Itsune's hand, the Wends/Edzo/Ellian couples, a manuscript shared by the Thuggee scholars, and Musaka's crescent collar make the subject immediately legible.
- Detail count alone is not the cause of success. The successful Thuggee ensemble is long because every block establishes role, hierarchy, action, light, or place. Kiran Varma is also detailed, but glamour-heavy features overpower his priestly function.

## Established visual families

### Obitelj — Wends — Guardian — Mafka — Mirgrad

Shared anchors:

- ancient Slavic material language;
- white linen with red and green embroidery;
- birch, wheat, wooden settlements, rivers, warm daylight;
- red mantle, wood-and-steel shield, heavy hammer, crystals and runes;
- care, home, fertility, protection, and strength without cruelty.

Observed results:

- `Velissa.jpg` has an excellent divine silhouette, birch/wheat setting, squirrel, ribbons, and clear palette. The competing human-ear prior required explicit `human ears, four ears` exclusions.
- `Wends.jpg` communicates warmth and family immediately. The close couple dominates so strongly that the village becomes supporting evidence rather than an equal subject; this is appropriate for a people article but should not become the default for every culture.
- `Guardian_m.jpg` and `Guardian_f.jpg` are a coherent pair with strong material detail, readable shield and hammer, and convincing benevolent strength. The male succeeds because build, cultural clothing, equipment, and open landscape work together instead of relying on facial beauty.
- `Obitelj.jpg` is a strong country cover because the representative Guardian-like figure occupies one side and the fields and village remain readable. It is not a city image.
- `Mirgrad_City.jpg` has pleasant architecture and geography but nearly empty roads. Its Positive has only about 49 words and names structures without human-scale activities.
- `Mafka.jpg` follows throne, flower, hair, and clothing cues but exaggerates large eyes and child-anime drift. Avoid `kawaii`, `super cute`, and beauty stacking for children; use a natural child activity and modest, age-specific phrasing.

### Amato — Edzo — Onmyoji — Amatsu Rin — Kaito

Shared anchors:

- ancient Japanese material language;
- black, grey, white, orange, and restrained sakura pink attached to garments, lacquer, lanterns, and shrines;
- sea, island bays, forested slopes, fog, wind, early light;
- blindfold, ritual katana, flowing haori, talisman ribbons, lantern;
- calm discipline, unseen spirits, purification, and duty.

Observed results:

- `Itsune.jpg` is one of the strongest portraits: fox anatomy, blindfold, lantern, orange/black palette, fog, hand gesture, and spirit effects form one identity. Contextual negatives correctly suppress eyes, human ears, extra katana, and bright summer scenery.
- `Edzo.jpg` conveys place and tenderness cleanly through the couple, sakura, stone bridge, lanterns, mist, and restrained grey/pink clothing.
- `Onmyoji_m.jpg` and `Onmyoji_f.jpg` share a convincing class silhouette. The male is cleaner but loses most talisman ribbons; the female retains the ribbons but the drawn katana bends and its weapon state is less coherent. Exact sheathing/drawing actions and curved blades are geometry risks.
- `Amato.jpg` is the strongest country panorama: a single blindfolded representative anchors the right side while roofs, harbor lights, fog, boats, and layered islands carry the national setting.
- `Amatsu_Rin.jpg` succeeds through controlled expression, symmetrical court hair, crown, kimono, sheathed katana, and a quiet palace interior. It conveys authority, though a future ruler prompt can be even more article-specific by adding a governing action.
- `Kaito_City.jpg` has a memorable bay, roofs, torii, and ships, but its broad empty foreground road makes the city feel uninhabited. Its Positive has only about 37 words.

### Gilas — Ellians — Paragon — Hyperion — Argos

Shared anchors:

- ancient Greek and Spartan material language;
- bronze armor, red cloth, white marble;
- spear, round shield, cypress, wheat, river valleys, and coast;
- discipline, civic pride, endurance, formation, and earned command.

Observed results:

- `Hyperion.jpg` is imposing and readable, but the spear is cut by the frame, the lower body is awkwardly cropped, and the generic throne-temple warrior language makes him less distinctive than the animalistic gods. His crown also drifts toward decorative feathers.
- `Ellians.jpg` gives the strict culture a humane, loving face and has unusually convincing male features. The architecture is distant, so the people remain the true subject.
- `Paragon_m.jpg` and `Paragon_f.jpg` have excellent shields, bronze/red palette, arena setting, and forceful poses. Both inherit an implausible high grip/foreshortened spear problem. The male helmet reads more Roman than the requested narrow Corinthian helmet; the female avoids that drift but exposes the thighs despite otherwise full armor.
- `Gilas.jpg` combines a warrior anchor and country terrain effectively, but the helmet remains Roman-coded and the foreground settlement is quiet.
- `Argos_City.jpg` is the best of the three original capitals. Its roughly 135-word Positive supplies a dominant temple, bridge, river/sea relation, fountain, banners, roads, cypress, varied buildings, and small civilians. The result has civic scale and visible life.

## Other high-value examples

- `Thuggee.jpg` is the clearest organization image. The old scholar and young assistant have distinct roles and gazes, share a manuscript task, and sit inside an archive whose lamps, shelves, scrolls, and darkness all reinforce the article. This also produces one of the strongest older men in the corpus.
- `Vanpur_City.jpg` proves that Anima can produce a lively city from a human-height street view with merchants and pedestrians. Repeated pyramids of spices and similar stalls show why population alone is insufficient; foreground objects and shop types must vary.
- `Musaka.jpg` is exceptionally clean because count, species, posture, collar symbol, expression, and forest habitat are unambiguous. The prompt does not burden the subject with lore names the model cannot know.
- `Chori_Mardjari.jpg` succeeds through a specific face, dirt mark, hood, restrained palette, and narrow poor-city lane. The background supports occupation and class without competing for attention.
- `Shasha.jpg` uses a close crop to avoid the checkpoint's likely failure on six arms. This is a valid composition-level workaround, provided the article does not require the full anatomy to be shown.
- `Liarin_Windy.jpg` has clear horns, freckles, braids, green clothing, and forest context, but `stupid smile` is needlessly demeaning and visually vague. Prefer the intended visible emotion, such as `unguarded cheerful smile`.

## Weak male portraits and the stronger alternative

- `Samir_Thakur.jpg` has a centered close portrait, smooth surfaces, hard age markers, red eyes, and little occupational action. The result reads plastic and culturally generic despite the clothing and bindi.
- `Kiran_Varma.jpg` combines `handsome rugged features`, `chiseled face`, intense red eyes, long hair, beard, jewelry, tattoos, dark red cloth, and `mysterious aura`. Those signals converge on a glamorous vampire-like antihero; the priestly role remains only a label.
- `Thuggee.jpg` succeeds because the older man reads, leans over a manuscript, shares a hierarchy with an assistant, and is shaped by warm side light in a specific workplace.

For difficult men, prefer a three-quarter environmental portrait and a role-bearing task. Describe a few distinctive facial structures and signs of age; avoid perfection, glamour, mystical-aura, and beauty-token stacks. An interesting man is made distinctive by history, posture, work, and asymmetry, not by requesting a perfect male face more forcefully.

## City and landscape diagnosis

The empty-city failure is primarily compositional:

- `panorama` plus architecture nouns encourages a distant scenic wallpaper;
- `crowded` alone can create repeated people or face noise;
- an unoccupied foreground road amplifies emptiness even when tiny figures exist far away;
- a list of equal monuments has no visual hierarchy;
- repeating one merchandise category produces cloned stalls.

A stronger city prompt chooses a viewpoint and creates a chain of use:

1. a foreground activity or framing object;
2. a route that pulls the eye through the city;
3. several distinct middle-ground occupations;
4. one dominant civic landmark;
5. background geography that explains the city's location and economy.

The country covers demonstrate a useful concession to a character-focused checkpoint: one representative figure can anchor a wide scene. Capital art should use only a small, secondary human anchor, otherwise it becomes another country or character cover.

## Prompt hygiene discovered in the corpus

- Fix grammar and pronouns. Examples contain `covering his eyes` in a female prompt, repeated `look aside`, and misspellings such as `poaint`; these add noise without value.
- Do not request `over-the-shoulder`, `back to viewer`, and detailed frontal facial expression at the same time.
- Do not describe a sword as in its scabbard, drawing from the scabbard, and an exposed perfect blade simultaneously. Choose one state.
- Preserve the user's baseline `cropped, out of frame` by default. If an intentional close-up or partial portrait is repeatedly pushed toward a wider composition, those are the first baseline tokens to test omitting because they can resist the requested crop.
- Contextual negatives are most valuable when tied to an observed prior: human ears for kemonomimi, visible eyes for blindfolds, Roman armor for a specific Greek silhouette, exposed belly for full female armor, modern objects for historical cities, duplicate long weapons, or empty streets.
- Do not mirror an unambiguous Positive with a catalogue of opposites. Subject count, gender, and hair color usually hold without separately banning every other gender and color; reserve those exclusions for observed drift. The revised Indulf portrait also showed the narrower pattern clearly: `shaggy braided beard` in Positive and the single observed failure `perfect beard` in Negative were more useful than a broad facial-hair blacklist.
- Astaria proper names are not visual instructions. A token such as `Solais` must be omitted after it has been translated into known architecture, weather, geography, and activity; leaving the untranslated name in the prompt adds noise and cannot teach the checkpoint the setting.
- Abstract praise such as `epic`, `noble`, `legendary`, `dramatic`, and `beautiful` may support a prompt but cannot carry identity. Each must be backed by pose, action, object, environment, or light.
- A restrained recurring palette creates family resemblance, but every color should belong to an object. Free-floating color lists often bleed across unrelated details.

## Model facts used cautiously

The [official Anima model card](https://huggingface.co/circlestone-labs/Anima) says the base model was trained on both Danbooru/Gelbooru-like tags and natural-language captions, supports mixing them, prefers lowercase tag forms with spaces, and benefits from descriptive natural language rather than extremely short prompts. It also says tag dropout means every possible tag need not be listed.

The user's DaSiWa-Anima checkpoint is a derivative with its own learned behavior, and the local examples are more relevant than generic base-model recipes. The user's explicit project rule against style labels and artist steering takes precedence over the base model's available style mechanisms.
