# Maps and geography

Use Obsidian Leaflet with the political `Assets/Maps/states_ru.png` layer as the default. Leaflet marker rows use `geoY, geoX` order. Derive the current marker count from `Карты/Карта Астарии.md`; do not rely on a remembered count.

Keep physical and biome layers linked nearby:

- `Assets/Maps/heightmap_ru.png`
- `Assets/Maps/biomes_ru.png`

The English layers use the matching `states_en.png`, `heightmap_en.png` and `biomes_en.png` paths in the same directory. `_translations/map-layers.yml` is the locale asset manifest. The six original PNGs are currently **11520 × 6480**; source and web/preview entries deliberately share these files. Do not restore obsolete `Assets/Maps/Web/` or `Assets/Maps/en/` copies. Keep the Leaflet `bounds: [[0, 0], [4320, 7680]]` and the canonical `map_width` / `map_height` regardless of PNG resolution.

### Editable Azgaar Sources

- `Assets/Maps/ru.map` and `Assets/Maps/en.map` are the editable Russian and English sources, currently Azgaar **1.158.0**. Editing them is authorised; PNG layers are separate exports and do not update automatically.
- The format has **56 CRLF-delimited records**. `.gitattributes` exempts these files from newline normalization; preserve that rule. An embedded SVG contains ordinary LF line breaks: never parse this format with `splitlines()` or treat it as one JSON document. Inspect it with `python3 _scripts/inspect_azgaar_map.py Assets/Maps/ru.map`; add `--names` to list object names without dumping geometry. The tool rejects unrecognised versions rather than guessing record offsets.
- The current Azgaar canvas is **1920 × 1080**. Convert it to the canonical coordinate space with `geoX = 4 * x`, `geoY = 4320 - 4 * y`. One Azgaar unit is **0.4 km**, so the map's distance scale is 0.4. This is distinct from the PNG export dimensions.
- Names live in structured records **and** the compatibility SVG. Burgs: record 15; added labels: 47 (`label.text`); countries: 14; cultures: 13; physical features: 12; rivers: 32; SVG: 5. Preserve IDs, array slots, label paths, anchor positions, cell arrays, roads and shorelines when renaming. Update both language files without replacing one map wholesale with the other.
- By the author's decisions of **13 November 2026**, generated religions, campaigns, armies, economic simulations and random diplomacy were cleared in both maps. The religion ID 0 and zero finances are technical placeholders for data not specified here, **not** canon assertions of atheism or tax-free states. `Unknown` diplomacy means unrecorded relationships. Do not regenerate these layers and present the result as lore.
- Unverified hidden water/land-feature names use technical IDs (`River #…`, `Island #…`, etc.). They are not proper names. Some visible river names cannot yet be assigned confidently to a single internal river near a confluence; preserve the visible labels and inspect the geometry before assigning a name.
- Population, generic settlement flags, generated coats of arms, algorithmic government/culture types and name-generator bases are not independent canon sources. Population was preserved during the initial cleanup. In the follow-up on 13 November 2026 the author instructed synchronizing map population to numeric canonical article values. Keep map population unchanged where the article has no confirmed number; do not promote generator values into new articles by default. Derived urban totals may be recomputed from active settlements. Do not infer a dynasty, religion, political constitution, language or military strength from these technical fields.
- The older `_scripts/translate_azgaar_map.rb` uses global string substitution and fallback transliteration. Do not run it over these cleaned maps as an automatic synchronizer: it predates their structured cleanup and can reintroduce obsolete translations. Use the approved name registry, canonical articles and the specific accepted decisions; do not promote an unapproved fallback map spelling into the registry silently.
- A detailed audit and the naming changes are in the task-specific private report `Идеи/2026-11-13 - Сверка и очистка карт Azgaar.md`. Read that report only within map-maintenance scope; it is not an additional lore source.

### Geography For Lore And Travel

Use map positions when describing places, livelihoods, journeys, and scenes. Read `geoX` and `geoY` from place notes when available, and consult the markers in `Карты/Карта Астарии.md`. Match positions to coastlines, roads, rivers, relief, and biomes across the map layers. Use `parent_location`, `country`, territorial articles, and the political layer for regional and state relationships; proximity to a country's label does not establish ownership. A region's marker is an anchor, not its boundary.

The author's scale is **10 canonical coordinate units = 1 km**. `geoX` increases eastward and `geoY` northward. Compute straight-line distance as `sqrt((x2 - x1)^2 + (y2 - y1)^2) / 10` km. A difference of 40 units on one axis is 4 km along that axis; include both axes for the full distance. Mistras and Theonia are approximately 12 km apart.

Distinguish straight-line distance from a road or sea route. Estimate route length from its visible course and account for terrain, crossings, and transport before inferring travel time. Treat the map as schematic: do not infer exact elevations, navigable water, or a large harbour merely from a coastal marker. Separate visible features and author-confirmed biomes from proposed explanations for them.

Crops or screenshots of map regions are allowed for geographic checks. Establish their bounds and scale first. Canonical coordinates use the **7680 × 4320** map space, while the current six `*_ru.png` / `*_en.png` rasters are **11520 × 6480**. Check actual image dimensions rather than assuming equal sizes. For a layer of width `W` and height `H`, convert to top-left raster coordinates with `pixelX = geoX * W / 7680` and `pixelY = (4320 - geoY) * H / 4320`. Preserve that conversion when cropping or resizing; screenshot pixels are not canonical map units. Local map analysis may use ordinary raster cropping tools without generating or repainting geography.
