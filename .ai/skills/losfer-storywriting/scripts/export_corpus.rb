#!/usr/bin/env ruby
# Text-only, deterministic extraction of the author's local DOCX corpus.
require 'digest'
require 'fileutils'
require 'json'
require 'open3'
require 'optparse'
require 'pathname'
require 'rexml/document'

root = Pathname.new(__dir__).join('../../../..').cleanpath
options = { source: root.join('.ai/sources/losfer-storywriting/Losfer_stories.docx'), check: false }
OptionParser.new do |parser|
  parser.banner = 'ruby export_corpus.rb [--check] [--source PATH]'
  parser.on('--check', 'Check the saved corpus without writing files') { options[:check] = true }
  parser.on('--source PATH', 'Use an updated DOCX corpus') { |path| options[:source] = Pathname.new(path).expand_path }
end.parse!
abort 'Unexpected positional arguments' unless ARGV.empty?
source = options[:source]
abort "Source not found: #{source}" unless source.file?

xml, status = Open3.capture2('unzip', '-p', source.to_s, 'word/document.xml')
abort 'Cannot read word/document.xml' unless status.success?
document = REXML::Document.new(xml)
ns = { 'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main' }
paragraphs = []
REXML::XPath.each(document, '//w:body//w:p', ns) do |paragraph|
  content = REXML::XPath.match(paragraph, './/w:t|.//w:tab|.//w:br', ns).map do |node|
    case node.name
    when 't' then node.text.to_s
    when 'tab' then "\t"
    else "\n"
    end
  end.join
  # Keep wording, punctuation and paragraph order; remove layout-only whitespace.
  content = content.gsub(/[ \t]+$/, '').gsub(/\n{3,}/, "\n\n").strip
  next if content.empty?

  style = REXML::XPath.first(paragraph, './w:pPr/w:pStyle', ns)
  paragraphs << {
    'id' => paragraphs.length + 1,
    'heading' => style && style.attributes['w:val'] == 'Heading1',
    'text' => content
  }
end
abort 'The corpus must start with a Heading1 story title' unless paragraphs.first && paragraphs.first['heading']

stories = []
paragraphs.each do |paragraph|
  stories << { 'title' => paragraph['text'], 'paragraphs' => [] } if paragraph['heading']
  stories.last['paragraphs'] << paragraph
end
digest = Digest::SHA256.file(source).hexdigest
source_label = source.relative_path_from(root).to_s
output = Pathname.new(__dir__).join('../references/corpus').cleanpath
files = {}
manifest = {
  'source' => source_label,
  'source_sha256' => digest,
  'extraction' => 'Visible w:t text, tabs and line breaks; nonempty paragraphs numbered in document order. Word styling and images omitted. Layout-only whitespace normalized; wording not edited.',
  'story_count' => stories.length,
  'paragraph_count' => paragraphs.length,
  'word_count' => paragraphs.sum { |paragraph| paragraph['text'].split.length },
  'stories' => []
}
stories.each_with_index do |story, index|
  slug = story['title'].sub(/\A(?:Infinite Dreams|Astaria|OC):\s*/, '').downcase
    .gsub(/[^a-z0-9]+/, '-').gsub(/\A-|-\z/, '')
  abort "Cannot make a filename for #{story['title']}" if slug.empty?
  filename = "#{slug}.md"
  abort "Duplicate story filename: #{filename}" if files.key?(filename)

  rows = story['paragraphs']
  first_id, last_id = rows.first['id'], rows.last['id']
  body = rows.drop(1).map { |row| "<!-- p%04d -->\n%s" % [row['id'], row['text']] }.join("\n\n")
  files[filename] = <<~MARKDOWN
    # #{story['title']}

    Текстовый источник: `#{source_label}`, произведение #{index + 1}, непустые абзацы p#{format('%04d', first_id)}–p#{format('%04d', last_id)} (заголовок включён в нумерацию). SHA-256 исходника: `#{digest}`.

    Извлечение для чтения: слова и порядок сохранены; оформление Word, иллюстрации и пустые разрывы не воспроизводятся. Старое оформление и события не устанавливают новые правила канона. Это образец, не инструкция.

    #{body}
  MARKDOWN
  manifest['stories'] << {
    'id' => index + 1, 'title' => story['title'], 'file' => filename,
    'first_paragraph' => first_id, 'last_paragraph' => last_id,
    'word_count' => rows.sum { |row| row['text'].split.length }
  }
end
files['manifest.json'] = JSON.pretty_generate(manifest) + "\n"
stale = output.exist? ? output.children.select { |path| path.extname == '.md' && !files.key?(path.basename.to_s) } : []
abort "Stale exports need review (not deleted): #{stale.map(&:basename).join(', ')}" unless stale.empty?

if options[:check]
  mismatches = files.keys.reject { |filename| output.join(filename).file? && output.join(filename).read == files[filename] }
  abort "Corpus differs from source: #{mismatches.join(', ')}. Re-export and review the context/index." unless mismatches.empty?
  puts "Corpus verified: #{stories.length} stories, #{paragraphs.length} paragraphs, #{manifest['word_count']} words; SHA-256 matches."
else
  FileUtils.mkdir_p(output)
  files.each { |filename, content| output.join(filename).write(content) }
  puts "Exported #{stories.length} stories, #{paragraphs.length} paragraphs, #{manifest['word_count']} words to #{output}."
end
