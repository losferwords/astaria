---
name: astaria-chatgpt-images-prompts
description: "Write or revise ChatGPT Images still-image prompts across Astaria article categories, including characters, gods, Imitei, peoples, organizations, countries, creatures, objects and places. Review results and match the author's approved Anima artwork. Use for ChatGPT Images art direction, not Anima Positive/Negative prompts or video."
---

# Astaria ChatGPT Images Prompts

Write a ready-to-paste English prompt for the user's **ChatGPT Images** workflow. Discuss the concept in Russian. The user clarified the product as **ChatGPT Images 2.5** on 2026-10-26; official documentation was checked that day. The model's **2.5** version and the preferred **2.5D** anime style are independent: naming the model does not establish the style. Do not infer the exact backend version of earlier illustrations.

ChatGPT Images covers all illustrated article categories. On 2026-10-28 the author expanded this workflow beyond environments so that encyclopedia art need not wait for the GPU running Anima. Preserve compatibility with the author's approved Anima illustrations; this is an alternative workflow, not a requirement to replace Anima or redraw existing art. The environment and figure references below describe related parts of the series, not one identical treatment for every subject.

## Routing and scope

- Create a single **still illustration**. The author's article formats are **portrait 9:16 for Персонажи, Боги and Имитеи**, and **landscape 16:9 for every other category**, including bestiary, peoples, organizations, countries, objects, flora, cuisine and places. Select by the target article's category, not whether its subject looks human: an animal in Персонажи uses 9:16, while a bestiary entry uses 16:9. State the format explicitly in every complete prompt. Keep it during iteration unless the user expressly requests a different format; adapt framing and pose within it rather than silently choosing square or another ratio. Do not introduce animation or sound.
- Honor an explicit model choice and continuity of an ongoing iteration. A city explicitly requested for Anima still belongs to Anima; a character requested for ChatGPT Images belongs here.
- Return a prompt, not a generated image. Do not operate image generation, publish artwork, edit lore, or change settings without a separate request.
- Do not assume account features or a selectable API backend in ChatGPT. Keep API parameters such as `model`, `quality`, and `size` separate from the image brief; writing them in chat is not evidence of changing a setting. Recheck official documentation for product controls or a model change. The creative brief itself needs no fresh product research.

## Effective ChatGPT Images briefs

Read [references/chatgpt-images-guidance.md](references/chatgpt-images-guidance.md) for model-specific guidance, reference-led revisions, or a persistent prompting failure. It separates official guidance checked on 2026-10-26 from the author's artistic preferences.

- State the intended result, visual medium, viewpoint and important spatial relationships. Establish what should attract attention first; keep subordinate details subordinate.
- Use connected natural language, with short labeled sections when they improve a complex brief. No special tag syntax or escalating word count is required. English is this user's delivery preference, not a magic quality switch.
- Include details that change the image. Avoid repeating style synonyms, stacking universal superlatives, or retaining every exclusion from previous scenes. A complete prompt can still be compact; do not prescribe a fixed length.
- Identify attached references by number or unambiguous description and **role**: style, layout, subject, heraldry. Say what transfers and what does not. Do not borrow noisy textures from a composition reference when clean rendering is the requested change.
- On revision, change a focused set of decisions, compare the result, and preserve what worked. This does **not** override the user's full-new-generation-prompt contract below. Use an actual editing brief only when explicitly requested.

## Ground the image

- Resolve the entity in `Энциклопедия/` and read its canonical note, plus only linked context that affects visible appearance, anatomy, age, clothing, equipment, role, culture, geography, ecology or light. For an existing image, resolve fields such as `cover_image`, `portrait_image`, `female_portrait` and `male_portrait`. If no note exists, use the user's description and disclose material assumptions briefly.
- Do not read `Идеи/` or `Энциклопедия/Секреты/` unless explicitly requested. Do not invent canonical landmarks to fill a composition.
- Inspect the target's existing artwork and the user's supplied results when revising. For a new style match, inspect relevant local references rather than claiming to remember their current appearance.
- Read [references/solais-approved.md](references/solais-approved.md) for Solais requests or comparisons to that successful environment experiment. Its scene is an example, not a universal template.
- For environments, read [references/chthonic-sea-approved.md](references/chthonic-sea-approved.md) when establishing or matching their rendering, or when a result drifts towards flat storybook treatment. Inspect `Assets/Images/Chtonic_Sea.png`. Its sea, sunlight and palette are scene-specific.
- For a figure, people, organization, creature or country cover with prominent figures, read [references/figure-style-and-references.md](references/figure-style-and-references.md), then inspect a small relevant selection of the actual images it identifies. It records the author's 38-image comparison, material treatment, compatible variation and disliked results. Do not load every image for an ordinary prompt.
- For subjects beyond cities and natural landscapes, read the relevant section of [references/article-composition.md](references/article-composition.md). For a coordinated country family, read its family section before designing the individual compositions.

## Established artistic direction

Unlike the Anima skill, **explicitly describe the artistic style**. Do not import Anima's prohibition on style steering or its Positive/Negative output contract.

For environments, the primary style reference is `Assets/Images/Chtonic_Sea.png`, approved by the user on 2026-10-02. Default to **premium modern anime 2.5D environment illustration** unless the user requests another style. For figures, use **premium modern anime 2.5D character illustration**, grounded in the dimensional, anime-influenced rendering of the approved Anima portraits and full-body art. Do not apply an environment-only brief to a face. Both modes share selective contours, substantial light-and-shadow volume, organized detail, differentiated materials and a visibly illustrated finish.

Translate this direction into concrete rendering decisions:

- confident silhouettes and expressive selective contours with varied edge strength, rather than thin uniform outlines around every object;
- convincing volume in terrain, architecture, foliage and clouds through sculpted light and shadow, layered shading, reflected light and material-specific highlights;
- rich colors attached to materials, luminous accents and substantial colored shadows, with quieter distant layers for atmospheric depth;
- organized detail with calm surrounding surfaces: keep important contours and ornaments readable, simplify distant forms, and avoid equal sharpness or high-contrast microtexture everywhere.

A reusable art-direction paragraph, adapted to the place's weather and mood:

> Premium modern anime 2.5D environment illustration, with strong dimensional depth, expressive selective contours, sculpted light and shadow, and convincing material volume. Use confident shape design, broad smoothly shaded color regions, rich material colors, restrained highlights and atmospheric perspective. Concentrate fine detail on important contours and ornaments, with calmer surfaces and simpler distant forms. Preserve a distinctly illustrated anime finish, not flat vector art or photographic texture.

For observed style drift, briefly exclude thin uniform outlines, flat color fills and pastel storybook or watercolor rendering. Avoid photorealism and glossy CGI. Do not rely on a studio name alone to define or exclude the style.

Earlier supporting references remain useful for composition and cultural continuity:

- Capital compositions: resolve the current `cover_image` of `Город Кайто` and `Город Аргос` and inspect it. Earlier `.jpg` examples have been replaced; do not treat observations about old art as a description of the current files.
- `Assets/Images/Gilas.jpg`: selective crisp contours, stylized figures, convincing volume and materials.
- `Assets/Images/Amato.jpg`: atmospheric distance, layered shorelines, controlled color and local warm accents.

Use these earlier environment references for perspective, scale, visual hierarchy and cultural materials; the Chthonic Sea reference takes precedence for environment rendering. The figure reference governs faces, anatomy and figure materials, including prominent people in a country cover. Preserve nuanced materials and organized light and shadow without defaulting to heavy impasto or flat cel shading.

Transfer rendering and depth, not Mediterranean geography, Greek/Japanese architecture, sunny weather, or the large foreground figures of the country covers. Rich color does not require every scene to be sunny or uniformly saturated: adapt local colors, contrast and light to rain, night, snow, desert or forest while preserving volume and selective contours. Color, season, and cultural forms belong to the requested place. Never assume the user's ChatGPT conversation has access to local files without an attachment.

For **daytime scenes**, the author's feedback on the successful Vivek portrait on 2026-10-28 favors slightly brighter, more saturated material colors and luminous daylight. Keep clear reds, blues, greens and warm skin tones where those materials exist, without an overall brown/sepia wash, clipped highlights or uniformly boosted saturation. Adapt this preference to the actual weather; do not brighten night or heavy overcast into sunshine. The suggested `modern anime 2.5D` label is useful explicit art direction, not a proven color-control setting.

### Figures and living materials

Keep each subject's established degree of stylization: Misty's expressive eyes, the more structured faces of Chori and Kenneth, and the animal head of Itsune are compatible variations. Do not flatten them into one generic anime face or replace them with photographic faces. Describe age and expression through facial structure, eyelids, mouth, posture and a coherent gaze; use selective shading and small local skin highlights rather than uniform gloss or an inventory of pores and wrinkles.

`Assets/Images/Vivek_Ashma.png` is the first author-approved character result from this expanded ChatGPT Images workflow. Use it as a positive reference for a youthful face, environmental portrait and material separation, with the daytime color refinement above. Read its approval notes in [the figure reference](references/figure-style-and-references.md#approved-chatgpt-images-test-vivek).

Differentiate skin, hair, fur, feathers, scales, cloth, leather and metal. Clean skin can remain soft and luminous; polished bronze and reptile scales can legitimately catch stronger highlights. Hair forms irregular locks with selected loose strands; shaggy fur needs an uneven tufted silhouette; feathers need overlapping directional groups. Their treatment and the four disliked examples are detailed in the figure reference. Do not fix plastic skin by making every material matte or fix texture by blurring the subject.

When matching an existing character, distinguish identity references from style references. Usually one close style reference and, when useful, one full-body or material reference are more informative than the whole gallery. Include numbered reference instructions in the English prompt only for images actually attached or explicitly being attached. When none are attached, write a self-contained visual description and optionally recommend the specific local files in Russian. Matching a checkpoint's overall character is an artistic target, not a promise of identical output.

### Clean rendering and grain-like texture

The user approved the cleaner Namibua revision on 2026-10-20. Apply its transferable lesson to new prompts: define clean rendering positively through grouped shapes, smooth tonal transitions and selective detail, rather than relying on a final `no grain` instruction or repeatedly demanding highly detailed materials. Preserve 2.5D volume and material differences; clean does not mean blurred, plastic or flat.

When reviewing grain, excessive surface detail or a request to clean up an otherwise successful image, read [references/clean-rendering-approved.md](references/clean-rendering-approved.md). It records the approved result, material-specific treatments and how to carry a focused rendering refinement into a complete new-generation prompt. Treat the guidance as a user-tested artistic approach, not a guaranteed model setting or a diagnosis of every noisy preview.

Do not respond to style drift by demanding maximum detail everywhere or turning the whole image into flat cel fills. In rainy scenes, control the distribution of highlights on roofs, paving and water. At a readable human scale, use the same dimensional shading and warm–cool light on inhabitants as on buildings; small figures are not automatically flat silhouettes. See the rendering and inhabited-scene references for these targeted corrections.

## Compose at the appropriate scale

### Inhabited scenes

When a settlement or another scene includes many readable inhabitants, organize them into a few spatially anchored **activity groups**, not scattered generic idle figures. Describe each group through a shared everyday task or interaction, an observable pose or moment of movement, and its partner or handled object: for example, a vendor leaning across a stall toward a buyer, or two porters sharing a load while walking toward a doorway. Include seated conversation and purposeful rest where appropriate; not everyone needs to be moving.

Read [references/inhabited-scenes.md](references/inhabited-scenes.md) when composing or revising populated scenes. Match action detail to viewing distance, keep inhabitants secondary, and leave incidental background figures unresolved rather than scripting every person. Do not add crowds to a natural landscape solely to apply this rule.

### Cities

- Make the settlement the subject. Describe the vantage and the route through the image, not just `panorama`: roofs stepping toward water, a river crossing neighborhoods, or streets climbing a ridge.
- Show the requested urban scale with extensive, overlapping neighborhoods and depth. Keep foreground roofs or rocks modest if they would otherwise turn the panorama into a close harbor vignette.
- Ground layout in geography: a deep bay is not a canal or an exposed straight coast. Preserve shore shape, relief, water access, and the connection to the wider landscape.
- Vary architecture by **function**, not only size: homes, closed warehouses, open boat sheds, civic halls. Choose one main landmark, leaving incidental design freedom.
- Match inhabitants to viewing distance and the activity-group guidance above. At a truly remote panorama, people may be unresolved traces. Do not remove all life automatically or add a foreground portrait to prove occupation.
- Avoid regular queues, cloned stalls, uniform boats, and equal illumination everywhere. Give work groups room to move, ships different positions, and local light a reason.

### Natural landscapes

- Choose one geographical relationship that defines the place: a river bending through a forested valley, dune fields around exposed rock, or a woodland canopy broken by waterways.
- Establish foreground framing, the main landform, and distant terrain. State scale through layered ridges, canopy masses, river width, atmospheric depth, or a small canon-supported scale cue.
- Favor a few coherent ecological and material features over a catalogue of plants and rocks. Do not add settlements, travelers, ruins, or monuments unless requested or supported by the concept.
- Select weather and light that make the terrain readable. Solais's rain, cold colors, and harbor activity are not defaults for a desert, forest, or river.

## Write the prompt

Use connected natural-language paragraphs with full stops; short labeled sections are welcome for a complex scene. Start with still-image intent, aspect ratio, and main subject; include compact art direction, composition, defining appearance or geography, action when relevant, and light or atmosphere. The order may change when it improves clarity. Remove redundant instructions before delivery rather than continually lengthening the prompt.

- Omit Anima quality/score tags, weights, and its technical negative baseline.
- Do not include Astaria-specific proper names in the English image prompt: this applies to the world itself, characters, places, peoples, organizations, deities, named buildings and artifacts. Keep those names in the Russian explanation and internal lore grounding only. Replace them with concrete visual descriptions and familiar cultural terms, such as `a fantasy world`, `an ancient Indian-inspired market town` or `a welcoming tea house`. Real-world cultural and geographic references remain useful. Include a fictional name only if the user explicitly asks for that name to appear as a readable inscription in the image. Anima's `losfy` and `losfer` LoRA triggers have no established identity function here; describe the characters and use actual visual references instead.
- Bind colors to materials. Replace abstract poverty, antiquity, grandeur, and beauty with visible evidence where it matters.
- Describe only details that change the image. Avoid piling on synonyms, exact counts for incidental crowds, and exhaustive microgeometry. The approved city example is a useful level of detail, not a mandatory length.
- Integrate a short final exclusion sentence only for important observed risks. Do not recreate a giant Negative list. Prefer specifying the intended road surface or vessel construction over banning entire eras.
- Keep constraints internally consistent: light and weather, viewing distance and people, ship size and harbor clearance, cultural materials and requested technology.

Always deliver a **complete, self-contained, ready-to-paste English prompt for a new generation in one code block**, including on every revision, however small the correction. Describe the whole intended image, starting with `Create a single still illustration...`, and incorporate the requested correction into that full scene description. Do not substitute an `Edit the attached image...` prompt, commands to remove or change only one element, or a shorter instruction to keep everything else unchanged. A request such as removing islands or reducing grain still requires the full new-generation prompt; use input images only as clearly assigned references. Provide an image-editing prompt only if the user explicitly requests that format.

Never provide replacement snippets, isolated paragraphs, diffs, or instructions to merge text with an earlier prompt. Precede the full prompt with one to three Russian sentences explaining the visual choice. Add an optional reference-attachment sentence only when useful; do not provide several competing prompt variants unless requested.

For a requested standard male/female Imitei pair, deliver two separate complete prompts with the same equipment, palette, rendering and comparable clothing coverage. For a requested article family, deliver one complete prompt per article and explain their shared visual anchors once. These requested sets are separate subjects, not competing variants of one prompt.

## Iterate without losing the successful image

When the user supplies results, distinguish visible evidence from a hypothesis about prompting. Name what worked, identify the few important departures, and preserve the successful composition. Revise the smallest meaningful set of decisions first; after accumulated contradictory corrections, rebuild cleanly. Do not turn every past Solais failure into a universal exclusion.

Before handing off, check article-specific identity, focal hierarchy, anatomy and count, ownership of attributes, material differences, gaze or covered eyes, weapon state, scale and light. Match the series' rendering rather than a reference's culture or costume, and leave secondary details to the image model. New wording is untested until an actual result has been inspected; distinguish user approval, visible evidence and hypotheses about why a prompt worked.
