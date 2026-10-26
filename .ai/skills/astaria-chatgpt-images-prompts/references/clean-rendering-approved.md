# Clean modern anime 2.5D rendering

## Approved result and scope

On 2026-10-20 the user reported that the focused rendering revision worked well, supplied `Assets/Images/Namibua_Village.png`, and requested that its successful techniques become part of the ChatGPT Images skill. The supplied local image was inspected: the village layout, skull-painted pillars, warm lights and background rock-cut necropolis remain recognizable, while rock planes, roof materials and foliage read as cleaner, more coherent illustrated forms. The workflow's product name was corrected on 2026-10-26; this does not establish the exact backend version of each earlier image.

Use this as a supporting reference for clean rendering, including night scenes. The Chthonic Sea remains the primary series reference. Do not transfer Namibua's jungle, African-inspired architecture, skull ornament, necropolis or night palette into unrelated subjects.

This is a user-approved result, not a controlled comparison or a guarantee that identical wording removes grain in every generation. A preview alone may not distinguish actual noise, excessive fine texture and compression artifacts. Describe visible evidence before suggesting a cause.

## Transferable decisions

- Specify the desired drawing treatment early: broad smoothly shaded color regions, confident silhouettes, selective contours and calm shadow tones. Retain sculpted volume, reflected light and material-specific color; do not replace the established style with flat fills or uniform outlines.
- Allocate detail rather than maximizing it. Important ornaments, focal objects and selected nearby edges can remain crisp; surrounding surfaces and distant layers should be quieter. Repeated high-contrast marks across every material can create grain-like visual chatter even without an explicit grain overlay.
- Group foliage into layered canopy or leaf clusters. Describe selected nearby leaves, but allow distant vegetation to merge into coherent masses instead of sharpening every twig or adding tiny bright marks throughout the shadows.
- Describe rock through major planes, fractures and structural edges, leaving broad surfaces calm. Reserve chips or roughness for places where they help identify the material or focal feature.
- Group thatch, wood grain and fabric texture into directional forms, folds and occasional purposeful marks. Do not demand every straw, pore, fiber or surface imperfection at panoramic viewing distance.
- Keep sky, mist and shadow transitions smooth. Concentrate highlights where light has a reason to catch, without a uniform sparkle or speckle layer.
- Seek clarity through deliberate drawing, not blanket blur, smeared denoising, excessive sharpening or glossy plastic surfaces. A short exclusion of grain, stippling or texture overlays can reinforce the positive treatment, but is not a substitute for it.

## When the scene already works

Keep the artistic refinement focused on rendering rather than redesigning a successful composition. The user clarified that the delivered ChatGPT Images prompt must nevertheless describe a complete new generation, not begin with `Edit` or give a short rendering-only instruction. Re-describe the successful framing, viewpoint, geography, object placement and scale, decorative motifs, lighting and palette in the full scene prompt, incorporating the cleaner drawing treatment.

If the approved scene is actually attached, identify it as a composition/content reference, not a surface-texture reference. Inspect the new result for drift rather than promising pixel-identical preservation.

If a separate style reference is useful and actually attached, assign its role explicitly. Do not ask to preserve the noisy source's style or texture while simultaneously requesting a new clean treatment. Do not add unrelated scene changes during the same test.

Carry forward the successful material treatments, not the original experiment's editing-command format. Deliver one complete self-contained English new-generation prompt beginning with `Create a single still illustration...`; do not replace it with an edit-only prompt, an isolated replacement paragraph or instructions to change one aspect while keeping everything else unchanged. An image-editing prompt is appropriate only when the user explicitly asks for that format.

## Research boundary

The official guidance consulted on 2026-10-20 supports explicit visual-medium descriptions, clearly separating changes from invariants, assigning roles to references and iterating with narrow edits. The material-specific cleanup choices above are the application that the user tested successfully, not an official universal anti-grain formula.

- [OpenAI image prompting](https://developers.openai.com/api/docs/guides/image-prompting): describe the intended medium and visible treatment; specify what an edit changes and preserves; inspect each result for drift.
- [OpenAI image-generation prompting cookbook](https://developers.openai.com/cookbook/examples/multimodal/image-gen-models-prompting-guide): use deliberate texture cues, explicit reference roles and focused iterations instead of accumulating requirements.
- [Current ChatGPT Images guidance](chatgpt-images-guidance.md): product naming, focused briefs, reference roles and API/UI boundaries rechecked on 2026-10-26. Video-generation advice is not the basis of this still-image workflow.

These links record the research basis, not a promise of current model or account behavior. Recheck official documentation when the user asks about present product controls or model capabilities.

## Rainy scenes and figure volume

On 2026-10-26 the author flagged the Amanohama result for grain-like surface chatter and flat anime figures against dimensional buildings. Keep this distinction observable: repeated bright marks on tiles, paving and water can make an image visually noisy; a preview does not prove a particular noise source or backend fault.

For similar results, keep most wet surfaces dark and calmly shaded, concentrating broad reflections near actual lights. Group tile courses and foliage rather than tracing every tile and leaf; depict rain selectively, not as equally sharp marks over the whole image. Do not polish the entire lane into a mirror or blur the whole image to hide texture.

Clean rendering must preserve volume in people as well as scenery. Use the figure-scale guidance in [inhabited-scenes.md](inhabited-scenes.md); do not interpret a request for anime styling as a requirement for flat two-tone characters. These are project-specific corrections to observed outputs, not guaranteed model controls.
