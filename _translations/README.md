# Astaria translations

The Russian Obsidian vault remains the canonical authoring source. Public
translations live in this directory and are overlaid during Quartz publishing.

## Layout

- `en-GB/names.yml` is the approved onomasticon and public-route registry.
- `en-GB/pages/` mirrors canonical vault paths and contains translated page
  frontmatter and prose.
- Generated `_quartz/content*` directories are never translation sources.

English page files retain Russian wikilink targets so links continue to resolve
against the canonical vault. Their visible labels are written in English, for
example `[[Гилас|Gilas]]`.

The English build must contain no Cyrillic outside approved `native_name`
values and the temporary Russian map rasters.

## Local preview

- `make multilingual-preview-serve` builds all Russian pages and only the
  English pages whose overlays already exist, then serves them on port 8080.
- `make multilingual-build` is the release gate. It refuses to build until
  every published page has an English overlay.
- `make serve` keeps the original Russian-only development workflow unchanged.

The public URL never contains a locale segment. An explicit RU/EN selection is
stored in the browser; before that, any Russian browser locale selects Russian
and every other locale selects British English. The Russian build is stored
under a private implementation path, marked `noindex`, and loaded into the
canonical URL after a full-page refresh.
