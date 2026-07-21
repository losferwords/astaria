#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "cgi"
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

parse_frontmatter = lambda do |path|
  source = File.read(path)
  match = source.match(/\A---\s*\n(.*?)\n---/m)
  data = match ? YAML.safe_load(match[1], permitted_classes: [], aliases: true) || {} : {}
  [data, source]
end

category_routes = {
  "Бестиарий" => "bestiary",
  "Боги" => "gods",
  "Знания" => "lore",
  "Имитеи" => "imitei",
  "Литература" => "literature",
  "Места" => "places",
  "Народы" => "peoples",
  "Организации" => "organizations",
  "Персонажи" => "characters",
  "Предметы" => "items",
  "События" => "events",
  "Страны" => "countries",
  "Флора" => "flora"
}

meta_country_order = [
  "Гилас", "Громовые Кланы", "Иомар", "Катахтонос",
  "Империя Ланг-Ан", "Лунаар", "Амон-Астат", "Кадир",
  "Талассия", "Хамоа", "Дикоземье", "Вактар-Йорден",
  "Сурадж Ка Гхар", "Вакумара", "Амато", "Обитель"
]
meta_people_order = [
  "Эллийцы", "Гойдаир", "Надаир", "Хтониды", "Джу", "Лудаир",
  "Хефат", "Кадийцы", "Талассийцы", "Манаи", "Авгарцы", "Вактары",
  "Раджати", "Ваку", "Эдзо", "Венды"
]
meta_imitei_order = [
  "Идеал", "Горец", "Друид", "Оракул", "Аватар", "Тень",
  "Светоносный", "Мститель", "Наварх", "Хранитель", "Варвар",
  "Вознесённый", "Жнец", "Шаман", "Онмёдзи", "Страж"
]
meta_god_order = [
  "Гиперион I", "Тарун", "Церунна", "Тиресий", "Дракон Ланг-Ан",
  "Мерката", "Аст", "Альзаман", "Калипсо", "Икатерра", "Хангор",
  "Винтра", "Шубханкари", "Руфу", "Ицунэ", "Велисса"
]
card_titles = lambda do |html|
  html.scan(/<h3>([^<]+)<\/h3>/).flatten.map { |title| CGI.unescapeHTML(title) }
end

ready_article_notes = Dir.glob(File.join(ROOT, "Энциклопедия", "**", "*.md")).sort.map do |path|
  next if path.include?(File.join("Энциклопедия", "Секреты"))

  data, source = parse_frontmatter.call(path)
  next unless data["ready"] == true

  { path: path, data: data, source: source }
end.compact
expect.call(ready_article_notes.length >= 301, "Expected the complete ready encyclopedia corpus")
intentionally_unpublished_titles = ["Бордель Уй-Джан", "Город Награкшаса", "Тхаги"]
unpublished_ready_notes = ready_article_notes.reject { |note| note[:data]["quartz"] == true }
expect.call(
  unpublished_ready_notes.map { |note| note[:data]["title"] }.sort == intentionally_unpublished_titles.sort,
  "Unexpected ready articles excluded from Quartz: #{unpublished_ready_notes.map { |note| note[:data]["title"] }.join(', ')}"
)
published_ready_notes = ready_article_notes.select { |note| note[:data]["quartz"] == true }

expected_by_category = published_ready_notes.group_by { |note| note[:data]["category"] }.transform_values(&:length)
categories = category_routes.to_h { |category, route| [route, expected_by_category.fetch(category, 0)] }

categories.each do |route, expected|
  html = read.call("#{route}/index.html")
  cards = html.scan(/class="[^"]*astaria-category-card(?:\s|\")/).length
  expect.call(cards == expected, "#{route}: expected #{expected} ready article cards, found #{cards}")
  expect.call(html.include?("astaria-category-header"), "#{route}: category header is missing")
  expect.call(!html.match?(/<pre><code>.*?&lt;(?:article|div|h3|p|span)(?:\s|&gt;)/m), "#{route}: generated card HTML is rendered as visible source code")
  expect.call(!html.include?("Энциклопедия ·"), "#{route}: redundant article count is still shown in the category header")
  unless expected.zero?
    expect.call(html.include?("astaria-category-tools"), "#{route}: large catalog has no local search toolbar")
    expect.call(html.include?("astaria-category-search"), "#{route}: local category search input is missing")
    expect.call(html.scan("data-search=").length == expected, "#{route}: not every card can be found with the local filter")
    ranks = html.scan(/data-meta-rank="(-?\d+)"/).flatten.map(&:to_i)
    expect.call(ranks.length == expected, "#{route}: not every card has a canonical meta rank")
    expect.call(ranks == ranks.sort, "#{route}: cards are not sorted by canonical meta order")
  end
end

representatives = {
  "countries/gilas.html" => %w[astaria-cover-image astaria-sidebar astaria-crest-image],
  "gods/mercate.html" => %w[astaria-sidebar-image astaria-infobox],
  "characters/persephone.html" => %w[astaria-sidebar-image astaria-article-footer],
  "places/khalisat-desert.html" => %w[astaria-cover-image astaria-content-title],
  "peoples/ellians.html" => %w[astaria-cover-image astaria-content-title],
  "characters/nisa-nereid.html" => %w[astaria-sidebar-image astaria-content-title],
  "flora/larudan-tree.html" => %w[astaria-cover-image astaria-content-title]
}

representatives.each do |relative, selectors|
  html = read.call(relative)
  selectors.each do |selector|
    expect.call(html.include?(selector), "#{relative}: expected #{selector}")
  end
  expect.call(html.scan(/<h1(?:\s|>)/).length == 1, "#{relative}: expected exactly one H1")
end

countries = read.call("countries/index.html")
country_titles = card_titles.call(countries)
expected_country_titles = meta_country_order.select { |title| country_titles.include?(title) }
expect.call(country_titles == expected_country_titles, "Countries are not in canonical meta order: #{country_titles.join(', ')}")
expect.call(countries.scan("astaria-category-card-crest").length >= 5, "Country cards must show their crests")
expect.call(!countries.include?("Государство Астарии"), "Country cards still use the generic subtitle")
["Республика героев", "Союз вольных кланов", "Друидский матриархат", "Приют хтонидов", "Морская держава"].each do |subtitle|
  expect.call(countries.include?(subtitle), "Country cards are missing the distinctive subtitle: #{subtitle}")
end

characters = read.call("characters/index.html")
character_groups = meta_country_order.map { |title| characters.index(">#{title} <span aria-hidden=\"true\">↗</span></a></h2>") }.compact
expect.call(character_groups == character_groups.sort, "Character groups are not in canonical country order")
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

peoples = read.call("peoples/index.html")
people_titles = card_titles.call(peoples)
expected_people_titles = meta_people_order.select { |title| people_titles.include?(title) } + (people_titles - meta_people_order).sort
expect.call(people_titles == expected_people_titles, "Peoples are not in canonical meta order: #{people_titles.join(', ')}")

imitei = read.call("imitei/index.html")
imitei_titles = card_titles.call(imitei)
expected_imitei_titles = meta_imitei_order.select { |title| imitei_titles.include?(title) } + (imitei_titles - meta_imitei_order).sort
expect.call(imitei_titles == expected_imitei_titles, "Imitei are not in canonical meta order: #{imitei_titles.join(', ')}")

gods = read.call("gods/index.html")
god_titles = card_titles.call(gods)
expected_god_titles = meta_god_order.select { |title| god_titles.include?(title) } + (god_titles - meta_god_order).sort
expect.call(god_titles == expected_god_titles, "Gods are not in canonical meta order: #{god_titles.join(', ')}")
god_article_paths = Dir.glob(File.join(CONTENT, "gods", "*.md")).reject { |path| File.basename(path) == "index.md" }
expect.call(god_article_paths.length == god_titles.length, "Not every published god has a generated article")
god_article_paths.each do |path|
  relative = "gods/#{File.basename(path, '.md')}.html"
  html = read.call(relative)
  expect.call(html.include?("<dt>Сферы влияния</dt>"), "#{relative}: influence spheres are missing from the infobox")
  expect.call(html.include?("<dt>Священные символы</dt>"), "#{relative}: sacred symbols are missing from the infobox")
  expect.call(!html.match?(/<h[2-6][^>]*>\s*(?:Божественные домены|Священные символы)\s*<\/h[2-6]>/), "#{relative}: god metadata is duplicated in the article body")
end

imitei_article = File.read(File.join(ROOT, "Энциклопедия", "Знания", "Имитей.md"))
known_imitei_section = imitei_article.split("## Известные Имитеи:", 2).last.to_s
imitei_article_positions = meta_imitei_order.map { |title| known_imitei_section.index("[[#{title}") }.compact
expect.call(imitei_article_positions == imitei_article_positions.sort, "Known Imitei list is not in canonical meta order")

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
{
  "places/" => "Места",
  "countries/" => "Страны",
  "peoples/" => "Народы",
  "characters/" => "Персонажи",
  "gods/" => "Боги",
  "bestiary/" => "Бестиарий",
  "imitei/" => "Имитеи",
  "organizations/" => "Организации",
  "lore/" => "Знания",
  "items/" => "Предметы",
  "events/" => "События",
  "literature/" => "Литература",
  "flora/" => "Флора"
}.each do |href, label|
  expect.call(home.match?(%r{<a href="\./#{Regexp.escape(href)}"[^>]*>#{Regexp.escape(label)}</a>}), "Home directory is missing #{label} (#{href})")
end
expect.call(journey_styles.match?(/\.astaria-home-portals\s*\{[^}]*align-items:\s*stretch/m), "Main portal cards must be equal-height")
expect.call(journey_styles.match?(/\.markdown-rendered \.astaria-portal-hit[^\{]*\{[^}]*height:\s*100%/m), "Visual portal links must fill equal-height cards")
expect.call(journey_styles.match?(/\.astaria-home-era span\s*\{[^}]*lining-nums tabular-nums/m), "Home era number must use aligned lining numerals")
expect.call(home.scan("data-discovery-candidates=").length == 5, "Home discovery block must contain five randomized thematic doors")
expect.call(home.include?("astaria-discovery-shuffle"), "Home discovery block has no shuffle control")
discovery_pools = home.scan(/data-discovery-candidates="([^"]+)"/).flatten.map do |payload|
  JSON.parse(CGI.unescapeHTML(payload))
end
expect.call(discovery_pools.length == 5 && discovery_pools.all? { |pool| pool.length > 1 }, "Every discovery door must have more than one candidate")
expect.call(discovery_pools.map { |pool| pool.first["label"] } == ["Государство", "Божество", "Личность", "Место", "Бестиарий"], "Discovery doors lost their category balance")
discovery_pools.flatten.each do |candidate|
  expect.call(File.file?(File.join(PUBLIC, "#{candidate["href"]}.html")), "Discovery candidate has no public page: #{candidate["href"]}")
  image_path = candidate["image"].sub(%r{\A\.?/}, "")
  expect.call(File.file?(File.join(PUBLIC, image_path)), "Discovery candidate has no public image: #{candidate["image"]}")
end
experience_script = File.read(File.join(ROOT, "_quartz", "quartz", "components", "scripts", "astaria.inline.ts"))
expect.call(experience_script.include?("setupAstariaDiscovery"), "Home discovery randomization is not initialized")

wind_of_change = read.call("literature/wind-of-change-saga.html")
expect.call(wind_of_change.include?("astaria-saga-chapters"), "Wind of Change has no designed chapter section")
expect.call(wind_of_change.include?("astaria-saga-empty"), "Wind of Change needs a graceful state while chapters are unpublished")
expect.call(wind_of_change.scan("astaria-saga-chapters-title").length >= 1, "Wind of Change chapter heading is missing")
expect.call(!wind_of_change.include?("<h2 id=\"главы\">Главы</h2>"), "Wind of Change still renders the old empty chapter heading")
expect.call(journey_styles.include?(".astaria-coverless-hero"), "Articles without a cover have no visual hero template")
expect.call(journey_styles.include?(".astaria-saga-chapter-card"), "Coverless saga chapters have no card template")
generator_source = File.read(File.join(ROOT, "_scripts", "sync_quartz_content.rb"))
expect.call(generator_source.include?("build_coverless_title"), "Quartz generator does not apply the coverless article template")

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
{
  "gods/itsune" => "イツネ",
  "gods/lang-an-dragon" => "龍安"
}.each do |route, native_name|
  html = read.call("#{route}.html")
  expect.call(html.include?("<dt>Имя на родном языке</dt>"), "#{route}: native-name label is missing from the infobox")
  expect.call(html.include?(native_name), "#{route}: native name #{native_name} is missing")
  expect.call(content_index.dig(route, "content")&.include?(native_name), "Search index must include #{native_name}")
end

halyk_byndir = read.call("places/halyk-byndir.html")
expect.call(halyk_byndir.match?(/<dt>Тип места<\/dt><dd>\s*Бордель\s*<\/dd>/), "Halyk-Byndir must use the Russian place type")
dragon_temple = read.call("places/dragon-temple.html")
expect.call(dragon_temple.match?(/<dt>Тип места<\/dt><dd>\s*Храмовый комплекс\s*<\/dd>/), "Dragon Temple must use the Russian place type")
["Страна", "Часть территории", "Основание"].each do |label|
  expect.call(dragon_temple.include?("<dt>#{label}</dt>"), "Dragon Temple infobox is missing #{label}")
end
expect.call(!dragon_temple.include?("Структурные связи"), "Dragon Temple still duplicates structural metadata in its body")
published_titles = content_index.values.map { |entry| entry["title"].to_s }
published_ready_notes.each do |note|
  title = note[:data]["title"].to_s
  expect.call(published_titles.include?(title), "Ready article is missing from the public search index: #{title}")
end
intentionally_unpublished_titles.each do |title|
  expect.call(!published_titles.include?(title), "Intentionally unpublished article leaked into search: #{title}")
end
generated_article_count = category_routes.values.sum do |route|
  Dir.glob(File.join(CONTENT, route, "*.md")).count { |path| File.basename(path) != "index.md" }
end
expect.call(generated_article_count == published_ready_notes.length, "Generated article count does not match the public ready encyclopedia corpus")
generated_article_paths = category_routes.values.flat_map do |route|
  Dir.glob(File.join(CONTENT, route, "*.md")).reject { |path| File.basename(path) == "index.md" }
end
duplicate_route_basenames = generated_article_paths.group_by { |path| File.basename(path, ".md") }
  .select { |_basename, paths| paths.length > 1 }
expect.call(duplicate_route_basenames.empty?, "Article slugs are ambiguous across categories: #{duplicate_route_basenames.keys.join(', ')}")

generated_article_paths.each do |path|
  relative = path.delete_prefix("#{CONTENT}/").sub(/\.md\z/, ".html")
  html = read.call(relative)
  expect.call(html.scan(/<h1(?:\s|>)/).length == 1, "#{relative}: expected exactly one H1")
  expect.call(!html.match?(/<pre><code>.*?&lt;(?:article|div|h[1-6]|p|span|a)(?:\s|&gt;)/m), "#{relative}: raw HTML is rendered as visible source code")
  expect.call(!html.include?("[["), "#{relative}: unresolved Obsidian link is visible")
  expect.call(!html.include?("FATE / GM") && !html.include?("Механика требует ручной вычитки"), "#{relative}: private campaign material leaked into the article")
  expect.call(html.match?(/<title>.+?<\/title>/m), "#{relative}: page title is missing")
  expect.call(html.match?(/<meta name="description" content="[^"]+"/), "#{relative}: meta description is missing")
end

missing_image_notes = []
ready_article_notes.each do |note|
  data = note[:data]
  values = data.select do |key, value|
    key.to_s.match?(/(?:portrait|cover|crest|flag|timeline)_image/) && !value.to_s.strip.empty?
  end.values
  values.concat(note[:source].scan(/!\[\[([^\]]+\.(?:png|jpe?g|webp|gif|svg))(?:\|[^\]]+)?\]\]/i).flatten.map { |path| "[[#{path}]]" })
  image_paths = values.map { |value| value.to_s[/\[\[([^|\]#]+)/, 1] }.compact.uniq
  valid_images = image_paths.select { |path| File.file?(File.join(ROOT, path)) }
  missing_files = image_paths - valid_images
  expect.call(missing_files.empty?, "Ready article references missing image files: #{note[:data]["title"]} — #{missing_files.join(', ')}")
  valid_images.each do |path|
    next unless note[:data]["quartz"] == true

    built_path = File.join(PUBLIC, path.downcase.tr(" ", "-"))
    expect.call(File.file?(built_path), "Ready article image is absent from the build: #{path}")
  end
  missing_image_notes << note if valid_images.empty?
end

missing_image_report = File.join(ROOT, "_quartz", "MISSING_IMAGES.md")
expect.call(File.file?(missing_image_report), "Missing-image publication report was not created")
if File.file?(missing_image_report)
  report_source = File.read(missing_image_report)
  missing_image_notes.each do |note|
    expect.call(report_source.include?(note[:data]["title"].to_s), "Missing-image report omits #{note[:data]["title"]}")
  end
  report_rows = report_source.lines.count { |line| line.match?(/^\| (?:Места|Знания|Организации|Литература) \|/) }
  expect.call(report_rows == missing_image_notes.length, "Missing-image report is stale: expected #{missing_image_notes.length} entries, found #{report_rows}")
end
expect.call(
  missing_image_notes.map { |note| note[:data]["title"] }.sort == intentionally_unpublished_titles.sort,
  "Unexpected ready articles without illustrations: #{missing_image_notes.map { |note| note[:data]["title"] }.join(', ')}"
)

expect.call(!File.exist?(File.join(ROOT, "Энциклопедия", "Знания", "Путь Клинка.md")), "Retired Path of the Blade article still exists")
expect.call(!published_titles.include?("Путь Клинка"), "Retired Path of the Blade article remains in search")
expect.call(!File.exist?(File.join(PUBLIC, "lore", "put-klinka.html")), "Retired Path of the Blade public route still exists")
avenger_source = File.read(File.join(ROOT, "Энциклопедия", "Имитеи", "Мститель.md"))
expect.call(avenger_source.include?("## Путь Клинка"), "Path of the Blade lore was not merged into Avenger")
expect.call(avenger_source.include?("650 году ХЭ"), "Avenger article lost the founding date of the Path of the Blade")
expect.call(!avenger_source.include?("[[Путь Клинка"), "Avenger article still links to the retired Path of the Blade note")
expect.call(read.call("lore/imitey.html").include?("assets/images/imithei.jpg"), "Imitei article does not use its new cover")
expect.call(read.call("literature/poka-bogi-spyat.html").include?("assets/images/eye_of_calypso.jpg"), "Poka Bogi Spyat does not reuse the Eye of Calypso cover")

index_payload = content_index.values.map { |entry| [entry["title"], entry["content"]].join(" ") }.join("\n")
expect.call(!index_payload.include?("FATE / GM"), "Private FATE blocks leaked into public search")
expect.call(!index_payload.include?("Механика требует ручной вычитки"), "Private FATE notes leaked into public search")

secret_notes = Dir.glob(File.join(ROOT, "Энциклопедия", "Секреты", "*.md")).sort
expect.call(secret_notes.length >= 27, "Expected the fully audited private Secrets corpus")
secret_notes.each do |path|
  source = File.read(path)
  match = source.match(/\A---\s*\n(.*?)\n---/m)
  data = match ? YAML.safe_load(match[1], permitted_classes: [], aliases: true) || {} : {}
  expect.call(data["quartz"] == false, "Secret note can be published by Quartz: #{File.basename(path)}")
  expect.call(data["secret"] == true, "Secret note lacks secret: true: #{File.basename(path)}")
  expect.call(data["private"] == true, "Secret note lacks private: true: #{File.basename(path)}")
end
conflict_report = File.join(ROOT, "Энциклопедия", "Секреты", "Противоречия и вопросы канона.md")
expect.call(File.file?(conflict_report), "Private canon-conflict report is missing")
if File.file?(conflict_report)
  conflict_source = File.read(conflict_report)
  expect.call(conflict_source.include?("# Противоречия и вопросы канона"), "Canon-conflict report has no structured title")
  expect.call(conflict_source.include?("## Разрешено автором"), "Canon-conflict report does not separate resolved decisions")
  expect.call(conflict_source.include?("обнаружение и освобождение — два разных события"), "Vintre chronology decision is not recorded")
  expect.call(conflict_source.include?("Аксель Хана убил Муспельхег"), "Aksel Khan's killer decision is not recorded")
  expect.call(conflict_source.include?("только внешность Сао"), "Sao Wu's apparent-age decision is not recorded")
end
dragon_legacy = File.join(ROOT, "Энциклопедия", "Секреты", "Наследие драконов.md")
dragon_legacy_source = File.read(dragon_legacy)
expect.call(dragon_legacy_source.scan(/^- \*\*-?\d+ год (?:ХЭ|НЭ)\./).length == 81, "Dragon legacy chronology lost or duplicated events")
expect.call(dragon_legacy_source.include?("**-1637 год ХЭ.** Экспедиция друидов обнаруживает тело Винтры"), "Vintre's body discovery must be dated -1637 ХЭ")
expect.call(dragon_legacy_source.include?("**-1635 год ХЭ.** Друиды извлекают Винтру из ледяного плена"), "Vintre's recovery must be dated -1635 ХЭ")
expect.call(!dragon_legacy_source.include?("Муспельхегг"), "Muspelheg's name still has the obsolete double-g spelling")
vaktar_foundation_source = File.read(File.join(ROOT, "Хронология", "События", "Основание Вактар-Йордена.md"))
expect.call(vaktar_foundation_source.include?("Через два года после обнаружения тела [[Винтра|Винтры]]"), "Vaktar-Yorden foundation event contradicts Vintre's -1637 discovery")
aksel_secret = File.read(File.join(ROOT, "Энциклопедия", "Секреты", "Тайны Аксель Хана и Ишиды Рецу.md"))
expect.call(aksel_secret.include?("его хранитель — [[Муспельхег]]"), "Aksel Khan secret does not name Muspelheg as the attacker")
expect.call(!aksel_secret.include?("драконья самка"), "Aksel Khan secret still names a female dragon as the attacker")
sao_source = File.read(File.join(ROOT, "Энциклопедия", "Персонажи", "Сао Ву.md"))
expect.call(sao_source.include?("С виду Сао около семи лет"), "Sao Wu's apparent age is not stated clearly")
expect.call(sao_source.include?("внешность не отражает календарного возраста"), "Sao Wu's apparent age is still presented as chronological")
expect.call(!index_payload.include?("Противоречия и вопросы канона"), "Private canon-conflict report leaked into search")
expect.call(!index_payload.include?("Ванпур — заметки для ведущего"), "Private Vanpur GM note leaked into search")

nisa = read.call("characters/nisa-nereid.html")
expect.call(!nisa.include?("<dt>Значимость</dt>"), "Non-event character Nisa must not display event significance")

vanpur = read.call("places/vanpur.html")
%w[Урист Мусака Гилья].each do |campaign_name|
  expect.call(!vanpur.include?(campaign_name), "Public Vanpur article leaks campaign-specific material: #{campaign_name}")
end
expect.call(!vanpur.include?("Для героев"), "Public Vanpur article still contains a campaign hook section")
expect.call(!vanpur.include?("Лето 106 года НЭ"), "Public Vanpur article still contains the current campaign state")
expect.call(!File.exist?(File.join(CONTENT, "secrets")), "Private Secrets directory was copied into Quartz content")

render_page_source = File.read(File.join(ROOT, "_quartz", "quartz", "components", "renderPage.tsx"))
expect.call(render_page_source.include?("componentData.ctx.argv.serve || !cfg.baseUrl"), "Local preview must not add the production /astaria prefix to search results")

native_name_notes = []
missing_native_names = []
visible_metadata_fields = %w[
  location_type organization_type item_type condition_type profession_type
  medium species government course rarity habitat
]
english_visible_metadata = []
structural_body_notes = []
legacy_founded_notes = []
Dir.glob(File.join(ROOT, "Энциклопедия", "**", "*.md")).sort.each do |path|
  next if path.include?(File.join("Энциклопедия", "Секреты"))

  source = File.read(path)
  match = source.match(/\A---\s*\n(.*?)\n---/m)
  next unless match

  data = YAML.safe_load(match[1], permitted_classes: [], aliases: true) || {}
  visible_metadata_fields.each do |field|
    values = Array(data[field]).map(&:to_s)
    english_visible_metadata << "#{File.basename(path)}: #{field}=#{values.join(', ')}" if values.any? { |value| value.match?(/[A-Za-z]/) }
  end
  structural_body_notes << path if source.include?("## Структурные связи")
  legacy_founded_notes << path if data.key?("founded")
  cjk_aliases = Array(data["aliases"]).flat_map { |value| value.to_s.split(/\s*,\s*/) }.select { |value| value.match?(/[一-龯ぁ-んァ-ン]/) }
  next if cjk_aliases.empty?

  native_name_notes << path
  missing_native_names << path if data["native_name"].to_s.strip.empty?
end
expect.call(native_name_notes.length >= 120, "Expected the recovered native-name corpus for Lang-An, Amato, Meilong and Onmyoji")
expect.call(missing_native_names.empty?, "CJK aliases without native_name: #{missing_native_names.map { |path| File.basename(path) }.join(', ')}")
expect.call(english_visible_metadata.empty?, "English values remain in public-facing metadata: #{english_visible_metadata.join('; ')}")
expect.call(structural_body_notes.empty?, "Structural metadata is duplicated in article bodies: #{structural_body_notes.map { |path| File.basename(path) }.join(', ')}")
expect.call(legacy_founded_notes.empty?, "Legacy founded fields are not rendered by the infobox: #{legacy_founded_notes.map { |path| File.basename(path) }.join(', ')}")
uy_dzhan_data, = parse_frontmatter.call(File.join(ROOT, "Энциклопедия", "Места", "Бордель Уй-Джан.md"))
expect.call(uy_dzhan_data["location_type"] == "Бордель", "Unpublished Uy-Dzhan must retain the Russian place type")

timeline = read.call("timeline/index.html")
expect.call(timeline.scan("astaria-timeline-event").length == 26, "Timeline must contain all 26 events")
expect.call(timeline.include?("astaria-timeline-search"), "Timeline search is missing")
expect.call(timeline.include?("astaria-timeline-category"), "Timeline category filter is missing")
expect.call(!timeline.include?("[!timeline]"), "Timeline exposes raw Obsidian callout markup")
expect.call(!timeline.match?(/<pre><code>.*?&lt;(?:article|div|h3|p|span)(?:\s|&gt;)/m), "Timeline event HTML is rendered as visible source code")
expect.call(timeline.scan(/<article class="astaria-timeline-card[^"]*">\s*<img/m).length == 26, "Every timeline event must have an illustration")
expect.call(timeline.scan("astaria-timeline-meta").length == 26, "Every timeline event must show a readable significance label")
expect.call(journey_styles.match?(/\.astaria-timeline-year\s*\{[^}]*padding-right:\s*0\.85rem/m), "Timeline date needs breathing room before the rail")
expect.call(journey_styles.match?(/\.astaria-timeline-year::after\s*\{[^}]*0 0 0 4px/m), "Timeline node needs a paper halo separating it from the rail")
expect.call(journey_styles.match?(/\.astaria-timeline-year\s*\{[^}]*lining-nums tabular-nums/m), "Timeline dates must use aligned lining numerals")
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
expect.call(map.scan("astaria-map-marker astaria-map-marker-").length == 132, "Map must render all 132 canonical markers")
%w[states.png heightmap.png biomes.png].each do |filename|
  expect.call(map.include?("assets/maps/#{filename}"), "Map does not use original layer #{filename}")
  source = File.join(ROOT, "Assets", "Maps", filename)
  built = File.join(PUBLIC, "assets", "maps", filename)
  expect.call(File.file?(built), "Built map layer is missing: #{filename}")
  expect.call(File.size(source) == File.size(built), "Built map layer differs from original: #{filename}") if File.file?(built)
end

marker_top = lambda do |name|
  match = map.match(/class="astaria-map-marker[^"]*"[^>]*data-name="#{Regexp.escape(name)}"[^>]*data-y="([\d.]+)"/)
  expect.call(!match.nil?, "Map marker is missing: #{name}")
  match && match[1].to_f
end
bakhara_top = marker_top.call("Город Бахара")
anderhan_top = marker_top.call("Город Андерхан")
expect.call(bakhara_top && anderhan_top && bakhara_top > anderhan_top, "Map Y axis is inverted: Bakhara must appear south of Anderhan")

mercate_source = File.read(File.join(CONTENT, "gods", "mercate.md"))
expect.call(!mercate_source.match?(/^- Луна\n\n- Ворон/m), "Mercate symbol list still contains oversized blank gaps")

unless failures.empty?
  warn "Quartz content QA failed (#{failures.length}/#{checks}):"
  failures.each { |failure| warn "  - #{failure}" }
  exit 1
end

puts "Quartz content QA passed: #{checks} checks across #{categories.length} categories."
