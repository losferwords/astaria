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
- If the idea touches existing lore, characters, WorldAnvil migration, Obsidian structure, maps, or articles, also use `.ai/skills/astaria-obsidian-migration/SKILL.md`.
- Unless the user explicitly says “только в чат”, “не создавай файл”, or similar, save the generated ideas to a Markdown note in `Идеи/`.
- Keep idea notes `publish: false` and `private: true`.
- Treat `Идеи/` as output-only by default. Do not read, search, reuse, summarize, or treat existing idea notes as source context unless the user explicitly asks to use a specific note, continue a previous idea, or canonize/implement an idea.
- Do not put GM-only twists, hidden mechanics, or spoilers into public encyclopedia articles unless explicitly requested.

## File Workflow

1. Infer a short topic from the user request.
2. Create a new note:

```text
Идеи/YYYY-MM-DD - <короткая тема>.md
```

If a file with that name exists, append `- 2`, `- 3`, etc.

3. Use this frontmatter:

```yaml
---
title:
type: idea
status: draft
created: YYYY-MM-DD
campaign: Ветер Перемен
related: []
publish: false
private: true
tags:
  - astaria
  - idea
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
- Prefer 3-7 strong options over a long vague list.
- Tie ideas to existing characters, cultures, gods, conflicts, and places when possible.
- Use canonical sources for those ties: WorldAnvil backup, `Энциклопедия/`, `Хронология/`, `.ai/context/`, and explicitly requested notes. Do not use `Идеи/` as canon.
- Give each situation at least one tension, choice, or cost.
- For FATE, provide aspects in a form that can be invoked and compelled.
- If the user is preparing a session, include at least one low-prep scene, one complication, and one optional escalation.

## Chat Response

After creating the note, answer briefly:

- say where the file was saved;
- summarize the strongest 2-3 ideas;
- mention any validation performed.

Do not paste the whole note back into chat unless the user asks.
