const mapKindLabels: Record<string, string> = {
  settlement: "Поселение",
  water: "Воды",
  terrain: "Ландшафт",
  realm: "Регион",
};

const normalizeMapQuery = (value: string) =>
  value.toLocaleLowerCase("ru-RU").replaceAll("ё", "е").trim();

function setupAstariaMap() {
  const explorer = document.querySelector<HTMLElement>(".astaria-map-explorer");
  if (!explorer || explorer.dataset.ready === "true") return;

  const viewport = explorer.querySelector<HTMLElement>(".astaria-map-viewport");
  const stage = explorer.querySelector<HTMLElement>(".astaria-map-stage");
  const search = explorer.querySelector<HTMLInputElement>(
    ".astaria-map-search",
  );
  const results = explorer.querySelector<HTMLElement>(".astaria-map-results");
  const detail = explorer.querySelector<HTMLElement>(".astaria-map-detail");
  const detailKind = detail?.querySelector<HTMLElement>(
    ".astaria-map-detail-kind",
  );
  const detailName = detail?.querySelector<HTMLElement>(
    ".astaria-map-detail-name",
  );
  const detailLink = detail?.querySelector<HTMLAnchorElement>(
    ".astaria-map-detail-link",
  );
  const detailNote = detail?.querySelector<HTMLElement>(
    ".astaria-map-detail-note",
  );
  const markers = Array.from(
    explorer.querySelectorAll<HTMLButtonElement>(".astaria-map-marker"),
  );
  const layerButtons = Array.from(
    explorer.querySelectorAll<HTMLButtonElement>(".astaria-map-layer-button"),
  );
  const layerImages = Array.from(
    explorer.querySelectorAll<HTMLImageElement>(".astaria-map-layer"),
  );
  if (
    !viewport ||
    !stage ||
    !search ||
    !results ||
    !detail ||
    markers.length === 0
  )
    return;

  explorer.dataset.ready = "true";
  const state = {
    scale: 1,
    x: 0,
    y: 0,
    dragging: false,
    pointerId: -1,
    px: 0,
    py: 0,
  };
  const minScale = 1;
  const mapWidth = Number(explorer.dataset.mapWidth ?? 7680);
  const mapHeight = Number(explorer.dataset.mapHeight ?? 4320);
  const pixelRatio = window.devicePixelRatio || 1;
  let selected: HTMLButtonElement | null = null;

  const baseDimensions = () => {
    const mapRatio = mapWidth / mapHeight;
    const viewportRatio = viewport.clientWidth / viewport.clientHeight;
    if (viewportRatio > mapRatio) {
      return {
        width: viewport.clientHeight * mapRatio,
        height: viewport.clientHeight,
      };
    }
    return {
      width: viewport.clientWidth,
      height: viewport.clientWidth / mapRatio,
    };
  };

  const maximumUsefulScale = (base = baseDimensions()) =>
    Math.max(
      minScale,
      Math.min(
        5,
        mapWidth / (base.width * pixelRatio),
        mapHeight / (base.height * pixelRatio),
      ),
    );

  const clamp = (renderedWidth: number, renderedHeight: number) => {
    const maxX = Math.max(0, (renderedWidth - viewport.clientWidth) / 2);
    const maxY = Math.max(0, (renderedHeight - viewport.clientHeight) / 2);
    state.x = Math.max(-maxX, Math.min(maxX, state.x));
    state.y = Math.max(-maxY, Math.min(maxY, state.y));
  };

  const renderTransform = () => {
    const base = baseDimensions();
    state.scale = Math.min(state.scale, maximumUsefulScale(base));
    const renderedWidth = base.width * state.scale;
    const renderedHeight = base.height * state.scale;
    clamp(renderedWidth, renderedHeight);
    stage.style.width = `${renderedWidth}px`;
    stage.style.height = `${renderedHeight}px`;
    stage.style.transform = `translate3d(calc(-50% + ${state.x}px), calc(-50% + ${state.y}px), 0)`;
    explorer.dataset.zoomed = state.scale > 1.02 ? "true" : "false";
  };

  const zoomAt = (nextScale: number, clientX?: number, clientY?: number) => {
    const oldScale = state.scale;
    const newScale = Math.max(
      minScale,
      Math.min(maximumUsefulScale(), nextScale),
    );
    if (Math.abs(oldScale - newScale) < 0.001) return;
    const rect = viewport.getBoundingClientRect();
    const pointX =
      (clientX ?? rect.left + rect.width / 2) - rect.left - rect.width / 2;
    const pointY =
      (clientY ?? rect.top + rect.height / 2) - rect.top - rect.height / 2;
    const ratio = newScale / oldScale;
    state.x = pointX - (pointX - state.x) * ratio;
    state.y = pointY - (pointY - state.y) * ratio;
    state.scale = newScale;
    renderTransform();
  };

  const resetMap = () => {
    state.scale = 1;
    state.x = 0;
    state.y = 0;
    renderTransform();
  };

  const showMarker = (marker: HTMLButtonElement, focusViewport = false) => {
    selected?.classList.remove("is-selected");
    selected = marker;
    selected.classList.add("is-selected");
    state.scale = Math.max(state.scale, 2.35);
    state.scale = Math.min(state.scale, maximumUsefulScale());
    const base = baseDimensions();
    const x = Number(marker.dataset.x ?? 50) / 100 - 0.5;
    const y = Number(marker.dataset.y ?? 50) / 100 - 0.5;
    state.x = -x * base.width * state.scale;
    state.y = -y * base.height * state.scale;
    renderTransform();

    const name = marker.dataset.name ?? "Неизвестное место";
    const kind = marker.dataset.kind ?? "realm";
    const href = marker.dataset.href ?? "";
    if (detailKind) detailKind.textContent = mapKindLabels[kind] ?? "Место";
    if (detailName) detailName.textContent = name;
    if (detailLink) {
      detailLink.hidden = href === "";
      if (href !== "") detailLink.href = href;
    }
    if (detailNote) detailNote.hidden = href !== "";
    detail.hidden = false;
    if (focusViewport) viewport.focus({ preventScroll: true });
  };

  const makeResult = (marker: HTMLButtonElement) => {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "astaria-map-result";
    const kind = document.createElement("span");
    kind.textContent = mapKindLabels[marker.dataset.kind ?? "realm"] ?? "Место";
    const name = document.createElement("strong");
    name.textContent = marker.dataset.name ?? "Неизвестное место";
    button.append(kind, name);
    button.addEventListener("click", () => showMarker(marker, true));
    return button;
  };

  const renderResults = () => {
    const term = normalizeMapQuery(search.value);
    const matches = term
      ? markers.filter((marker) =>
          normalizeMapQuery(marker.dataset.name ?? "").includes(term),
        )
      : markers.filter((marker) =>
          [
            "Талассия",
            "Антра",
            "Храм Меркаты",
            "Город Сангалла",
            "Озеро Сильвиан",
          ].includes(marker.dataset.name ?? ""),
        );

    for (const marker of markers) {
      const visible = term === "" || matches.includes(marker);
      marker.classList.toggle("is-search-hidden", !visible);
    }

    results.replaceChildren();
    if (matches.length === 0) {
      const empty = document.createElement("p");
      empty.className = "astaria-map-results-empty";
      empty.textContent = term
        ? "На карте нет места с таким названием."
        : "Выберите точку на карте.";
      results.append(empty);
      return;
    }

    const heading = document.createElement("p");
    heading.className = "astaria-map-results-heading";
    heading.textContent = term
      ? `Найдено: ${matches.length}`
      : "Попробуйте начать отсюда";
    results.append(heading, ...matches.slice(0, 12).map(makeResult));
  };

  search.addEventListener("input", renderResults);
  search.addEventListener("keydown", (event) => {
    if (event.key === "Enter") {
      const first = results.querySelector<HTMLButtonElement>(
        ".astaria-map-result",
      );
      if (first) {
        event.preventDefault();
        first.click();
      }
    }
  });

  for (const marker of markers) {
    marker.addEventListener("click", (event) => {
      event.stopPropagation();
      showMarker(marker);
    });
  }

  let requestedLayer =
    layerImages.find((image) => image.classList.contains("is-active"))?.dataset
      .layer ?? "states";

  const commitLayer = (layer: string) => {
    if (requestedLayer !== layer) return;
    for (const candidate of layerButtons) {
      const active = candidate.dataset.layer === layer;
      candidate.classList.toggle("is-active", active);
      candidate.setAttribute("aria-pressed", String(active));
    }
    for (const image of layerImages) {
      image.classList.toggle("is-active", image.dataset.layer === layer);
    }
  };

  const stopLayerLoading = (layer: string) => {
    const button = layerButtons.find(
      (candidate) => candidate.dataset.layer === layer,
    );
    button?.classList.remove("is-loading");
    button?.removeAttribute("aria-busy");
  };

  const loadLayer = (button: HTMLButtonElement) => {
    const layer = button.dataset.layer;
    const image = layerImages.find(
      (candidate) => candidate.dataset.layer === layer,
    );
    if (!layer || !image) return;
    requestedLayer = layer;

    if (image.complete && image.naturalWidth > 0) {
      commitLayer(layer);
      return;
    }

    button.classList.add("is-loading");
    button.setAttribute("aria-busy", "true");
    if (image.dataset.loading === "true") return;
    image.dataset.loading = "true";

    const finish = async () => {
      delete image.dataset.loading;
      delete image.dataset.src;
      try {
        await image.decode();
      } catch {
        // The image is already usable when the load event has fired.
      }
      stopLayerLoading(layer);
      commitLayer(layer);
    };
    const fail = () => {
      delete image.dataset.loading;
      stopLayerLoading(layer);
      image.removeAttribute("src");
    };
    image.addEventListener("load", finish, { once: true });
    image.addEventListener("error", fail, { once: true });
    if (image.dataset.src) image.src = image.dataset.src;
  };

  for (const button of layerButtons) {
    button.addEventListener("click", () => loadLayer(button));
  }

  const initialLayer = layerImages.find((image) =>
    image.classList.contains("is-active"),
  );
  const initialButton = layerButtons.find(
    (button) => button.dataset.layer === initialLayer?.dataset.layer,
  );
  if (initialLayer && initialButton && !initialLayer.complete) {
    initialButton.classList.add("is-loading");
    initialButton.setAttribute("aria-busy", "true");
    initialLayer.addEventListener(
      "load",
      () => stopLayerLoading(initialLayer.dataset.layer ?? "states"),
      { once: true },
    );
  }

  viewport.addEventListener(
    "wheel",
    (event) => {
      event.preventDefault();
      zoomAt(
        state.scale * (event.deltaY < 0 ? 1.18 : 0.84),
        event.clientX,
        event.clientY,
      );
    },
    { passive: false },
  );

  viewport.addEventListener("pointerdown", (event) => {
    if ((event.target as Element).closest("button, a")) return;
    state.dragging = true;
    state.pointerId = event.pointerId;
    state.px = event.clientX;
    state.py = event.clientY;
    viewport.setPointerCapture(event.pointerId);
    viewport.classList.add("is-dragging");
  });
  viewport.addEventListener("pointermove", (event) => {
    if (!state.dragging || event.pointerId !== state.pointerId) return;
    state.x += event.clientX - state.px;
    state.y += event.clientY - state.py;
    state.px = event.clientX;
    state.py = event.clientY;
    renderTransform();
  });
  const stopDragging = (event: PointerEvent) => {
    if (event.pointerId !== state.pointerId) return;
    state.dragging = false;
    viewport.classList.remove("is-dragging");
    if (viewport.hasPointerCapture(event.pointerId))
      viewport.releasePointerCapture(event.pointerId);
  };
  viewport.addEventListener("pointerup", stopDragging);
  viewport.addEventListener("pointercancel", stopDragging);

  viewport.addEventListener("keydown", (event) => {
    const step = event.shiftKey ? 90 : 42;
    if (
      [
        "ArrowLeft",
        "ArrowRight",
        "ArrowUp",
        "ArrowDown",
        "+",
        "=",
        "-",
        "0",
      ].includes(event.key)
    ) {
      event.preventDefault();
    }
    if (event.key === "ArrowLeft") state.x += step;
    if (event.key === "ArrowRight") state.x -= step;
    if (event.key === "ArrowUp") state.y += step;
    if (event.key === "ArrowDown") state.y -= step;
    if (event.key === "+" || event.key === "=") zoomAt(state.scale * 1.22);
    if (event.key === "-") zoomAt(state.scale / 1.22);
    if (event.key === "0") resetMap();
    if (event.key === "Escape") detail.hidden = true;
    renderTransform();
  });

  for (const button of explorer.querySelectorAll<HTMLButtonElement>(
    "[data-map-action]",
  )) {
    button.addEventListener("click", () => {
      if (button.dataset.mapAction === "zoom-in") zoomAt(state.scale * 1.25);
      if (button.dataset.mapAction === "zoom-out") zoomAt(state.scale / 1.25);
      if (button.dataset.mapAction === "reset") resetMap();
    });
  }

  detail
    .querySelector<HTMLButtonElement>(".astaria-map-detail-close")
    ?.addEventListener("click", () => {
      detail.hidden = true;
      selected?.classList.remove("is-selected");
      selected = null;
    });

  const observer = new ResizeObserver(renderTransform);
  observer.observe(viewport);
  const quartzWindow = window as Window & {
    addCleanup?: (fn: () => void) => void;
  };
  quartzWindow.addCleanup?.(() => observer.disconnect());
  renderResults();
  renderTransform();
}

function setupAstariaTimeline() {
  const timeline = document.querySelector<HTMLElement>(
    ".astaria-timeline-page",
  );
  if (!timeline || timeline.dataset.ready === "true") return;

  const search = timeline.querySelector<HTMLInputElement>(
    ".astaria-timeline-search",
  );
  const category = timeline.querySelector<HTMLSelectElement>(
    ".astaria-timeline-category",
  );
  const count = timeline.querySelector<HTMLElement>(".astaria-timeline-count");
  const empty = timeline.querySelector<HTMLElement>(".astaria-timeline-empty");
  const events = Array.from(
    timeline.querySelectorAll<HTMLElement>(".astaria-timeline-event"),
  );
  const eras = Array.from(
    timeline.querySelectorAll<HTMLElement>(".astaria-timeline-era"),
  );
  if (!search || !category || !count || !empty || events.length === 0) return;

  timeline.dataset.ready = "true";
  const filter = () => {
    const term = normalizeMapQuery(search.value);
    const selectedCategory = category.value;
    let visibleCount = 0;

    for (const event of events) {
      const matchesSearch =
        term === "" || (event.dataset.search ?? "").includes(term);
      const matchesCategory =
        selectedCategory === "" || event.dataset.category === selectedCategory;
      const visible = matchesSearch && matchesCategory;
      event.hidden = !visible;
      if (visible) visibleCount += 1;
    }

    for (const era of eras) {
      era.hidden = !era.querySelector(".astaria-timeline-event:not([hidden])");
    }
    count.textContent = `Показано: ${visibleCount}`;
    empty.hidden = visibleCount !== 0;
  };

  search.addEventListener("input", filter);
  category.addEventListener("change", filter);
  filter();
}

function setupAstariaCategoryFilters() {
  const pages = document.querySelectorAll<HTMLElement>(
    ".astaria-category-page",
  );

  for (const page of pages) {
    if (page.dataset.ready === "true") continue;

    const search = page.querySelector<HTMLInputElement>(
      ".astaria-category-search",
    );
    const count = page.querySelector<HTMLElement>(".astaria-category-count");
    const clear = page.querySelector<HTMLButtonElement>(
      ".astaria-category-clear",
    );
    const empty = page.querySelector<HTMLElement>(
      ".astaria-category-no-results",
    );
    const cards = Array.from(
      page.querySelectorAll<HTMLElement>(".astaria-category-card"),
    );
    const groups = Array.from(
      page.querySelectorAll<HTMLElement>(".astaria-category-group"),
    );
    if (!search || !count || !clear || !empty || cards.length === 0) continue;

    page.dataset.ready = "true";
    const filter = () => {
      const term = normalizeMapQuery(search.value);
      let visibleCount = 0;

      for (const card of cards) {
        const visible =
          term === "" || (card.dataset.search ?? "").includes(term);
        card.hidden = !visible;
        if (visible) visibleCount += 1;
      }

      for (const group of groups) {
        group.hidden = !group.querySelector(
          ".astaria-category-card:not([hidden])",
        );
      }

      count.textContent = `Показано: ${visibleCount} из ${cards.length}`;
      clear.hidden = term === "";
      empty.hidden = visibleCount !== 0;
    };

    const reset = () => {
      search.value = "";
      filter();
      search.focus();
    };

    search.addEventListener("input", filter);
    search.addEventListener("keydown", (event) => {
      if (event.key !== "Escape" || search.value === "") return;
      event.preventDefault();
      reset();
    });
    clear.addEventListener("click", reset);
    filter();
  }
}

type AstariaDiscoveryCandidate = {
  href: string;
  image: string;
  title: string;
  label: string;
  variant: "wide" | "portrait";
};

function setupAstariaDiscovery() {
  const section = document.querySelector<HTMLElement>(".astaria-home-discover");
  if (!section || section.dataset.ready === "true") return;

  const button = section.querySelector<HTMLButtonElement>(
    ".astaria-discovery-shuffle",
  );
  const status = section.querySelector<HTMLElement>(
    ".astaria-discovery-status",
  );
  const items = Array.from(
    section.querySelectorAll<HTMLElement>(".astaria-discovery-item"),
  );
  if (!button || items.length === 0) return;

  const pools = items.map((item) => {
    try {
      return JSON.parse(
        item.dataset.discoveryCandidates ?? "[]",
      ) as AstariaDiscoveryCandidate[];
    } catch {
      return [];
    }
  });
  if (pools.some((pool) => pool.length === 0)) return;

  const choose = (pool: AstariaDiscoveryCandidate[], currentHref: string) => {
    const alternatives = pool.filter(
      (candidate) => candidate.href !== currentHref,
    );
    const source = alternatives.length > 0 ? alternatives : pool;
    return source[Math.floor(Math.random() * source.length)];
  };

  const render = (announce: boolean) => {
    items.forEach((item, index) => {
      const card = item.querySelector<HTMLAnchorElement>(
        ".astaria-discovery-card",
      );
      const image = card?.querySelector<HTMLImageElement>("img");
      const label = card?.querySelector<HTMLElement>("small");
      const title = card?.querySelector<HTMLElement>("b");
      if (!card || !image || !label || !title) return;

      const candidate = choose(pools[index], card.getAttribute("href") ?? "");
      card.setAttribute("href", candidate.href);
      card.classList.toggle(
        "astaria-discovery-portrait",
        candidate.variant === "portrait",
      );
      card.classList.toggle(
        "astaria-discovery-wide",
        candidate.variant === "wide",
      );
      image.src = candidate.image;
      image.alt = candidate.title;
      label.textContent = candidate.label;
      title.textContent = candidate.title;

      if (
        announce &&
        !window.matchMedia("(prefers-reduced-motion: reduce)").matches
      ) {
        card.animate(
          [
            { opacity: 0.55, transform: "translateY(4px)" },
            { opacity: 1, transform: "translateY(0)" },
          ],
          { duration: 260, easing: "ease-out" },
        );
      }
    });

    if (announce && status)
      status.textContent = "Подборка маршрутов обновлена.";
  };

  section.dataset.ready = "true";
  button.addEventListener("click", () => render(true));
  render(false);
}

function setupAstariaExperience() {
  setupAstariaMap();
  setupAstariaTimeline();
  setupAstariaCategoryFilters();
  setupAstariaDiscovery();
}

document.addEventListener("nav", setupAstariaExperience);
document.addEventListener("render", setupAstariaExperience);
