# Quartz publication and layout

Read when publishing, changing public relationships, or editing Quartz layout. Read `.ai/context/astaria-project.md` for public lore boundaries.

`_scripts/sync_quartz_content.rb` generates `_quartz/content/` from notes with `quartz: true`. Never edit generated content as the source of truth.

Keep secrets, private mechanics, brainstorming, and notes with `quartz: false` out of the public build. The Secrets directory is denied even if a note is marked `quartz: true` by mistake.

Site typography is self-hosted: keep `fontOrigin: local` and the bundled Alegreya SC / IBM Plex Mono files and licenses in `_quartz/quartz/static/fonts/`. Use `1rem` for the article body and preserve the author's `--astaria-prose-width: 82ch` when changing fonts. Keep `82ch` as a maximum, not a minimum requirement for displaying the sidebar. Keep the article container at `1170px`, as requested by the author, independently of the prose measure. Above the existing `900px` mobile breakpoint, the text uses the available space up to the sidebar's left margin and keeps that same width below the sidebar. Do not reintroduce a container query that stacks metadata merely because the full maximum prose measure does not fit. On mobile and in search previews, place metadata above the prose. This applies to countries, characters and other lore as well as stories.

## Publication workflow

- Generate from canonical sources and approved `_translations/en-GB/` overlays. Do not edit `_quartz/content/`, `_quartz/content-ru/`, `_quartz/content-en/`, `_quartz/build/` or `_quartz/public/` as sources.
- For a publication request, set intentional `quartz: true`, prepare or update the English translation and approved routes as needed, then run `make multilingual-build`. It validates translations, synchronizes both locales, builds, merges and audits them. Read `Makefile` if the commands change.
- Use `make multilingual-preview` for an explicitly requested preview with incomplete translations. The single-locale `quartz-sync`/`quartz-build` targets are useful for local diagnosis, not the complete publication check.
- Pure `.ai/` maintenance does not require a Quartz build. Git actions follow `.ai/AGENTS.md`.

## Structured relationships

Forward fields are the source of truth. New places declare `parent_location` and `country`; character fields are listed in [characters.md](characters.md). Quartz derives reverse lists for people, locations, countries, Imitei, organizations, species and other supported relationships. Do not maintain parallel reverse lists merely to match the sidebar.

The synchronizer also derives public target references from ordinary fields in unpublished canonical notes. Put spoiler-only relationships in `Энциклопедия/Секреты/` or `secret_*` fields; `quartz: false` alone does not hide those relationships.
