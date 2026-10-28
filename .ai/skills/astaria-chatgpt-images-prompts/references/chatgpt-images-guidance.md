# ChatGPT Images: verified prompting guidance

Checked on **2026-10-26** for the author's still-image workflow. Read this for model-specific questions, reference-led revisions or persistent failures. It is not an API integration guide.

## Product, model and style

[OpenAI's announcement](https://openai.com/index/introducing-chatgpt-images-2-5/) and the [ChatGPT help article](https://help.openai.com/en/articles/11084440-images-in-chatgpt) identify the current product as **ChatGPT Images 2.5**. The author confirmed that this is the workflow used for these illustrations. The earlier project terminology was incorrect; do not assign a particular backend version retroactively to older successful images.

**2.5** is a model version; **modern anime 2.5D** is the author's independent artistic direction. The version name alone does not request that rendering style. Naming is now corrected, but this does not prove that incorrect naming caused earlier grain, geometry or figure failures.

## Official guidance to apply

The [image prompting guide](https://developers.openai.com/api/docs/guides/image-prompting), including its GPT Image 2.5 section, supports these decisions:

- Define the intended result and medium, then specify viewpoint, composition and important placement relationships.
- Choose an understandable, maintainable prompt format. Use concrete materials, light, colors and scale; mood words alone do not explain a low-light or rainy scene.
- Describe people's framing, relative size, gaze and interactions with objects.
- Assign numbered or clearly described references to roles such as subject, style or layout, explaining how they combine.
- For edits, distinguish the requested change from invariants and inspect the result; repeated edits need not preserve every detail perfectly.

The [image-generation cookbook](https://developers.openai.com/cookbook/examples/multimodal/image-gen-models-prompting-guide) adds useful general practices: give complex briefs readable sections, use texture cues deliberately, and debug through focused changes instead of piling instructions onto a failing prompt. Long prompts can work; brevity is not an absolute requirement or quality guarantee. Its older-model request examples are not evidence of current ChatGPT interface controls.

## Apply this without losing the author's workflow

Keep these as author preferences, not claims that OpenAI requires them:

- One complete English **new-generation** prompt in one code block after a short Russian concept; every revision remains complete. English is the agreed delivery language, not a special rendering parameter.
- No fictional proper names inside the image brief unless the author explicitly wants a readable inscription. Translate the lore into familiar visual terms.
- Explicit modern anime 2.5D environment direction; for figures, the approved Anima references and [figure guidance](figure-style-and-references.md). Both use clean grouped forms, selective detail and consistent volume.
- In settlement illustrations, a few situated activity groups with people secondary and no forced foreground portraits. Peoples, organizations and character scenes have their own focal hierarchy in [article composition](article-composition.md).

Official examples sometimes use short follow-up edits. Do not replace the author's full-prompt preference with those snippets. Change a focused aspect while re-delivering the full scene; switch to an editing brief only on explicit request.

## Limits and settings

ChatGPT supports creating images from a description and editing uploaded or generated images. The help article notes that selection-based edits can extend beyond the marked area. An instruction to preserve something is not a pixel-identity guarantee.

The API guide distinguishes GPT Image 2.5 Flare and Sunburst and documents request parameters separately from prose. Do not assume the author can select those backends, set API quality levels or access a particular control in ChatGPT. Do not add parameter-like incantations to a creative brief or claim they changed the active model.

The consulted documentation does not establish a universal grain-off switch or a guaranteed prompt for this anime style. Treat grouped foliage, quieter wet highlights and dimensional figures as the project's artistic approach. Compare an actual result before calling a new wording successful; do not confuse surface detail, compression and noise, or make the image flat or blurry in the name of cleanliness.
