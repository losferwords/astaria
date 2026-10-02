---
name: astaria-sora-prompts
description: "Write or revise Sora still-image prompts for Astaria cities, places, and large-scale natural landscapes. Use for requests such as «сделай промт для Sora» and related art review; not for video production or Anima character prompts."
---

# Astaria Sora Prompts

Write a ready-to-paste English prompt for the user's Sora workflow in ChatGPT. Discuss the concept in Russian. The user prefers Sora for macro-scale environments and approved modern anime 2.5D as the default Astaria Sora style after the Chthonic Sea illustration; characters remain primarily an Anima workflow. These are project preferences and observed results, not universal claims about model capabilities.

## Routing and scope

- Default to a single **still illustration, landscape 16:9**, unless the user specifies another format. Do not introduce camera movement, duration, animation, or sound just because Sora is named.
- Honor an explicit model choice and continuity of an ongoing iteration. A city explicitly requested for Anima still belongs to Anima; an explicit Sora character request is not forbidden.
- Return a prompt, not a generated image. Do not operate Sora, publish artwork, edit lore, or change settings without a separate request. A request to make a prompt does not authorize those actions.
- Do not assume a particular Sora version, account feature, or API. Product instructions, if requested, require current documentation; the creative brief itself needs no product research.

## Ground the image

- Resolve the entity in `Энциклопедия/` and read its canonical note, plus only linked context that affects visible geography, culture, buildings, ecology, weather, or landmarks. If absent, use the user's description and disclose material assumptions briefly.
- Do not read `Идеи/` or `Энциклопедия/Секреты/` unless explicitly requested. Do not invent canonical landmarks to fill a composition.
- Inspect the target's existing artwork and the user's supplied results when revising. For a new style match, inspect relevant local references rather than claiming to remember their current appearance.
- Read [references/solais-approved.md](references/solais-approved.md) for Solais requests, comparisons to the successful experiment, or when establishing the series style for the first time. Its scene is an example, not a universal template.
- Read [references/chthonic-sea-approved.md](references/chthonic-sea-approved.md) when establishing or matching the current default style, or when a result drifts towards flat storybook rendering. Inspect `Assets/Images/Chtonic_Sea.png` as the primary visual reference. The reference's sea, sunlight and palette are scene-specific.

## Established artistic direction

Unlike the Anima skill, **explicitly describe the artistic style**. Do not import Anima's prohibition on style steering or its Positive/Negative output contract.

The current primary style reference is `Assets/Images/Chtonic_Sea.png`, approved by the user on 2026-10-02. Default to **premium modern anime 2.5D environment illustration** unless the user requests another style. Keep natural environmental proportions and a visibly illustrated finish.

Translate this direction into concrete rendering decisions:

- confident silhouettes and expressive selective contours with varied edge strength, rather than thin uniform outlines around every object;
- convincing volume in terrain, architecture, foliage and clouds through sculpted light and shadow, layered shading, reflected light and material-specific highlights;
- rich colors attached to materials, luminous accents and substantial colored shadows, with quieter distant layers for atmospheric depth;
- abundant but organized detail, readable focal areas and simpler distant forms instead of equal sharpness and contrast everywhere.

A reusable art-direction paragraph, adapted to the place's weather and mood:

> Premium modern anime 2.5D environment illustration, with strong dimensional depth, expressive selective contours, sculpted light and shadow, richly layered shading, and detailed natural materials. Confident shape design, rich material colors, luminous highlights and atmospheric perspective. Forms have convincing volume while retaining a distinctly illustrated anime finish.

For observed style drift, briefly exclude thin uniform outlines, flat color fills and pastel storybook or watercolor rendering. Avoid photorealism and glossy CGI. Do not rely on a studio name alone to define or exclude the style.

Earlier supporting references remain useful for composition and cultural continuity:

- `Assets/Images/Kaito_City.jpg`: clearly drawn roof silhouettes, layered coastal space, readable materials and painted clouds.
- `Assets/Images/Argos_City.jpg`: coherent architectural perspective, civic scale, small inhabitants, clear visual hierarchy and water-led composition.
- `Assets/Images/Gilas.jpg`: selective crisp contours, stylized figures, convincing volume and materials.
- `Assets/Images/Amato.jpg`: atmospheric distance, layered shorelines, controlled color and local warm accents.

Use these earlier references for perspective, scale, visual hierarchy and cultural materials; the Chthonic Sea reference takes precedence for the current rendering direction. Preserve nuanced materials and organized light and shadow without defaulting to heavy impasto or flat cel shading.

Transfer rendering and depth, not Mediterranean geography, Greek/Japanese architecture, sunny weather, or the large foreground figures of the country covers. Rich color does not require every scene to be sunny or uniformly saturated: adapt local colors, contrast and light to rain, night, snow, desert or forest while preserving volume and selective contours. Color, season, and cultural forms belong to the requested place. When recommending attached references, explicitly distinguish **style references** from **content/composition references**; never assume the user's Sora session has access to local files.

## Compose at the appropriate scale

### Cities

- Make the settlement the subject. Describe the vantage and the route through the image, not just `panorama`: roofs stepping toward water, a river crossing neighborhoods, or streets climbing a ridge.
- Show the requested urban scale with extensive, overlapping neighborhoods and depth. Keep foreground roofs or rocks modest if they would otherwise turn the panorama into a close harbor vignette.
- Ground layout in geography: a deep bay is not a canal or an exposed straight coast. Preserve shore shape, relief, water access, and the connection to the wider landscape.
- Vary architecture by **function**, not only size: homes, closed warehouses, open boat sheds, civic halls. Choose one main landmark, leaving incidental design freedom.
- Match inhabitants to viewing distance. At a view where doors and quays are readable, include secondary small figures engaged in a few tasks. At a truly remote panorama, people may be unresolved traces. Do not remove all life automatically or add a foreground portrait to prove occupation.
- Avoid regular queues, cloned stalls, uniform boats, and equal illumination everywhere. Give work groups room to move, ships different positions, and local light a reason.

### Natural landscapes

- Choose one geographical relationship that defines the place: a river bending through a forested valley, dune fields around exposed rock, or a woodland canopy broken by waterways.
- Establish foreground framing, the main landform, and distant terrain. State scale through layered ridges, canopy masses, river width, atmospheric depth, or a small canon-supported scale cue.
- Favor a few coherent ecological and material features over a catalogue of plants and rocks. Do not add settlements, travelers, ruins, or monuments unless requested or supported by the concept.
- Select weather and light that make the terrain readable. Solais's rain, cold colors, and harbor activity are not defaults for a desert, forest, or river.

## Write the prompt

Use connected natural-language paragraphs with full stops. Start with still-image intent, aspect ratio, and main subject; include a compact art-direction paragraph, composition and geography, defining content, and light or atmosphere. The order may change when it improves clarity.

- Omit Anima quality/score tags, weights, and its technical negative baseline.
- Translate setting names into visible information. Keep the lore name in the Russian introduction; do not rely on an unexplained fictional name to supply architecture or geography.
- Bind colors to materials. Replace abstract poverty, antiquity, grandeur, and beauty with visible evidence where it matters.
- Describe only details that change the image. Avoid piling on synonyms, exact counts for incidental crowds, and exhaustive microgeometry. The approved city example is a useful level of detail, not a mandatory length.
- Integrate a short final exclusion sentence only for important observed risks. Do not recreate a giant Negative list. Prefer specifying the intended road surface or vessel construction over banning entire eras.
- Keep constraints internally consistent: light and weather, viewing distance and people, ship size and harbor clearance, cultural materials and requested technology.

Default output: one to three Russian sentences explaining the visual choice, then **one English code block**. Add an optional reference-attachment sentence only when useful; do not provide several competing prompt variants unless requested.

## Iterate without losing the successful image

When the user supplies results, distinguish visible evidence from a hypothesis about prompting. Name what worked, identify the few important departures, and preserve the successful composition. Revise the smallest meaningful set of decisions first; after accumulated contradictory corrections, rebuild cleanly. Do not turn every past Solais failure into a universal exclusion.

Before handing off, check that the artwork represents the requested place, matches the series' rendering rather than a reference's culture, has a coherent scale and light, and leaves secondary details to the image model.
