#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "tmpdir"
require_relative "astaria_map_coordinates"

class AzgaarCoordinatesTest < Minitest::Test
  def setup
    @root = Dir.mktmpdir("astaria-coordinates-")
    @places = File.join(@root, "Энциклопедия/Места")
    @map_note = File.join(@root, "Карты/Карта Астарии.md")
    @city = File.join(@places, "Город Тест.md")
    FileUtils.mkdir_p([@places, File.dirname(@map_note), File.join(@root, "Assets/Maps")])
    File.write(@city, <<~MD)
      ---
      title: Город Тест
      aliases: [Прежнее имя]
      type: settlement
      population: 16000
      ready: false
      quartz: false
      geoX: 5000
      geoY: 1000
      ---
      # Тест

      Текст и [[ссылки]] остаются прежними.
    MD
    File.write(@map_note, <<~MD)
      ---
      title: Карта Астарии
      map_width: 7680
      map_height: 4320
      ---
      ```leaflet
      marker:
        - default, 1000, 5000, [[Прежнее имя|Тест]]
        - default, 4220, 3454, [[Антра]]
      ```
      | Маркер | X | Y | Статья |
      | --- | ---: | ---: | --- |
      | Тест | 5000 | 1000 | [[Прежнее имя]] |
      | Антра | 3454 | 4220 | [[Антра]] |
    MD
    @burg = { "i" => 7, "name" => "Тест", "x" => 1381.99, "y" => 301.55 }
    write_maps
  end

  def teardown
    FileUtils.remove_entry(@root)
  end

  def write_map(locale, burg = @burg)
    records = Array.new(56, "")
    records[0] = "1.158.0|fixture"
    records[1] = JSON.generate("graph" => { "width" => 1920, "height" => 1080 })
    records[5] = "<svg>\n<g/>\n</svg>"
    records[15] = JSON.generate([0, burg, { "i" => 9, "name" => "Удалённый", "removed" => true }])
    File.binwrite(File.join(@root, "Assets/Maps/#{locale}.map"), records.join("\r\n"))
  end

  def write_maps
    %w[ru en].each { |locale| write_map(locale) }
  end

  def plan
    AstariaMapCoordinates.plan(@root)
  end

  def test_precision_axis_direction_and_preservation_of_existing_content
    before = AstariaMapCoordinates.read_note(@city)
    result = plan
    match = result[:matches].fetch(0)
    assert_equal 1, result[:matches].length # Deleted burg has no article and is ignored.
    assert_equal ["5527.96", "3113.8"], match.values_at(:geoX, :geoY)
    updated = result[:changes].fetch(@city)
    data = YAML.safe_load(updated.split(/^---$/, 3)[1])
    assert_equal before[:data].reject { |key, _| %w[geoX geoY].include?(key) },
      data.reject { |key, _| %w[geoX geoY].include?(key) }
    assert_equal before[:text].split(/^---$/, 3)[2], updated.split(/^---$/, 3)[2]
    assert_includes result[:changes].fetch(@map_note), "- default, 3113.8, 5527.96, [[Прежнее имя|Тест]]"
    assert_includes result[:changes].fetch(@map_note), "- default, 4220, 3454, [[Антра]]"
    assert_includes result[:changes].fetch(@map_note), "| Тест | 5527.96 | 3113.8 | [[Прежнее имя]] |"
    assert_includes result[:changes].fetch(@map_note), "| Антра | 3454 | 4220 | [[Антра]] |"
    assert_equal 1, result[:table_changes].length
    assert_equal 2, result[:marker_count]
    assert_equal 1, result[:marker_changes].length
  end

  def test_dry_run_and_repeat_synchronization_are_safe
    originals = [@city, @map_note].to_h { |path| [path, File.read(path)] }
    maps = %w[ru en].to_h { |locale| [locale, File.binread(File.join(@root, "Assets/Maps/#{locale}.map"))] }
    result = plan
    assert_equal originals, originals.keys.to_h { |path| [path, File.read(path)] }
    result[:changes].each { |path, text| File.write(path, text) }
    assert_empty plan[:changes]
    assert_empty plan[:marker_changes]
    assert_equal maps, maps.keys.to_h { |locale| [locale, File.binread(File.join(@root, "Assets/Maps/#{locale}.map"))] }
  end

  def test_different_ru_en_geometry_stops_before_any_note_is_changed
    write_map("en", @burg.merge("x" => 1382))
    before = File.read(@city)
    error = assert_raises(AstariaMapCoordinates::Error) { plan }
    assert_includes error.message, "RU/EN burg #7 differs on x"
    assert_equal before, File.read(@city)
  end

  def test_ambiguous_article_stops_instead_of_guessing
    File.write(File.join(@places, "Другой город.md"), "---\ntitle: Другой город\naliases: [Город Тест]\n---\n")
    error = assert_raises(AstariaMapCoordinates::Error) { plan }
    assert_includes error.message, "expected one article, found 2"
  end

  def test_settlement_without_an_active_burg_and_nonsettlement_markers_stay_unchanged
    path = File.join(@places, "Город Подводный.md")
    File.write(path, "---\ntitle: Город Подводный\ntype: settlement\nquartz: true\n---\nПод водой.\n")
    File.open(@map_note, "a") { |file| file.puts "  - default, 10.5, 20.25, [[Город Подводный]]" }
    result = plan
    assert_equal ["Город Подводный"], result[:unmapped_notes]
    refute result[:changes].key?(path)
    assert_includes result[:changes].fetch(@map_note), "- default, 10.5, 20.25, [[Город Подводный]]"
    assert_equal 3, result[:marker_count]
  end

  def test_conversion_uses_canonical_bounds_not_png_dimensions_or_a_fixed_multiplier
    File.write(@map_note, File.read(@map_note).sub("7680", "3840").sub("4320", "2160"))
    assert_equal ["2763.98", "1556.9"], plan[:matches].first.values_at(:geoX, :geoY)
  end

  def test_unknown_format_and_out_of_bounds_coordinates_are_rejected
    File.binwrite(File.join(@root, "Assets/Maps/en.map"), "1.159.0|fixture\r\n")
    assert_raises(AstariaMapCoordinates::Error) { plan }
    @burg["x"] = 1921
    write_maps
    error = assert_raises(AstariaMapCoordinates::Error) { plan }
    assert_includes error.message, "outside canvas"
  end

  def test_nonfinite_canonical_bounds_cannot_be_written_to_articles
    File.write(@map_note, File.read(@map_note).sub("map_width: 7680", "map_width: .inf"))
    before = File.read(@city)
    error = assert_raises(AstariaMapCoordinates::Error) { plan }
    assert_includes error.message, "Not a finite coordinate"
    assert_equal before, File.read(@city)
  end
end
