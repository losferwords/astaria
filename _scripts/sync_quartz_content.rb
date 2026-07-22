#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "date"
require "fileutils"
require "json"
require "pathname"
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
}.freeze

COUNTRY_ORDER = [
  "Гилас",
  "Громовые Кланы",
  "Иомар",
  "Катахтонос",
  "Империя Ланг-Ан",
  "Лунаар",
  "Амон-Астат",
  "Кадир",
  "Талассия",
  "Хамоа",
  "Дикоземье",
  "Вактар-Йорден",
  "Сурадж Ка Гхар",
  "Вакумара",
  "Амато",
  "Обитель"
].freeze

COUNTRY_BY_PEOPLE = {
  "Эллийцы" => "Гилас",
  "Гойдаир" => "Громовые Кланы",
  "Надаир" => "Иомар",
  "Хтониды" => "Катахтонос",
  "Джу" => "Империя Ланг-Ан",
  "Лудаир" => "Лунаар",
  "Хефат" => "Амон-Астат",
  "Кадийцы" => "Кадир",
  "Талассийцы" => "Талассия",
  "Манаи" => "Хамоа",
  "Авгарцы" => "Дикоземье",
  "Вактары" => "Вактар-Йорден",
  "Раджати" => "Сурадж Ка Гхар",
  "Ваку" => "Вакумара",
  "Эдзо" => "Амато",
  "Венды" => "Обитель"
}.freeze

PEOPLE_ORDER = [
  "Эллийцы",
  "Гойдаир",
  "Надаир",
  "Хтониды",
  "Джу",
  "Лудаир",
  "Хефат",
  "Кадийцы",
  "Талассийцы",
  "Манаи",
  "Авгарцы",
  "Вактары",
  "Раджати",
  "Ваку",
  "Эдзо",
  "Венды"
].freeze

IMITEI_ORDER = [
  "Идеал",
  "Горец",
  "Друид",
  "Оракул",
  "Аватар",
  "Тень",
  "Светоносный",
  "Мститель",
  "Наварх",
  "Хранитель",
  "Варвар",
  "Вознесённый",
  "Жнец",
  "Шаман",
  "Онмёдзи",
  "Страж"
].freeze

GOD_ORDER = [
  "Гиперион I",
  "Тарун",
  "Церунна",
  "Тиресий",
  "Дракон Ланг-Ан",
  "Мерката",
  "Аст",
  "Альзаман",
  "Калипсо",
  "Икатерра",
  "Хангор",
  "Винтра",
  "Шубханкари",
  "Руфу",
  "Ицунэ",
  "Велисса"
].freeze

CATEGORY_TITLE_ORDER = {
  "Страны" => COUNTRY_ORDER,
  "Народы" => PEOPLE_ORDER,
  "Имитеи" => IMITEI_ORDER,
  "Боги" => GOD_ORDER
}.freeze

CATEGORY_DESCRIPTIONS = {
  "Бестиарий" => "Виды существ, чудовищ и разумных народов, с которыми делят мир смертные и боги.",
  "Боги" => "Пантеоны, культы и бессмертные силы, вмешивающиеся в судьбы народов.",
  "Знания" => "Законы мира, ремёсла, магия и открытия древних цивилизаций.",
  "Имитеи" => "Люди, сумевшие превзойти человеческие пределы и изменить ход истории.",
  "Литература" => "Саги, хроники, предания и тексты, которыми Астария помнит своё прошлое.",
  "Места" => "Города, земли и забытые уголки, где начинаются путешествия.",
  "Народы" => "Культуры и традиции народов, населяющих берега Хтонического моря.",
  "Организации" => "Ордены, культы, гильдии и тайные союзы со своими целями.",
  "Персонажи" => "Герои, правители, странники и те, чьи решения меняют Астарию.",
  "Предметы" => "Реликвии, оружие и вещи, сохранившие след великих событий.",
  "События" => "Войны, открытия и переломные мгновения истории мира.",
  "Страны" => "Государства Астарии, их устройство, противоречия и место в мире.",
  "Флора" => "Растения Астарии, их свойства, происхождение и место в культурах мира."
}.freeze

SIGNIFICANCE_LABELS = {
  0 => "Эпохальное",
  1 => "Переломное",
  2 => "Важное",
  3 => "Заметное"
}.freeze

ASSET_REWRITES = {
  "Assets/Maps/states.png" => "Assets/Maps/Web/states-web.jpg",
  "Assets/Maps/heightmap.png" => "Assets/Maps/Web/heightmap-web.jpg",
  "Assets/Maps/biomes.png" => "Assets/Maps/Web/biomes-web.jpg"
}.freeze

INFOBOX_FIELDS = [
  ["native_name", "Имя на родном языке"],
  ["location_type", "Тип места"],
  ["organization_type", "Тип организации"],
  ["item_type", "Тип предмета"],
  ["condition_type", "Тип явления"],
  ["profession_type", "Направление"],
  ["medium", "Форма / носитель"],
  ["species", "Вид"],
  ["current_era", "Текущая эпоха"],
  ["birth_year", "Год рождения"],
  ["current_location", "Текущее местоположение"],
  ["birth_place", "Место рождения"],
  ["parents", "Родители"],
  ["siblings", "Братья и сёстры"],
  ["children", "Дети"],
  ["partner", "Партнёр"],
  ["country", "Страна"],
  ["region", "Регион"],
  ["parent_location", "Часть территории"],
  ["continents", "Материки"],
  ["seas", "Моря"],
  ["population", "Население"],
  ["foundation", "Основание"],
  ["capital", "Столица"],
  ["headquarters", "Штаб-квартира"],
  ["ruler", "Глава"],
  ["founder", "Основатель"],
  ["founders", "Основатели"],
  ["creator", "Создатель"],
  ["creation_date", "Создание"],
  ["authors", "Авторы"],
  ["origin", "Происхождение"],
  ["ethnicity", "Народ"],
  ["imitei", "Путь Имитея"],
  ["occupation", "Род занятий"],
  ["organizations", "Организации"],
  ["deities", "Божества"],
  ["faiths", "Верования"],
  ["religions", "Религии"],
  ["church", "Вера/культ"],
  ["government", "Форма правления"],
  ["domains", "Сферы влияния"],
  ["symbols", "Священные символы"],
  ["eyes", "Глаза"],
  ["hair", "Волосы"],
  ["skin", "Кожа / окрас"],
  ["height", "Рост"],
  ["weight", "Вес"],
  ["distinguishing_features", "Особые приметы"],
  ["dimensions", "Размеры"],
  ["habitat", "Среда обитания"],
  ["average_height", "Средний рост"],
  ["average_length", "Средняя длина"],
  ["average_weight", "Средний вес"],
  ["lifespan", "Продолжительность жизни"],
  ["course", "Течение"],
  ["rarity", "Редкость"],
  ["historical_date", "Дата"],
  ["starting_date", "Начало"],
  ["ending_date", "Завершение"],
  ["year", "Год"],
  ["endingYear", "Год завершения"],
  ["conflict_location", "Место событий"],
  ["belligerents", "Стороны"],
  ["significance", "Значимость"],
  ["parent_peoples", "Родственные народы"],
  ["child_locations", "Включает"],
  ["inhabiting_peoples", "Народы"],
  ["inhabiting_species", "Обитатели"],
  ["trade_route", "Торговые связи"],
  ["associated_places", "Связанные места"],
  ["related_places", "Связанные места"],
  ["related_conflicts", "Связанные конфликты"],
  ["associated_organizations", "Связанные организации"],
  ["related_organizations", "Связанные организации"],
  ["aligned_organization", "Связанная организация"],
  ["known_practitioners", "Известные представители"],
  ["known_individuals", "Известные особи"],
  ["historical_figures", "Известные личности"],
  ["notable_people", "Известные личности"],
  ["important_people", "Важные личности"],
  ["other_people", "Другие участники"],
  ["known_members", "Известные участники"],
  ["central_characters", "Центральные персонажи"],
  ["affected_people", "Кого затрагивает"],
  ["related_peoples", "Связанные народы"],
  ["related_ethnicities", "Связанные народы"],
  ["related_species", "Связанные виды"],
  ["associated_peoples", "Связанные народы"],
  ["related_professions", "Связанные профессии"],
  ["related_items", "Связанные предметы"],
  ["related_myths", "Связанные предания"],
  ["controlled_territories", "Контролируемые территории"],
  ["contested_territories", "Спорные территории"],
  ["opposes", "Противники"]
].freeze

INFOBOX_VALUE_TRANSLATIONS = {
  "Military" => "Воинское",
  "Religious" => "Религиозное",
  "Arcane" => "Мистическое",
  "Paper" => "Бумага",
  "Illicit, Rebel" => "Тайная повстанческая",
  "Religious, Organised Religion" => "Организованная религия",
  "Religious, Cult" => "Религиозный культ",
  "Druidic Circle" => "Друидический круг",
  "Consumable, Magical" => "Магический расходуемый предмет",
  "Weapon, Melee" => "Оружие ближнего боя"
}.freeze

CURRENT_ASTARIAN_YEAR = Date.today.year - 1920

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
  data["quartz"] == true
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

def normalize_reference(value)
  value.to_s
    .split("#", 2)
    .first
    .tr("\\", "/")
    .split("/")
    .last
    .to_s
    .sub(/\.md\z/i, "")
    .downcase
    .tr("ё", "е")
    .gsub(/\s+/, " ")
    .strip
end

def relative_href(from_route, to_route)
  from_dir = File.dirname(from_route)
  from_dir = "." if from_dir == "."

  if to_route == "index"
    depth = from_dir == "." ? 0 : from_dir.split("/").length
    return depth.zero? ? "./" : "../" * depth
  end

  relative = Pathname.new(to_route).relative_path_from(Pathname.new(from_dir)).to_s
  relative == "." ? "../#{File.basename(to_route)}" : relative
end

def build_reference_lookup(records)
  lookup = {}
  records.each do |record|
    data = record[:data]
    keys = [data["title"], data["public_slug"], File.basename(record[:source], ".md")]
    keys.concat(Array(data["aliases"]))
    keys.compact.each do |key|
      normalized = normalize_reference(key)
      lookup[normalized] ||= record unless normalized.empty?
    end
  end
  lookup
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
  return "index" if explicit == "index"
  return "map" if source.start_with?(File.join(ROOT, "Карты")) || data["type"] == "map"

  if source.start_with?(File.join(ROOT, "Хронология"))
    return "timeline/index" if data["type"] == "timeline" || explicit == "timeline"
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

def display_category(category)
  category
end

def astaria_year_number(value)
  return value.to_i if value.is_a?(Numeric)

  match = value.to_s.strip.match(/\A(-?\d+)\s*(ХЭ|НЭ)?/i)
  return nil unless match

  number = match[1].to_i
  era = match[2].to_s.upcase
  era == "ХЭ" ? -number.abs : number
end

def astaria_year_label(value)
  number = astaria_year_number(value)
  return display_value(value) if number.nil?

  "#{number.abs} #{number.negative? ? "ХЭ" : "НЭ"}"
end

def age_label(age)
  mod100 = age % 100
  mod10 = age % 10
  return "лет" if (11..14).cover?(mod100)
  return "год" if mod10 == 1
  return "года" if (2..4).cover?(mod10)

  "лет"
end

def render_inline_value(value, route, lookup)
  raw = INFOBOX_VALUE_TRANSLATIONS.fetch(value.to_s, value.to_s)
  return "" if raw.strip.empty?

  rendered = +""
  index = 0
  raw.to_enum(:scan, /\[\[([^|\]]+)(?:\|([^\]]+))?\]\]/).each do
    match = Regexp.last_match
    rendered << CGI.escapeHTML(raw[index...match.begin(0)].to_s)
    target = match[1]
    label = match[2] || match[1]
    record = lookup[normalize_reference(target)]
    rendered << if record && record[:route] != route
      href = relative_href(route, record[:route])
      %(<a class="astaria-infobox-link" href="#{CGI.escapeHTML(href)}">#{CGI.escapeHTML(label)}</a>)
    elsif record
      %(<span class="astaria-infobox-reference astaria-self-reference">#{CGI.escapeHTML(label)}</span>)
    else
      %(<span class="astaria-infobox-reference" title="Статья готовится к публикации">#{CGI.escapeHTML(label)}</span>)
    end
    index = match.end(0)
  end
  rendered << CGI.escapeHTML(raw[index..].to_s)
  rendered.strip
end

def render_value(value, route, lookup)
  case value
  when Array
    items = value.map { |item| render_value(item, route, lookup) }.reject(&:empty?)
    return "" if items.empty?
    return items.join(", ") if items.length <= 3

    if items.length > 6
      visible = items.first(5).map { |item| "<li>#{item}</li>" }.join
      hidden = items.drop(5).map { |item| "<li>#{item}</li>" }.join
      remaining = items.length - 5
      return %(<ul class="astaria-infobox-list">#{visible}</ul><details class="astaria-infobox-more"><summary>Ещё #{remaining}</summary><ul class="astaria-infobox-list">#{hidden}</ul></details>)
    end

    list_items = items.map { |item| "<li>#{item}</li>" }.join
    %(<ul class="astaria-infobox-list">#{list_items}</ul>)
  else
    render_inline_value(value, route, lookup)
  end
end

def render_infobox_value(key, data, route, lookup)
  return "" if key == "imitei" && (data[key] == false || data[key].to_s.strip.empty?)

  if key == "significance"
    return "" unless data["timeline"] == true || data["type"].to_s == "historical-event"

    label = SIGNIFICANCE_LABELS.fetch(data[key].to_i, "Летописное")
    return CGI.escapeHTML("#{label} событие")
  end

  if key == "birth_year"
    year = astaria_year_number(data[key])
    return render_value(data[key], route, lookup) if year.nil?

    age = CURRENT_ASTARIAN_YEAR - year
    age_note = age.negative? ? "" : %(<span class="astaria-infobox-note">#{age} #{age_label(age)}</span>)
    return "#{CGI.escapeHTML(astaria_year_label(year))}#{age_note}"
  end

  return "" if key == "year" && (data["historical_date"] || data["starting_date"])
  return "" if key == "endingYear" && data["ending_date"]

  if %w[year endingYear].include?(key)
    return CGI.escapeHTML(astaria_year_label(data[key]))
  end

  render_value(data[key], route, lookup)
end

def public_asset_url(asset_path)
  asset_path.split("/").map { |part| part.downcase.tr(" ", "-") }.join("/")
end

def render_image_tag(asset_path, css_class, alt_text: nil, fetchpriority: nil)
  url = public_asset_url(asset_path)
  alt = alt_text.to_s.strip
  alt = File.basename(asset_path, File.extname(asset_path)).tr("_-", " ") if alt.empty?
  priority = fetchpriority ? %( fetchpriority="#{CGI.escapeHTML(fetchpriority)}") : ""
  %(<img class="#{css_class}" src="#{CGI.escapeHTML(url)}" alt="#{CGI.escapeHTML(alt)}"#{priority}>)
end

# CommonMark ends a raw HTML block at a blank line. Optional fragments inside
# generated cards used to leave whitespace-only rows, so the remaining nested
# tags were occasionally rendered as visible source code. Keep generated UI
# fragments contiguous while leaving ordinary article Markdown untouched.
def markdown_safe_html(html)
  html.lines.reject { |line| line.strip.empty? }.join.strip
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

def render_public_wikilinks(body, route, lookup)
  body.gsub(/(?<!!)\[\[([^\]|#]+)(?:#[^\]|]+)?(?:\|([^\]]+))?\]\]/) do
    target = Regexp.last_match(1).strip
    label = (Regexp.last_match(2) || File.basename(target)).strip
    record = lookup[normalize_reference(target)]
    escaped_label = CGI.escapeHTML(label)

    if record && record[:route] != route
      href = relative_href(route, record[:route])
      %(<a class="astaria-inline-link" href="#{CGI.escapeHTML(href)}">#{escaped_label}</a>)
    elsif record
      %(<span class="astaria-self-reference">#{escaped_label}</span>)
    else
      %(<span class="astaria-unpublished-reference" title="Статья готовится к публикации">#{escaped_label}</span>)
    end
  end
end

def description_from_body(body, data)
  explicit = data["description"].to_s.strip
  return explicit unless explicit.empty?
  return "Интерактивная карта Астарии с поиском по местам, масштабированием и слоями границ, рельефа и биомов." if data["type"] == "map"

  main_section = body.match(/^## Основной текст\s*\n+(.*?)(?=^## |\z)/m)
  text = main_section ? main_section[1] : cleanup_public_body(body, data)
  text = text.gsub(/```.*?```/m, " ")
  text = text.gsub(/%%.*?%%/m, " ")
  text = text.gsub(/!\[\[[^\]]+\]\]/, " ")
  text = text.gsub(/\[\[([^|\]]+)\|([^\]]+)\]\]/, '\\2')
  text = text.gsub(/\[\[([^\]]+)\]\]/, '\\1')
  text = text.gsub(/^\s*[#>|*-]+\s*/, "")
  text = text.gsub(/<[^>]+>/, " ")
  text = text.gsub(/\s+/, " ").strip
  title = data["title"].to_s.strip
  if !title.empty? && text.start_with?(title)
    text = text.delete_prefix(title)
      .sub(/\A\s*(?:[,;:.!—–-]\s*)+/, "")
      .strip
    text = text.sub(/\A([«„“"']*)([а-яё])/u) do
      "#{Regexp.last_match(1)}#{Regexp.last_match(2).upcase}"
    end
  end
  return "Энциклопедия мира Астарии." if text.empty?

  return text if text.length <= 180

  shortened = text[0, 177].sub(/\s+\S*\z/, "").strip
  "#{shortened}…"
end

def article_count_label(count)
  mod100 = count % 100
  mod10 = count % 10
  return "статей" if (11..14).cover?(mod100)
  return "статья" if mod10 == 1
  return "статьи" if (2..4).cover?(mod10)

  "статей"
end

def place_count_label(count)
  mod100 = count % 100
  mod10 = count % 10
  return "мест" if (11..14).cover?(mod100)
  return "место" if mod10 == 1
  return "места" if (2..4).cover?(mod10)

  "мест"
end

def sidebar_image(data)
  return nil if data["public_slug"].to_s.strip == "index"

  raw = data["portrait_image"] || data["flag_image"]
  path = extract_asset_path(raw)
  path && ASSET_REWRITES.fetch(path, path)
end

def crest_image(data)
  return nil if data["public_slug"].to_s.strip == "index"

  path = extract_asset_path(data["crest_image"])
  path && ASSET_REWRITES.fetch(path, path)
end

def cover_image(data)
  raw = data["cover_image"]
  path = extract_asset_path(raw)
  return nil unless path

  path = ASSET_REWRITES.fetch(path, path)
  path == sidebar_image(data) ? nil : path
end

def timeline_image(data)
  raw = data["timeline_image"] || data["cover_image"]
  path = extract_asset_path(raw)
  path && ASSET_REWRITES.fetch(path, path)
end

def build_cover(data)
  image_path = cover_image(data)
  return "" unless image_path

  <<~HTML
    <figure class="astaria-cover-frame">
    #{render_image_tag(image_path, "astaria-cover-image", alt_text: data["title"], fetchpriority: "high")}
    </figure>
  HTML
end

def build_title(route, data)
  return "" if data["public_slug"].to_s.strip == "index"

  title = CGI.escapeHTML(data["title"].to_s)
  home_href = relative_href(route, "index")
  category = data["category"].to_s
  category_route = CATEGORY_ROUTES[category]
  category_crumb = if category_route
    category_href = "../#{category_route}/"
    %(<span aria-hidden="true">/</span><a href="#{CGI.escapeHTML(category_href)}">#{CGI.escapeHTML(display_category(category))}</a>)
  else
    ""
  end

  <<~HTML
    <nav class="astaria-article-trail" aria-label="Хлебные крошки">
    <a href="#{CGI.escapeHTML(home_href)}">Астария</a>
    #{category_crumb}
    </nav>
    <h1 class="astaria-content-title">#{title}</h1>
  HTML
end

def build_coverless_title(source, route, data)
  return "" if data["public_slug"].to_s.strip == "index"

  chapter_page = %w[chapter session].include?(data["type"].to_s)
  title = chapter_page ? chapter_short_title(data) : data["title"].to_s
  escaped_title = CGI.escapeHTML(title)
  home_href = relative_href(route, "index")
  category = data["category"].to_s
  category_route = CATEGORY_ROUTES[category]
  category_crumb = if category_route
    %(<span aria-hidden="true">/</span><a href="../#{CGI.escapeHTML(category_route)}/">#{CGI.escapeHTML(display_category(category))}</a>)
  else
    ""
  end
  saga = saga_landing_record(source, data)
  saga_crumb = if saga
    %(<span aria-hidden="true">/</span><a href="#{CGI.escapeHTML(relative_href(route, saga[:route]))}">#{CGI.escapeHTML(saga[:data]["title"].to_s)}</a>)
  else
    ""
  end
  kicker = case data["type"].to_s
  when "chapter", "session" then "Глава #{format("%03d", data["chapter"].to_i)}"
  when "campaign", "document" then "Сага Астарии"
  else display_category(category)
  end
  metadata = [
    data["year"] && astaria_year_label(data["year"]),
    data["season"],
    display_value(data["region"])
  ].compact.map(&:to_s).reject(&:empty?).first(3)
  metadata_html = metadata.map { |value| %(<span>#{CGI.escapeHTML(value)}</span>) }.join
  metadata_block = metadata_html.empty? ? "" : %(\n          <div class="astaria-coverless-meta">#{metadata_html}</div>)
  english_title = data["english_title"].to_s.strip
  english_title_html = if english_title.empty?
    ""
  else
    %(\n          <p class="astaria-coverless-subtitle" lang="en">#{CGI.escapeHTML(english_title)}</p>)
  end
  hero_class = chapter_page ? "astaria-coverless-hero astaria-coverless-hero-chapter" : "astaria-coverless-hero"

  <<~HTML
    <header class="#{hero_class}">
      <nav class="astaria-article-trail" aria-label="Хлебные крошки">
        <a href="#{CGI.escapeHTML(home_href)}">Астария</a>
        #{category_crumb}
        #{saga_crumb}
      </nav>
      <div class="astaria-coverless-main">
        <div>
          <p class="astaria-coverless-kicker">#{CGI.escapeHTML(kicker)}</p>
          <h1 class="astaria-content-title">#{escaped_title}</h1>#{english_title_html}#{metadata_block}
        </div>
        <div class="astaria-coverless-ornament" aria-hidden="true"><span></span><i></i></div>
      </div>
    </header>
  HTML
end

def build_sidebar(data, route, lookup)
  return "" if data["public_slug"].to_s.strip == "index"

  image_path = sidebar_image(data)
  crest_path = crest_image(data)
  rows = INFOBOX_FIELDS.map do |key, label|
    rendered = render_infobox_value(key, data, route, lookup)
    next if rendered.empty?

    %(<div class="astaria-infobox-row"><dt>#{CGI.escapeHTML(label)}</dt><dd>#{rendered}</dd></div>)
  end.compact

  return "" if image_path.nil? && crest_path.nil? && rows.empty?

  image = if image_path
    "#{render_image_tag(image_path, "astaria-sidebar-image", alt_text: data["title"])}\n"
  else
    ""
  end

  crest = if crest_path
    "#{render_image_tag(crest_path, "astaria-crest-image", alt_text: "Герб: #{data["title"]}")}\n"
  else
    ""
  end

  infobox = if rows.empty?
    ""
  else
    <<~HTML
      <div class="astaria-infobox">
      <p class="astaria-infobox-heading">Сведения</p>
      <dl>
      #{rows.join("\n")}
      </dl>
      </div>
    HTML
  end

  markdown_safe_html(<<~HTML)
    <aside class="astaria-sidebar" aria-label="Сведения: #{CGI.escapeHTML(data["title"].to_s)}">
    #{image}
    #{crest}
    #{infobox}
    </aside>
  HTML
end

def build_featured_lede(data)
  return "" unless data["featured_entry"]

  description = data["description"].to_s.strip
  return "" if description.empty?

  %(<p class="astaria-article-lede">#{CGI.escapeHTML(description)}</p>)
end

def build_astaria_journey(route, data)
  return "" unless data["featured_entry"] && data["category"] == "Места"

  category_href = lambda do |category_route|
    relative_href(route, "#{category_route}/index").sub(/index\z/, "")
  end
  destinations = [
    ["Атлас мира", relative_href(route, "map"), "132 отмеченных места, масштаб и слои карты."],
    ["Хронология", relative_href(route, "timeline/index"), "События, которые превратили древний мир в нынешний."],
    ["Страны", category_href.call("countries"), "Государства, их правители, земли и неразрешённые противоречия."],
    ["Народы", category_href.call("peoples"), "Культуры, обычаи и память тех, кто населяет Астарию."],
    ["Боги", category_href.call("gods"), "Бессмертные силы, культы и опасные игры с судьбами смертных."],
    ["Персонажи", category_href.call("characters"), "Герои, странники и существа, чьи решения меняют мир." ]
  ]
  cards = destinations.each_with_index.map do |(title, href, description), index|
    <<~HTML
      <a class="astaria-journey-card" href="#{CGI.escapeHTML(href)}">
        <span>#{format("%02d", index + 1)}</span>
        <strong>#{CGI.escapeHTML(title)}</strong>
        <p>#{CGI.escapeHTML(description)}</p>
        <b>Исследовать <i aria-hidden="true">→</i></b>
      </a>
    HTML
  end

  <<~HTML
    <section class="astaria-place-next" aria-labelledby="astaria-place-next-title">
      <header>
        <p>Выберите свой путь</p>
        <h2 id="astaria-place-next-title">Куда отправиться дальше?</h2>
      </header>
      <div>#{cards.join("\n")}</div>
    </section>
  HTML
end

def map_markers(body)
  markers = []
  body.scan(/^\s*-\s+default,\s*(\d+),\s*(\d+),\s*\[\[([^|\]]+)(?:\|([^\]]+))?\]\]\s*$/) do |y, x, target, label|
    name = (label || target).strip
    kind = case name
    when /(?:Город|Деревня|Храм|Кузня|Обитель)/i then "settlement"
    when /(?:Озеро|Река|море|залив|пролив|перешеек)/i then "water"
    when /(?:Гор|Пустын|Лес|Джунг|Болот|Долин|луг|земл|Вулкан|Предгор)/i then "terrain"
    else "realm"
    end
    markers << { y: y.to_f, x: x.to_f, target: target.strip, name: name, kind: kind }
  end
  markers
end

def build_map_explorer(data, body, route, lookup)
  width = data["map_width"].to_f
  height = data["map_height"].to_f
  width = 7680.0 if width <= 0
  height = 4320.0 if height <= 0
  markers = map_markers(body)

  layers = {
    "states" => ["Границы", "Политическая карта"],
    "heightmap" => ["Рельеф", "Физическая карта"],
    "biomes" => ["Биомы", "Карта природных зон"]
  }.map do |key, labels|
    path = extract_asset_path((data["map_layers"] || {})[key])
    [key, labels, path]
  end

  layer_images = layers.map.with_index do |(key, labels, path), index|
    next unless path
    url_attribute = index.zero? ? %(src="#{CGI.escapeHTML(public_asset_url(path))}" fetchpriority="high") : %(data-src="#{CGI.escapeHTML(public_asset_url(path))}")
    %(<img class="astaria-map-layer#{index.zero? ? " is-active" : ""}" data-layer="#{key}" #{url_attribute} alt="#{CGI.escapeHTML(labels.last)}" decoding="async" draggable="false">)
  end.compact.join("\n")

  layer_buttons = layers.map.with_index do |(key, labels, _path), index|
    %(<button type="button" class="astaria-map-layer-button#{index.zero? ? " is-active" : ""}" data-layer="#{key}" aria-pressed="#{index.zero?}">#{CGI.escapeHTML(labels.first)}</button>)
  end.join("\n")

  marker_buttons = markers.map do |marker|
    record = lookup[normalize_reference(marker[:target])]
    href = record ? relative_href(route, record[:route]) : ""
    left = (marker[:x] / width * 100).round(4)
    # Leaflet image coordinates use a geographic Y axis: larger geoY values
    # point north. CSS `top` grows southward, so the vertical position must be
    # mirrored when the canonical marker is placed over the raster.
    top = ((height - marker[:y]) / height * 100).round(4)
    %(<button type="button" class="astaria-map-marker astaria-map-marker-#{marker[:kind]}" style="left:#{left}%;top:#{top}%" data-name="#{CGI.escapeHTML(marker[:name])}" data-kind="#{marker[:kind]}" data-x="#{left}" data-y="#{top}" data-href="#{CGI.escapeHTML(href)}" aria-label="Показать: #{CGI.escapeHTML(marker[:name])}"><span></span></button>)
  end.join("\n")

  home_href = relative_href(route, "index")
  <<~HTML
    <section class="astaria-map-page" aria-labelledby="astaria-map-title">
      <nav class="astaria-article-trail astaria-map-trail" aria-label="Хлебные крошки"><a href="#{CGI.escapeHTML(home_href)}">Астария</a><span aria-hidden="true">/</span><span>Атлас мира</span></nav>
      <header class="astaria-map-heading">
        <div>
          <p class="astaria-map-kicker">Интерактивный атлас · #{markers.length} #{place_count_label(markers.length)}</p>
          <h1 id="astaria-map-title">Карта Астарии</h1>
        </div>
        <p>Приближайте карту колёсиком, перемещайте её мышью или касанием и переключайте слои, чтобы увидеть границы, рельеф и природные зоны.</p>
      </header>
      <div class="astaria-map-explorer" data-map-width="#{width.to_i}" data-map-height="#{height.to_i}">
        <div class="astaria-map-toolbar">
          <label class="astaria-map-search-label">
            <svg aria-hidden="true" viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"></circle><path d="m20 20-4-4"></path></svg>
            <span class="sr-only">Найти место на карте</span>
            <input class="astaria-map-search" type="search" placeholder="Найти город, реку или регион…" autocomplete="off">
          </label>
          <div class="astaria-map-layer-switcher" role="group" aria-label="Слой карты">
            #{layer_buttons}
          </div>
        </div>
        <div class="astaria-map-shell">
          <aside class="astaria-map-panel" aria-label="Результаты поиска по карте">
            <div class="astaria-map-panel-intro">
              <span>Путеводитель</span>
              <strong>#{markers.length} #{place_count_label(markers.length)} на карте</strong>
              <p>Введите название или выберите точку прямо на карте.</p>
            </div>
            <div class="astaria-map-results" aria-live="polite"></div>
            <div class="astaria-map-legend" aria-label="Легенда карты">
              <span><i class="astaria-map-legend-settlement"></i>Поселения</span>
              <span><i class="astaria-map-legend-water"></i>Воды</span>
              <span><i class="astaria-map-legend-terrain"></i>Ландшафт</span>
              <span><i class="astaria-map-legend-realm"></i>Регионы</span>
            </div>
          </aside>
          <div class="astaria-map-viewport" tabindex="0" aria-label="Интерактивная карта. Перемещайте стрелками, приближайте клавишами плюс и минус.">
            <div class="astaria-map-stage">
              <img class="astaria-map-preview" src="assets/maps/web/states-web.jpg" alt="" aria-hidden="true" decoding="async" fetchpriority="high" draggable="false">
              #{layer_images}
              <div class="astaria-map-markers">#{marker_buttons}</div>
            </div>
            <div class="astaria-map-detail" hidden>
              <button type="button" class="astaria-map-detail-close" aria-label="Закрыть карточку места">×</button>
              <span class="astaria-map-detail-kind"></span>
              <strong class="astaria-map-detail-name"></strong>
              <a class="astaria-map-detail-link" href="">Читать статью <span aria-hidden="true">→</span></a>
              <p class="astaria-map-detail-note">Статья об этом месте пока готовится.</p>
            </div>
            <div class="astaria-map-zoom-controls" aria-label="Масштаб карты">
              <button type="button" data-map-action="zoom-in" aria-label="Приблизить">+</button>
              <button type="button" data-map-action="zoom-out" aria-label="Отдалить">−</button>
              <button type="button" data-map-action="reset" aria-label="Показать всю карту">⌂</button>
            </div>
            <p class="astaria-map-help">Колёсико — масштаб · Перетаскивание — обзор</p>
          </div>
        </div>
      </div>
    </section>
  HTML
end

def timeline_year_label(year, ending_year = nil)
  year = year.to_i
  ending_year = ending_year.to_i unless ending_year.nil? || ending_year.to_s.empty?
  era = year.negative? ? "ХЭ" : "НЭ"
  start = year.negative? ? year.abs : year
  finish = if ending_year
    ending_year.negative? ? ending_year.abs : ending_year
  end
  range = finish && finish != start ? "#{start}–#{finish}" : start.to_s
  "#{range} #{era}"
end

def timeline_events(lookup)
  paths = Dir.glob(File.join(ROOT, "Хронология", "События", "*.md"))
  paths.concat(Dir.glob(File.join(ROOT, "Энциклопедия", "События", "*.md")))

  paths.map do |path|
    data, body = frontmatter_for(path)
    next unless data["timeline"] == true
    next if data["year"].nil?

    title = data["title"].to_s
    published = lookup[normalize_reference(title)]
    {
      title: title,
      year: data["year"].to_i,
      ending_year: data["endingYear"],
      category: data["timeline_category"].to_s.strip,
      significance: data["significance"].to_i,
      significance_label: SIGNIFICANCE_LABELS.fetch(data["significance"].to_i, "Летописное"),
      description: timeline_description(body, data),
      image: timeline_image(data),
      route: published && published[:route]
    }
  end.compact.sort_by { |event| [event[:year], event[:title]] }
end

def timeline_description(body, data)
  lines = body.lines
  marker = lines.index { |line| line.match?(/^>\s*\[!timeline\]/i) }
  callout = if marker
    lines[(marker + 1)..].take_while { |line| line.start_with?(">") }.map do |line|
      line.sub(/^>\s?/, "").strip
    end.join(" ")
  else
    ""
  end
  text = callout.empty? ? description_from_body(body, data) : callout
  text = text.gsub(/\[\[([^|\]]+)\|([^\]]+)\]\]/, '\\2')
  text = text.gsub(/\[\[([^\]]+)\]\]/, '\\1')
  text = text.gsub(/\s+/, " ").strip
  return text if text.length <= 180

  "#{text[0, 177].sub(/\s+\S*\z/, "").strip}…"
end

def build_timeline_page(data, route, lookup)
  events = timeline_events(lookup)
  categories = events.map { |event| event[:category] }.reject(&:empty?).uniq.sort
  home_href = relative_href(route, "index")

  controls = categories.map do |category|
    %(<option value="#{CGI.escapeHTML(category)}">#{CGI.escapeHTML(category)}</option>)
  end.join("\n")

  era_sections = [
    ["chthonic", "Хтоническая эра", "До Падения Хтона", events.select { |event| event[:year].negative? }],
    ["new", "Новая эра", "После Падения Хтона", events.reject { |event| event[:year].negative? }]
  ].map do |era, title, subtitle, era_events|
    cards = era_events.map do |event|
      event_title = CGI.escapeHTML(event[:title])
      heading = if event[:route]
        href = relative_href(route, event[:route])
        %(<h3><a href="#{CGI.escapeHTML(href)}">#{event_title}</a></h3>)
      else
        %(<h3>#{event_title}</h3>)
      end
      image = if event[:image]
        %(<img src="#{CGI.escapeHTML(public_asset_url(event[:image]))}" alt="" loading="lazy">)
      else
        ""
      end
      category = event[:category].empty? ? "Историческая веха" : event[:category]
      search_value = [event[:title], category, event[:significance_label], event[:description]].join(" ").downcase.tr("ё", "е")
      markdown_safe_html(<<~HTML)
        <li class="astaria-timeline-event" data-era="#{era}" data-category="#{CGI.escapeHTML(category)}" data-search="#{CGI.escapeHTML(search_value)}">
          <div class="astaria-timeline-year"><span>#{timeline_year_label(event[:year], event[:ending_year])}</span></div>
          <article class="astaria-timeline-card astaria-timeline-significance-#{event[:significance]}">
            #{image}
            <div>
              <p class="astaria-timeline-meta"><span>#{CGI.escapeHTML(category)}</span><span>#{CGI.escapeHTML(event[:significance_label])}</span></p>
              #{heading}
              <div>#{CGI.escapeHTML(event[:description])}</div>
              #{event[:route] ? %(<a class="astaria-timeline-read" href="#{CGI.escapeHTML(relative_href(route, event[:route]))}">Читать летопись <span aria-hidden="true">→</span></a>) : ""}
            </div>
          </article>
        </li>
      HTML
    end.join("\n")

    <<~HTML
      <section class="astaria-timeline-era" data-timeline-era="#{era}">
        <header><p>#{CGI.escapeHTML(subtitle)}</p><h2>#{CGI.escapeHTML(title)}</h2><span>#{era_events.length} событий</span></header>
        <ol class="astaria-timeline-list">#{cards}</ol>
      </section>
    HTML
  end.join("\n")

  <<~HTML
    <section class="astaria-timeline-page" aria-labelledby="astaria-timeline-title">
      <nav class="astaria-article-trail"><a href="#{CGI.escapeHTML(home_href)}">Астария</a><span aria-hidden="true">/</span><span>Хронология</span></nav>
      <header class="astaria-timeline-hero">
        <img src="../assets/images/acheus_invasion.jpg" alt="Город Астарии во время вторжения" fetchpriority="high">
        <div class="astaria-timeline-hero-shade"></div>
        <div>
          <p>#{events.length} вех · от 5025 года ХЭ до наших дней</p>
          <h1 id="astaria-timeline-title">История Астарии</h1>
          <span>Летопись цивилизаций, войн, открытий и падений, сохранившихся в архивах мира.</span>
        </div>
      </header>
      <div class="astaria-timeline-controls" role="search" aria-label="Фильтры хронологии">
        <label><span>Поиск события</span><input class="astaria-timeline-search" type="search" placeholder="Например, Талассия или Падение Хтона…" autocomplete="off"></label>
        <label><span>Тип события</span><select class="astaria-timeline-category"><option value="">Все события</option>#{controls}</select></label>
        <p class="astaria-timeline-count" aria-live="polite">Показано: #{events.length}</p>
      </div>
      <div class="astaria-timeline-empty" hidden><strong>Событий не найдено</strong><span>Попробуйте изменить запрос или выбрать другой тип.</span></div>
      <div class="astaria-timeline-eras">#{era_sections}</div>
    </section>
  HTML
end

def build_article_footer(route, data)
  return "" if data["public_slug"].to_s.strip == "index"

  category = data["category"].to_s
  category_route = CATEGORY_ROUTES[category]
  category_link = if category_route
    href = "../#{category_route}/"
    %(<a href="#{CGI.escapeHTML(href)}">#{CGI.escapeHTML(display_category(category))}</a>)
  end

  links = [%(<a href="#{CGI.escapeHTML(relative_href(route, "index"))}">Астария</a>), category_link].compact.join("\n")
  <<~HTML
    <footer class="astaria-article-footer">
    #{links}
    </footer>
  HTML
end

def cleanup_public_body(body, data)
  image_paths = [sidebar_image(data), cover_image(data), crest_image(data)].compact

  body = body.gsub(/\r\n?/, "\n")
  body = body.gsub(/%%.*?%%\s*/m, "")
  body = body.sub(/\A\s*# .+?\n+/, "")
  body = body.gsub(/^## Основной текст\s*\n+/, "")
  body = body.gsub(/^## Связи\s*\n+```dataview\n.*?```\s*/m, "")
  body = body.gsub(/```dataview\n.*?```\s*/m, "")
  body = body.gsub(/^## Главы\s*\n*/, "") if saga_landing?(data)
  body = body.gsub(/^> \[!info\] Домены\s*\n(?:>.*\n?)+/i, "") if data["domains"]
  body = body.gsub(/^## Куда отправиться дальше\s*\n.*\z/m, "") if data["featured_entry"]
  unless data["english_title"].to_s.strip.empty?
    english_title = Regexp.escape(data["english_title"].to_s.strip)
    body = body.sub(/\A\s*\*#{english_title}\*\s*\n+/, "")
  end
  body = body.gsub(/^(\s*[-*+] .+)\n(?:\s*\n)+(?=\s*[-*+] )/, "\\1\n") while body.match?(/^(\s*[-*+] .+)\n(?:\s*\n)+(?=\s*[-*+] )/)

  image_paths.each do |image_path|
    body = body.gsub(/^\s*!\[\[#{Regexp.escape(image_path)}(?:\|[^\]]+)?\]\]\s*\n+/, "")
  end

  body.strip
end

def saga_landing?(data)
  data["category"] == "Литература" && !Array(data["central_characters"]).empty?
end

def saga_chapter_records(source)
  Dir.glob(File.join(File.dirname(source), "*.md")).sort.map do |path|
    next if path == source || !publishable_markdown?(path)

    data, body = frontmatter_for(path)
    next unless %w[chapter session].include?(data["type"].to_s)

    { source: path, data: data, body: body, route: public_route(path, data) }
  end.compact.sort_by { |chapter| [chapter[:data]["chapter"].to_i, chapter[:data]["title"].to_s] }
end

def saga_landing_record(source, data)
  return nil unless %w[chapter session].include?(data["type"].to_s)

  expected_title = data["saga"].to_s.strip
  Dir.glob(File.join(File.dirname(source), "*.md")).sort.each do |candidate|
    next if candidate == source || !publishable_markdown?(candidate)

    candidate_data, = frontmatter_for(candidate)
    next unless saga_landing?(candidate_data)
    next if !expected_title.empty? && candidate_data["title"].to_s != expected_title

    return { source: candidate, data: candidate_data, route: public_route(candidate, candidate_data) }
  end
  nil
end

def chapter_short_title(data)
  data["title"].to_s.sub(/^Глава\s+\d+\s*[-—:]\s*/i, "")
end

def saga_chapter_card(chapter, route)
  chapter_data = chapter[:data]
  number = chapter_data["chapter"].to_i
  meta = [
    chapter_data["year"] && astaria_year_label(chapter_data["year"]),
    chapter_data["season"],
    display_value(chapter_data["region"])
  ].compact.map(&:to_s).reject(&:empty?).join(" · ")
  english_title = chapter_data["english_title"].to_s.strip
  english_html = english_title.empty? ? "" : %(<em lang="en">#{CGI.escapeHTML(english_title)}</em>)
  meta_html = meta.empty? ? "" : %(<small>#{CGI.escapeHTML(meta)}</small>)
  [
    %(<a class="astaria-saga-chapter-card" href="#{CGI.escapeHTML(relative_href(route, chapter[:route]))}">),
    %(<span>#{format("%03d", number)}</span>),
    "<div>",
    %(<strong>#{CGI.escapeHTML(chapter_short_title(chapter_data))}</strong>),
    english_html,
    meta_html,
    "</div>",
    %(<b aria-hidden="true">→</b>),
    "</a>"
  ].reject(&:empty?).join("\n")
end

def saga_chapter_region_groups(chapters)
  chapters.chunk_while do |left, right|
    display_value(left[:data]["region"]) == display_value(right[:data]["region"])
  end.to_a
end

def build_saga_chapters(source, route, data, lookup)
  return "" unless saga_landing?(data)

  chapters = saga_chapter_records(source)
  content = if chapters.empty?
    character_links = Array(data["central_characters"]).first(4).map do |character|
      render_value(character, route, lookup)
    end.join
    links = if character_links.empty?
      ""
    else
      %(<nav class="astaria-saga-character-links" aria-label="Герои саги">#{character_links}</nav>)
    end
    <<~HTML
      <div class="astaria-saga-empty">
        <div class="astaria-saga-empty-mark" aria-hidden="true"><span>✦</span></div>
        <div>
          <strong>Летопись ещё раскрывается</strong>
          <p>Главы пока не опубликованы. Начать знакомство с сагой можно с её героев — их судьбы уже вплетены в Энциклопедию.</p>
          #{links}
        </div>
      </div>
    HTML
  else
    if chapters.length > 24
      groups = saga_chapter_region_groups(chapters)
      region_links = groups.each_with_index.map do |group, index|
        region = display_value(group.first[:data]["region"])
        region = "Пролог" if region.empty?
        first_number = group.first[:data]["chapter"].to_i
        last_number = group.last[:data]["chapter"].to_i
        range = first_number == last_number ? format("%03d", first_number) : "#{format("%03d", first_number)}–#{format("%03d", last_number)}"
        %(<a href="#chapters-region-#{index + 1}"><strong>#{CGI.escapeHTML(region)}</strong><small>#{range}</small></a>)
      end.join
      regions = groups.each_with_index.map do |group, index|
        region = display_value(group.first[:data]["region"])
        region = "Пролог" if region.empty?
        first_number = group.first[:data]["chapter"].to_i
        last_number = group.last[:data]["chapter"].to_i
        range = first_number == last_number ? "Глава #{format("%03d", first_number)}" : "Главы #{format("%03d", first_number)}–#{format("%03d", last_number)}"
        cards = group.map { |chapter| saga_chapter_card(chapter, route) }.join
        <<~HTML
          <section class="astaria-saga-chapter-range" id="chapters-region-#{index + 1}">
            <header><p>#{CGI.escapeHTML(range)}</p><h3>#{CGI.escapeHTML(region)}</h3></header>
            <div class="astaria-saga-chapter-grid">#{cards}</div>
          </section>
        HTML
      end.join
      %(<nav class="astaria-saga-range-nav" aria-label="Регионы саги">#{region_links}</nav>#{regions})
    else
      cards = chapters.map { |chapter| saga_chapter_card(chapter, route) }.join
      %(<div class="astaria-saga-chapter-grid">#{cards}</div>)
    end
  end

  count_label = chapters.empty? ? "Главы готовятся к публикации" : "Доступно глав: #{chapters.length}"
  <<~HTML
    <section class="astaria-saga-chapters" aria-labelledby="astaria-saga-chapters-title">
      <header>
        <div><p>Летопись путешествия</p><h2 id="astaria-saga-chapters-title">Главы</h2></div>
        <span>#{CGI.escapeHTML(count_label)}</span>
      </header>
      #{content}
    </section>
  HTML
end

def build_chapter_navigation(source, route, data)
  saga = saga_landing_record(source, data)
  return "" unless saga

  chapters = saga_chapter_records(saga[:source])
  current_index = chapters.index { |chapter| File.expand_path(chapter[:source]) == File.expand_path(source) }
  return "" unless current_index

  previous = current_index.positive? ? chapters[current_index - 1] : nil
  following = current_index < chapters.length - 1 ? chapters[current_index + 1] : nil
  previous_link = if previous
    %(<a class="astaria-chapter-nav-previous" href="#{CGI.escapeHTML(relative_href(route, previous[:route]))}"><small>← Предыдущая глава</small><strong>#{CGI.escapeHTML(chapter_short_title(previous[:data]))}</strong></a>)
  else
    %(<span aria-hidden="true"></span>)
  end
  following_link = if following
    %(<a class="astaria-chapter-nav-next" href="#{CGI.escapeHTML(relative_href(route, following[:route]))}"><small>Следующая глава →</small><strong>#{CGI.escapeHTML(chapter_short_title(following[:data]))}</strong></a>)
  else
    %(<span aria-hidden="true"></span>)
  end

  saga_link = %(<a class="astaria-chapter-nav-saga" href="#{CGI.escapeHTML(relative_href(route, saga[:route]))}"><small>Вернуться к саге</small><strong>#{CGI.escapeHTML(saga[:data]["title"].to_s)}</strong></a>)
  [
    %(<nav class="astaria-chapter-navigation" aria-label="Навигация по главам">),
    previous_link,
    saga_link,
    following_link,
    "</nav>"
  ].join("\n")
end

def generated_frontmatter(data, body)
  public_data = data.reject { |key, _value| %w[ready quartz].include?(key) || key.to_s.start_with?("secret_") }
  aliases = Array(public_data["aliases"])
  aliases << public_data["title"] if public_data["title"]
  public_data["aliases"] = aliases.compact.map(&:to_s).uniq
  public_data["description"] = description_from_body(body, data)

  yaml = YAML.dump(public_data).sub(/\A---\s*\n/, "")
  "---\n#{yaml}---\n"
end

def write_public_article(source, route, data, body, lookup)
  destination = target_path(route)
  FileUtils.mkdir_p(File.dirname(destination))
  lede = ""
  journey = ""
  chapters = ""
  chapter_navigation = ""
  source_category_name = source_category(source)
  if data["category"].to_s.empty? && CATEGORY_ROUTES.key?(source_category_name)
    data = data.merge("category" => source_category_name)
  end

  if data["type"] == "map"
    clean_body = build_map_explorer(data, body, route, lookup)
    cover = ""
    title = ""
    sidebar = ""
  elsif data["type"] == "timeline"
    clean_body = build_timeline_page(data, route, lookup)
    cover = ""
    title = ""
    sidebar = ""
  else
    clean_body = cleanup_public_body(body, data)
    clean_body = render_asset_embeds(clean_body)
    clean_body = render_public_wikilinks(clean_body, route, lookup)
    cover = build_cover(data)
    has_visual = !cover.empty? || !sidebar_image(data).nil? || !crest_image(data).nil?
    title = has_visual ? build_title(route, data) : build_coverless_title(source, route, data)
    lede = build_featured_lede(data)
    sidebar = build_sidebar(data, route, lookup)
    journey = build_astaria_journey(route, data)
    chapters = build_saga_chapters(source, route, data, lookup)
    chapter_navigation = build_chapter_navigation(source, route, data)
  end
  footer = build_article_footer(route, data)
  sections = [cover, title, lede, sidebar, clean_body, chapter_navigation, chapters, journey, footer].map(&:strip).reject(&:empty?)
  text = "#{generated_frontmatter(data, body)}\n#{sections.join("\n\n")}\n"
  unless data["type"] == "map"
    ASSET_REWRITES.each { |old_path, new_path| text = text.gsub(old_path, new_path) }
  end
  File.write(destination, text)

  {
    source: source,
    path: destination,
    route: route,
    title: data["title"].to_s,
    category: source_category(source),
    description: description_from_body(body, data),
    image_path: sidebar_image(data) || cover_image(data),
    cover_path: cover_image(data),
    sidebar_path: sidebar_image(data),
    crest_path: crest_image(data),
    data: data
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

def reference_names(value)
  Array(value).flat_map do |item|
    matches = item.to_s.scan(/\[\[([^|\]]+)(?:\|[^\]]+)?\]\]/).flatten
    matches.empty? ? [display_value(item)] : matches
  end.reject(&:empty?)
end

def entry_country(entry)
  data = entry[:data]
  direct_values = [data["country"], data["origin"], data["organizations"], data["ethnicity"], data["related_ethnicities"], data["related"]]
  names = direct_values.flat_map { |value| reference_names(value) }
  names.each do |name|
    return name if COUNTRY_ORDER.include?(name)
    mapped = COUNTRY_BY_PEOPLE[name]
    return mapped if mapped
  end
  nil
end

def creature_character?(entry)
  return false unless entry[:category] == "Персонажи"

  data = entry[:data]
  return true if display_value(data["character_group"]) == "Существа"

  reference_names(data["species"]).any?
end

def character_group(entry)
  return "Существа" if creature_character?(entry)

  entry_country(entry) || "Другие земли"
end

def character_group_sort_key(group)
  return COUNTRY_ORDER.index(group) if COUNTRY_ORDER.include?(group)
  return COUNTRY_ORDER.length if group == "Существа"

  COUNTRY_ORDER.length + 1
end

def entry_sort_key(entry)
  return [-1, entry[:title].downcase] if entry[:data]["featured_entry"]
  return [COUNTRY_ORDER.length, entry[:title].downcase] if creature_character?(entry)

  title_order = CATEGORY_TITLE_ORDER[entry[:category]]
  title_index = title_order&.index(entry[:title])
  return [title_index, entry[:title].downcase] unless title_index.nil?

  country = if entry[:category] == "Страны"
    entry[:title]
  else
    entry_country(entry)
  end
  country_index = COUNTRY_ORDER.index(country) || COUNTRY_ORDER.length
  [country_index, entry[:title].downcase]
end

def category_card(entry, route)
  href = if entry[:route].start_with?("#{route}/")
    entry[:route].delete_prefix("#{route}/")
  elsif entry[:route] == "index"
    "../"
  else
    "../#{entry[:route]}"
  end

  variant = if entry[:category] == "Страны"
    "country"
  elsif entry[:category] == "Места"
    "place"
  elsif %w[Боги Персонажи].include?(entry[:category]) || entry[:sidebar_path]
    "portrait"
  else
    "cover"
  end

  image = if entry[:image_path]
    crest = if entry[:crest_path]
      %(<img class="astaria-category-card-crest" src="#{CGI.escapeHTML(public_asset_url(entry[:crest_path]))}" alt="Герб государства #{CGI.escapeHTML(entry[:title])}" loading="lazy">)
    else
      ""
    end
    %(<div class="astaria-category-card-image"><img src="#{CGI.escapeHTML(public_asset_url(entry[:image_path]))}" alt="" loading="lazy">#{crest}</div>)
  else
    initial = entry[:title].each_char.find { |char| char.match?(/[[:alpha:]]/) } || "✦"
    %(<div class="astaria-category-card-image astaria-category-card-placeholder" aria-hidden="true">#{CGI.escapeHTML(initial)}</div>)
  end

  country = entry_country(entry)
  featured = entry[:data]["featured_entry"]
  eyebrow = if featured
    %(<small>Отправная точка</small>)
  elsif entry[:category] == "Страны"
    subtitle = entry[:data]["card_subtitle"].to_s.strip
    subtitle = Array(entry[:data]["aliases"]).find { |value| value.to_s.match?(/[А-Яа-яЁё]/) }.to_s if subtitle.empty?
    subtitle = "Государство Астарии" if subtitle.empty?
    %(<small>#{CGI.escapeHTML(subtitle)}</small>)
  elsif creature_character?(entry)
    species = reference_names(entry[:data]["species"]).first || "Существо"
    %(<small>#{CGI.escapeHTML(species)}</small>)
  elsif country
    %(<small>#{CGI.escapeHTML(country)}</small>)
  else
    ""
  end
  featured_class = featured ? " astaria-category-card-featured" : ""
  action = featured ? "Начать путешествие" : "Открыть статью"
  search_value = [
    entry[:title],
    entry[:description],
    entry[:category],
    entry[:data]["type"],
    country,
    display_value(entry[:data]["aliases"])
  ].compact.join(" ").downcase.tr("ё", "е").gsub(/\s+/, " ").strip
  meta_rank = entry_sort_key(entry).first
  markdown_safe_html(<<~HTML)
    <a class="astaria-category-card astaria-category-card-#{variant}#{featured_class}" href="#{CGI.escapeHTML(href)}" data-search="#{CGI.escapeHTML(search_value)}" data-meta-rank="#{meta_rank}">
      #{image}
      <div class="astaria-category-card-copy">
        #{eyebrow}
        <h3>#{CGI.escapeHTML(entry[:title])}</h3>
        <p>#{CGI.escapeHTML(entry[:description])}</p>
        <span>#{action} <b aria-hidden="true">→</b></span>
      </div>
    </a>
  HTML
end

def write_category_indexes(entries)
  grouped = entries.group_by { |entry| entry[:category] }
  CATEGORY_ROUTES.each do |category, route|
    category_entries = grouped.fetch(category, []).reject do |entry|
      %w[chapter session].include?(entry[:data]["type"].to_s)
    end
    route = CATEGORY_ROUTES.fetch(category)
    sorted_entries = category_entries.sort_by { |entry| entry_sort_key(entry) }
    cards = sorted_entries.map { |entry| category_card(entry, route) }
    description = CATEGORY_DESCRIPTIONS.fetch(category, "Статьи энциклопедии Астарии.")
    listing = if cards.empty?
      <<~HTML
        <div class="astaria-category-empty">
          <span aria-hidden="true">✦</span>
          <h2>Раздел ещё пополняется</h2>
          <p>Летописцы готовят первые материалы. Пока можно продолжить путь по карте или вернуться к оглавлению.</p>
          <div><a href="../map">Открыть карту</a><a href="../">На главную</a></div>
        </div>
      HTML
    elsif category == "Персонажи"
      country_entries = entries.select { |entry| entry[:category] == "Страны" }.to_h { |entry| [entry[:title], entry] }
      groups = sorted_entries.group_by { |entry| character_group(entry) }
        .sort_by { |group, _group_entries| character_group_sort_key(group) }
        .map do |group, group_entries|
        group_cards = group_entries.map { |entry| category_card(entry, route) }.join("\n")
        country_entry = country_entries[group]
        group_heading = if country_entry
          href = "../#{country_entry[:route]}"
          %(<a href="#{CGI.escapeHTML(href)}">#{CGI.escapeHTML(group)} <span aria-hidden="true">↗</span></a>)
        else
          CGI.escapeHTML(group)
        end
        <<~HTML
          <section class="astaria-category-group">
            <header><h2>#{group_heading}</h2></header>
            <div class="astaria-category-grid">#{group_cards}</div>
          </section>
        HTML
      end
      %(<div class="astaria-category-groups">#{groups.join("\n")}</div>)
    else
      %(<div class="astaria-category-grid">#{cards.join("\n")}</div>)
    end
    category_title = display_category(category)
    controls = if cards.empty?
      ""
    else
      <<~HTML
        <div class="astaria-category-tools" role="search" aria-label="Поиск по разделу #{CGI.escapeHTML(category_title)}">
          <label class="astaria-category-search-label">
            <svg aria-hidden="true" viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"></circle><path d="m20 20-4-4"></path></svg>
            <span class="sr-only">Найти статью в разделе #{CGI.escapeHTML(category_title)}</span>
            <input class="astaria-category-search" type="search" placeholder="Найти статью в разделе…" autocomplete="off">
          </label>
          <p class="astaria-category-count" aria-live="polite">Показано: #{cards.length} из #{cards.length}</p>
          <button class="astaria-category-clear" type="button" hidden>Сбросить</button>
        </div>
        <div class="astaria-category-no-results" hidden>
          <strong>Ничего не найдено</strong>
          <span>Попробуйте изменить запрос или открыть другой раздел Энциклопедии.</span>
        </div>
      HTML
    end
    body = <<~MARKDOWN
      ---
      title: #{category_title}
      lang: ru
      description: #{description}
      aliases:
        - #{category}
      ---

      <section class="astaria-category-page" aria-labelledby="astaria-category-title">
        <nav class="astaria-article-trail"><a href="../">Астария</a><span aria-hidden="true">/</span><span>Энциклопедия</span></nav>
        <header class="astaria-category-header">
          <h1 id="astaria-category-title">#{category_title}</h1>
          <div>#{description}</div>
        </header>
        #{controls}
        #{listing}
      </section>
    MARKDOWN

    destination = File.join(DEST, route, "index.md")
    FileUtils.mkdir_p(File.dirname(destination))
    File.write(destination, body)
  end
end

DISCOVERY_DOORS = [
  ["Страны", "Государство", "wide"],
  ["Боги", "Божество", "portrait"],
  ["Персонажи", "Личность", "portrait"],
  ["Места", "Место", "wide"],
  ["Бестиарий", "Бестиарий", "wide"]
].freeze

def home_discovery_item(entries, category, label, variant)
  candidates = entries.select do |entry|
    entry[:category] == category && entry[:image_path] && !entry[:data]["featured_entry"]
  end.sort_by { |entry| entry_sort_key(entry) }.map do |entry|
    {
      href: entry[:route],
      image: public_asset_url(entry[:image_path]),
      title: entry[:title],
      label: label,
      variant: variant
    }
  end
  return "" if candidates.empty?

  fallback = candidates.first
  payload = CGI.escapeHTML(JSON.generate(candidates))
  <<~HTML
    <div class="astaria-discovery-item" data-discovery-candidates="#{payload}">
      <a class="astaria-discovery-card astaria-discovery-#{variant}" href="#{CGI.escapeHTML(fallback[:href])}">
        <img src="#{CGI.escapeHTML(fallback[:image])}" alt="#{CGI.escapeHTML(fallback[:title])}" loading="lazy">
        <span><small>#{CGI.escapeHTML(label)}</small><b>#{CGI.escapeHTML(fallback[:title])}</b></span>
      </a>
    </div>
  HTML
end

def home_discovery_grid(entries)
  DISCOVERY_DOORS.map do |category, label, variant|
    home_discovery_item(entries, category, label, variant)
  end.reject(&:empty?).join("\n")
end

def write_index(entries)
  discovery_grid = home_discovery_grid(entries)
  body = <<~MARKDOWN
    ---
    title: Астария
    lang: ru
    description: Мифологическая энциклопедия Астарии — мира богов, героев и древних цивилизаций.
    aliases:
      - Астария
    ---

    <div class="astaria-home">
      <section class="astaria-home-hero" aria-label="Добро пожаловать в Астарию">
        <img src="assets/images/avatar-on-north.jpg" alt="Воин с огненным клинком встречает чудовищ Астарии" fetchpriority="high">
        <div class="astaria-home-hero-shade"></div>
      </section>

      <section class="astaria-home-intro" aria-labelledby="astaria-home-title">
        <div class="astaria-home-ornament" aria-hidden="true"><span></span></div>
        <p class="astaria-home-era"><span>106</span> год Новой Эры</p>
        <h1 id="astaria-home-title">Астария</h1>
        <p class="astaria-home-lede">Мир древних цивилизаций и опасных богов, где судьбы народов меняют герои, сумевшие превзойти человеческие пределы.</p>
        <div class="astaria-home-actions">
          <a class="astaria-home-button astaria-home-button-primary" href="places/astaria">Начать путешествие <span aria-hidden="true">→</span></a>
          <a class="astaria-home-button astaria-home-button-quiet" href="map">Открыть карту</a>
        </div>
      </section>

      <section class="astaria-home-portals" aria-label="Основные разделы">
        <article class="astaria-portal astaria-portal-visual astaria-portal-encyclopedia">
          <div class="astaria-portal-image">
            <img src="assets/images/silvian_lake.jpg" alt="Водопады и озеро Астарии" loading="lazy">
          </div>
          <div class="astaria-portal-copy">
            <p class="astaria-portal-kicker">Оглавление мира</p>
            <h2>Энциклопедия</h2>
            <p>Народы, страны, личности и существа — всё, из чего соткан живой мир.</p>
            <div class="astaria-topic-links" aria-label="Популярные разделы">
              <a href="countries/">Страны</a>
              <a href="characters/">Персонажи</a>
              <a href="gods/">Боги</a>
            </div>
            <details class="astaria-home-directory">
              <summary>Все разделы <span aria-hidden="true">⌄</span></summary>
              <nav aria-label="Разделы энциклопедии">
                <a href="places/">Места</a>
                <a href="countries/">Страны</a>
                <a href="peoples/">Народы</a>
                <a href="characters/">Персонажи</a>
                <a href="gods/">Боги</a>
                <a href="bestiary/">Бестиарий</a>
                <a href="imitei/">Имитеи</a>
                <a href="organizations/">Организации</a>
                <a href="lore/">Знания</a>
                <a href="items/">Предметы</a>
                <a href="events/">События</a>
                <a href="literature/">Литература</a>
                <a href="flora/">Флора</a>
              </nav>
            </details>
          </div>
        </article>
        <article class="astaria-portal astaria-portal-visual astaria-portal-map">
          <a class="astaria-portal-hit" href="map" aria-label="Исследовать интерактивную карту Астарии">
            <div class="astaria-portal-image">
              <img src="assets/maps/web/states-web.jpg" alt="Политическая карта Астарии" loading="lazy">
              <span class="astaria-map-pin astaria-map-pin-one" aria-hidden="true"></span>
              <span class="astaria-map-pin astaria-map-pin-two" aria-hidden="true"></span>
              <span class="astaria-map-pin astaria-map-pin-three" aria-hidden="true"></span>
            </div>
            <div class="astaria-portal-copy">
              <p class="astaria-portal-kicker">132 места на карте</p>
              <h2>Исследовать мир</h2>
              <p>Океаны, государства и забытые уголки на одной интерактивной карте.</p>
              <span class="astaria-portal-link">Открыть карту <b aria-hidden="true">→</b></span>
            </div>
          </a>
        </article>
        <article class="astaria-portal astaria-portal-visual astaria-portal-timeline">
          <a class="astaria-portal-hit" href="timeline/" aria-label="Открыть хронологию Астарии">
            <div class="astaria-portal-image">
              <img src="assets/images/acheus_invasion.jpg" alt="Древний город во время великого вторжения" loading="lazy">
            </div>
            <div class="astaria-portal-copy">
              <p class="astaria-portal-kicker">Сквозь эпохи</p>
              <h2>Хронология</h2>
              <ol class="astaria-mini-timeline">
                <li><span>5025 ХЭ</span> Приход Археев</li>
                <li><span>426 ХЭ</span> Основание Талассии</li>
                <li><span>106 НЭ</span> Нынешняя эпоха</li>
              </ol>
              <span class="astaria-portal-link">Увидеть всю историю <b aria-hidden="true">→</b></span>
            </div>
          </a>
        </article>
      </section>

      <section class="astaria-home-discover" aria-labelledby="astaria-discover-title">
        <div class="astaria-home-section-heading">
          <div>
            <p class="astaria-portal-kicker">Пять дверей в Астарию</p>
            <h2 id="astaria-discover-title">Куда отправиться дальше?</h2>
          </div>
          <div class="astaria-discovery-heading-actions">
            <p>Каждый раз Астария открывает другой путь — через страну, героя, божество, место или существо.</p>
            <button class="astaria-discovery-shuffle" type="button"><span aria-hidden="true">↻</span> Другие пути</button>
          </div>
        </div>
        <div class="astaria-discovery-grid">#{discovery_grid}</div>
        <p class="astaria-discovery-status sr-only" aria-live="polite"></p>
      </section>

      <footer class="astaria-home-footer">
        <span aria-hidden="true">✦</span>
        <p>Всякая легенда начинается с первого шага.</p>
        <span aria-hidden="true">✦</span>
      </footer>
    </div>
  MARKDOWN

  File.write(File.join(DEST, "index.md"), body)
end

FileUtils.rm_rf(DEST)
FileUtils.mkdir_p(DEST)

entries = []
routes = {}
records = []

PUBLIC_ROOTS.each do |root|
  Dir.glob(File.join(ROOT, root, "**", "*.md")).sort.each do |source|
    next unless publishable_markdown?(source)

    data, body = frontmatter_for(source)
    route = public_route(source, data)
    if routes.key?(route)
      raise "Duplicate public route #{route.inspect}: #{routes[route]} and #{source}"
    end

    routes[route] = source
    records << { source: source, route: route, data: data, body: body }
  end
end

reference_lookup = build_reference_lookup(records)
records.each do |record|
  entries << write_public_article(
    record[:source],
    record[:route],
    record[:data],
    record[:body],
    reference_lookup
  )
end

write_category_indexes(entries)
write_index(entries) unless entries.any? { |entry| entry[:route] == "index" }

asset_paths = entries.flat_map do |entry|
  asset_paths_from_markdown(entry[:source]) + asset_paths_from_markdown(entry[:path])
end
asset_paths.concat(timeline_events(reference_lookup).map { |event| event[:image] }.compact)
asset_paths.map! { |relative| ASSET_REWRITES.fetch(relative, relative) }
asset_paths.concat([
  "Assets/Images/Avatar on north.jpg",
  "Assets/Images/Acheus_Invasion.jpg",
  "Assets/Images/bg.jpg",
  "Assets/Maps/Web/states-web.jpg",
  "Assets/Maps/states.png",
  "Assets/Maps/heightmap.png",
  "Assets/Maps/biomes.png"
])
asset_paths.uniq.sort.each { |relative| copy_asset(relative) }

puts "Prepared #{entries.size} published notes in #{DEST}"
puts entries.sort_by { |entry| entry[:route] }.map { |entry| "  /#{entry[:route]} <- #{entry[:title]}" }
