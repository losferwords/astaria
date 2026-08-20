#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "uri"

ROOT = Pathname.new(File.expand_path("..", __dir__))
PUBLIC = ROOT.join("_quartz", "public")
PREVIEW = ARGV.delete("--preview")
abort "Usage: #{$PROGRAM_NAME} [--preview]" unless ARGV.empty?

abort "Quartz build not found: #{PUBLIC}" unless PUBLIC.directory?

broken = []
checked = 0
preview_fallbacks = 0

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
    found = candidates.any?(&:file?)
    if !found && PREVIEW && target.to_s.start_with?(PUBLIC.to_s + File::SEPARATOR)
      relative = target.relative_path_from(PUBLIC)
      locale_target = PUBLIC.join("__locales", "ru", relative)
      locale_candidates = [locale_target]
      locale_candidates << Pathname.new("#{locale_target}.html") if locale_target.extname.empty?
      locale_candidates << locale_target.join("index.html") if locale_target.extname.empty? || path.end_with?("/")
      if locale_candidates.any?(&:file?)
        found = true
        preview_fallbacks += 1
      end
    end
    broken << [html.relative_path_from(PUBLIC).to_s, raw] unless found
  end
end

puts "Checked #{checked} internal links and assets"
puts "Accepted #{preview_fallbacks} untranslated preview targets" if PREVIEW
if broken.empty?
  puts "No broken build references found"
  exit 0
end

broken.each { |source, target| warn "#{source} -> #{target}" }
abort "Found #{broken.length} broken build references"
