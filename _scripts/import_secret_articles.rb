#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"

SOURCE_DIR = "World-Астария-2fa/articles"
OUT_DIR = "Энциклопедия/Секреты"

REQUESTED = {
  "Тайна происхождения веталов" => "Тайна происхождения Веталов",
  "Догмы Меркаты для Томаса Робинсона" => "Догмы Меркаты для Томаса Робинсона",
  "Игры Богов" => "Игры Богов",
  "Наследие драконов" => "Наследие драконов",
  "Тайны Археев" => "Тайны Археев",
  "Тайна Маяка Душ" => "Тайна Маяка Душ"
}.freeze

TITLE_OVERRIDES_BY_ID = {
  "a043e092-49a9-43f6-a73d-7e4644315d91" => "Тайна происхождения Веталов",
  "48920ae5-f9f2-4ec0-94ca-97437da4089b" => "Оракул",
  "b384d6d2-6650-477e-8025-527029f8458c" => "Нага"
}.freeze

def yaml_scalar(value)
  return "\"\"" if value.nil? || value.to_s.empty?

  value.to_s.inspect
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
    "т.е." => "то есть",
    "Т.е." => "То есть",
    "т.к." => "так как",
    "Т.к." => "Так как",
    "посокльку" => "поскольку",
    "кровожадны монстров" => "кровожадных монстров",
    "на счет" => "насчёт",
    "вообщем-то" => "в общем-то",
    "вообщем" => "в общем",
    "Учёных сразу же заинтересовывают свойства" => "Учёных сразу же заинтересовали свойства",
    "исследования их когнитивных и физических свойств производят" => "исследования их когнитивных и физических свойств произвели",
    "За несколько лет учёным проводят" => "За несколько лет учёные проводят",
    "гуманоид Астарианского происхождения" => "гуманоид астарианского происхождения",
    "стали становится" => "стали становиться",
    "с целью закончить и свернуть программу" => "с целью завершить и свернуть программу",
    "по прежнему" => "по-прежнему",
    "В отличии от" => "В отличие от",
    "Маяка моментально" => "Маяка, моментально",
    "Оставшись без души тело" => "Оставшись без души, тело",
    "либо перебили друг друга или закончили" => "либо перебили друг друга, либо закончили",
    "Часе Сумерек - великой катастрофе, что произойдёт с Солнцем, что освещает" => "Часе Сумерек - великой катастрофе, которая произойдёт с Солнцем, освещающим",
    "Суть Часа Сумерек - это смерть звезды, что зовётся так же" => "Суть Часа Сумерек - смерть звезды, которая зовётся так же",
    "Когда она погаснет - Астарию" => "Когда она погаснет, Астарию",
    "магические силы, что даруют" => "магические силы, которые даруют",
    "не умышленный" => "неумышленный",
    "с семьей Ву" => "с семьёй Ву",
    "торговые отношения с Авгарцами" => "торговые отношения с авгарцами",
    "уничтожает армию Кочевников" => "уничтожает армию кочевников"
  }

  replacements.each_with_object(text) { |(from, to), memo| memo.gsub!(from, to) }
              .gsub(/\s+([,.!?;:])/, '\1')
              .gsub(/([,.!?;:])([^\s\n\)\]"'])/, '\1 \2')
              .gsub(/[ \t]+\n/, "\n")
              .gsub(/\n{3,}/, "\n\n")
              .strip
end

articles = Dir[File.join(SOURCE_DIR, "*.json")].map do |file|
  [file, JSON.parse(File.read(file))]
end

id_to_title = {}
articles.each do |_file, article|
  id_to_title[article["id"]] = article["title"] if article["id"] && article["title"]
end
id_to_title.merge!(TITLE_OVERRIDES_BY_ID)

FileUtils.mkdir_p(OUT_DIR)

selected = articles.select { |_file, article| REQUESTED.key?(article["title"]) }
selected.sort_by! { |_file, article| REQUESTED.keys.index(article["title"]) || 999 }

selected.each do |_file, article|
  title = REQUESTED.fetch(article["title"])
  body = polish_text(normalize_text(article["content"]))

  body = body.gsub(/@\[([^\]]+)\]\(([^:]+):\s*([0-9a-f-]+)\)/) do
    visible = Regexp.last_match(1)
    id = Regexp.last_match(3)
    target = id_to_title[id] || visible
    target == visible ? "[[#{target}]]" : "[[#{target}|#{visible}]]"
  end

  related = body.scan(/\[\[([^\]|#]+)(?:[\]|#])/).flatten.map(&:strip).uniq
  cover = article["cover"].is_a?(Hash) ? article["cover"] : {}
  tags = %w[astaria secret]
  tags << "worldanvil-draft" if article["isDraft"]

  frontmatter = []
  frontmatter << "---"
  frontmatter << "title: #{yaml_scalar(title)}"
  if article["title"] != title
    frontmatter << "aliases:"
    frontmatter << "- #{yaml_scalar(article["title"])}"
  end
  frontmatter << "lang: ru"
  frontmatter << "type: #{yaml_scalar(article["templateType"] || "article")}"
  frontmatter << "category: Секреты"
  frontmatter << "status: secret-imported"
  frontmatter << "secret: true"
  frontmatter << "private: true"
  frontmatter << "wa_id: #{yaml_scalar(article["id"])}"
  frontmatter << "wa_source_title: #{yaml_scalar(article["title"])}" if article["title"] != title
  frontmatter << "wa_url: #{yaml_scalar(article["url"])}" if article["url"] && !article["url"].empty?
  frontmatter << "wa_slug: #{yaml_scalar(article["slug"])}" if article["slug"] && !article["slug"].empty?
  frontmatter << "wa_cover_id: #{cover["id"]}" if cover["id"]
  frontmatter << "wa_cover_url: #{yaml_scalar(cover["url"])}" if cover["url"] && !cover["url"].empty?
  frontmatter << "publish: false"
  frontmatter << "draft: #{!!article["isDraft"]}"
  frontmatter << "wip: #{!!article["isWip"]}"
  frontmatter << "tags:"
  tags.each { |tag| frontmatter << "- #{tag}" }
  unless related.empty?
    frontmatter << "related:"
    related.each { |link| frontmatter << "- #{yaml_scalar("[[#{link}]]")}" }
  end
  frontmatter << "---"

  content = "#{frontmatter.join("\n")}\n\n# #{title}\n\n#{body}\n"
  File.write(File.join(OUT_DIR, "#{title}.md"), content)
end

puts selected.map { |_file, article| REQUESTED.fetch(article["title"]) }
