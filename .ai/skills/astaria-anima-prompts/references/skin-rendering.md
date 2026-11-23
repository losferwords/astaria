# Soft skin with dimensional shading

## Target and evidence

On 2026-11-18 the author requested softer, even-toned skin in Anima, especially for men and darker-skinned characters, with a `modern 2.5D anime` direction. All six supplied local images were inspected. This refines surface treatment, not facial identity, skin color, age or the whole scene's style.

| Image under `Assets/Images/` | Role and visible evidence |
| --- | --- |
| `Vivek_Ashma.png` | Author-identified Sora result, documented in the former Sora/current ChatGPT Images workflow. Soft brown skin, broad cheek and neck tones, drawn facial structure and restrained skin highlights despite bright sunlight. Transfer skin treatment, not his youth, setting or complexion. |
| `Shani-Hat-Su.png` | Positive Anima reference for warm brown skin: even cheek tones and soft transitions, with small nose/lip highlights. Hair and the water bowl remain more reflective than skin. |
| `Losfer.png` | Positive Anima male reference: calm skin planes and restrained highlights beside shinier wet black clothing. Do not transfer the blindfold, pale complexion, rain or low light as prerequisites. |
| `Kiran_Varma.png` | Unwanted finish: conspicuous forehead and nose shine, strongly contrasted facial planes and shiny hand details. Costume, tattoos and facial identity are separate decisions. |
| `Samir_Thakur.jpg` | Unwanted finish: polished nose and cheek planes, wax-like surface, deeply emphasized age lines and moulded-looking moustache. Preserve maturity when correcting it. |
| `Chori_Mardjari.png` | Unwanted skin finish despite useful facial structure and composition: bright narrow nose/forehead highlights and polished cheeks/lips. Her dirt mark is intentional content, not the gloss defect. |

These are author preferences and visible comparisons, not matched generations. They do not establish which source token, checkpoint property or lighting choice caused the differences. The wording below has not yet been tested by new Anima generations.

## Transfer from the former Sora workflow

The relevant sources are [figure/material guidance](../../astaria-chatgpt-images-prompts/references/figure-style-and-references.md#skin-age-gaze-and-organic-materials) and [clean rendering](../../astaria-chatgpt-images-prompts/references/clean-rendering-approved.md#transferable-decisions). Transfer broad color regions, softly blended intermediate tones, selective detail and material-specific highlights. Keep Anima's quality prefix, compact tag/clause syntax, sentence capitalization, identity triggers and technical Negative baseline.

Use `modern 2.5D anime` as optional art direction when useful, supported by concrete shading language. Its effect has not been isolated; do not automatically copy a long ChatGPT Images style paragraph or add artist/franchise names.

## Write a compact skin instruction

Place one short clause or sentence alongside the subject's skin color and facial description. A starting vocabulary, adapted rather than accumulated:

```text
Soft mostly matte skin, even complexion, softly blended midtones, gentle light-to-shadow transitions and clearly modeled facial volume.
```

For darker skin, retain the specified hue and depth in the midtones and lit planes; use gentle reflected color to keep shadowed features readable. A possible clause:

```text
Deep brown skin with an even warm complexion, soft tonal transitions and restrained highlights that preserve its rich color.
```

An even complexion means a calm underlying tone, not one flat fill. Preserve freckles, scars, dirt, tattoos and subtle local color where the character needs them. Avoid solving gloss with `pale`, `porcelain`, chalky highlights or grey lifted shadows.

For men and mature faces, keep jaw, brow, nose, beard pattern and age-specific lines. Model those forms with broad tones and selective edges; do not make every plane a sharp highlight or every wrinkle an engraved groove. Soft skin does not mean a younger, feminized or featureless face. Beard hair should retain directional groups and an irregular edge rather than become a smooth sculpted mass.

## Light and material separation

- Favor broad diffuse illumination on the face or gentle fill/reflected light when compatible with the scene. In sunlight, retain directional shadows while keeping skin highlights subdued. At night, preserve the intended low light instead of forcing daytime brightness.
- Keep a few small natural highlights where appropriate. The goal is reduced oily sheen across forehead, nose, cheeks, neck and hands, not the removal of every light accent or all facial volume.
- Keep contours and important eyes, brows, mouth, facial hair and markings readable. Smooth transitions are a shading choice, not defocus, smeared detail or airbrushed anatomy.
- Scope softness to skin. Eyes, metal, glazed pottery, water, scales and wet cloth may legitimately have stronger reflections; ordinary cloth, leather and hair keep their own material treatment.
- For deliberately wet or sweating skin, retain the requested moisture and control its distribution. Do not apply a dry-skin exclusion that contradicts the scene.

Avoid piling on `perfect skin`, `flawless porcelain skin`, `glowing skin`, `highly detailed skin`, photographic pores or subsurface-scattering jargon as blanket fixes. They do not describe the preferred calm, illustrated surface.

## Negative and review

A compact contextual tail for a prominent face or exposed skin:

```text
glossy skin, oily skin, waxy skin, plastic skin
```

Append it to the existing technical baseline in the delivered single-list Negative; select only compatible terms for intentionally wet scenes. Avoid global `glossy`, `shiny`, `highlights`, `realistic` or `3d` bans that can suppress desirable materials or dimensional shading.

Review forehead, nose, cheeks, neck and hands for broad midtones and restrained shine, then check that facial structure, age, skin color and other materials survived. For a comparison generation, keep subject, pose, crop and scene stable and change the skin/light wording as a focused revision. Describe the result before attributing it to a particular phrase; do not claim the new wording works until an actual generation is reviewed.
