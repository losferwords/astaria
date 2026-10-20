# Losfy, Losfer and Misty — visual identity and story scenes

Use for solo portraits, alternate outfits, and shared scenes with any of these three characters. This reference distills the author's 22 added pairs in [prompt-examples.md](prompt-examples.md): `# Лосфи:` examples 1–13, `# Losfer` examples 1–5, and `# Misty` examples 1–4. The author confirmed on 2026-10-19 that Losfy and Losfer each have a LoRA, Misty has none, and Misty's extra human ears often require inpainting. The assembly patterns below are guidance derived from the prompts, not a claim that new combinations have been generated successfully.

## Sources and scene selection

- Follow the user's current direction, then the requested story passage and canonical appearance; use these examples for visual vocabulary. An example's costume, gesture, weather, prop or companion does not become a universal requirement or a new biographical fact.
- Read the public notes `Энциклопедия/Персонажи/Лосфи.md`, `Лосфер.md`, and `Мисти.md` for the requested cast, plus the shared character context and authorial meta required by `.ai/AGENTS.md`. Read additional story or private material only within the task's authorized scope.
- Choose between physical Astaria, a specified dream/crossover, and an expressly requested symbolic illustration. Modern clothing, headphones, a contemporary kitchen and city lights belong to their requested scene; do not introduce them into a historical Astaria scene merely because an example uses them. Do not force historical clothes into a requested modern/dream outfit either.
- For `The Demon to Hunt` / `Демон для охоты`, use `Энциклопедия/Литература/Демон для охоты.md`: rainy Рэйкацу, spring 106 НЭ, an old Japanese material language, wet dark wood, muddy paving, eaves and paper lanterns where the passage calls for them. Translate the location into visible details rather than writing its proper name in Positive.
- Establish who is actually visible. In the waking conversation in that story, Losfy speaks within Losfer; a dialogue between them does not automatically require two bodies. Use a solo Losfer composition for that literal moment. Show Losfy separately when the requested scene supports it, or when the user asks for a dream, manifestation, symbolic presence or joint image; state a necessary symbolic assumption briefly in the Russian concept. Do not silently invent her physical presence or turn Misty's dream appearance into a public biographical revelation.

## Trigger ownership and reusable identity fragments

Use lowercase `losfy` for Losfy and `losfer` for Losfer, regardless of historical capitalization. Each trigger goes in its subject's identity sentence after the shared quality/count opening, or at the start of that subject's block in an ensemble. Use only the triggers for characters actually visible in the image.

Misty has no trained trigger: neither `misty` nor `losfer` identifies her. The `Losfer` token in her first historical example and the `Losfer girl` phrase in Losfy's kitchen example are cross-character leftovers; do not propagate them. Do not invent LoRA filenames, loading syntax, weights or strengths.

The fragments below are starting material for identity sentences, not complete Positive prompts or obligatory lists of every visible feature. Keep the strongest visible anchors; replace open eyes with closed eyes when the pose requires it, and omit details outside the crop. Add clothing, action and environment from the request. The English prompt and punctuation contract remains in [SKILL.md](../SKILL.md).

### Losfy / Лосфи

```text
Adult woman, losfy, slim build, pale skin, long messy wavy black hair, subtle freckles, small curled black horns with a faint dark red glow, black eyes with round dark red glowing pupils, sharp teeth, long sharp black nails, human ears.
```

Preserve these distinctions:

- Black hair, black horns with restrained red light, freckles, dark eyes with red round pupils, and long black pointed nails form the recurring identity. Do not replace the eye description with solid black sclera or slit pupils. Describe teeth when the mouth is open enough to show them.
- She has regular human ears and human legs. Horns do not require elf ears, hooves, wings, a tail or an all-over demon body. Hair can cover her ears; the kitchen example's `no ears` does not redefine her anatomy.
- Expressions range from sly warmth and a sharp-toothed grin to pride, sadness, tenderness and concern. Choose the emotion of the passage. A serious armored scene need not smile; a comforting scene need not seduce.
- Keep her slim silhouette. The examples vary in chest description; exact breast size and exposed skin are not required identity anchors for an ordinary story illustration. Do not import erotic pose or body language into an unrelated scene.
- A youthful appearance is not an instruction to use the legacy `15yo` tag. Depict the ordinary present-day heroine as an adult. For a specifically requested childhood scene, use age-appropriate fully clothed, non-sexual characterization and omit sexualized body descriptors.

Outfit and motif options, selected by request:

- **Dark gothic clothing:** black fabric with dark red lace or trim, fitted bodice, layered skirt, optional black stockings, heart earrings or choker. Choose one hem length and one arrangement of straps. Accessories are costume choices, not anatomy.
- **Armored swordswoman:** fitted black/dark red plate, restrained runic ornament, a heart motif only if wanted, one enormous broad two-handed sword with dark red blade ornament or edge light. Choose its drawn state and a readable grip. Do not copy the contradictory `bare legs` and `full leg armor` together, or require the sword to fill the entire frame at the expense of the figure.
- **Quiet domestic or dream scene:** a black knitted sweater, pajamas, or a requested metalhead outfit. Preserve the character while replacing the original scene's posture and emotion.
- **Optional signature actions:** a black heart between her hands, a notebook and pencil, a reaching hand, or comforting someone. Use only the chosen action; do not give the same hands several incompatible tasks.

Useful targeted Negative additions when relevant: `horn accessories` for unwanted horn ornaments; `pointed ears on the black-haired woman` for ear drift. In a solo image, unqualified `elf ears` can be sufficient. Do not exclude pointed ears globally when an elf companion needs them. Rain beyond a window does not imply wet indoor skin or horns; use `rain indoors` only when that is an actual risk.

### Losfer / Лосфер

```text
Adult man, losfer, slim slender build, pale skin, short black hair with upward-swept bangs, black blindfold covering his eyes, restrained tired expression.
```

- His canonical age is 35 in 106 НЭ. Historical prompts use `20yo`; treat that as a visual cue in those examples, not a change to his biography. Prefer `adult man` for the reusable visual profile and use the canonical age if the request needs an exact number. Do not combine competing ages in one prompt or force wrinkles onto the youthful appearance established by the examples.
- The black blindfold and layered dark silhouette are stronger anchors than generic male beauty tags. In the usual hooded outfit, the deep hood shadows the upper face; mouth and lower nose may remain faintly visible. Express emotion through head angle, mouth, shoulders and hands rather than visible eyes.
- Standard travel clothes: a long black haori over a fitted black inner layer, loose black trousers, arm wraps or bracers, high dark boots, a broad hood, and small dark books secured at the waist. Restrained white kanji-like markings on cloth or ribbons and dark red katana lacing reproduce the examples' visual language; do not invent a translation or magical property for them.
- Keep one katana and one weapon state: sheathed, drawn, or visibly being drawn. For a quiet scene, holding the black scabbard or resting a hand on its hilt is sufficient. The separate huge broad sword belongs to Losfy when her scene calls for it.
- Weariness, melancholy and reserve recur, but rain, tears, a raised chin and total darkness are scene decisions. Tears can pass below the blindfold while the eyes stay covered. A simple indoor haori outfit is possible when requested; a hood and travel equipment need not be worn in bed.
- Do not carry over `danmei`, `realistic body proportions`, fashion-model pose or sexualized male-body tags as a default style prescription. Use concrete build, garments, light and action under the shared style rules.

Solo contextual Negative may include `eyes visible, mask, scarf, brightly lit face, duplicate katana` for the standard hooded portrait; add `katana blade visible` only while sheathed. Do not copy `hood` from generic Onmyoji negatives into his hooded outfit. Do not exclude `wet face` if the requested moment includes tears or rain on his cheek. In shared scenes, qualify face/eye exclusions to the man so they do not suppress the companions' faces.

### Misty / Мисти

```text
Adult woman, rabbit girl, kemonomimi, slim slender build, medium-length white hair with soft pink gradient tips, simple loose haircut with neat bangs, blue eyes, two long white rabbit ears lowered gently to the sides, hair covering the sides of her head, shy gentle smile, light blush.
```

- Repeat her descriptive identity in every new prompt because no LoRA supplies it. The white-to-pink hair, blue eyes and long white ears distinguish her from a generic white-haired animal girl. The loose hairstyle has no ponytail or twin tails; this is a hair instruction, not a requirement about an unseen animal tail.
- In Russian lore she is a **полу-зайка**, not a rabbit. Preserve the author's repeated `rabbit girl, white rabbit ears` as the default model-facing vocabulary for this established design; do not silently replace it with an untested tag set to correct an English species label. Keep the intended ears long and her Russian lore accurate. Use literal `hare` wording when requested, without stacking both vocabularies as different species assignments.
- Her intended head has exactly the two long animal ears and no additional human pair. Keep the ears visible without making the framing expose the sides of her head. Hair over the human-ear area can help the composition.
- The recurring ear problem is **observed and unresolved by prompting alone**. In a solo image, begin with the small contextual tail `human ears, four ears, cropped ears`; use subject-qualified wording in an ensemble. Do not promise that `no human ears` or any new Negative will solve it. If the user asks about the failure, acknowledge their existing inpainting workaround; do not append an unsolicited editing workflow or settings.
- Bashfulness, blush and a hesitant smile recur; they do not imply helplessness, a permanent ashamed expression or a fixed pose. Use a calm, interested or happy expression when the scene calls for it. She is an adult, including in the pastel and pajama variants.

Outfit and setting options:

- **Astaria/coastal home:** simple blue linen Greek-inspired draped clothing; pale white/blue walls, light wood and a round wooden window when the scene is at her established home. A house near the sea does not require visible sea through every window.
- **Requested garden variant:** light blue overalls, a straw hat, gardening boots and a basket of carrots. Denim belongs to the supplied variant; for a historical Astaria scene, use suitable cloth instead of silently importing modern denim.
- **Pastel gothic variant:** a white dress with pastel pink/blue lace and bows, layered ruffles, optional matching stockings and shoes. Hair clips and a small bag are optional accessories. Do not combine `no accessories` with requested clips or jewelry.
- **Sleepwear variant:** modest white/pink pajamas in the same light coastal interior. Carrots are a recurring prop, not a requirement in every image; choose one carrot or a basket as the scene needs. Treat the prop as an ordinary object unless the user explicitly requests a different context.

## Shared scenes and other characters

The Losfy pair examples establish a useful writing pattern: exact count, separate character blocks, one shared interaction, then one environment. Follow that structure without copying their historical sexualized labels, injuries, captions or relationship assumptions. Use a companion's appearance from the current request, their canonical note, or the specifically named source; do not invent a LoRA for Maisie, Morpho, Aya or another OC, or infer an OC's personality from its real creator.

1. Open with `Masterpiece, best quality, score_9, score_8` and the actual visible cast: `1man, 1woman`, `2girls`, or `1man, 2women` as appropriate. Add adult wording in the character blocks when using the model's `girl` count tags. Use `solo` only for one visible person; an internal voice does not add another visible subject.
2. Assign stable screen positions from the viewer's perspective: left/right for two, left/center/right for three. Keep that assignment throughout. Place each trigger, hair, eyes, ears, horns, clothing, hands and expression inside its owner's block. Put no character-specific trigger or anatomy into the shared opening.
3. Give one readable interaction and identify actor and recipient explicitly: the left woman's right hand rests on the man's sleeve; the center man offers the white-haired woman a book. Use a pronoun only when its owner is clear. Do not copy the switched first/second-girl references from the pier example, or request closed eyes and both eyes visible together.
4. Keep hair, horns, ears, blindfold, colors and weapons distinct. Losfy has black horns and human ears; Misty has white animal ears; Losfer has a black blindfold and human anatomy. Put common weather, light and setting after the character blocks. Describe the emotion through their different responses rather than giving everyone the same facial expression.
5. Let contact be simple enough to read. For a three-person scene, choose one main shared task and secondary reactions instead of several overlapping embraces, props and hand gestures. Do not insert romance, kisses or a new canonical relationship merely because the two-girl corpus includes them.
6. Audit the single shared Negative against every subject. For Losfer with either woman, prefer `visible eyes on the blindfolded man` over `eyes visible`; for Misty with human-eared companions, prefer `human ears on the white-haired hare woman, four ears on the white-haired hare woman` over global `human ears`. If another character has pointed ears, qualify an exclusion such as `pointed ears on the black-haired horned woman`. Wording reduces ambiguity but does not guarantee regional control. Do not invent regional-prompt syntax or promise that separate blocks isolate LoRA effects.

### Example assembly: a requested dream scene with all three

This is a new composition example, not an established event or an image-tested recipe. It demonstrates identity ownership in a calm, fully clothed scene. Adapt its action, costume and environment to the actual request.

Positive:

```text
Masterpiece, best quality, score_9, score_8, 1man, 2women, three adults.

On the left, losfy, slim adult woman, pale skin, long messy black hair, subtle freckles, small curled black horns with a faint dark red glow, human ears, black eyes with round dark red pupils, long sharp black nails. She wears a long black dress with dark red trim, smiling gently, her hands resting in her lap.

In the center, losfer, slim adult man, short black hair, a black blindfold fully covering his eyes, tired relaxed mouth. He wears a black haori over dark travel clothes, small books secured at his waist, holding an open book with both hands.

On the right, a slim adult woman, rabbit girl, kemonomimi, medium-length white hair with soft pink gradient tips, neat bangs, blue eyes, two long white rabbit ears lowered to the sides, hair covering the sides of her head. She wears a simple blue linen dress, a shy smile, both hands folded in her lap.

Medium shot, front view, all three seated beside one another at a wooden table. The horned woman and the white-haired woman lean slightly toward the book held by the blindfolded man.

Quiet coastal room, white walls, pale blue curtains, a round wooden window behind the table, soft afternoon light.
```

For Negative, use the technical baseline from SKILL.md once, with a minimal tail such as `visible eyes on the blindfolded man, human ears on the white-haired hare woman, four ears on the white-haired hare woman`. These are additions to one continuous Negative, not a replacement baseline. Human ears and open eyes remain valid for the other subjects.

## Captions, references and revision

- Greetings, `Master`, a black-heart symbol and notebook lettering appear in particular examples. Add visible text only on request, preserve its exact wording, and remove the conflicting `text` Negative. Do not make another creator's personal address a default line spoken by Losfy.
- Follow current sentence capitalization, full stops, unweighted wording and style boundaries. Do not reproduce historical `JRPG vibe`, repeated anatomy praise, spelling errors, self-contradictory hand visibility, or an entire old contextual Negative.
- When matching a particular existing image, inspect that image through its current canonical note rather than assuming its filename or prompt proves what was actually rendered. Do not claim a newly assembled prompt has been image-tested.
- When revising a failed result, identify whether the failure concerns identity, attribute transfer, pose, environment or Misty's persistent ears. Rewrite the affected blocks cleanly while keeping the other characters' anchors. Keep prompt repair within scope; images, settings and inpainting instructions remain separate requests.
