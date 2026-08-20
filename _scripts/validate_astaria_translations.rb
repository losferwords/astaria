#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "yaml"
require_relative "astaria_translations"

require_complete = ARGV.delete("--complete")
abort "Usage: #{$PROGRAM_NAME} [--complete]" unless ARGV.empty?

failures = []
names = AstariaTranslations.names
map_fallbacks = []
missing_map_markers = []
published_relatives = []
excluded_prefixes = [
  File.join(AstariaTranslations::ROOT, "Энциклопедия", "Секреты"),
  File.join(AstariaTranslations::ROOT, "Энциклопедия", "Идеи")
].map { |path| "#{path}/" }

unless names.is_a?(Hash) && !names.empty?
  failures << "The en-GB onomasticon is empty"
end

known_titles = %w[Энциклопедия Хронология Карты].flat_map do |root|
  Dir.glob(File.join(AstariaTranslations::ROOT, root, "**", "*.md")).map do |path|
    next if excluded_prefixes.any? { |prefix| path.start_with?(prefix) }

    source = File.read(path)
    next unless source.start_with?("---\n")

    yaml_text = source.split(/^---\s*$/, 3)[1]
    data = YAML.safe_load(
      yaml_text || "",
      permitted_classes: [Date, Time],
      aliases: true
    ) || {}
    if data["quartz"] == true || data["timeline"] == true
      published_relatives << path.delete_prefix("#{AstariaTranslations::ROOT}/")
    end
    data["title"].to_s.strip unless data["title"].to_s.strip.empty?
  end.compact
end.uniq

slugs = {}
names.each do |canonical_title, entry|
  failures << "Unknown canonical title in names.yml: #{canonical_title}" unless known_titles.include?(canonical_title)
  unless entry.is_a?(Hash)
    failures << "#{canonical_title}: entry must be a mapping"
    next
  end

  title = entry["title"].to_s.strip
  slug = entry["slug"].to_s.strip
  failures << "#{canonical_title}: missing English title" if title.empty?
  failures << "#{canonical_title}: English title contains Cyrillic" if title.match?(/[А-Яа-яЁё]/)
  failures << "#{canonical_title}: invalid slug #{slug.inspect}" unless slug.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)

  if slugs.key?(slug)
    failures << "Duplicate approved slug #{slug.inspect}: #{slugs[slug]} and #{canonical_title}"
  else
    slugs[slug] = canonical_title
  end
end

AstariaTranslations.map_layers.each do |key, locales|
  %w[ru en-GB].each do |locale|
    unless locales[locale].is_a?(Hash)
      failures << "Map layer #{key}: missing #{locale} configuration"
      next
    end

    %w[source web].each do |variant|
      relative = locales[locale][variant].to_s
      if relative.empty?
        failures << "Map layer #{key}: missing #{locale} #{variant} path"
      elsif locale == "ru" && !File.file?(File.join(AstariaTranslations::ROOT, relative))
        failures << "Map layer #{key}: missing Russian #{variant} asset #{relative}"
      elsif locale == "en-GB" && !File.file?(File.join(AstariaTranslations::ROOT, relative))
        map_fallbacks << "#{key}/#{variant}"
      end
    end
  end
end

map_sources = Dir.glob(File.join(AstariaTranslations::ROOT, "Карты", "**", "*.md"))
map_sources.each do |path|
  File.read(path).scan(/^\s*-\s+default,\s*\d+,\s*\d+,\s*\[\[([^|\]]+)(?:\|[^\]]+)?\]\]\s*$/) do |match|
    target = match.first.strip
    missing_map_markers << target if AstariaTranslations.english_title_for(target).to_s.empty?
  end
end
missing_map_markers.uniq!
if require_complete && !missing_map_markers.empty?
  failures << "English map marker names are incomplete: #{missing_map_markers.size} missing"
end

translation_paths = Dir.glob(File.join(AstariaTranslations::ENGLISH_ROOT, "pages", "**", "*.md")).sort
translation_paths.each do |path|
  relative = path.delete_prefix("#{AstariaTranslations::ENGLISH_ROOT}/pages/")
  canonical = File.join(AstariaTranslations::ROOT, relative)
  failures << "Translation has no canonical source: #{relative}" unless File.file?(canonical)

  source = File.read(path)
  visible_source = source
    .gsub(/!\[\[[^\]]+\]\]/, "")
    .gsub(/\[\[[^|\]]+\|/, "[[|")
    .gsub(/^native_name:\s*.*$/, "")
  if visible_source.match?(/[А-Яа-яЁё]/)
    failures << "Translation contains visible Cyrillic: #{relative}"
  end
end

translated_relatives = translation_paths.map do |path|
  path.delete_prefix("#{AstariaTranslations::ENGLISH_ROOT}/pages/")
end
completed = (published_relatives & translated_relatives).size
if require_complete && completed != published_relatives.uniq.size
  failures << "English release is incomplete: #{completed}/#{published_relatives.uniq.size} published pages translated"
end

if failures.empty?
  puts "Astaria translation registry is valid (#{names.size} approved names)"
  puts "Completed published page translations: #{completed}/#{published_relatives.uniq.size}"
  total_markers = map_sources.sum do |path|
    File.read(path).scan(/^\s*-\s+default,\s*\d+,\s*\d+,\s*\[\[/).size
  end
  puts "Approved English map marker names: #{total_markers - missing_map_markers.size}/#{total_markers}"
  puts "English map fallbacks: #{map_fallbacks.join(', ')}" unless map_fallbacks.empty?
else
  warn failures.map { |failure| "- #{failure}" }.join("\n")
  exit 1
end
