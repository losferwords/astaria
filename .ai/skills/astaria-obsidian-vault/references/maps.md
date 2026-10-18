# Maps and geography

Use Obsidian Leaflet with the political `Assets/Maps/states.png` layer as the default. Leaflet marker rows use `geoY, geoX` order. Derive the current marker count from `Карты/Карта Астарии.md`; do not rely on a remembered count.

Keep physical and biome layers linked nearby:

- `Assets/Maps/heightmap.png`
- `Assets/Maps/biomes.png`

### Geography For Lore And Travel

Use map positions when describing places, livelihoods, journeys, and scenes. Read `geoX` and `geoY` from place notes when available, and consult the markers in `Карты/Карта Астарии.md`. Match positions to coastlines, roads, rivers, relief, and biomes across the map layers. Use `parent_location`, `country`, territorial articles, and the political layer for regional and state relationships; proximity to a country's label does not establish ownership. A region's marker is an anchor, not its boundary.

The author's scale is **10 canonical coordinate units = 1 km**. `geoX` increases eastward and `geoY` northward. Compute straight-line distance as `sqrt((x2 - x1)^2 + (y2 - y1)^2) / 10` km. A difference of 40 units on one axis is 4 km along that axis; include both axes for the full distance. Mistras and Theonia are approximately 12 km apart.

Distinguish straight-line distance from a road or sea route. Estimate route length from its visible course and account for terrain, crossings, and transport before inferring travel time. Treat the map as schematic: do not infer exact elevations, navigable water, or a large harbour merely from a coastal marker. Separate visible features and author-confirmed biomes from proposed explanations for them.

Crops or screenshots of map regions are allowed for geographic checks. Establish their bounds and scale first. Canonical coordinates use the **7680 × 4320** map space, while the current `heightmap.png` and `biomes.png` rasters are **5760 × 3240**. Check actual image dimensions rather than assuming equal sizes. For a layer of width `W` and height `H`, convert to top-left raster coordinates with `pixelX = geoX * W / 7680` and `pixelY = (4320 - geoY) * H / 4320`. Preserve that conversion when cropping or resizing; screenshot pixels are not canonical map units. Local map analysis may use ordinary raster cropping tools without generating or repainting geography.
