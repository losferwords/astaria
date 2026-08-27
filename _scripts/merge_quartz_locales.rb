#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"

ROOT = File.expand_path("..", __dir__)
QUARTZ = File.join(ROOT, "_quartz")
ENGLISH = File.join(QUARTZ, "build", "en")
RUSSIAN = File.join(QUARTZ, "build", "ru")
PUBLIC = File.join(QUARTZ, "public")
RUSSIAN_PUBLIC = File.join(PUBLIC, "__locales", "ru")

{
  "English" => ENGLISH,
  "Russian" => RUSSIAN
}.each do |label, path|
  raise "#{label} Quartz build is missing: #{path}" unless File.file?(File.join(path, "index.html"))
end

FileUtils.rm_rf(PUBLIC)
FileUtils.mkdir_p(PUBLIC)
FileUtils.cp_r(File.join(ENGLISH, "."), PUBLIC)
FileUtils.mkdir_p(RUSSIAN_PUBLIC)
FileUtils.cp_r(File.join(RUSSIAN, "."), RUSSIAN_PUBLIC)

# The Russian tree is an implementation detail used by the browser-side locale
# loader. It deliberately has no independent SEO surface or public URL scheme.
Dir.glob(File.join(RUSSIAN_PUBLIC, "**", "*.html")).each do |path|
  html = File.read(path)
  unless html.include?('name="robots"')
    html = html.sub(
      "<head>",
      '<head><meta name="robots" content="noindex, nofollow">'
    )
  end

  # Search result links are created at runtime from body[data-basepath]. Keep
  # those links inside the Russian tree so preview fetches Russian HTML. The
  # locale loader canonicalises the URL when a visitor follows the result.
  html = html.sub(/data-basepath="([^"]*)"/) do
    basepath = Regexp.last_match(1).sub(%r{/\z}, "")
    %(data-basepath="#{basepath}/__locales/ru")
  end
  File.write(path, html)
end
FileUtils.rm_f(File.join(RUSSIAN_PUBLIC, "sitemap.xml"))
FileUtils.rm_f(File.join(RUSSIAN_PUBLIC, "index.xml"))

puts "Merged en-GB and ru Quartz builds into #{PUBLIC}"
