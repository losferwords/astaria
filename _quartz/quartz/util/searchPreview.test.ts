import assert from "node:assert/strict"
import test from "node:test"
import { resolveSearchPreviewUrl } from "./searchPreview"

const route = "/literature/the-demon-to-hunt"

for (const [label, page, base, configured, language, target, expected] of [
  [
    "Russian local preview",
    `http://localhost:8080${route}`,
    `http://localhost:8080/__locales/ru${route}`,
    "/astaria/__locales/ru",
    "ru",
    route,
    `/__locales/ru${route}`,
  ],
  [
    "Russian preview with an upstream base prefix",
    `http://localhost:8080${route}`,
    `http://localhost:8080/__locales/ru${route}`,
    "/astaria/__locales/ru",
    "ru",
    `/astaria/__locales/ru${route}`,
    `/__locales/ru${route}`,
  ],
  [
    "English local preview",
    `http://localhost:8080${route}`,
    `http://localhost:8080${route}`,
    "/astaria",
    "en-GB",
    `/astaria${route}`,
    route,
  ],
  [
    "Russian production subpath",
    `https://example.org/astaria${route}`,
    `https://example.org/astaria/__locales/ru${route}`,
    "/astaria/__locales/ru",
    "ru",
    `/astaria${route}`,
    `/astaria/__locales/ru${route}`,
  ],
  [
    "Russian production root",
    `https://example.org${route}`,
    `https://example.org/__locales/ru${route}`,
    "/__locales/ru",
    "ru",
    route,
    `/__locales/ru${route}`,
  ],
  [
    "English production subpath",
    `https://example.org/astaria${route}`,
    `https://example.org/astaria${route}`,
    "/astaria",
    "en-GB",
    `/astaria${route}`,
    `/astaria${route}`,
  ],
  [
    "Already localised Russian target",
    `https://example.org/astaria${route}`,
    `https://example.org/astaria/__locales/ru${route}`,
    "/astaria/__locales/ru",
    "ru-RU",
    `/astaria/__locales/ru${route}`,
    `/astaria/__locales/ru${route}`,
  ],
  [
    "Preserve query and fragment",
    `http://localhost:8080${route}`,
    `http://localhost:8080/__locales/ru${route}`,
    "/astaria/__locales/ru",
    "ru",
    `${route}?view=full#ending`,
    `/__locales/ru${route}?view=full#ending`,
  ],
]) {
  test(label, () => {
    assert.equal(
      resolveSearchPreviewUrl(target, page, base, configured, language),
      new URL(expected, page).toString(),
    )
  })
}

test("Leave external preview URLs unchanged", () => {
  assert.equal(
    resolveSearchPreviewUrl(
      "https://external.example/story",
      "https://example.org/astaria/",
      "https://example.org/astaria/",
      "/astaria",
      "ru",
    ),
    "https://external.example/story",
  )
})
