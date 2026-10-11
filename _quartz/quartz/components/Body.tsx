import {
  QuartzComponent,
  QuartzComponentConstructor,
  QuartzComponentProps,
} from "./types";
import { FullSlug, resolveRelative } from "../util/path";

const Body: QuartzComponent = ({
  children,
  fileData,
  cfg,
}: QuartzComponentProps) => {
  const current = fileData.slug!;
  // Navigation belongs to the site build, not to an individual article.
  // Older notes do not all declare `lang`, so using frontmatter here could
  // render an English header around otherwise Russian generated content.
  const isRussian = cfg.locale.toLowerCase().startsWith("ru");
  const multilingual = process.env.ASTARIA_MULTILINGUAL === "true";
  const homeHref = resolveRelative(current, "index" as FullSlug);
  const mapHref = resolveRelative(current, "map" as FullSlug);
  const timelineHref = resolveRelative(current, "timeline/index" as FullSlug);

  return (
    <div id="quartz-body">
      <header class="astaria-sitebar">
        <a
          class="astaria-sitebar-brand"
          href={homeHref}
          aria-label={
            isRussian ? "На главную страницу Астарии" : "Astaria home page"
          }
        >
          <span aria-hidden="true">
            <i>A</i>
          </span>
          <strong>{isRussian ? "Астария" : "Astaria"}</strong>
        </a>
        <div class="astaria-sitebar-actions">
          <nav
            class="astaria-sitebar-nav"
            aria-label={isRussian ? "Основная навигация" : "Primary navigation"}
          >
            <a href={mapHref}>{isRussian ? "Карта" : "Map"}</a>
            <a href={timelineHref}>{isRussian ? "Хронология" : "Timeline"}</a>
          </nav>
          {multilingual && (
            <div
              class="astaria-language-switcher"
              role="group"
              aria-label={isRussian ? "Язык сайта" : "Site language"}
            >
              <button
                type="button"
                data-astaria-language="ru"
                aria-label={isRussian ? "Русский" : "Russian"}
              >
                RU
              </button>
              <span aria-hidden="true">/</span>
              <button
                type="button"
                data-astaria-language="en"
                aria-label={isRussian ? "Английский" : "English"}
              >
                EN
              </button>
            </div>
          )}
          <button
            type="button"
            class="astaria-theme-toggle"
            aria-label={isRussian ? "Тёмная тема Лосфи" : "Losfy dark theme"}
            aria-pressed="false"
            data-light-label={
              isRussian ? "Включить светлую тему" : "Switch to light theme"
            }
            data-dark-label={
              isRussian
                ? "Включить тёмную тему Лосфи"
                : "Switch to Losfy dark theme"
            }
          >
            <svg
              class="astaria-theme-moon"
              viewBox="0 0 24 24"
              aria-hidden="true"
            >
              <path d="M20.5 14a9 9 0 0 1-10.5-10.5A9 9 0 1 0 20.5 14Z" />
            </svg>
            <svg
              class="astaria-theme-sun"
              viewBox="0 0 24 24"
              aria-hidden="true"
            >
              <circle cx="12" cy="12" r="4" />
              <path d="M12 2v2m0 16v2M2 12h2m16 0h2M4.9 4.9l1.4 1.4m11.4 11.4 1.4 1.4M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4" />
            </svg>
          </button>
        </div>
      </header>
      {children}
    </div>
  );
};

export default (() => Body) satisfies QuartzComponentConstructor;
