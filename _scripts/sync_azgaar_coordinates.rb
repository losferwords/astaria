#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require_relative "astaria_map_coordinates"

options = { root: File.expand_path("..", __dir__) }
parser = OptionParser.new do |opts|
  opts.banner = "Usage: ruby _scripts/sync_azgaar_coordinates.rb [--write | --check] [--report FILE]"
  opts.on("--write", "Synchronize article coordinates and existing settlement marker rows") { options[:write] = true }
  opts.on("--check", "Fail when coordinates need synchronization; never write") { options[:check] = true }
  opts.on("--report FILE", "Write the matching and change report as JSON") { |v| options[:report] = v }
end
parser.parse!
abort parser.to_s unless ARGV.empty? && !(options[:write] && options[:check])

begin
  plan = AstariaMapCoordinates.plan(options[:root])
  if options[:report]
    report = plan.reject { |key, _| key == :changes }
    report[:changed_paths] = plan[:changes].keys.map { |path| Pathname.new(path).relative_path_from(Pathname.new(options[:root])).to_s }
    File.write(options[:report], JSON.pretty_generate(report) + "\n")
  end
  plan[:changes].each { |path, text| File.write(path, text) } if options[:write]
  puts "Matched #{plan[:matches].length} active burgs; #{plan[:changes].length} files #{options[:write] ? 'updated' : 'need updates'}; #{plan[:marker_changes].length}/#{plan[:marker_count]} marker rows adjusted."
  puts "Marker coordinate table: #{plan[:table_changes].length} rows adjusted."
  puts "Settlement notes without an active burg (left unchanged): #{plan[:unmapped_notes].join(', ')}" unless plan[:unmapped_notes].empty?
  exit 1 if options[:check] && !plan[:changes].empty?
rescue AstariaMapCoordinates::Error, KeyError, JSON::ParserError, Psych::Exception => error
  warn "Coordinate synchronization stopped before writing: #{error.message}"
  exit 1
end
