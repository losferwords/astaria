#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "date"
require "fileutils"
require "yaml"

ROOT = File.expand_path("..", __dir__)
DEST = File.join(ROOT, "_quartz", "content")

PUBLIC_ROOTS = [
  "Энциклопедия",
  "Хронология",
  "Карты"
].freeze

PRIVATE_PATH_PREFIXES = [
  File.join(ROOT, "Энциклопедия", "Секреты")
].freeze

CATEGORY_ROUTES = {
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
  "Страны" => "countries"
}.freeze

ASSET_REWRITES = {
  "Assets/Maps/states.png" => "Assets/Maps/Web/states-web.jpg",
  "Assets/Maps/heightmap.png" => "Assets/Maps/Web/heightmap-web.jpg",
  "Assets/Maps/biomes.png" => "Assets/Maps/Web/biomes-web.jpg"
}.freeze

INFOBOX_FIELDS = [
  ["religions", "Религии"],
  ["current_location", "Текущее местоположение"],
  ["foundation", "Основание"],
  ["capital", "Столица"],
  ["ruler", "Глава"],
  ["deities", "Божества"],
  ["origin", "Происхождение"],
  ["ethnicity", "Народ"],
  ["profession", "Род занятий"],
  ["birth_year", "Год рождения"],
  ["church", "Вера/культ"],
  ["government", "Форма правления"],
  ["population", "Население"],
  ["related_professions", "Связанные профессии"],
  ["controlled_territories", "Контролируемые территории"],
  ["known_members", "Известные участники"],
  ["related_ethnicities", "Связанные народы"],
  ["eyes", "Глаза"],
  ["hair", "Волосы"],
  ["skin", "Кожа"],
  ["height", "Рост"],
  ["weight", "Вес"],
  ["aligned_organization", "Согласованная организация"],
  ["related", "Связи"]
].freeze

TRANSLITERATION = {
  "а" => "a", "б" => "b", "в" => "v", "г" => "g", "д" => "d",
  "е" => "e", "ё" => "yo", "ж" => "zh", "з" => "z", "и" => "i",
  "й" => "y", "к" => "k", "л" => "l", "м" => "m", "н" => "n",
  "о" => "o", "п" => "p", "р" => "r", "с" => "s", "т" => "t",
  "у" => "u", "ф" => "f", "х" => "kh", "ц" => "ts", "ч" => "ch",
  "ш" => "sh", "щ" => "shch", "ъ" => "", "ы" => "y", "ь" => "",
  "э" => "e", "ю" => "yu", "я" => "ya"
}.freeze

def frontmatter_for(path)
  text = File.read(path)
  return [{}, text] unless text.start_with?("---\n")

  _before, yaml_text, body = text.split(/^---\s*$/, 3)
  data = YAML.safe_load(
    yaml_text || "",
    permitted_classes: [Date, Time],
    aliases: true
  ) || {}
  [data, body || ""]
rescue Psych::SyntaxError => error
  warn "Skipping #{path}: invalid YAML (#{error.message})"
  [{}, text]
end

def publishable_markdown?(path)
  return false if PRIVATE_PATH_PREFIXES.any? { |prefix| path.start_with?("#{prefix}/") }

  data, = frontmatter_for(path)
  data["publish"] == true && data["draft"] != true
end

def extract_asset_path(value)
  value.to_s[/\[\[([^|\]#]+)(?:[|\]#])?/, 1]
end

def slugify(value)
  transliterated = value.to_s.downcase.each_char.map do |char|
    TRANSLITERATION.fetch(char, char)
  end.join

  transliterated
    .gsub(/[^a-z0-9]+/, "-")
    .gsub(/\A-+|-+\z/, "")
end

def image_slug(data)
  raw = data["portrait_image"] || data["cover_image"] || data["flag_image"]
  path = extract_asset_path(raw)
  return nil unless path

  base = File.basename(path, File.extname(path))
  base = base.sub(/_(landscape|male|female|m|f)\z/i, "")
  slugify(base)
end

def source_category(path)
  encyclopedia = File.join(ROOT, "Энциклопедия")
  return nil unless path.start_with?("#{encyclopedia}/")

  relative = path.delete_prefix("#{encyclopedia}/")
  parts = relative.split("/")
  parts.length > 1 ? parts.first : nil
end

def article_slug(data)
  explicit = data["public_slug"].to_s.strip
  return slugify(explicit) unless explicit.empty?

  image_slug(data) || slugify(data["title"])
end

def public_route(source, data)
  explicit = data["public_slug"].to_s.strip
  return "index" if explicit == "index" || data["title"] == "Астария"
  return "map" if source.start_with?(File.join(ROOT, "Карты")) || data["type"] == "map"

  if source.start_with?(File.join(ROOT, "Хронология"))
    return "timeline" if data["type"] == "timeline" || explicit == "timeline"
    return "timeline/#{article_slug(data)}"
  end

  category = source_category(source)
  category_route = CATEGORY_ROUTES.fetch(category, slugify(category || "articles"))
  "#{category_route}/#{article_slug(data)}"
end

def target_path(route)
  File.join(DEST, "#{route}.md")
end

def display_value(value)
  case value
  when Array
    value.map { |item| display_value(item) }.reject(&:empty?).join(", ")
  else
    value.to_s
      .gsub(/\[\[([^|\]]+)\|([^\]]+)\]\]/, '\\2')
      .gsub(/\[\[([^\]]+)\]\]/, '\\1')
      .strip
  end
end

def render_inline_value(value)
  raw = value.to_s
  return "" if raw.strip.empty?

  rendered = +""
  index = 0
  raw.to_enum(:scan, /\[\[([^|\]]+)(?:\|([^\]]+))?\]\]/).each do
    match = Regexp.last_match
    rendered << CGI.escapeHTML(raw[index...match.begin(0)].to_s)
    label = match[2] || match[1]
    rendered << %(<span class="astaria-infobox-reference">#{CGI.escapeHTML(label)}</span>)
    index = match.end(0)
  end
  rendered << CGI.escapeHTML(raw[index..].to_s)
  rendered.strip
end

def render_value(value)
  case value
  when Array
    items = value.map { |item| render_value(item) }.reject(&:empty?)
    return "" if items.empty?
    return items.join(", ") if items.length <= 3

    list_items = items.map { |item| "<li>#{item}</li>" }.join
    %(<ul class="astaria-infobox-list">#{list_items}</ul>)
  else
    render_inline_value(value)
  end
end

def public_asset_url(asset_path)
  asset_path.split("/").map { |part| part.downcase.tr(" ", "-") }.join("/")
end

def render_image_tag(asset_path, css_class)
  url = public_asset_url(asset_path)
  alt = File.basename(asset_path, File.extname(asset_path)).tr("_-", " ")
  %(<img class="#{css_class}" src="#{CGI.escapeHTML(url)}" alt="#{CGI.escapeHTML(alt)}">)
end

def render_asset_embeds(body)
  body.gsub(/!\[\[([^|\]#]+)(?:[|#][^\]]*)?\]\]/) do |match|
    raw_path = Regexp.last_match(1).strip
    unless raw_path.start_with?("Assets/Images/") || raw_path.start_with?("Assets/Maps/")
      next match
    end

    asset_path = ASSET_REWRITES.fetch(raw_path, raw_path)
    render_image_tag(asset_path, "astaria-inline-image")
  end
end

def sidebar_image(data)
  return nil if data["public_slug"].to_s.strip == "index"

  raw = data["portrait_image"] || data["flag_image"] || data["crest_image"]
  path = extract_asset_path(raw)
  path && ASSET_REWRITES.fetch(path, path)
end

def cover_image(data)
  raw = data["cover_image"]
  path = extract_asset_path(raw)
  return nil unless path

  path = ASSET_REWRITES.fetch(path, path)
  path == sidebar_image(data) ? nil : path
end

def build_cover(data)
  image_path = cover_image(data)
  return "" unless image_path

  "#{render_image_tag(image_path, "astaria-cover-image")}\n"
end

def build_title(data)
  return "" if data["public_slug"].to_s.strip == "index"

  title = CGI.escapeHTML(data["title"].to_s)
  %(<h1 class="astaria-content-title">#{title}</h1>\n)
end

def build_sidebar(data)
  return "" if data["public_slug"].to_s.strip == "index"

  image_path = sidebar_image(data)
  rows = INFOBOX_FIELDS.map do |key, label|
    rendered = render_value(data[key])
    next if rendered.empty?

    %(<div class="astaria-infobox-row"><dt>#{CGI.escapeHTML(label)}</dt><dd>#{rendered}</dd></div>)
  end.compact

  return "" if image_path.nil? && rows.empty?

  image = if image_path
    "#{render_image_tag(image_path, "astaria-sidebar-image")}\n"
  else
    ""
  end

  <<~HTML
    <aside class="astaria-sidebar">
    #{image}
    <div class="astaria-infobox">
    <dl>
    #{rows.join("\n")}
    </dl>
    </div>
    </aside>
  HTML
end

def build_article_footer(route, data)
  return "" if data["public_slug"].to_s.strip == "index"

  category = data["category"].to_s
  category_route = CATEGORY_ROUTES[category]
  category_link = if category_route
    %(<a href="../#{CGI.escapeHTML(category_route)}/">#{CGI.escapeHTML(category)}</a>)
  end

  links = [%(<a href="../">Астария</a>), category_link].compact.join("\n")
  <<~HTML
    <footer class="astaria-article-footer">
    #{links}
    </footer>
  HTML
end

def cleanup_public_body(body, data)
  image_paths = [sidebar_image(data), cover_image(data)].compact

  body = body.gsub(/\r\n?/, "\n")
  body = body.sub(/\A\s*# .+?\n+/, "")
  body = body.gsub(/^## Основной текст\s*\n+/, "")
  body = body.gsub(/^## Связи\s*\n+```dataview\n.*?```\s*/m, "")
  body = body.gsub(/```dataview\n.*?```\s*/m, "")
  body = body.gsub(/^> \[!info\] Домены\s*\n(?:>.*\n?)+/i, "") if data["domains"]

  image_paths.each do |image_path|
    body = body.gsub(/^\s*!\[\[#{Regexp.escape(image_path)}(?:\|[^\]]+)?\]\]\s*\n+/, "")
  end

  body.strip
end

def generated_frontmatter(data)
  aliases = Array(data["aliases"])
  aliases << data["title"] if data["title"]
  data["aliases"] = aliases.compact.map(&:to_s).uniq

  yaml = YAML.dump(data).sub(/\A---\s*\n/, "")
  "---\n#{yaml}---\n"
end

def write_public_article(source, route, data, body)
  destination = target_path(route)
  FileUtils.mkdir_p(File.dirname(destination))

  clean_body = cleanup_public_body(body, data)
  clean_body = render_asset_embeds(clean_body)
  cover = build_cover(data)
  title = build_title(data)
  sidebar = build_sidebar(data)
  footer = build_article_footer(route, data)
  text = "#{generated_frontmatter(data)}\n#{cover}#{title}#{sidebar}#{clean_body}\n#{footer}"
  ASSET_REWRITES.each { |old_path, new_path| text = text.gsub(old_path, new_path) }
  File.write(destination, text)

  {
    source: source,
    path: destination,
    route: route,
    title: data["title"].to_s,
    category: source_category(source)
  }
end

def asset_paths_from_markdown(path)
  text = File.read(path)
  paths = []

  text.scan(/!?\[\[([^\]]*Assets\/(?:Images|Maps)\/[^\]|#]+)(?:[|#][^\]]*)?\]\]/) do |match|
    paths << match.first.strip
  end
  text.scan(/\]\((Assets\/(?:Images|Maps)\/[^)]+)\)/) do |match|
    paths << match.first.strip
  end

  paths.uniq
end

def copy_asset(relative)
  source = File.join(ROOT, relative)
  return unless File.file?(source)

  destination = File.join(DEST, relative)
  FileUtils.mkdir_p(File.dirname(destination))
  FileUtils.cp(source, destination)
end

def card_grid(cards)
  cards.map do |href, title|
    %(<a class="astaria-card" href="#{CGI.escapeHTML(href)}">#{CGI.escapeHTML(title)}</a>)
  end.join("\n")
end

def write_category_indexes(entries)
  entries.group_by { |entry| entry[:category] }.each do |category, category_entries|
    next unless CATEGORY_ROUTES.key?(category)

    route = CATEGORY_ROUTES.fetch(category)
    cards = category_entries.sort_by { |entry| entry[:title] }.map do |entry|
      href = if entry[:route].start_with?("#{route}/")
        entry[:route].delete_prefix("#{route}/")
      elsif entry[:route] == "index"
        "../"
      else
        "../#{entry[:route]}"
      end
      [href, entry[:title]]
    end
    body = <<~MARKDOWN
      ---
      title: #{category}
      publish: true
      aliases:
        - #{category}
      ---

      <div class="astaria-card-grid astaria-category-grid">
      #{card_grid(cards)}
      </div>
    MARKDOWN

    destination = File.join(DEST, route, "index.md")
    FileUtils.mkdir_p(File.dirname(destination))
    File.write(destination, body)
  end
end

def write_index(entries)
  categories = entries.map { |entry| entry[:category] }.compact.uniq
  category_cards = CATEGORY_ROUTES.map do |title, route|
    ["#{route}/", title] if categories.include?(title)
  end.compact

  body = <<~MARKDOWN
    ---
    title: Астария
    publish: true
    aliases:
      - Астария
    ---

    ![[Assets/Images/Avatar on north.jpg]]

    Приветствуем вас в удивительном мире Астарии - мифической вселенной, полной легенд, тайн, загадок, великих героев и приключений.

    <div class="astaria-card-grid astaria-quick-links">
    #{card_grid([["map", "Карта"], ["timeline", "Хронология"]])}
    </div>

    ## Энциклопедия

    <div class="astaria-card-grid astaria-category-grid">
    #{card_grid(category_cards)}
    </div>
  MARKDOWN

  File.write(File.join(DEST, "index.md"), body)
end

FileUtils.rm_rf(DEST)
FileUtils.mkdir_p(DEST)

entries = []
routes = {}

PUBLIC_ROOTS.each do |root|
  Dir.glob(File.join(ROOT, root, "**", "*.md")).sort.each do |source|
    next unless publishable_markdown?(source)

    data, body = frontmatter_for(source)
    route = public_route(source, data)
    if routes.key?(route)
      raise "Duplicate public route #{route.inspect}: #{routes[route]} and #{source}"
    end

    routes[route] = source
    entries << write_public_article(source, route, data, body)
  end
end

write_category_indexes(entries)
write_index(entries) unless entries.any? { |entry| entry[:route] == "index" }

asset_paths = entries.flat_map do |entry|
  asset_paths_from_markdown(entry[:source]) + asset_paths_from_markdown(entry[:path])
end
asset_paths.concat([
  "Assets/Images/Avatar on north.jpg",
  "Assets/Images/bg.jpg"
])
asset_paths.uniq.sort.each { |relative| copy_asset(relative) }

puts "Prepared #{entries.size} published notes in #{DEST}"
puts entries.sort_by { |entry| entry[:route] }.map { |entry| "  /#{entry[:route]} <- #{entry[:title]}" }
