#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "open3"
require "yaml"

ROOT = File.expand_path("..", __dir__)
ARCHIVE_REF = ENV.fetch("WA_ARCHIVE_REF", "efeb494^")
ARCHIVE_ROOT = "World-Астария-2fa/articles"
PUBLIC_PLACE_TEMPLATES = %w[Settlement Location Landmark].freeze
TARGET_COUNTRIES = ["Империя Ланг-Ан", "Амато"].freeze
CJK_PATTERN = /[一-龯ぁ-んァ-ン]/

apply = ARGV.delete("--apply")
abort "Usage: ruby #{__FILE__} [--apply]" unless ARGV.empty?

def capture_git(*arguments)
  output, status = Open3.capture2("git", *arguments, chdir: ROOT)
  abort "git #{arguments.join(' ')} failed" unless status.success?

  output
end

def frontmatter(path)
  text = File.read(path)
  match = text.match(/\A---\s*\n(.*?)\n---/m)
  return [{}, text] unless match

  data = YAML.safe_load(match[1], permitted_classes: [], aliases: true) || {}
  [data, text]
end

def native_value(alternative_name)
  parts = alternative_name.split(/\s*,\s*/).reject(&:empty?)
  parts.find { |part| part.match?(CJK_PATTERN) } || alternative_name
end

notes = {}
Dir.glob(File.join(ROOT, "Энциклопедия", "**", "*.md")).sort.each do |path|
  next if path.include?(File.join("Энциклопедия", "Секреты"))

  data, text = frontmatter(path)
  title = data["title"].to_s.strip
  notes[title] = { path: path, data: data, text: text } unless title.empty?
end

archive_paths = capture_git(
  "ls-tree",
  "-r",
  "--name-only",
  ARCHIVE_REF,
  "--",
  ARCHIVE_ROOT
).lines.map(&:strip).select do |path|
  basename = File.basename(path)
  (PUBLIC_PLACE_TEMPLATES + ["Person"]).any? { |template| basename.start_with?("#{template}-") } && basename.end_with?(".json")
end

records = archive_paths.map do |archive_path|
  data = JSON.parse(capture_git("show", "#{ARCHIVE_REF}:#{archive_path}"))
  next unless data["state"] == "public"

  if File.basename(archive_path).start_with?("Person-")
    alternative_name = data["pronouns"].to_s.strip
    next unless alternative_name.match?(CJK_PATTERN)

    country = "Персонажи Ланг-Ана и Амато"
    source_field = "pronouns"
  else
    country = data.dig("organization", "title")
    next unless TARGET_COUNTRIES.include?(country)

    alternative_name = data["alternativename"].to_s.strip
    next if alternative_name.empty?

    source_field = "alternativename"
  end

  {
    title: data["title"].to_s,
    country: country,
    alternative_name: alternative_name,
    native_name: native_value(alternative_name),
    source_field: source_field,
    archive_path: archive_path
  }
end.compact.sort_by { |record| [record[:country], record[:title]] }

missing_notes = []
missing_aliases = []
missing_native_names = []
mismatched_native_names = []
updated = []

records.each do |record|
  note = notes[record[:title]]
  unless note
    missing_notes << record
    next
  end

  aliases = Array(note[:data]["aliases"]).map(&:to_s)
  expected_aliases = record[:alternative_name].split(/\s*,\s*/).reject(&:empty?)
  aliases_to_add = expected_aliases.reject { |name| aliases.include?(name) }
  missing_aliases << record unless aliases_to_add.empty?

  current_native_name = note[:data]["native_name"].to_s.strip
  needs_native_name = current_native_name.empty?
  if current_native_name.empty?
    missing_native_names << record
  elsif current_native_name != record[:native_name]
    mismatched_native_names << record.merge(current_native_name: current_native_name)
  end

  next unless apply && (needs_native_name || !aliases_to_add.empty?)

  changed = note[:text].dup
  if needs_native_name
    changed = changed.sub(/^(title:\s*.+\n)/, "\\1native_name: #{JSON.generate(record[:native_name])}\n")
  end
  if aliases_to_add.any?
    alias_lines = aliases_to_add.map { |name| "  - #{JSON.generate(name)}\n" }.join
    if changed.match?(/^aliases:\s*\n(?:  - .*\n)*/)
      changed = changed.sub(/^(aliases:\s*\n(?:  - .*\n)*)/, "\\1#{alias_lines}")
    else
      changed = changed.sub(/^(title:\s*.+\n)/, "\\1aliases:\n#{alias_lines}")
    end
  end
  abort "Could not update native-name metadata in #{note[:path]}" if changed == note[:text]

  File.write(note[:path], changed)
  updated << record
end

puts "WorldAnvil native-name audit (#{ARCHIVE_REF})"
place_records = records.reject { |record| record[:source_field] == "pronouns" }
person_records = records.select { |record| record[:source_field] == "pronouns" }
puts "  Public Lang-An/Amato places with alternative names: #{place_records.length}"
TARGET_COUNTRIES.each do |country|
  puts "  #{country}: #{records.count { |record| record[:country] == country }}"
end
puts "  Public characters with native names in WA pronouns: #{person_records.length}"
puts "  Missing canonical notes: #{missing_notes.length}"
puts "  Missing archive values in aliases: #{missing_aliases.length}"
puts "  Missing native_name fields: #{missing_native_names.length}"
puts "  Conflicting native_name fields: #{mismatched_native_names.length}"
puts "  Updated: #{updated.length}" if apply

problems = missing_notes + mismatched_native_names
problems += missing_aliases + missing_native_names unless apply
problems.each do |record|
  details = [record[:country], record[:title], record[:alternative_name]]
  details << "current=#{record[:current_native_name]}" if record[:current_native_name]
  warn "  #{details.join(' | ')}"
end

exit 1 unless problems.empty?
