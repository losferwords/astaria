import {
  QuartzComponent,
  QuartzComponentConstructor,
  QuartzComponentProps,
} from "./types";
import { FullSlug, resolveRelative } from "../util/path";

const Body: QuartzComponent = ({
  children,
  fileData,
}: QuartzComponentProps) => {
  const current = fileData.slug!;
  const homeHref = resolveRelative(current, "index" as FullSlug);
  const mapHref = resolveRelative(current, "map" as FullSlug);
  const timelineHref = resolveRelative(current, "timeline/index" as FullSlug);

  return (
    <div id="quartz-body">
      <header class="astaria-sitebar">
        <a
          class="astaria-sitebar-brand"
          href={homeHref}
          aria-label="На главную страницу Астарии"
        >
          <span aria-hidden="true">
            <i>A</i>
          </span>
          <strong>Астария</strong>
        </a>
        <nav class="astaria-sitebar-nav" aria-label="Основная навигация">
          <a href={mapHref}>Карта</a>
          <a href={timelineHref}>Хронология</a>
        </nav>
      </header>
      {children}
    </div>
  );
};

export default (() => Body) satisfies QuartzComponentConstructor;
