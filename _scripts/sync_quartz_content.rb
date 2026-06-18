#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "fileutils"
require "yaml"

ROOT = File.expand_path("..", __dir__)
DEST = File.join(ROOT, "_quartz", "content")

PUBLIC_ROOTS = [
  "01 Мир",
  "02 Энциклопедия",
  "04 Хронология",
  "05 Карты"
].freeze

ASSET_REWRITES = {
  "Assets/Maps/states.png" => "Assets/Maps/Web/states-web.jpg",
  "Assets/Maps/heightmap.png" => "Assets/Maps/Web/heightmap-web.jpg",
  "Assets/Maps/biomes.png" => "Assets/Maps/Web/biomes-web.jpg"
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
  data, = frontmatter_for(path)
  data["publish"] == true && data["draft"] != true
end

def copy_file(source, dest_root)
  relative = source.delete_prefix("#{ROOT}/")
  target = File.join(dest_root, relative)
  FileUtils.mkdir_p(File.dirname(target))
  FileUtils.cp(source, target)
  target
end

def rewrite_public_markdown(path)
  text = File.read(path)
  ASSET_REWRITES.each do |source, replacement|
    text = text.gsub(source, replacement)
  end
  File.write(path, text)
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

def write_index(copied)
  published = copied.map { |path| path.delete_prefix("#{DEST}/").delete_suffix(".md") }
  links = published
    .reject { |path| path == "index" }
    .sort
    .map { |path| "- [[#{path}|#{File.basename(path)}]]" }
    .join("\n")

  body = <<~MARKDOWN
    ---
    title: Астария
    publish: true
    ---

    # Астария

    ![[Assets/Images/Silvian_Lake.jpg]]

    Добро пожаловать в энциклопедию мира Астария.

    ## Основные страницы

    - [[01 Мир/Астария|Астария]]
    - [[05 Карты/Карта Астарии|Карта Астарии]]
    - [[04 Хронология/История Астарии|История Астарии]]

    ## Опубликованные заметки

    #{links}
  MARKDOWN

  File.write(File.join(DEST, "index.md"), body)
end

FileUtils.rm_rf(DEST)
FileUtils.mkdir_p(DEST)

copied_markdown = []

PUBLIC_ROOTS.each do |root|
  Dir.glob(File.join(ROOT, root, "**", "*.md")).sort.each do |path|
    next unless publishable_markdown?(path)

    copied_markdown << copy_file(path, DEST)
    rewrite_public_markdown(copied_markdown.last)
  end
end

asset_paths = copied_markdown.flat_map { |path| asset_paths_from_markdown(path) }
asset_paths << "Assets/Images/Silvian_Lake.jpg"

asset_paths.uniq.sort.each do |relative|
  source = File.join(ROOT, relative)
  next unless File.file?(source)

  copy_file(source, DEST)
end

write_index(copied_markdown)

puts "Prepared #{copied_markdown.size} published notes in #{DEST}"
