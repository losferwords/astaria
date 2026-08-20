# frozen_string_literal: true

require "date"
require "pathname"
require "yaml"

module AstariaTranslations
  ROOT = File.expand_path("..", __dir__)
  SUPPORTED_LOCALES = %w[ru en-GB].freeze
  ENGLISH_ROOT = File.join(ROOT, "_translations", "en-GB")
  ENGLISH_NAMES_PATH = File.join(ENGLISH_ROOT, "names.yml")
  MAP_LAYERS_PATH = File.join(ROOT, "_translations", "map-layers.yml")

  module_function

  def locale
    value = ENV.fetch("ASTARIA_LOCALE", "ru")
    raise "Unsupported Astaria locale: #{value}" unless SUPPORTED_LOCALES.include?(value)

    value
  end

  def english?
    locale == "en-GB"
  end

  def names
    @names ||= begin
      document = YAML.safe_load(File.read(ENGLISH_NAMES_PATH), aliases: true) || {}
      document.fetch("names")
    end
  end

  def name_for(canonical_title)
    names[canonical_title.to_s]
  end

  def page_titles
    @page_titles ||= Dir.glob(File.join(ENGLISH_ROOT, "pages", "**", "*.md")).each_with_object({}) do |translation_path, index|
      relative = translation_path.delete_prefix("#{ENGLISH_ROOT}/pages/")
      next if relative.start_with?("Энциклопедия/Идеи/", "Энциклопедия/Секреты/")

      source_path = File.join(ROOT, relative)
      next unless File.file?(source_path)

      source_text = File.read(source_path)
      translated_text = File.read(translation_path)
      next unless source_text.start_with?("---\n") && translated_text.start_with?("---\n")

      source_yaml = source_text.split(/^---\s*$/, 3)[1]
      translated_yaml = translated_text.split(/^---\s*$/, 3)[1]
      source_data = YAML.safe_load(source_yaml || "", permitted_classes: [Date, Time], aliases: true) || {}
      translated_data = YAML.safe_load(translated_yaml || "", permitted_classes: [Date, Time], aliases: true) || {}
      canonical_title = source_data["title"].to_s.strip
      english_title = translated_data["title"].to_s.strip
      index[canonical_title] = english_title unless canonical_title.empty? || english_title.empty?
    end
  end

  def english_title_for(canonical_title)
    approved = name_for(canonical_title)
    return approved.fetch("title") if approved

    page_titles[canonical_title.to_s]
  end

  def map_layers
    @map_layers ||= begin
      document = YAML.safe_load(File.read(MAP_LAYERS_PATH), aliases: true) || {}
      document.fetch("layers")
    end
  end

  def map_layer_for(key, variant: "source")
    layer = map_layers.fetch(key.to_s)
    preferred = layer.fetch(locale).fetch(variant)
    fallback = layer.fetch("ru").fetch(variant)
    File.file?(File.join(ROOT, preferred)) ? preferred : fallback
  end

  def public_slug_for(data)
    approved = name_for(data["title"])&.fetch("slug", nil).to_s.strip
    return approved unless approved.empty?

    data["public_slug"].to_s.strip
  end

  def apply_english_name(data)
    approved = name_for(data["title"])
    return data.dup unless approved

    translated = data.dup
    translated["title"] = approved.fetch("title")
    translated["public_slug"] = approved.fetch("slug")
    translated["native_name"] = approved["native_name"] if approved.key?("native_name")
    translated["aliases"] = Array(approved["aliases"]) + [approved.fetch("title")]
    translated["aliases"].uniq!
    translated
  end

  def translation_path(source)
    relative = Pathname.new(source).relative_path_from(Pathname.new(ROOT)).to_s
    File.join(ENGLISH_ROOT, "pages", relative)
  end

  def translation_for(source)
    path = translation_path(source)
    return nil unless File.file?(path)

    text = File.read(path)
    return [{}, text, path] unless text.start_with?("---\n")

    _before, yaml_text, body = text.split(/^---\s*$/, 3)
    data = YAML.safe_load(
      yaml_text || "",
      permitted_classes: [Date, Time],
      aliases: true
    ) || {}
    [data, body || "", path]
  end
end
