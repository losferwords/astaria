#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "pathname"
require_relative "astaria_translations"

ROOT = Pathname.new(File.expand_path("..", __dir__))
PUBLIC = ROOT.join("_quartz", "public")
ENGLISH_CONTENT = ROOT.join("_quartz", "content-en")
RUSSIAN_CONTENT = ROOT.join("_quartz", "content-ru")
PREVIEW = ARGV.delete("--preview")
abort "Usage: #{$PROGRAM_NAME} [--preview]" unless ARGV.empty?

failures = []
checks = 0

expect = lambda do |condition, message|
  checks += 1
  failures << message unless condition
end

expect.call(PUBLIC.directory?, "Merged Quartz public directory is missing")
expect.call(ENGLISH_CONTENT.directory?, "English generated content is missing")
expect.call(RUSSIAN_CONTENT.directory?, "Russian generated content is missing")

english_index = PUBLIC.join("index.html")
russian_index = PUBLIC.join("__locales", "ru", "index.html")
expect.call(english_index.file?, "English home page is missing")
expect.call(russian_index.file?, "Russian locale home page is missing")

if english_index.file?
  html = english_index.read
  expect.call(html.match?(/<html[^>]+lang="en-GB"/), "English home page has the wrong lang attribute")
  expect.call(html.include?('data-astaria-language="en"'), "English home page has no EN language control")
  expect.call(html.include?('data-astaria-language="ru"'), "English home page has no RU language control")
end

if russian_index.file?
  html = russian_index.read
  expect.call(html.match?(/<html[^>]+lang="ru"/), "Russian home page has the wrong lang attribute")
  expect.call(html.include?('name="robots" content="noindex, nofollow"'), "Russian locale is not marked noindex")
end

russian_html = PUBLIC.join("__locales", "ru").glob("**/*.html")
russian_html.each do |path|
  html = path.read
  expect.call(
    html.match?(/<meta[^>]+name="robots"[^>]+content="[^"]*noindex/i),
    "Hidden Russian page is indexable: #{path.relative_path_from(PUBLIC)}"
  )
end
expect.call(!PUBLIC.join("__locales", "ru", "sitemap.xml").exist?, "Hidden Russian sitemap must not be published")
expect.call(!PUBLIC.join("__locales", "ru", "index.xml").exist?, "Hidden Russian RSS feed must not be published")

allowed_native_names = AstariaTranslations.names.values.map do |entry|
  entry.is_a?(Hash) ? entry["native_name"].to_s : ""
end.reject(&:empty?).uniq

english_text_files = PUBLIC.glob("**/*.{html,json,xml}").reject do |path|
  path.to_s.start_with?(PUBLIC.join("__locales").to_s + File::SEPARATOR)
end
english_text_files.each do |path|
  source = path.read
  # Cyrillic native names are a deliberate display feature of the English
  # encyclopaedia, not an untranslated fragment.
  allowed_native_names.each { |native_name| source = source.gsub(native_name, "") }
  expect.call(
    !source.match?(/[А-Яа-яЁё]/),
    "Visible English build contains Cyrillic: #{path.relative_path_from(PUBLIC)}"
  )
end

ENGLISH_CONTENT.glob("**/*.md").each do |path|
  source = path.read
  allowed_native_names.each { |native_name| source = source.gsub(native_name, "") }
  expect.call(
    !source.match?(/[А-Яа-яЁё]/),
    "Generated English Markdown contains Cyrillic: #{path.relative_path_from(ENGLISH_CONTENT)}"
  )
end

markdown_routes = lambda do |root|
  root.glob("**/*.md").map do |path|
    path.relative_path_from(root).to_s.sub(/\.md\z/, "")
  end.sort
end

english_routes = ENGLISH_CONTENT.directory? ? markdown_routes.call(ENGLISH_CONTENT) : []
russian_routes = RUSSIAN_CONTENT.directory? ? markdown_routes.call(RUSSIAN_CONTENT) : []
if PREVIEW
  missing = english_routes - russian_routes
  expect.call(missing.empty?, "Preview has English routes without Russian counterparts: #{missing.join(', ')}")
else
  missing_ru = english_routes - russian_routes
  missing_en = russian_routes - english_routes
  expect.call(missing_ru.empty?, "English routes without Russian counterparts: #{missing_ru.join(', ')}")
  expect.call(missing_en.empty?, "Russian routes without English counterparts: #{missing_en.join(', ')}")
end

{
  "characters/kenneth-mac-rayne.html" => "Kenneth mac Rayne",
  "characters/nuwa-xi.html" => "Nuwa Xi",
  "characters/qiong-qi.html" => "Qiong-Qi",
  "events/crisis-of-faith-in-amon-astat.html" => "Crisis of Faith in Amon-Astat",
  "events/fall-of-chthon.html" => "Fall of Chthon",
  "events/invasion-of-achaeus.html" => "Invasion of Achaeus",
  "events/schism-of-qadir.html" => "Schism of Qadir",
  "events/war-of-the-thirsty.html" => "War of the Thirsty",
  "map.html" => "Map of Astaria",
  "peoples/dju.html" => "Dju",
  "places/chang-sha.html" => "Chang-Sha",
  "places/dju-suo.html" => "Dju-Suo",
  "places/he-dji-gu.html" => "He-Dji-Gu",
  "places/shenyan.html" => "Shenyan",
  "bestiary/rukh.html" => "Rukh",
  "timeline/index.html" => "History of Astaria"
}.each do |relative, title|
  english_path = PUBLIC.join(relative)
  russian_path = PUBLIC.join("__locales", "ru", relative)
  expect.call(english_path.file?, "Approved English route is missing: /#{relative}")
  expect.call(russian_path.file?, "Matching Russian route is missing: /#{relative}")
  expect.call(english_path.read.include?(title), "English page does not render #{title}") if english_path.file?
end

puts "Checked #{checks} multilingual build invariants"
puts "Routes: #{english_routes.size} en-GB / #{russian_routes.size} ru#{PREVIEW ? ' (preview)' : ''}"
if failures.empty?
  puts "Multilingual Quartz build is valid"
  exit 0
end

failures.each { |failure| warn "- #{failure}" }
abort "Found #{failures.length} multilingual build problems"
