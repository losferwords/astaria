---
name: astaria-anima-prompts
description: "Create or revise English Positive and Negative prompts for Astaria illustrations in Anima or DaSiWa-Anima: lore articles, Losfy, Losfer and Misty portraits, story scenes with other characters, and coordinated country–people–Imitei–ruler–capital image families. Use for prompt writing and prompt/art review; image generation and settings require a separate request."
---

# Astaria Anima Prompts

Create an image concept that expresses the target article, then translate it into an efficient English prompt for the user's DaSiWa-Anima checkpoint. Preserve the stable, unlabelled visual character of the model instead of naming an art style.

## Scope and boundaries

- Write discussion and the short concept note in Russian; write `Positive` and `Negative` in English.
- Return prompts, not ComfyUI, CFG, step, sampler, scheduler, LoRA configuration, resolution, or post-processing advice unless the user explicitly asks for those subjects. The established identity triggers `losfy` and `losfer` belong in Positive when depicting their respective characters; this does not require a settings discussion.
- Do not generate or edit an image merely because this skill is active. Use an image-generation skill only when the user separately asks for an image.
- Never add style steering such as `anime`, `realistic`, `photorealistic`, `semi-realistic`, `cinematic`, `3d`, `render`, `painterly`, `concept art`, an artist name, or a franchise style. Replace such labels with concrete framing, light, materials, atmosphere, and depth.
- Treat the user's existing quality prefix and negative baseline as tested checkpoint conventions. Do not silently replace them with generic advice from the base Anima model card.
- Never use prompt weights or emphasis syntax in either Positive or Negative. This includes `(tag:1.4)`, `(tag)`, `[tag]`, and equivalent weighted forms. Write plain unweighted tags and clauses; weighting can shift the checkpoint's established color balance, composition, and overall visual character.
- Keep minors fully clothed and plainly non-sexualized. Describe age, childlike proportions, activity, expression, and clothing; omit breast, body-beauty, erotic pose, and glamour language.

## Research the target economically

1. Resolve the requested entity in `Энциклопедия/` and read its canonical note. Use the user's supplied description when no note exists. For a story illustration, also read the requested passage; follow its moment, clothing and physical presence rather than copying an older portrait's scene.
2. Do not read `Идеи/` or `Энциклопедия/Секреты/` unless the user explicitly names the material. Never leak private revelations into a public-facing visual concept.
3. Read only first-degree context that changes visible decisions: appearance, culture, clothing, role, signature equipment, geography, architecture, season, palette, mood, and a defining action or relationship.
4. For a country-family request, resolve the country note's `Ключевая связка` or YAML fields: `related_ethnicities`, `related_professions`, `deities`, `ruler`, and `capital`. Read those linked notes only as needed.
5. If matching or revising existing art, inspect the local image referenced by `cover_image`, `portrait_image`, `female_portrait`, or `male_portrait` under `Assets/Images/`.
6. When the request concerns the existing examples, a known visual family, male characters, cities, or prompt/art diagnosis, read [references/empirical-findings.md](references/empirical-findings.md).

Do not summarize the lore before prompting. Extract a compact visual brief in memory:

- the one idea the viewer should understand first;
- three identity anchors: silhouette or anatomy, culture or material language, and signature motif;
- one meaningful action or relationship;
- one setting with a clear foreground, middle ground, and background;
- a restrained palette tied to named objects rather than free-floating color words.

If important visual facts remain genuinely unknown, state the smallest assumption in the Russian concept note. Do not invent canon merely to fill the image.

## Losfy, Losfer and Misty

For any portrait, alternate outfit, story illustration, or shared scene involving Лосфи / Losfy, Лосфер / Losfer, or Мисти / Misty, read [references/losfy-losfer-misty.md](references/losfy-losfer-misty.md). It contains the visual identity fragments, LoRA trigger ownership, Misty's recurring ear failure, outfit modes, and multi-character composition rules learned from the author's examples. Read the shared character context and authorial meta required by `.ai/AGENTS.md`; use only task-relevant lore within its access boundaries.

Keep identity stable while adapting expression, costume, action and setting to the request. `losfy` and `losfer` are trained identity triggers, not interchangeable names or scene labels. Misty has no LoRA: repeat her descriptive anchors and omit her name from the English prompt. Read the raw [prompt examples](references/prompt-examples.md) only when a particular original outfit, interaction or wording needs inspection; legacy mistakes do not override the current rules.

## Compose for the entity

Read the relevant section of [references/composition.md](references/composition.md) for characters, male portraits, cities, peoples, creatures, objects or coordinated country families. Do not load the other composition modes for a simple portrait.

## Write Positive

Use comma-separated English tags and compact natural-language clauses. Inside each logical thought, join tags and clauses with commas; end the completed thought with a full stop. Separate larger logical blocks with blank lines. Do not turn the entire Positive prompt into one comma splice. The usual block contains one to three short sentences, and every block ends with a full stop. The user's established default order is:

1. `Masterpiece, best quality, score_9, score_8,` followed by exact subject count and gender when applicable;
2. identity, species, age, build, face, hair, expression, and anatomy;
3. clothing layers, materials, attached colors, equipment, and signature motif;
4. shot size, viewpoint, placement, pose, action, gaze, and interaction;
5. foreground, middle ground, background, architecture or terrain, weather, light, motion, and atmosphere.

Begin every sentence in Positive with a capital letter, including the opening `Masterpiece`. Keep ordinary tag-like phrases lowercase within sentences where practical; score tags keep their underscores and spelling. Negative remains a continuous tag list rather than sentence-form prose.

Punctuation is structural rather than decorative. A full stop marks a change in what the model should resolve: for example, subject identity may form one sentence, clothing and equipment another, and pose or interaction a third. Commas continue describing the same visual decision. Preserve this sentence rhythm even when each sentence is mostly tags.

- Omit unsupported Astaria proper names from Positive and Negative: keep lore names in the Russian heading and concept note, and translate them into visible anatomy, clothing, architecture, terrain, objects, action or atmosphere. The established exception is `losfy` or `losfer` in the corresponding character's Positive identity block, because the user has a LoRA for each. Do not infer other trained names, add either trigger to Misty, or use them as atmosphere tags. Explicitly requested visible lettering is handled as lettering, not as an identity tag.
- Translate culture through a small number of legible analogues such as `ancient slavic`, `ancient japanese`, or `ancient greek`, then add Astaria-specific motifs from canon.
- Bind colors to objects: `crimson sash`, `white linen tunic with green embroidery`, `black lacquered scabbard`.
- Translate abstractions into evidence. Instead of only `protective`, show the character shielding someone, repairing a bridge, or standing between danger and a home.
- Repeat only two to four essential anchors when reinforcement helps. Remove synonym piles, contradictory poses, pronoun mistakes, and impossible simultaneous actions.
- Simplify fragile geometry. A long spear held vertically beside the body or resting across the shoulder is more reliable than a foreshortened spear pointed at the viewer. Specify one weapon state: sheathed, drawn, or being drawn.

Length follows complexity, not a quota. A city or ensemble normally needs more scene information than a close portrait, but every clause must change a visible decision.

For a single-character illustration, begin with the compact rhythm established by the successful examples: one identity sentence, one clothing or equipment sentence, one composition sentence, and one setting sentence. Add detail only when it changes a necessary visible decision. Preserve room for the checkpoint to solve secondary ornament, folds, light, and incidental scenery on its own.

- After a failed generation, do not keep appending corrective clauses to the previous prompt. Identify the two or three failed anchors and rewrite the prompt cleanly; accumulated corrections can overconstrain pose, symmetry, crop, and background.
- Keep framing and camera angle syntactically separate. Use forms such as `full body view, three-quarter view, low angle view`; avoid ambiguous phrases such as `three-quarter body view`, which can be interpreted as a partial-body crop rather than a three-quarter camera angle.
- For an unusual accessory or magical effect, use one direct object label followed by two or three concrete structural cues. Exhaustively describing every edge, gap, attachment, and exclusion can turn an organic effect into a rigid emblem or force the camera to expose its construction.

## Write Negative

Begin from the user's tested technical baseline, then adapt it:

```text
score_1, score_2, score_3, lowres, bad anatomy, bad hands, text, error, missing fingers, extra digit, fewer digits, cropped, worst quality, low quality, normal quality, jpeg artifacts, signature, watermark, username, blurry, artist name, deformed, ugly, mutilated, out of frame, extra limbs, bad proportions, gross proportions, duplicate, morbid, mutated hands, poorly drawn hands, mutation, disfigured
```

- Keep the entire Negative prompt as one continuous comma-separated list inside a single code block. Do not divide it into thematic sections, labeled groups, separate paragraphs, or separate lines.
- Treat Positive as the primary constraint. Do not mechanically negate every alternative to an already explicit attribute: `1man` and `silver-gray hair` do not by themselves justify lists such as `1woman, blonde hair, black hair, brown hair`. Add a competing gender, color, age, costume, or setting only when the checkpoint has actually drifted toward it, the requested feature is unusually fragile, or that error would destroy the concept.
- Start with the technical baseline and the smallest useful contextual tail. Prefer one observed exclusion such as `perfect beard` over a speculative catalogue of everything the image should not contain. A long contextual Negative is justified only by genuinely complex anatomy, crowded scenes, fragile equipment, or repeated generation failures.
- The technical baseline retains `cropped, out of frame` as the user's established default. Omit them only when an intentional close-up or partial crop is being suppressed by those tokens.
- Add only likely contextual failures: wrong gender or age, human ears on a kemonomimi, visible eyes under a blindfold, modern objects, wrong historical armor, unwanted nudity, duplicate weapons, empty city, or repeated architecture.
- In shared scenes, check each contextual exclusion against every character. Scope fragile traits to their owner, such as `human ears on the white-haired hare woman` or `visible eyes on the blindfolded man`; a global `human ears` or `eyes visible` can suppress another character's correct anatomy. See the character reference for mixed-cast examples.
- For weapons, consider `bent spear, broken weapon, warped blade, duplicated weapon, floating weapon, merged hand and weapon` rather than adding more heroic adjectives to Positive.
- Never negate something explicitly requested in Positive. Check count, gender, indoors/outdoors, daylight, visibility, weapon state, body crop, ears, and clothing coverage.
- Do not expand Negative with unrelated fears. A shorter targeted exclusion is more useful than an indiscriminate blacklist.
- When rebuilding a prompt after several iterations, discard obsolete contextual exclusions from earlier attempts. Keep only the failure modes that remain plausible for the rewritten Positive.
- When exact visible lettering is requested, remove `text` from the technical baseline and describe one inscription, its placement and necessary color in Positive. Do not copy greetings or notebook text from examples into an unrelated illustration.

## Output contract

Unless the user requests prompt-only output, return a heading with the entity and `замысел`, followed by one to three Russian sentences naming the article-specific visual thesis and composition. Then provide `Positive` and `Negative` as separate English `text` code blocks.

For a standard Imitei pair, return `Мужской образ` and `Женский образ` separately. For a complete country family, keep each entity separate and state the shared visual anchors once before the prompts.

Do not append generation settings. Mention one concise risk only when it materially affects prompt design, such as a long weapon, multiple arms, exact heraldry, or distant crowd geometry.

## Final audit

Check the image’s article- or story-specific identity, focal hierarchy and consistency of anatomy, count, clothing, light and framing. For the recurring trio, check trigger ownership, each character's separate features, and whether a second visible body belongs in this moment. Verify the Positive/Negative and output contracts above; remove contradictions, unsupported lore names and obsolete corrections. Preserve the user’s tested conventions.
