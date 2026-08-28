type AstariaLanguage = "en" | "ru";

const ASTARIA_LANGUAGE_KEY = "astaria-language";
const ASTARIA_LANGUAGE_COOKIE = "astaria_lang";
const ASTARIA_LOCALE_SEGMENT = "/__locales/";

function normaliseAstariaLanguage(
  value: string | null | undefined,
): AstariaLanguage | null {
  if (value === "ru" || value?.toLowerCase().startsWith("ru-")) return "ru";
  if (value === "en" || value?.toLowerCase().startsWith("en-")) return "en";
  return null;
}

function storedAstariaLanguage(): AstariaLanguage | null {
  try {
    const local = normaliseAstariaLanguage(
      window.localStorage.getItem(ASTARIA_LANGUAGE_KEY),
    );
    if (local) return local;
  } catch {
    // Storage may be disabled; the cookie remains a best-effort fallback.
  }

  const cookie = document.cookie
    .split(";")
    .map((part) => part.trim())
    .find((part) => part.startsWith(`${ASTARIA_LANGUAGE_COOKIE}=`));
  return normaliseAstariaLanguage(cookie?.split("=", 2)[1]);
}

function preferredAstariaLanguage(): AstariaLanguage {
  const stored = storedAstariaLanguage();
  if (stored) return stored;

  const browserLanguages = navigator.languages?.length
    ? navigator.languages
    : [navigator.language];
  return browserLanguages.some(
    (language) => normaliseAstariaLanguage(language) === "ru",
  )
    ? "ru"
    : "en";
}

function rememberAstariaLanguage(
  language: AstariaLanguage,
  canonicalRoot: string,
) {
  try {
    window.localStorage.setItem(ASTARIA_LANGUAGE_KEY, language);
  } catch {
    // A cookie is still written when localStorage is unavailable.
  }
  const siteRoot = canonicalRoot || "/";
  document.cookie = `${ASTARIA_LANGUAGE_COOKIE}=${language}; Max-Age=34560000; Path=${siteRoot}; SameSite=Lax`;
}

function documentAstariaLanguage(): AstariaLanguage {
  return document.documentElement.lang.toLowerCase().startsWith("ru")
    ? "ru"
    : "en";
}

function scriptAssetRoot(): string {
  const script = document.currentScript as HTMLScriptElement | null;
  if (!script?.src) return "";

  const path = new URL(script.src, window.location.href).pathname;
  return path.replace(/\/prescript(?:-[a-f0-9]+)?\.js$/, "").replace(/\/$/, "");
}

function canonicalSiteRoot(assetRoot: string): string {
  const marker = assetRoot.indexOf(ASTARIA_LOCALE_SEGMENT);
  return marker === -1 ? assetRoot : assetRoot.slice(0, marker);
}

function canonicaliseLocaleUrl(url: URL, canonicalRoot: string): URL {
  const marker = url.pathname.indexOf(ASTARIA_LOCALE_SEGMENT);
  if (marker === -1) return url;

  const languageEnd = url.pathname.indexOf(
    "/",
    marker + ASTARIA_LOCALE_SEGMENT.length,
  );
  const suffix = languageEnd === -1 ? "/" : url.pathname.slice(languageEnd);
  url.pathname = `${canonicalRoot}${suffix}`.replace(/\/{2,}/g, "/");
  return url;
}

function localeDocumentUrl(
  language: AstariaLanguage,
  canonicalRoot: string,
): URL {
  const current = new URL(window.location.href);
  const root = canonicalRoot.replace(/\/$/, "");
  const currentPath = current.pathname;
  const suffix =
    currentPath === root
      ? "/"
      : currentPath.startsWith(`${root}/`)
        ? currentPath.slice(root.length)
        : currentPath;
  current.pathname =
    `${root}${ASTARIA_LOCALE_SEGMENT}${language}${suffix}`.replace(
      /\/{2,}/g,
      "/",
    );
  return current;
}

async function replaceWithAstariaLocale(
  language: AstariaLanguage,
  canonicalRoot: string,
) {
  const target = localeDocumentUrl(language, canonicalRoot);
  const response = await fetch(target, { credentials: "same-origin" });
  if (!response.ok)
    throw new Error(`Unable to load ${language} locale (${response.status})`);

  const parser = new DOMParser();
  const translated = parser.parseFromString(await response.text(), "text/html");
  const base = translated.createElement("base");
  base.href = target.toString();
  translated.head.prepend(base);

  for (const anchor of translated.querySelectorAll<HTMLAnchorElement>(
    "a[href]",
  )) {
    const href = anchor.getAttribute("href");
    if (
      !href ||
      href.startsWith("#") ||
      href.startsWith("mailto:") ||
      href.startsWith("tel:")
    )
      continue;
    const absolute = new URL(href, target);
    if (absolute.origin !== window.location.origin) continue;
    anchor.href = canonicaliseLocaleUrl(absolute, canonicalRoot).toString();
  }

  translated.documentElement.classList.remove("astaria-locale-loading");
  translated.documentElement.dataset.astariaLanguage = language;
  document.open();
  document.write(`<!DOCTYPE html>\n${translated.documentElement.outerHTML}`);
  document.close();
}

function setupAstariaLanguageControls(canonicalRoot: string) {
  const current = preferredAstariaLanguage();
  document.documentElement.dataset.astariaLanguage = current;

  for (const button of document.querySelectorAll<HTMLButtonElement>(
    "[data-astaria-language]",
  )) {
    const language = normaliseAstariaLanguage(button.dataset.astariaLanguage);
    if (!language) continue;
    const active = language === current;
    button.classList.toggle("is-active", active);
    button.setAttribute("aria-pressed", String(active));
    button.addEventListener("click", () => {
      if (language === current) return;
      rememberAstariaLanguage(language, canonicalRoot);
      window.location.reload();
    });
  }

  document.addEventListener(
    "click",
    (event) => {
      const anchor = (
        event.target as Element | null
      )?.closest<HTMLAnchorElement>("a[href]");
      if (!anchor) return;
      const url = new URL(anchor.href, window.location.href);
      if (!url.pathname.includes(ASTARIA_LOCALE_SEGMENT)) return;
      event.preventDefault();
      window.location.assign(
        canonicaliseLocaleUrl(url, canonicalRoot).toString(),
      );
    },
    { capture: true },
  );
}

const requestedAstariaLanguage = preferredAstariaLanguage();
const loadedAstariaLanguage = documentAstariaLanguage();
const astariaAssetRoot = scriptAssetRoot();
const astariaCanonicalRoot = canonicalSiteRoot(astariaAssetRoot);
const isLocaleAsset = astariaAssetRoot.includes(ASTARIA_LOCALE_SEGMENT);
const isLocaleDocument = window.location.pathname.includes(
  ASTARIA_LOCALE_SEGMENT,
);

if (isLocaleDocument) {
  window.location.replace(
    canonicaliseLocaleUrl(
      new URL(window.location.href),
      astariaCanonicalRoot,
    ).toString(),
  );
} else if (
  !isLocaleAsset &&
  requestedAstariaLanguage !== loadedAstariaLanguage
) {
  document.documentElement.classList.add("astaria-locale-loading");
  replaceWithAstariaLocale(
    requestedAstariaLanguage,
    astariaCanonicalRoot,
  ).catch((error) => {
    console.error("Astaria language loading failed", error);
    document.documentElement.classList.remove("astaria-locale-loading");
  });
}

if (document.readyState === "loading") {
  document.addEventListener(
    "DOMContentLoaded",
    () => setupAstariaLanguageControls(astariaCanonicalRoot),
    { once: true },
  );
} else {
  setupAstariaLanguageControls(astariaCanonicalRoot);
}
