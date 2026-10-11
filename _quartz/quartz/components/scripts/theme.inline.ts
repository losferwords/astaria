type AstariaTheme = "light" | "dark";

const ASTARIA_THEME_KEY = "astaria-theme";
const boundAstariaThemeButtons = new WeakSet<HTMLButtonElement>();

function savedAstariaTheme(): AstariaTheme {
  try {
    return localStorage.getItem(ASTARIA_THEME_KEY) === "dark"
      ? "dark"
      : "light";
  } catch {
    return "light";
  }
}

function updateAstariaThemeControls() {
  const dark = document.documentElement.getAttribute("saved-theme") === "dark";
  document
    .querySelector<HTMLMetaElement>('meta[name="theme-color"]')
    ?.setAttribute("content", dark ? "#1a1b1e" : "#fbfaf7");
  for (const button of document.querySelectorAll<HTMLButtonElement>(
    ".astaria-theme-toggle",
  )) {
    button.setAttribute("aria-pressed", String(dark));
    button.title =
      (dark ? button.dataset.lightLabel : button.dataset.darkLabel) ?? "";
  }
}

function applyAstariaTheme(theme: AstariaTheme) {
  document.documentElement.setAttribute("saved-theme", theme);
  updateAstariaThemeControls();
  document.dispatchEvent(new CustomEvent("themechange", { detail: { theme } }));
}

// Run before the locale loader and the first paint, including translated documents.
applyAstariaTheme(savedAstariaTheme());

function setupAstariaThemeToggle() {
  updateAstariaThemeControls();
  for (const button of document.querySelectorAll<HTMLButtonElement>(
    ".astaria-theme-toggle",
  )) {
    if (boundAstariaThemeButtons.has(button)) continue;
    boundAstariaThemeButtons.add(button);
    button.addEventListener("click", () => {
      const theme: AstariaTheme =
        document.documentElement.getAttribute("saved-theme") === "dark"
          ? "light"
          : "dark";
      try {
        localStorage.setItem(ASTARIA_THEME_KEY, theme);
      } catch {
        // Switching still works when the browser disables persistent storage.
      }
      applyAstariaTheme(theme);
    });
  }
}

document.addEventListener("nav", setupAstariaThemeToggle);
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", setupAstariaThemeToggle, {
    once: true,
  });
} else {
  setupAstariaThemeToggle();
}

window.addEventListener("storage", (event) => {
  if (event.key === ASTARIA_THEME_KEY) {
    applyAstariaTheme(event.newValue === "dark" ? "dark" : "light");
  }
});
