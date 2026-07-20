#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "json"
require "yaml"

ROOT = File.expand_path("..", __dir__)
PUBLIC = File.join(ROOT, "_quartz", "public")
CONTENT = File.join(ROOT, "_quartz", "content")

failures = []
checks = 0

expect = lambda do |condition, message|
  checks += 1
  failures << message unless condition
end

read = lambda do |relative|
  path = File.join(PUBLIC, relative)
  expect.call(File.file?(path), "Missing built page: #{relative}")
  File.file?(path) ? File.read(path) : ""
end

categories = {
  "bestiary" => 5,
  "gods" => 5,
  "lore" => 5,
  "imitei" => 5,
  "literature" => 3,
  "places" => 5,
  "peoples" => 5,
  "organizations" => 5,
  "characters" => 8,
  "items" => 5,
  "events" => 5,
  "countries" => 5
}

categories.each do |route, minimum|
  html = read.call("#{route}/index.html")
  cards = html.scan(/class="[^"]*astaria-category-card(?:\s|\")/).length
  expect.call(cards >= minimum, "#{route}: expected at least #{minimum} article cards, found #{cards}")
  expect.call(html.include?("astaria-category-header"), "#{route}: category header is missing")
  expect.call(!html.match?(/<pre><code>.*?&lt;(?:article|div|h3|p|span)(?:\s|&gt;)/m), "#{route}: generated card HTML is rendered as visible source code")
  expect.call(!html.include?("Энциклопедия ·"), "#{route}: redundant article count is still shown in the category header")
end

representatives = {
  "countries/gilas.html" => %w[astaria-cover-image astaria-sidebar astaria-crest-image],
  "gods/mercate.html" => %w[astaria-sidebar-image astaria-infobox],
  "characters/persephone.html" => %w[astaria-sidebar-image astaria-article-footer],
  "places/khalisat-desert.html" => %w[astaria-cover-image astaria-content-title],
  "peoples/ellians.html" => %w[astaria-cover-image astaria-content-title],
  "characters/nisa-nereid.html" => %w[astaria-sidebar-image astaria-content-title]
}

representatives.each do |relative, selectors|
  html = read.call(relative)
  selectors.each do |selector|
    expect.call(html.include?(selector), "#{relative}: expected #{selector}")
  end
  expect.call(html.scan(/<h1(?:\s|>)/).length == 1, "#{relative}: expected exactly one H1")
end

countries = read.call("countries/index.html")
country_positions = ["Гилас", "Громовые Кланы", "Иомар", "Катахтонос"].map { |title| countries.index(">#{title}</h3>") }
expect.call(country_positions.none?(&:nil?) && country_positions == country_positions.sort, "Countries are not in canonical order")
expect.call(countries.scan("astaria-category-card-crest").length >= 5, "Country cards must show their crests")
expect.call(!countries.include?("Государство Астарии"), "Country cards still use the generic subtitle")
["Республика героев", "Союз вольных кланов", "Друидский матриархат", "Приют хтонидов", "Морская держава"].each do |subtitle|
  expect.call(countries.include?(subtitle), "Country cards are missing the distinctive subtitle: #{subtitle}")
end

characters = read.call("characters/index.html")
character_groups = ["Гилас", "Громовые Кланы", "Иомар", "Катахтонос"].map { |title| characters.index(">#{title} <span aria-hidden=\"true\">↗</span></a></h2>") }
expect.call(character_groups.none?(&:nil?) && character_groups == character_groups.sort, "Character groups are not in canonical country order")
creature_group = characters.index("Существа</h2>")
expect.call(!creature_group.nil? && creature_group > character_groups.compact.max, "Creature characters must have their own group after countries")
expect.call(!characters.include?("Лица и судьбы"), "Character groups still repeat the 'Лица и судьбы' kicker")
expect.call(!characters.match?(/astaria-category-group.*?<header>.*?\d+ (?:статья|статьи|статей)/m), "Character groups still display redundant article counts")
["gilas", "thunder-clans", "iomar", "katachthonos"].each do |slug|
  expect.call(characters.include?("data-slug=\"countries/#{slug}\""), "Character group does not link to country: #{slug}")
end
["Ниса", "Мэйлун", "Стикс"].each do |title|
  position = characters.index(">#{title}</h3>")
  expect.call(!position.nil? && position > creature_group, "#{title} must appear in the creature character group")
end

bestiary = read.call("bestiary/index.html")
expect.call(bestiary.include?(">Бестиарий</h1>"), "Bestiary must keep its canonical name")
["Ниса", "Мэйлун", "Стикс"].each do |title|
  expect.call(!bestiary.include?(">#{title}</h3>"), "#{title} is an individual and must not appear in Bestiary")
end

places = read.call("places/index.html")
expect.call(places.scan("astaria-category-card-place").length >= 5, "Place cards must use the landscape place layout")
expect.call(places.include?("assets/images/silvian_lake.jpg"), "Astaria place card must use Silvian Lake")
featured_place = places.index("astaria-category-card-featured")
first_regular_place = places.index("astaria-category-card-place", featured_place.to_i + 1)
expect.call(!featured_place.nil? && !first_regular_place.nil? && featured_place < first_regular_place, "Astaria must be the first featured place card")
expect.call(places.include?("Начать путешествие"), "Featured Astaria card is missing its journey call to action")

astaria = read.call("places/astaria.html")
expect.call(astaria.scan("astaria-cover-image").length == 1, "Astaria entry page must have exactly one cover image")
expect.call(astaria.include?("assets/images/silvian_lake.jpg"), "Astaria entry page must use Silvian Lake")
expect.call(!astaria.include?("avatar-on-north"), "Astaria entry page still contains the retired home artwork")
expect.call(astaria.include?("astaria-article-lede"), "Astaria entry page is missing its introductory lede")
expect.call(astaria.scan("astaria-journey-card").length == 6, "Astaria entry page must offer six exploration paths")
expect.call(astaria.scan("astaria-cover-frame").length == 1, "Astaria cover must use the framed article layout")
expect.call(astaria.match?(/class="astaria-cover-image"[^>]*alt="Астария"[^>]*fetchpriority="high"/), "Astaria cover must provide useful alternative text and high LCP priority")
journey_styles = File.read(File.join(ROOT, "_quartz", "quartz", "styles", "custom.scss"))
expect.call(journey_styles.include?("grid-template-rows: auto auto 1fr auto"), "Astaria journey cards must keep their compact aligned row layout")
expect.call(!journey_styles.match?(/\.astaria-journey-card > span\s*\{[^}]*margin-bottom:\s*auto/m), "Astaria journey card number still creates a large vertical gap")
expect.call(journey_styles.include?("padding: 1.25rem !important"), "Astaria journey card padding can be overridden by the generic internal-link rule")
expect.call(journey_styles.match?(/\.astaria-cover-image\s*\{[^}]*width:\s*100%/m), "Article covers must align with the article content width")
expect.call(!journey_styles.match?(/\.astaria-cover-image\s*\{[^}]*margin:\s*0\s+-/m), "Article covers still use asymmetric negative margins")
expect.call(journey_styles.include?(".search .preview-container .astaria-category-grid"), "Search preview must suppress full category grids")

home = read.call("index.html")
expect.call(home.scan("astaria-portal-image").length >= 3, "All three main portals must use the same visual card structure")
expect.call(home.include?("assets/images/silvian_lake.jpg"), "Encyclopedia portal must use the Astaria article cover")
expect.call(journey_styles.match?(/\.astaria-home-portals\s*\{[^}]*align-items:\s*stretch/m), "Main portal cards must be equal-height")
expect.call(journey_styles.match?(/\.markdown-rendered \.astaria-portal-hit[^\{]*\{[^}]*height:\s*100%/m), "Visual portal links must fill equal-height cards")

rich_infoboxes = {
  "bestiary/nereid.html" => 5,
  "gods/mercate.html" => 10,
  "lore/chthonotema.html" => 4,
  "imitei/druid.html" => 4,
  "literature/poka-bogi-spyat.html" => 2,
  "places/astaria.html" => 4,
  "peoples/ellians.html" => 3,
  "organizations/druidism.html" => 6,
  "characters/meilong.html" => 6,
  "items/deathbringer.html" => 5,
  "events/war-of-the-thirsty.html" => 5,
  "countries/gilas.html" => 9
}

rich_infoboxes.each do |relative, minimum|
  html = read.call(relative)
  rows = html.scan("astaria-infobox-row").length
  expect.call(rows >= minimum, "#{relative}: expected at least #{minimum} useful infobox rows, found #{rows}")
  expect.call(html.include?(">Сведения</p>"), "#{relative}: infobox must use the neutral 'Сведения' heading")
  expect.call(!html.include?("Кратко о статье"), "#{relative}: obsolete infobox heading is still present")
end

meilong = read.call("characters/meilong.html")
["媚龍", "Дракон неустановленного вида", "104 НЭ", "Красные", "50см", "13кг"].each do |value|
  expect.call(meilong.include?(value), "Meilong infobox is missing #{value}")
end
expect.call(meilong.include?("astaria-infobox-note"), "Meilong infobox must show the calculated current age")
expect.call(read.call("bestiary/nereid.html").include?("astaria-infobox-link"), "Published infobox references must be clickable")
content_index = JSON.parse(read.call("static/contentIndex.json"))
expect.call(content_index.dig("characters/meilong", "content")&.include?("媚龍"), "Search index must include Meilong's native name")

render_page_source = File.read(File.join(ROOT, "_quartz", "quartz", "components", "renderPage.tsx"))
expect.call(render_page_source.include?("componentData.ctx.argv.serve || !cfg.baseUrl"), "Local preview must not add the production /astaria prefix to search results")

native_name_notes = []
missing_native_names = []
Dir.glob(File.join(ROOT, "Энциклопедия", "**", "*.md")).sort.each do |path|
  next if path.include?(File.join("Энциклопедия", "Секреты"))

  source = File.read(path)
  match = source.match(/\A---\s*\n(.*?)\n---/m)
  next unless match

  data = YAML.safe_load(match[1], permitted_classes: [], aliases: true) || {}
  cjk_aliases = Array(data["aliases"]).flat_map { |value| value.to_s.split(/\s*,\s*/) }.select { |value| value.match?(/[一-龯ぁ-んァ-ン]/) }
  next if cjk_aliases.empty?

  native_name_notes << path
  missing_native_names << path if data["native_name"].to_s.strip.empty?
end
expect.call(native_name_notes.length >= 120, "Expected the recovered native-name corpus for Lang-An, Amato, Meilong and Onmyoji")
expect.call(missing_native_names.empty?, "CJK aliases without native_name: #{missing_native_names.map { |path| File.basename(path) }.join(', ')}")

timeline = read.call("timeline/index.html")
expect.call(timeline.scan("astaria-timeline-event").length == 26, "Timeline must contain all 26 events")
expect.call(timeline.include?("astaria-timeline-search"), "Timeline search is missing")
expect.call(timeline.include?("astaria-timeline-category"), "Timeline category filter is missing")
expect.call(!timeline.include?("[!timeline]"), "Timeline exposes raw Obsidian callout markup")
expect.call(!timeline.match?(/<pre><code>.*?&lt;(?:article|div|h3|p|span)(?:\s|&gt;)/m), "Timeline event HTML is rendered as visible source code")
expect.call(timeline.scan(/<article class="astaria-timeline-card[^"]*">\s*<img/m).length == 26, "Every timeline event must have an illustration")
expect.call(timeline.scan("astaria-timeline-meta").length == 26, "Every timeline event must show a readable significance label")
%w[Эпохальное Переломное Важное Заметное].each do |label|
  expect.call(timeline.include?(label), "Timeline is missing the significance level: #{label}")
end
[
  "amon-astat_drought.jpg",
  "gunpowder.jpg",
  "archaeans.jpg",
  "orion_city.jpg",
  "katachthonos_colony.jpg"
].each do |filename|
  expect.call(timeline.include?("assets/images/#{filename}"), "Timeline is missing the requested illustration: #{filename}")
end

event_article_pages = %w[
  events/war-of-the-thirsty.html
  events/acheus-invasion.html
  events/faith-crysis-amon-astat.html
  events/chthonid-fall.html
  events/kad-kharad-disbandment.html
  timeline/foundation-of-talassia.html
]
event_article_pages.each do |relative|
  html = read.call(relative)
  expect.call(!html.match?(/<dt>Значимость<\/dt><dd>\s*\d/), "#{relative}: raw significance number is still visible")
  expect.call(html.match?(/<dt>Значимость<\/dt><dd>(?:Эпохальное|Переломное|Важное|Заметное) событие<\/dd>/), "#{relative}: readable significance label is missing")
end

timeline_source_paths = Dir.glob(File.join(ROOT, "Хронология", "События", "*.md")) + Dir.glob(File.join(ROOT, "Энциклопедия", "События", "*.md"))
timeline_sources = timeline_source_paths.map do |path|
  source = File.read(path)
  match = source.match(/\A---\s*\n(.*?)\n---/m)
  data = match ? YAML.safe_load(match[1], permitted_classes: [], aliases: true) || {} : {}
  next unless data["timeline"] == true

  [path, data]
end.compact
missing_timeline_images = []
timeline_sources.each do |path, data|
  raw_image = data["timeline_image"] || data["cover_image"]
  image_path = raw_image.to_s[/\[\[([^\]]+)\]\]/, 1]
  missing_timeline_images << File.basename(path) if image_path.to_s.empty? || !File.file?(File.join(ROOT, image_path))
  next if image_path.to_s.empty?

  built_image = File.join(PUBLIC, image_path.downcase.tr(" ", "-"))
  expect.call(File.file?(built_image), "Timeline illustration is not copied into the build: #{image_path}")
end
expect.call(timeline_sources.length == 26, "Expected 26 canonical timeline sources")
expect.call(missing_timeline_images.empty?, "Timeline events without a valid image: #{missing_timeline_images.join(', ')}")

country_notes = Dir.glob(File.join(ROOT, "Энциклопедия", "Страны", "*.md")).reject { |path| File.basename(path) == "Культ Меркаты.md" }
missing_country_subtitles = country_notes.reject do |path|
  source = File.read(path)
  match = source.match(/\A---\s*\n(.*?)\n---/m)
  data = match ? YAML.safe_load(match[1], permitted_classes: [], aliases: true) || {} : {}
  !data["card_subtitle"].to_s.strip.empty?
end
expect.call(country_notes.length >= 16, "Expected all canonical countries in the subtitle audit")
expect.call(missing_country_subtitles.empty?, "Countries without card_subtitle: #{missing_country_subtitles.map { |path| File.basename(path) }.join(', ')}")

map = read.call("map.html")
%w[states.png heightmap.png biomes.png].each do |filename|
  expect.call(map.include?("assets/maps/#{filename}"), "Map does not use original layer #{filename}")
  source = File.join(ROOT, "Assets", "Maps", filename)
  built = File.join(PUBLIC, "assets", "maps", filename)
  expect.call(File.file?(built), "Built map layer is missing: #{filename}")
  expect.call(File.size(source) == File.size(built), "Built map layer differs from original: #{filename}") if File.file?(built)
end

mercate_source = File.read(File.join(CONTENT, "gods", "mercate.md"))
expect.call(!mercate_source.match?(/^- Луна\n\n- Ворон/m), "Mercate symbol list still contains oversized blank gaps")

unless failures.empty?
  warn "Quartz content QA failed (#{failures.length}/#{checks}):"
  failures.each { |failure| warn "  - #{failure}" }
  exit 1
end

puts "Quartz content QA passed: #{checks} checks across #{categories.length} categories."
