---
name: astaria-idea-workbench
description: "Use when the user asks for Astaria creative ideas, brainstorming, chapter ideas, scenes, encounters, NPC concepts, twists, situations, complications, session prep, or prompts like 'мне нужна идея', 'придумай', 'накидай', 'что может произойти', 'помоги придумать'. Save the result as a browsable draft Markdown note unless the user explicitly asks to answer only in chat."
---

# Astaria Idea Workbench

Use this skill for creative brainstorming in the Astaria setting.

## Core Behaviour

- Write in Russian by default.
- Use `.ai/context/astaria-project.md` for project background.
- Use `.ai/context/astaria-meta-and-fate.md` for cultures, correct demonyms, FATE aspects, skills, and stunts.
- For FATE characters, NPCs, scenes, scenarios, arcs, conflicts, terminology, or mechanical preparation, also use `.ai/skills/astaria-fate-core/SKILL.md` and its relevant references.
- For FATE session preparation, select incremental scene cards or a full module using `.ai/skills/astaria-fate-core/references/preparation-modes.md`. Ongoing campaigns default to incremental scene cards.
- If the idea touches existing lore, characters, Obsidian structure, maps, or articles, also use `.ai/skills/astaria-obsidian-vault/SKILL.md`.
- Unless the user explicitly says “только в чат”, “не создавай файл”, or similar, save the generated ideas to a Markdown note in `Идеи/`.
- Keep idea notes `ready: false`, `quartz: false`, and `private: true`.
- Treat `Идеи/` as output-only by default. Do not read, search, reuse, summarize, or treat existing idea notes as source context unless the user explicitly asks to use a specific note, continue a previous idea, or canonize/implement an idea.
- Do not put GM-only twists, hidden mechanics, or spoilers into public encyclopedia articles unless explicitly requested.

## File Workflow

1. Infer a short topic from the user request.
2. Create a new note:

```text
Идеи/YYYY-MM-DD - <короткая тема>.md
```

If a file with that name exists, append `- 2`, `- 3`, etc.

For incremental preparation of the same campaign chapter, keep one live chapter note instead of creating a new numbered file for every scene. When a scene has been played or the user has chosen a direction, collapse the old option batch to a brief factual result and add only the next batch. Do not accumulate rejected branches unless the user asks to preserve them.

3. Use this frontmatter:

```yaml
---
title:
type: idea
created: YYYY-MM-DD
campaign: Ветер Перемен
related: []
ready: false
quartz: false
private: true
---
```

4. Include a compact, useful body. Prefer sections such as:

- `# <title>`
- `## Коротко`
- `## Идеи`
- `## Игровые аспекты`, when FATE is useful
- `## Зацепки для персонажей`, when PCs are involved
- `## Что можно подготовить`, when the user is prepping a session

5. Update `Идеи/Идеи.md` by adding a link to the new note under `## Последние идеи`, unless the note is a trivial scratchpad.

## Creative Style

- Make ideas immediately playable.
- Write all read-aloud artistic descriptions of unfolding GM scenes in the present tense. Use past tense only for established backstory, prior events, and canonical session retellings.
- Prefer 3-7 strong options over a long vague list.
- In incremental scene-card mode, prepare only the nearest scene and stop; do not anticipate the rest of the session.
- Tie ideas to existing characters, cultures, gods, conflicts, and places when possible.
- Use canonical sources for those ties: `Энциклопедия/`, `Хронология/`, `Карты/`, `.ai/context/`, and explicitly requested notes. Do not use `Идеи/` as canon.
- Give each situation at least one tension, choice, or cost.
- For FATE, provide aspects in a form that can be invoked and compelled.
- For FATE scenarios, prepare problems, motives, story questions, stakes, and branching consequences rather than a fixed sequence of mandatory scenes.
- If the user is preparing a session, include at least one low-prep scene, one complication, and one optional escalation.

## Chat Response

After creating the note, answer briefly:

- say where the file was saved;
- summarize the strongest 2-3 ideas;
- mention any validation performed.

Do not paste the whole note back into chat unless the user asks.
