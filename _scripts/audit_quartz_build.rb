#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "uri"

ROOT = Pathname.new(File.expand_path("..", __dir__))
PUBLIC = ROOT.join("_quartz", "public")

abort "Quartz build not found: #{PUBLIC}" unless PUBLIC.directory?

broken = []
checked = 0

PUBLIC.glob("**/*.html").each do |html|
  html.read.scan(/(?:href|src|data-src)="([^"]+)"/) do |match|
    raw = match.first
    next if raw.empty? || raw.start_with?("#", "http:", "https:", "mailto:", "data:")

    path = raw.split(/[?#]/, 2).first
    next if path.empty?

    target = if path.start_with?("/astaria/")
      PUBLIC.join(path.delete_prefix("/astaria/"))
    elsif path == "/astaria"
      PUBLIC.join("index.html")
    else
      html.dirname.join(URI.decode_www_form_component(path)).cleanpath
    end

    checked += 1
    candidates = [target]
    candidates << Pathname.new("#{target}.html") if target.extname.empty?
    candidates << target.join("index.html") if target.extname.empty? || path.end_with?("/")
    broken << [html.relative_path_from(PUBLIC).to_s, raw] unless candidates.any?(&:file?)
  end
end

puts "Checked #{checked} internal links and assets"
if broken.empty?
  puts "No broken build references found"
  exit 0
end

broken.each { |source, target| warn "#{source} -> #{target}" }
abort "Found #{broken.length} broken build references"
