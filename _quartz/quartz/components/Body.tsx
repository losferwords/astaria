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
        </div>
      </header>
      {children}
    </div>
  );
};

export default (() => Body) satisfies QuartzComponentConstructor;
