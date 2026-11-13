# frozen_string_literal: true

require "bigdecimal"
require "date"
require "json"
require "pathname"
require "yaml"

# Coordinates belong to the canonical map space, not PNG pixels or label anchors.
module AstariaMapCoordinates
  class Error < StandardError; end
  NUMBER = /\d+(?:\.\d+)?/.freeze
  MARKER_ROW = /^(\s*-\s+default,\s*)(#{NUMBER})(,\s*)(#{NUMBER})(,\s*\[\[([^|\]]+)(?:\|[^\]]+)?\]\]\s*)$/.freeze
  MARKER_TABLE_ROW = /^(\|[^\n|]+\|[ \t]*)(#{NUMBER})([ \t]*\|[ \t]*)(#{NUMBER})([ \t]*\|[ \t]*\[\[([^|\]]+)(?:\|[^\]]+)?\]\][ \t]*\|[ \t]*)$/.freeze
  module_function

  def decimal(value)
    result = BigDecimal(value.to_s)
    raise Error, "Not a finite coordinate: #{value.inspect}" unless result.finite?
    result
  rescue ArgumentError
    raise Error, "Not a numeric coordinate: #{value.inspect}"
  end

  def number(value)
    text = decimal(value).to_s("F")
    text.sub(/\.0+\z/, "").sub(/(\.\d*?)0+\z/, '\\1')
  end

  def normalize(value)
    value.to_s.split("#", 2).first.to_s.tr("\\", "/").split("/").last.to_s
      .sub(/\.md\z/i, "").downcase.tr("ё", "е").gsub(/\s+/, " ").strip
  end

  def read_note(path)
    text = File.read(path, encoding: "UTF-8")
    match = text.match(/\A---\n(?<yaml>.*?)\n---(?=\n|\z)/m)
    raise Error, "Missing YAML frontmatter: #{path}" unless match

    data = YAML.safe_load(match[:yaml], permitted_classes: [Date, Time], aliases: true) || {}
    { path: path, text: text, yaml: match[:yaml], match: match, data: data,
      stem: File.basename(path, ".md") }
  end

  def read_map(path)
    records = File.binread(path).force_encoding(Encoding::UTF_8).split("\r\n", -1)
    unless records.length == 56 && records[0].start_with?("1.158.0|")
      raise Error, "Unsupported Azgaar format: #{path} (expected 1.158.0, 56 CRLF records)"
    end
    graph = JSON.parse(records[1]).fetch("graph")
    burgs = JSON.parse(records[15]).select { |b| b.is_a?(Hash) && b["i"].to_i.positive? && !b["removed"] }
    ids = burgs.map { |b| b.fetch("i") }
    raise Error, "Duplicate burg IDs: #{path}" unless ids.uniq.length == ids.length

    { width: decimal(graph.fetch("width")), height: decimal(graph.fetch("height")), burgs: burgs }
  end

  def paired_burgs(ru_path, en_path)
    ru = read_map(ru_path)
    en = read_map(en_path)
    raise Error, "RU/EN canvas dimensions differ" unless ru.values_at(:width, :height) == en.values_at(:width, :height)
    en_by_id = en[:burgs].to_h { |b| [b.fetch("i"), b] }
    raise Error, "RU/EN active burg IDs differ" unless ru[:burgs].map { |b| b.fetch("i") }.sort == en_by_id.keys.sort
    ru[:burgs].each do |burg|
      other = en_by_id.fetch(burg.fetch("i"))
      %w[x y].each do |axis|
        raise Error, "RU/EN burg ##{burg['i']} differs on #{axis}" unless decimal(burg.fetch(axis)) == decimal(other.fetch(axis))
      end
      x, y = %w[x y].map { |axis| decimal(burg.fetch(axis)) }
      raise Error, "Burg ##{burg['i']} outside canvas" unless x.between?(0, ru[:width]) && y.between?(0, ru[:height])
    end
    ru
  end

  def with_coordinates(note, x, y)
    yaml = note[:yaml].dup
    { "geoX" => x, "geoY" => y }.each do |key, value|
      field = /^#{key}:.*$/
      raise Error, "Duplicate #{key}: #{note[:path]}" if yaml.scan(field).length > 1
      line = "#{key}: #{number(value)}"
      yaml = yaml.match?(field) ? yaml.sub(field, line) : "#{yaml}\n#{line}"
    end
    text = note[:text].dup
    text[note[:match].begin(:yaml)...note[:match].end(:yaml)] = yaml
    text
  end

  def plan(root)
    root = File.expand_path(root)
    map_path = File.join(root, "Карты", "Карта Астарии.md")
    map_note = read_note(map_path)
    width = decimal(map_note[:data].fetch("map_width"))
    height = decimal(map_note[:data].fetch("map_height"))
    pair = paired_burgs(File.join(root, "Assets/Maps/ru.map"), File.join(root, "Assets/Maps/en.map"))
    raise Error, "Invalid coordinate canvas" unless [width, height, pair[:width], pair[:height]].all?(&:positive?)

    notes = Dir.glob(File.join(root, "Энциклопедия", "Места", "*.md")).sort.map { |path| read_note(path) }
    index = Hash.new { |h, k| h[k] = [] }
    notes.each do |note|
      ([note[:stem], note[:data]["title"]] + Array(note[:data]["aliases"])).compact.each do |key|
        normalized = normalize(key)
        index[normalized] << note unless index[normalized].include?(note)
      end
    end

    changes = {}
    matches = []
    used = {}
    pair[:burgs].each do |burg|
      name = burg.fetch("name")
      preferred = name.start_with?("д. ") ? "Деревня #{name.delete_prefix('д. ')}" : "Город #{name}"
      candidates = index[normalize(preferred)]
      candidates = index[normalize(name)] if candidates.empty?
      raise Error, "Burg ##{burg['i']} #{name.inspect}: expected one article, found #{candidates.length}" unless candidates.length == 1
      note = candidates.first
      raise Error, "Two burgs resolve to #{note[:path]}" if used[note[:path]]
      used[note[:path]] = true
      x = decimal(burg.fetch("x")) * width / pair[:width]
      y = height - decimal(burg.fetch("y")) * height / pair[:height]
      text = with_coordinates(note, x, y)
      changes[note[:path]] = text if text != note[:text]
      matches << { id: burg.fetch("i"), title: note[:stem], path: note[:path], geoX: number(x), geoY: number(y),
                   old_geoX: note[:data]["geoX"], old_geoY: note[:data]["geoY"] }
    end

    by_reference = {}
    matches.each do |match|
      note = notes.find { |n| n[:path] == match[:path] }
      ([note[:stem], note[:data]["title"]] + Array(note[:data]["aliases"])).compact.each do |key|
        key = normalize(key)
        raise Error, "Ambiguous settlement reference: #{key}" if by_reference[key] && by_reference[key][:id] != match[:id]
        by_reference[key] = match
      end
    end
    marker_changes = []
    marker_count = 0
    map_text = map_note[:text].gsub(MARKER_ROW) do |row|
      prefix, old_y, comma, old_x, suffix, target = Regexp.last_match.captures
      marker_count += 1
      match = by_reference[normalize(target)]
      next row unless match
      updated = "#{prefix}#{match[:geoY]}#{comma}#{match[:geoX]}#{suffix}"
      if updated != row
        marker_changes << { title: target, id: match[:id], old_geoX: old_x, old_geoY: old_y,
                            geoX: match[:geoX], geoY: match[:geoY] }
      end
      updated
    end
    table_changes = []
    map_text = map_text.gsub(MARKER_TABLE_ROW) do |row|
      prefix, old_x, separator, old_y, suffix, target = Regexp.last_match.captures
      match = by_reference[normalize(target)]
      next row unless match
      updated = "#{prefix}#{match[:geoX]}#{separator}#{match[:geoY]}#{suffix}"
      table_changes << { title: target, id: match[:id] } if updated != row
      updated
    end
    changes[map_path] = map_text if map_text != map_note[:text]
    without_burg = notes.select { |n| n[:data]["type"] == "settlement" && !used[n[:path]] }.map { |n| n[:stem] }
    { changes: changes, matches: matches, marker_changes: marker_changes, table_changes: table_changes, marker_count: marker_count,
      unmapped_notes: without_burg, root: root }
  end
end
