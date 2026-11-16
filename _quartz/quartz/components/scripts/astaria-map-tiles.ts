// HD tiles retain original raster pixels. Only visible tiles have DOM/image resources.
export type TileGrid = { id: string; tileWidth: number; tileHeight: number; columns: number; rows: number };
export type TileDescriptor = { version: number; width: number; height: number; grids: TileGrid[] };
export type TileRect = { left: number; top: number; right: number; bottom: number };

export function visibleTiles(descriptor: TileDescriptor, rect: TileRect) {
  for (const grid of descriptor.grids) {
    const x0 = Math.max(0, Math.floor(rect.left / grid.tileWidth));
    const y0 = Math.max(0, Math.floor(rect.top / grid.tileHeight));
    const x1 = Math.min(grid.columns - 1, Math.ceil((rect.right - 1e-7) / grid.tileWidth) - 1);
    const y1 = Math.min(grid.rows - 1, Math.ceil((rect.bottom - 1e-7) / grid.tileHeight) - 1);
    if (x1 < x0 || y1 < y0) return [];
    if ((x1 - x0 + 1) * (y1 - y0 + 1) > 4) continue;
    const tiles = [];
    for (let y = y0; y <= y1; y++) for (let x = x0; x <= x1; x++) {
      const left = x * grid.tileWidth, top = y * grid.tileHeight;
      tiles.push({ key: `${grid.id}/${x}-${y}`, left, top,
        width: Math.min(grid.tileWidth, descriptor.width - left),
        height: Math.min(grid.tileHeight, descriptor.height - top) });
    }
    return tiles;
  }
  return [];
}

export function createMapTileRenderer(viewport: HTMLElement, stage: HTMLElement, layers: HTMLImageElement[]) {
  const container = stage.querySelector<HTMLElement>(".astaria-map-tiles")!;
  const images = new Map<string, HTMLImageElement>();
  const descriptors = new Map<string, Promise<TileDescriptor>>();
  const metadataRequests = new Set<AbortController>();
  let currentLayer = "", enabled = false, frame = 0, destroyed = false;
  const clear = () => {
    for (const image of images.values()) { image.removeAttribute("src"); image.remove(); }
    images.clear();
    container.dataset.count = "0";
  };
  const render = async () => {
    frame = 0;
    if (destroyed) return;
    if (!enabled) { clear(); return; }
    const layer = currentLayer;
    const source = layers.find(image => image.dataset.layer === layer)?.dataset.tilesSrc;
    if (!source) return;
    const url = new URL(source, document.baseURI).href;
    if (!descriptors.has(layer)) {
      const controller = new AbortController();
      metadataRequests.add(controller);
      const promise = fetch(url, { signal: controller.signal }).then(response => {
        if (!response.ok) throw new Error(`HD map metadata: ${response.status}`);
        return response.json() as Promise<TileDescriptor>;
      }).then(data => {
        if (data.version !== 1 || !data.width || !data.height || !data.grids.length) throw new Error("Invalid HD map metadata");
        return data;
      }).finally(() => metadataRequests.delete(controller));
      descriptors.set(layer, promise);
    }
    let descriptor: TileDescriptor;
    try { descriptor = await descriptors.get(layer)!; }
    catch { descriptors.delete(layer); return; } // Existing map remains usable; a later interaction retries.
    if (destroyed || layer !== currentLayer || !enabled) return;
    const s = stage.getBoundingClientRect(), v = viewport.getBoundingClientRect();
    if (!s.width || !s.height) return;
    const rect = {
      left: Math.max(0, (v.left - s.left) / s.width * descriptor.width),
      top: Math.max(0, (v.top - s.top) / s.height * descriptor.height),
      right: Math.min(descriptor.width, (v.right - s.left) / s.width * descriptor.width),
      bottom: Math.min(descriptor.height, (v.bottom - s.top) / s.height * descriptor.height),
    };
    const tiles = visibleTiles(descriptor, rect);
    const wanted = new Set(tiles.map(tile => `${layer}/${tile.key}`));
    // Remove old/offscreen images before starting replacements, including pending requests.
    for (const [key, image] of images) if (!wanted.has(key)) {
      image.removeAttribute("src"); image.remove(); images.delete(key);
    }
    for (const tile of tiles) {
      const key = `${layer}/${tile.key}`;
      if (images.has(key)) continue;
      const image = new Image();
      image.alt = ""; image.draggable = false; image.decoding = "async";
      image.dataset.tile = key;
      image.style.cssText = `left:${tile.left / descriptor.width * 100}%;top:${tile.top / descriptor.height * 100}%;width:${tile.width / descriptor.width * 100}%;height:${tile.height / descriptor.height * 100}%`;
      image.onload = () => { if (images.get(key) === image) image.classList.add("is-ready"); };
      image.onerror = () => { if (images.get(key) === image) { images.delete(key); image.remove(); container.dataset.count = String(images.size); } };
      images.set(key, image);
      container.append(image);
      image.src = new URL(`${tile.key}.webp`, url).href;
    }
    container.dataset.count = String(images.size);
    container.dataset.grid = tiles[0]?.key.split("/")[0] ?? "";
  };
  return {
    update(layer: string, show: boolean) {
      if (layer !== currentLayer) clear();
      currentLayer = layer; enabled = show;
      if (!frame && !destroyed) frame = requestAnimationFrame(render);
    },
    destroy() {
      destroyed = true; cancelAnimationFrame(frame); clear();
      for (const controller of metadataRequests) controller.abort();
      descriptors.clear();
    },
  };
}
