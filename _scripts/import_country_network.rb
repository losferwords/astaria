#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "set"

SOURCE_DIR = "World-Астария-2fa/articles"
ASSET_DIR = "Assets/Images"
COUNTRY_PRIORITY_PLACE_LIMIT = 12
FULL_IMPORT = ENV["FULL_IMPORT"] == "1"
WRITE_COUNTRY_INDEXES = ENV["WRITE_COUNTRY_INDEXES"] == "1"

FOLDERS = {
  "organization" => {
    "Страны" => "Энциклопедия/Страны",
    "default" => "Энциклопедия/Организации"
  },
  "article" => {
    "Бестиарий" => "Энциклопедия/Бестиарий",
    "Боги" => "Энциклопедия/Знания",
    "Имитеи" => "Энциклопедия/Знания",
    "Литература" => "Энциклопедия/Литература",
    "Народы" => "Энциклопедия/Знания",
    "Персонажи" => "Энциклопедия/Знания",
    "Предметы" => "Энциклопедия/Знания",
    "Секреты" => "Энциклопедия/Секреты",
    "События" => "Энциклопедия/Знания",
    "Страны" => "Энциклопедия/Знания",
    "Флора" => "Энциклопедия/Флора",
    "default" => "Энциклопедия/Знания"
  },
  "condition" => { "default" => "Энциклопедия/Знания" },
  "document" => { "default" => "Энциклопедия/Литература" },
  "ethnicity" => { "default" => "Энциклопедия/Народы" },
  "item" => { "default" => "Энциклопедия/Предметы" },
  "militaryConflict" => { "default" => "Энциклопедия/События" },
  "myth" => { "default" => "Энциклопедия/События" },
  "profession" => { "default" => "Энциклопедия/Имитеи" },
  "person" => {
    "Боги" => "Энциклопедия/Боги",
    "default" => "Энциклопедия/Персонажи"
  },
  "settlement" => { "default" => "Энциклопедия/Места" },
  "location" => { "default" => "Энциклопедия/Места" },
  "landmark" => { "default" => "Энциклопедия/Места" },
  "ritual" => { "default" => "Энциклопедия/Знания" },
  "species" => {
    "Флора" => "Энциклопедия/Флора",
    "default" => "Энциклопедия/Бестиарий"
  }
}.freeze

TITLE_OVERRIDES_BY_ID = {
  "a043e092-49a9-43f6-a73d-7e4644315d91" => "Тайна происхождения Веталов"
}.freeze

PEOPLE_TO_SKIP_AS_CHARACTERS = Set["Дракон Ланг-Ан"].freeze
CATEGORY_PRESENTATION_TITLES = Set[
  "Бестиарий",
  "Боги",
  "Знания",
  "Имитеи",
  "Литература",
  "Места",
  "Народы",
  "Персонажи",
  "Предметы",
  "События",
  "Страны",
  "Флора"
].freeze

COUNTRY_RELATION_OVERRIDES = {
  "Катахтонос" => {
    "professions" => ["[[Оракул]]"],
    "deities" => ["[[Тиресий]]"]
  },
  "Лунаар" => {
    "professions" => ["[[Тень]]"]
  }
}.freeze

def yaml_scalar(value)
  return "\"\"" if value.nil? || value.to_s.empty?

  value.to_s.inspect
end

def frontmatter_value(path, key)
  text = File.read(path)
  text[/^#{Regexp.escape(key)}:\s*(.+)$/, 1]&.strip&.delete_prefix('"')&.delete_suffix('"')
end

def existing_status(path)
  return nil unless File.exist?(path)

  frontmatter_value(path, "status")
end

def updatable_status?(status)
  status.nil? || status.include?("stub") || status == "source-empty"
end

def title_for(article)
  TITLE_OVERRIDES_BY_ID.fetch(article["id"], article["title"])
end

def note_title_for(article)
  title = title_for(article)
  return title unless defined?($duplicate_titles) && $duplicate_titles.include?(article["title"])

  "#{title} - #{article["id"].to_s.split("-").first}"
end

def folder_for(article)
  type = article["templateType"].to_s
  category = article.dig("category", "title").to_s
  mapping = FOLDERS.fetch(type, { "default" => "Энциклопедия/Знания" })
  mapping[category] || mapping["default"]
end

def path_for(article)
  File.join(folder_for(article), "#{note_title_for(article)}.md")
end

def category_presentation_article?(article)
  return false unless article["templateType"] == "article"
  return false unless CATEGORY_PRESENTATION_TITLES.include?(title_for(article))
  return false unless title_for(article) == article.dig("category", "title")

  content = article["content"].to_s
  content.match?(/\[(?:table|toc|timeline|center)\b/i)
end

def local_asset_for(image)
  return nil unless image.is_a?(Hash)

  title = image["title"].to_s
  return nil if title.empty? || title == "header.png"

  exact = File.join(ASSET_DIR, title)
  return exact if File.exist?(exact)

  base = File.basename(title, File.extname(title)).downcase.tr(" ", "_").tr("-", "_")
  Dir[File.join(ASSET_DIR, "*")].find do |candidate|
    File.basename(candidate, File.extname(candidate)).downcase.tr(" ", "_").tr("-", "_") == base
  end
end

def obsidian_embed(path)
  return nil unless path

  "[[#{path}]]"
end

def normalize_text(text)
  text.to_s
      .gsub("\r\n", "\n")
      .gsub("\r", "\n")
      .gsub(" ", " ")
      .gsub(/[“”]/, "\"")
      .gsub(/[‘’]/, "'")
      .gsub("–", "-")
      .gsub("—", "-")
      .gsub(/\[br\s*\/?\]/i, "\n")
      .gsub(/\[h1\|?[^\]]*\]/i, "# ")
      .gsub(/\[\/h1\]/i, "")
      .gsub(/\[h2\|?[^\]]*\]/i, "## ")
      .gsub(/\[\/h2\]/i, "")
      .gsub(/\[h3\|?[^\]]*\]/i, "### ")
      .gsub(/\[\/h3\]/i, "")
      .gsub(/\[b\](.*?)\[\/b\]/im, '**\1**')
      .gsub(/\[i\](.*?)\[\/i\]/im, '*\1*')
      .gsub(/\[u\](.*?)\[\/u\]/im, '\1')
      .gsub(/\[p\]/i, "")
      .gsub(/\[\/p\]/i, "\n\n")
      .gsub(/\[ul\]/i, "\n")
      .gsub(/\[\/ul\]/i, "\n")
      .gsub(/\[ol\]/i, "\n")
      .gsub(/\[\/ol\]/i, "\n")
      .gsub(/\[li\]/i, "- ")
      .gsub(/\[\/li\]/i, "\n")
      .gsub(/\[url:([^\]]+)\](.*?)\[\/url\]/im, '[\2](\1)')
      .gsub(/\[img:([^\]|]+)(?:\|[^\]]*)?\]/i, "")
      .gsub(/\[map:([^\]|]+)(?:\|[^\]]*)?\]/i, "")
      .gsub(/\[container:[^\]]+\]/i, "")
      .gsub(/\[\/container\]/i, "")
      .gsub(/\[row\]/i, "")
      .gsub(/\[\/row\]/i, "")
      .gsub(/\[col[^\]]*\]/i, "")
      .gsub(/\[\/col\]/i, "")
      .gsub(/\[quote\]/i, "> ")
      .gsub(/\[\/quote\]/i, "")
      .gsub(/\[spoiler[^\]]*\]/i, "")
      .gsub(/\[\/spoiler\]/i, "")
end

def polish_text(text)
  replacements = {
    "Сурадж ка Гхара" => "Сурадж Ка Гхара",
    "Сурадж ка Гхар" => "Сурадж Ка Гхар",
    "т. е." => "то есть",
    "т.е." => "то есть",
    "Т. е." => "То есть",
    "Т.е." => "То есть",
    "т. к." => "так как",
    "т.к." => "так как",
    "Т. к." => "Так как",
    "Т.к." => "Так как",
    "посокльку" => "поскольку",
    "кровожадны монстров" => "кровожадных монстров",
    "на счет" => "насчёт",
    "вообщем-то" => "в общем-то",
    "вообщем" => "в общем",
    "по прежнему" => "по-прежнему",
    "В отличии от" => "В отличие от",
    "не потерять при этом" => "не потерял при этом",
    "никогда могут и не встретится" => "никогда могут и не встретиться",
    "часы перевернуться" => "часы перевернутся",
    "Империи Ланг-Ан'а" => "Империи Ланг-Ан",
    "Бога-кузнеца" => "бога-кузнеца",
    "Богиня Ночи" => "богиня Ночи",
    "Богиня Вод" => "богиня Вод",
    "Богиня Крови" => "богиня Крови"
  }

  replacements.each_with_object(text.dup) { |(from, to), memo| memo.gsub!(from, to) }
              .gsub(/\s+([,.!?;:])/, '\1')
              .gsub(/([,.!?;:])([^\s\n\)\]"'])/, '\1 \2')
              .gsub(/[ \t]+\n/, "\n")
              .gsub(/\n{3,}/, "\n\n")
              .strip
end

def article_ref_title(ref)
  return nil unless ref.is_a?(Hash)

  return $id_to_note_title[ref["id"]] if defined?($id_to_note_title) && $id_to_note_title[ref["id"]]

  TITLE_OVERRIDES_BY_ID.fetch(ref["id"], ref["title"])
end

def wikilink(title)
  return nil if title.to_s.empty?

  "[[#{title}]]"
end

def ref_link(ref)
  wikilink(article_ref_title(ref))
end

def ref_links(value)
  Array(value).map { |ref| ref_link(ref) }.compact.uniq
end

def country_profession_links(country)
  (ref_links(country["professions"]) + COUNTRY_RELATION_OVERRIDES.dig(title_for(country), "professions").to_a).uniq
end

def country_deity_links(country)
  (ref_links(country["deities"]) + COUNTRY_RELATION_OVERRIDES.dig(title_for(country), "deities").to_a).uniq
end

def convert_links(body, id_to_title)
  body.gsub(/@\[([^\]]+)\]\(([^:]+):\s*([0-9a-f-]+)\)/) do
    visible = Regexp.last_match(1).strip
    id = Regexp.last_match(3)
    target = id_to_title[id] || visible
    target == visible ? "[[#{target}]]" : "[[#{target}|#{visible}]]"
  end
end

def section(label, value)
  text = polish_text(normalize_text(value))
  return nil if text.empty?

  "## #{label}\n\n#{text}"
end

def yaml_array(lines, key, values)
  return if values.compact.empty?

  lines << "#{key}:"
  values.compact.uniq.each { |value| lines << "  - #{yaml_scalar(value)}" }
end

def important_sections(article)
  case article["templateType"]
  when "organization"
    [
      ["Культура", article["culture"]],
      ["История", article["history"]],
      ["Территория", article["territory"]],
      ["Религия", article["religion"]],
      ["Мифология", article["mythos"]],
      ["Внешние отношения", article["foreignrelations"]],
      ["Военное дело", article["military"]]
    ]
  when "ethnicity"
    [
      ["Культура", article["culture"]],
      ["Общие ценности", article["sharedValues"]],
      ["Обычаи", article["customs"]],
      ["Этикет", article["etiquette"]],
      ["Одежда", article["dresscode"]],
      ["Мифы и легенды", article["mythsAndLegends"]]
    ]
  when "profession"
    [
      ["Назначение", article["purpose"]],
      ["Подготовка", article["qualifications"]],
      ["Структура", article["structure"]],
      ["История", article["history"]],
      ["Общественное положение", article["socialStatus"]]
    ]
  when "settlement", "location", "landmark"
    [
      ["История", article["history"]],
      ["География", article["geography"]],
      ["Туризм", article["tourism"]],
      ["Архитектура", article["architecture"]],
      ["Население", article["demographics"]]
    ]
  when "person"
    [
      ["История", article["history"]],
      ["Внешность", article["bodyFeatures"]],
      ["Особые способности", article["specialAbilities"]],
      ["Мотивация", article["motivation"]],
      ["Религия", article["religion"]],
      ["Цели", article["goals"]]
    ]
  else
    []
  end
end

articles = Dir[File.join(SOURCE_DIR, "*.json")].map { |file| [file, JSON.parse(File.read(file))] }
$duplicate_titles = articles
  .map { |_file, article| article["title"] }
  .group_by(&:itself)
  .select { |_title, titles| titles.size > 1 }
  .keys
  .to_set
by_id = articles.to_h { |_file, article| [article["id"], article] }
by_title = articles.to_h { |_file, article| [article["title"], article] }
$id_to_note_title = articles.to_h { |_file, article| [article["id"], note_title_for(article)] }
id_to_title = $id_to_note_title

country_articles = articles.map(&:last).select do |article|
  article["templateType"] == "organization" && article.dig("category", "title") == "Страны"
end
country_ids = country_articles.map { |article| article["id"] }.to_set

selected_ids = Set.new
if FULL_IMPORT
  selected_ids.merge(articles.map { |_file, article| article["id"] })
else
  selected_ids.merge(country_ids)
  articles.each do |_file, article|
    selected_ids << article["id"] if %w[Народы Имитеи Боги Секреты].include?(article.dig("category", "title"))
  end

  country_articles.each do |country|
    %w[capital leader headofstate headofgovernment rulingorganization].each do |field|
      selected_ids << country.dig(field, "id") if country[field].is_a?(Hash)
    end
    %w[deities professions ethnicities].each do |field|
      Array(country[field]).each { |ref| selected_ids << ref["id"] if ref.is_a?(Hash) }
    end

    Array(country["people"]).each do |person|
      title = article_ref_title(person)
      next if PEOPLE_TO_SKIP_AS_CHARACTERS.include?(title)

      selected_ids << person["id"] if person.is_a?(Hash)
    end

    Array(country["locations"])
      .reject { |place| ref_link(place) == ref_link(country["capital"]) }
      .first(COUNTRY_PRIORITY_PLACE_LIMIT)
      .each { |place| selected_ids << place["id"] if place.is_a?(Hash) }
  end
end

selected_ids.delete(nil)
selected_articles = selected_ids.map { |id| by_id[id] }.compact.reject { |article| category_presentation_article?(article) }

written = []
skipped = []

selected_articles.sort_by { |article| [folder_for(article), title_for(article)] }.each do |article|
  title = note_title_for(article)
  source_title = title_for(article)
  folder = folder_for(article)
  FileUtils.mkdir_p(folder)
  path = path_for(article)
  status = existing_status(path)

  unless updatable_status?(status)
    skipped << path
    next
  end

  cover_path = local_asset_for(article["cover"])
  portrait_path = local_asset_for(article["portrait"])
  flag_path = local_asset_for(article["flag"])

  body = polish_text(convert_links(normalize_text(article["content"]), id_to_title))
  source_body_empty = body.empty?
  body = "_В исходной статье WorldAnvil основной текст отсутствует._" if source_body_empty

  related = body.scan(/\[\[([^\]|#]+)(?:[\]|#])/).flatten.map(&:strip).uniq

  frontmatter = []
  frontmatter << "---"
  frontmatter << "title: #{yaml_scalar(title)}"
  if article["title"] != title || source_title != title
    frontmatter << "aliases:"
    [article["title"], source_title].uniq.each { |article_alias| frontmatter << "  - #{yaml_scalar(article_alias)}" }
  end
  frontmatter << "lang: ru"
  frontmatter << "type: #{yaml_scalar(article["templateType"])}"
  frontmatter << "category: #{yaml_scalar(article.dig("category", "title") || File.basename(folder))}"
  status_value =
    if article.dig("category", "title") == "Секреты"
      "secret-imported"
    elsif source_body_empty
      "source-empty"
    else
      "imported"
    end
  frontmatter << "status: #{status_value}"
  frontmatter << "secret: true" if article.dig("category", "title") == "Секреты"
  frontmatter << "private: true" if article.dig("category", "title") == "Секреты"
  frontmatter << "publish: false"
  frontmatter << "draft: #{!!article["isDraft"]}"
  frontmatter << "wip: #{!!article["isWip"]}"
  frontmatter << "wa_id: #{yaml_scalar(article["id"])}"
  frontmatter << "wa_url: #{yaml_scalar(article["url"])}" if article["url"] && !article["url"].empty?
  frontmatter << "wa_slug: #{yaml_scalar(article["slug"])}" if article["slug"] && !article["slug"].empty?

  if article["cover"].is_a?(Hash)
    frontmatter << "wa_cover_id: #{article.dig("cover", "id")}" if article.dig("cover", "id")
    frontmatter << "wa_cover_url: #{yaml_scalar(article.dig("cover", "url"))}" if article.dig("cover", "url")
  end
  if article["portrait"].is_a?(Hash)
    frontmatter << "wa_portrait_id: #{article.dig("portrait", "id")}" if article.dig("portrait", "id")
    frontmatter << "wa_portrait_url: #{yaml_scalar(article.dig("portrait", "url"))}" if article.dig("portrait", "url")
  end
  if article["flag"].is_a?(Hash)
    frontmatter << "wa_flag_id: #{article.dig("flag", "id")}" if article.dig("flag", "id")
    frontmatter << "wa_flag_url: #{yaml_scalar(article.dig("flag", "url"))}" if article.dig("flag", "url")
  end

  frontmatter << "cover_image: #{yaml_scalar(obsidian_embed(cover_path))}" if cover_path
  frontmatter << "portrait_image: #{yaml_scalar(obsidian_embed(portrait_path))}" if portrait_path
  frontmatter << "flag_image: #{yaml_scalar(obsidian_embed(flag_path))}" if flag_path

  case article["templateType"]
  when "organization"
    frontmatter << "foundation: #{yaml_scalar(article["foundingDate"])}" if article["foundingDate"]
    frontmatter << "capital: #{yaml_scalar(ref_link(article["capital"]))}" if article["capital"].is_a?(Hash)
    ruler = ref_link(article["headofstate"]) || ref_link(article["leader"]) || ref_link(article["headofgovernment"])
    frontmatter << "ruler: #{yaml_scalar(ruler)}" if ruler
    yaml_array(frontmatter, "deities", country_deity_links(article))
    yaml_array(frontmatter, "related_professions", country_profession_links(article))
    yaml_array(frontmatter, "related_ethnicities", ref_links(article["ethnicities"]))
    yaml_array(frontmatter, "important_people", ref_links(article["people"]))
    yaml_array(frontmatter, "controlled_territories", ref_links(article["locations"]).first(60))
  when "ethnicity"
    yaml_array(frontmatter, "major_religions", ref_links(article["majorReligions"]))
    yaml_array(frontmatter, "major_organizations", ref_links(article["majorOrganizations"]))
    yaml_array(frontmatter, "related_organizations", ref_links(article["organizations"]))
  when "person"
    frontmatter << "gender: #{yaml_scalar(article["gender"])}" if article["gender"]
    frontmatter << "ethnicity: #{yaml_scalar(ref_link(article["ethnicity"]))}" if article["ethnicity"].is_a?(Hash)
    frontmatter << "species: #{yaml_scalar(ref_link(article["species"]))}" if article["species"].is_a?(Hash)
    frontmatter << "birth_place: #{yaml_scalar(ref_link(article["birthplace"]))}" if article["birthplace"].is_a?(Hash)
    frontmatter << "current_location: #{yaml_scalar(ref_link(article["currentLocation"]) || ref_link(article["residence"]))}" if article["currentLocation"].is_a?(Hash) || article["residence"].is_a?(Hash)
    %w[eyes hair skin height weight dobDisplay age titles domains classification].each do |field|
      next unless article[field] && !article[field].to_s.empty?

      frontmatter << "#{field}: #{yaml_scalar(polish_text(normalize_text(article[field])))}"
    end
  when "settlement", "location", "landmark"
    frontmatter << "population: #{yaml_scalar(article["population"])}" if article["population"] && !article["population"].to_s.empty?
    frontmatter << "founded: #{yaml_scalar(article["constructed"])}" if article["constructed"] && !article["constructed"].to_s.empty?
    parent_link = ref_link(article["parent"]) || ref_link(article["articleParent"])
    frontmatter << "parent_location: #{yaml_scalar(parent_link)}" if parent_link
    frontmatter << "country: #{yaml_scalar(ref_link(article["organization"]))}" if article["organization"].is_a?(Hash)
    frontmatter << "ruler: #{yaml_scalar(ref_link(article["ruler"]))}" if article["ruler"].is_a?(Hash)
    yaml_array(frontmatter, "child_locations", ref_links(article["children"]).first(30))
  end

  yaml_array(frontmatter, "related", related.map { |link| wikilink(link) })
  frontmatter << "tags:"
  frontmatter << "  - astaria"
  frontmatter << "  - secret" if article.dig("category", "title") == "Секреты"
  frontmatter << "  - state" if article.dig("category", "title") == "Страны"
  frontmatter << "---"

  parts = ["#{frontmatter.join("\n")}\n\n# #{title}\n"]
  parts << "![[#{cover_path}]]\n" if cover_path
  parts << "![[#{portrait_path}]]\n" if portrait_path && portrait_path != cover_path
  parts << "![[#{flag_path}]]\n" if flag_path

  if article.dig("category", "title") == "Страны"
    quick = []
    quick << "- Народ: #{ref_links(article["ethnicities"]).join(", ")}" unless ref_links(article["ethnicities"]).empty?
    quick << "- Имитей: #{country_profession_links(article).join(", ")}" unless country_profession_links(article).empty?
    quick << "- Бог: #{country_deity_links(article).join(", ")}" unless country_deity_links(article).empty?
    ruler = ref_link(article["headofstate"]) || ref_link(article["leader"]) || ref_link(article["headofgovernment"])
    quick << "- Правитель: #{ruler}" if ruler
    quick << "- Столица: #{ref_link(article["capital"])}" if article["capital"].is_a?(Hash)
    parts << "## Ключевая связка\n\n#{quick.join("\n")}\n" unless quick.empty?
  end

  parts << "## Основной текст\n\n#{body}\n"

  if %w[settlement location landmark].include?(article["templateType"])
    place_lines = []
    place_lines << "- Страна или организация: #{ref_link(article["organization"])}" if article["organization"].is_a?(Hash)
    place_lines << "- Родительская область: #{ref_link(article["parent"]) || ref_link(article["articleParent"])}" if article["parent"].is_a?(Hash) || article["articleParent"].is_a?(Hash)
    place_lines << "- Население: #{article["population"]}" if article["population"] && !article["population"].to_s.empty?
    place_lines << "- Основание или постройка: #{article["constructed"]}" if article["constructed"] && !article["constructed"].to_s.empty?
    children = ref_links(article["children"]).first(12)
    place_lines << "- Связанные дочерние места: #{children.join(", ")}" unless children.empty?
    parts << "## Структурные связи\n\n#{place_lines.join("\n")}\n" unless place_lines.empty?
  end

  important_sections(article).each do |label, value|
    converted = convert_links(section(label, value).to_s, id_to_title)
    parts << converted unless converted.empty?
  end

  if article["templateType"] == "person" && article.dig("category", "title") != "Боги"
    parts << <<~FATE.strip

      %% FATE / GM
      aspects:
        concept:
        trouble:
        call_of_blood:
        free_1:
        free_2:
      skills:
        +4:
        +3:
        +2:
        +1:
      stunts:
        - name:
          text:
      stress:
        physical:
        mental:
      consequences:
        mild:
        moderate:
        severe:
      notes: Импортировано из WorldAnvil как заготовка; механика требует ручной вычитки.
      %%
    FATE
  end

  parts << "\n## Связи\n\n```dataview\nLIST\nFROM \"\"\nWHERE contains(file.outlinks, this.file.link)\nSORT title ASC\n```\n"

  File.write(path, "#{parts.join("\n").gsub(/\n{4,}/, "\n\n\n").strip}\n")
  written << path
end

if WRITE_COUNTRY_INDEXES
  priority_path = "Энциклопедия/Страны/Приоритеты переноса связанных статей.md"
  priority_lines = [
  "---",
  "title: \"Приоритеты переноса связанных статей\"",
  "lang: ru",
  "type: migration-plan",
  "category: Страны",
  "status: generated",
  "publish: false",
  "private: true",
  "tags:",
  "  - astaria",
  "  - migration",
  "---",
  "",
  "# Приоритеты переноса связанных статей",
  "",
  "Этот список собран из связей стран WorldAnvil: правители, столицы, важные персонажи и ключевые территории. Он предназначен для дальнейшего переноса контекста, а не для публикации.",
  ""
  ]

  country_articles.sort_by { |country| title_for(country) }.each do |country|
    priority_lines << "## #{title_for(country)}"
    core = []
    core << "Народ: #{ref_links(country["ethnicities"]).join(", ")}" unless ref_links(country["ethnicities"]).empty?
    core << "Имитей: #{country_profession_links(country).join(", ")}" unless country_profession_links(country).empty?
    core << "Бог: #{country_deity_links(country).join(", ")}" unless country_deity_links(country).empty?
    ruler = ref_link(country["headofstate"]) || ref_link(country["leader"]) || ref_link(country["headofgovernment"])
    core << "Правитель: #{ruler}" if ruler
    core << "Столица: #{ref_link(country["capital"])}" if country["capital"].is_a?(Hash)
    priority_lines.concat(core.map { |line| "- #{line}" })

    people = ref_links(country["people"]).reject { |link| PEOPLE_TO_SKIP_AS_CHARACTERS.any? { |skip| link.include?(skip) } }.first(10)
    places = ref_links(country["locations"]).reject { |link| link == ref_link(country["capital"]) }.first(12)
    priority_lines << ""
    priority_lines << "Персонажи для контекста: #{people.join(", ")}." unless people.empty?
    priority_lines << "Места для первоочередного переноса: #{places.join(", ")}." unless places.empty?
    priority_lines << ""
  end

  File.write(priority_path, priority_lines.join("\n").gsub(/\n{3,}/, "\n\n"))
  written << priority_path

  links_path = "Энциклопедия/Страны/Связки стран.md"
  links_lines = [
  "---",
  "title: \"Связки стран\"",
  "lang: ru",
  "type: migration-index",
  "category: Страны",
  "status: generated",
  "publish: false",
  "private: true",
  "tags:",
  "  - astaria",
  "  - migration",
  "---",
  "",
  "# Связки стран",
  "",
  "| Страна | Народ | Имитей | Бог | Правитель | Столица |",
  "| --- | --- | --- | --- | --- | --- |"
  ]

  country_articles.sort_by { |country| title_for(country) }.each do |country|
    ruler = ref_link(country["headofstate"]) || ref_link(country["leader"]) || ref_link(country["headofgovernment"]) || "-"
    row = [
      wikilink(title_for(country)),
      ref_links(country["ethnicities"]).join(", "),
      country_profession_links(country).join(", "),
      country_deity_links(country).join(", "),
      ruler,
      ref_link(country["capital"]) || "-"
    ].map { |cell| cell.to_s.empty? ? "-" : cell }
    links_lines << "| #{row.join(" | ")} |"
  end

  File.write(links_path, links_lines.join("\n"))
  written << links_path
end

puts "written=#{written.size}"
written.each { |path| puts "W #{path}" }
puts "skipped=#{skipped.size}"
skipped.each { |path| puts "S #{path}" }
