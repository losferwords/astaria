# Quartz publication and layout

Read when publishing, changing public relationships, editing Quartz layout, or checking the local site in a browser. Read `.ai/context/astaria-project.md` for public lore boundaries.

`_scripts/sync_quartz_content.rb` generates `_quartz/content/` from notes with `quartz: true`. Never edit generated content as the source of truth.

Keep secrets, private mechanics, brainstorming, and notes with `quartz: false` out of the public build. The Secrets directory is denied even if a note is marked `quartz: true` by mistake.

Site typography is self-hosted: keep `fontOrigin: local` and the bundled Alegreya SC / IBM Plex Mono files and licenses in `_quartz/quartz/static/fonts/`. Use `1rem` for the article body and preserve the author's `--astaria-prose-width: 82ch` when changing fonts. Keep `82ch` as a maximum, not a minimum requirement for displaying the sidebar. Keep the article container at `1170px`, as requested by the author, independently of the prose measure. Above the existing `900px` mobile breakpoint, the text uses the available space up to the sidebar's left margin and keeps that same width below the sidebar. Do not reintroduce a container query that stacks metadata merely because the full maximum prose measure does not fit. On mobile and in search previews, place metadata above the prose. This applies to countries, characters and other lore as well as stories.

## Publication workflow

- Generate from canonical sources and approved `_translations/en-GB/` overlays. Do not edit `_quartz/content/`, `_quartz/content-ru/`, `_quartz/content-en/`, `_quartz/build/` or `_quartz/public/` as sources.
- For a publication request, set intentional `quartz: true`, prepare or update the English translation and approved routes as needed, then run `make multilingual-build`. It validates translations, synchronizes both locales, builds, merges and audits them. Read `Makefile` if the commands change.
- Use `make multilingual-preview` for an explicitly requested preview with incomplete translations. The single-locale `quartz-sync`/`quartz-build` targets are useful for local diagnosis, not the complete publication check.
- Pure `.ai/` maintenance does not require a Quartz build. Git actions follow `.ai/AGENTS.md`.

## Local preview and browser checks

Maksim uses the Codex extension in VS Code. His default for local website checks is a separate headless browser launched through standalone Playwright from the terminal. Use this directly for screenshots and interaction tests; a connected Browser plugin session is not required. An empty `browser-client` discovery result does not establish that screenshots or browser automation are unavailable. Routine local checks do not require changing `~/.codex/config.toml` or moving the task to another app. If Maksim explicitly requests his own browser session or the built-in Browser, follow the relevant Browser skill for that surface instead.

### Server

- Check the supplied URL, or `http://localhost:8080`, and reuse an existing Astaria server. For shell HTTP checks, use `curl --noproxy '*' --max-time 5` so proxy settings do not turn a working localhost server into a misleading HTTP 403.
- **Standing authorization:** when the local site is not running, Maksim authorizes starting it without asking again. Prefer `make multilingual-preview-serve` from the repository root; another suitable local command is also authorized. If the current public build is already fresh, `ruby _scripts/serve_quartz.rb` is sufficient. Use `make multilingual-serve` when a complete bilingual build is needed. If the port belongs to another service, choose a free one, for example `make multilingual-preview-serve PORT=8081`.
- Check `Makefile` for current targets. After code/content changes, rebuild the relevant preview before testing; the WEBrick server serves generated files and does not rebuild them itself. Keep publication validation separate from preview validation as described above.
- Run the server in a long-lived tool session with captured logs. Check readiness through HTTP and the rendered page, using short tool waits to stay responsive during builds. Reuse the user's process; do not stop it to start a duplicate. Leave a server started for review available and report its URL.

### Browser

Use an installed Playwright package if available. Otherwise, install it in a task-specific temporary directory, keeping test dependencies and artifacts outside the repository. On this Mac, `chromium.launch({ channel: "chrome", headless: true })` has been verified with the installed Google Chrome. Playwright's own installed Chromium is another suitable option. Create a fresh context rather than attaching to the author's Chrome profile, and close the test browser in `finally`.

For example, this standalone map screenshot can be run from a shell; adapt the URL and readiness locator for other pages:

```bash
ASTARIA_BROWSER_TOOLS_DIR="$(mktemp -d /tmp/astaria-browser.XXXXXX)"
npm install --prefix "$ASTARIA_BROWSER_TOOLS_DIR" --no-save --ignore-scripts playwright
export ASTARIA_BROWSER_TOOLS_DIR
node <<'JS'
const { chromium } = require(`${process.env.ASTARIA_BROWSER_TOOLS_DIR}/node_modules/playwright`);
(async () => {
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  try {
    const page = await browser.newPage({
      viewport: { width: 1440, height: 1000 }, locale: 'en-GB',
    });
    await page.goto('http://localhost:8080/map', { waitUntil: 'domcontentloaded' });
    await page.locator('.astaria-map-explorer[data-ready="true"]').waitFor();
    await page.locator('.astaria-map-layer.is-active').evaluate(image => image.decode());
    await page.evaluate(() => document.fonts.ready);
    const path = `${process.env.ASTARIA_BROWSER_TOOLS_DIR}/astaria-preview.png`;
    await page.screenshot({ path, fullPage: true });
    console.log(path);
  } finally {
    await browser.close();
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
JS
```

Exercise the changed controls in the real page and inspect screenshots with `view_image`. HTTP responses and simulated DOM tests are supporting checks, not visual verification. Wait for the affected component, images and fonts rather than assuming that `DOMContentLoaded` makes every control ready or relying on blanket `networkidle` waits. Native dialog closure completes asynchronously; wait for the restored page state before asserting it.

Choose desktop/mobile dimensions and themes relevant to the change. Set the temporary browser context's `locale` to `en-GB` or `ru-RU`, or use the site's language control, and verify the resulting document language. Visiting a hidden RU URL alone can redirect back to English according to browser preferences. Record JavaScript errors and verify article links when they are affected. Report the scenarios actually checked and provide useful screenshot paths.

## Structured relationships

Forward fields are the source of truth. New places declare `parent_location` and `country`; character fields are listed in [characters.md](characters.md). Quartz derives reverse lists for people, locations, countries, Imitei, organizations, species and other supported relationships. Do not maintain parallel reverse lists merely to match the sidebar.

The synchronizer also derives public target references from ordinary fields in unpublished canonical notes. Put spoiler-only relationships in `Энциклопедия/Секреты/` or `secret_*` fields; `quartz: false` alone does not hide those relationships.
