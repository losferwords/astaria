#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "pathname"
require "yaml"
require_relative "astaria_translations"

ROOT = Pathname.new(File.expand_path("..", __dir__))
TRANSLATIONS = ROOT.join("_translations", "en-GB", "pages")
RUSSIAN_CONTENT = ROOT.join("_quartz", "content-ru")
ENGLISH_CONTENT = ROOT.join("_quartz", "content-en")

# These values are prose or presentation copy. They are expected to differ
# between languages and may exist only in a translation file.
TRANSLATION_ONLY_FIELDS = %w[
  title aliases description card_subtitle
].freeze

# Sidebar and Imithei-profile fields whose facts must continue to come from the
# Russian canonical note. English files may translate their labels and scalar
# values, but must not add or silently lose the underlying information.
PARITY_FIELDS = %w[
  native_name location_type settlement_type organization_type item_type
  condition_type profession_type medium species current_era birth_year
  death_year current_location birth_place parents siblings children partner
  country region parent_location water mouth continents seas population
  foundation independence capital headquarters ruler founder founders creator
  creation_date authors origin ethnicity people imitei occupation organizations
  deity deities faiths religions church government domains symbols eyes hair
  skin height weight distinguishing_features dimensions habitat average_height
  average_length average_weight lifespan course rarity historical_date
  starting_date ending_date year endingYear conflict_location belligerents
  significance parent_peoples child_locations inhabiting_peoples
  inhabiting_species trade_route associated_places related_places
  related_conflicts associated_organizations related_organizations
  aligned_organization known_practitioners known_individuals
  historical_figures notable_people important_people other_people known_members
  central_characters affected_people related_peoples related_ethnicities
  related_species associated_peoples related_professions related_items
  related_myths controlled_territories contested_territories contested_by
  opposes
].freeze

NUMERIC_FACT_FIELDS = %w[
  current_era birth_year death_year population foundation independence
  creation_date height weight dimensions average_height average_length
  average_weight lifespan historical_date starting_date ending_date year
  endingYear
].freeze

# These collections may be enriched from reverse relationships. During an
# incomplete English preview they are deliberately a subset of Russian data,
# because untranslated source pages are not part of the English build yet.
DERIVED_RELATIONSHIP_FIELDS = %w[
  child_locations controlled_territories inhabiting_species important_people
  notable_people known_members known_individuals known_practitioners
  related_professions deities faiths related_organizations
  associated_organizations related_conflicts
].freeze

failures = []
checks = 0

expect = lambda do |condition, message|
  checks += 1
  failures << message unless condition
end

parse_frontmatter = lambda do |path|
  text = path.read
  yaml_text = text.start_with?("---\n") ? text.split(/^---\s*$/, 3)[1] : ""
  YAML.safe_load(
    yaml_text || "",
    permitted_classes: [Date, Time],
    aliases: true
  ) || {}
rescue Psych::SyntaxError => error
  failures << "Invalid YAML in #{path.relative_path_from(ROOT)}: #{error.message.lines.first.to_s.strip}"
  {}
end

meaningful = lambda do |value|
  !value.nil? && value != false && (!value.respond_to?(:empty?) || !value.empty?)
end

value_shape = lambda do |value|
  case value
  when Array then :array
  when Hash then :mapping
  else :scalar
  end
end

numeric_facts = nil
numeric_facts = lambda do |value|
  case value
  when Array
    value.flat_map { |item| numeric_facts.call(item) }
  when Hash
    value.values.flat_map { |item| numeric_facts.call(item) }
  else
    text = value.to_s
    facts = text.scan(/-?\d+(?:[.,]\s*\d+)?/).map do |number|
      number.gsub(/,\s*/, ".")
    end
    # ChE/ХЭ denotes a negative Chthonic Era year even when display metadata
    # omits a leading minus. A hyphen between positive numbers, by contrast,
    # is a range rather than a sign.
    if text.match?(/(?:ChE|ХЭ)/i)
      facts.map { |number| number.start_with?("-") ? number : "-#{number}" }
    else
      facts
    end
  end
end

reference_targets = nil
reference_targets = lambda do |value|
  case value
  when Array
    value.flat_map { |item| reference_targets.call(item) }
  when Hash
    value.values.flat_map { |item| reference_targets.call(item) }
  else
    value.to_s.scan(/\[\[([^|\]#]+)/).flatten.map(&:strip)
  end
end

normalize = lambda do |value|
  value.to_s
    .split("/", -1)
    .last
    .sub(/\.md\z/i, "")
    .downcase
    .tr("ё", "е")
    .gsub(/\s+/, " ")
    .strip
end

canonical_notes = {}
%w[Энциклопедия Хронология Карты].each do |directory|
  ROOT.join(directory).glob("**/*.md").sort.each do |path|
    next if path.to_s.start_with?(ROOT.join("Энциклопедия", "Секреты").to_s + File::SEPARATOR)

    data = parse_frontmatter.call(path)
    title = data["title"].to_s.strip
    canonical_notes[title] = [path, data] unless title.empty?
  end
end

# First inspect the authored translation overlays themselves. This catches the
# dangerous case where English quietly becomes a second, conflicting database.
translation_pairs = 0
TRANSLATIONS.glob("**/*.md").sort.each do |english_path|
  relative = english_path.relative_path_from(TRANSLATIONS)
  russian_path = ROOT.join(relative)
  next unless russian_path.file?

  translation_pairs += 1
  russian = parse_frontmatter.call(russian_path)
  english = parse_frontmatter.call(english_path)

  (english.keys - russian.keys - TRANSLATION_ONLY_FIELDS).sort.each do |field|
    expect.call(
      false,
      "#{relative}: English adds canonical field #{field.inspect}; add it to the Russian source first"
    )
  end

  (english.keys & russian.keys & PARITY_FIELDS).sort.each do |field|
    russian_value = russian[field]
    english_value = english[field]
    expect.call(
      value_shape.call(russian_value) == value_shape.call(english_value),
      "#{relative}: #{field} changes shape between RU and EN"
    )
    if NUMERIC_FACT_FIELDS.include?(field)
      expect.call(
        numeric_facts.call(russian_value) == numeric_facts.call(english_value),
        "#{relative}: #{field} contains different numeric facts in RU and EN"
      )
    end

    russian_targets = reference_targets.call(russian_value).map(&normalize).sort
    english_targets = reference_targets.call(english_value).map(&normalize).sort
    next if russian_targets.empty? && english_targets.empty?

    expect.call(
      russian_targets == english_targets,
      "#{relative}: #{field} points to different canonical targets in RU and EN"
    )
  end
end

# Every approved native name is a piece of canonical lore rather than an
# English-only decoration. Keeping it in the Russian note also makes both
# sidebars consistent, as requested by the author.
AstariaTranslations.names.each do |canonical_title, entry|
  next unless entry.is_a?(Hash) && entry.key?("native_name")

  note = canonical_notes[canonical_title]
  expect.call(!note.nil?, "#{canonical_title}: approved native name has no canonical note")
  next unless note

  path, data = note
  expect.call(
    data["native_name"] == entry["native_name"],
    "#{path.relative_path_from(ROOT)}: native_name differs from names.yml"
  )
end

unless RUSSIAN_CONTENT.directory? && ENGLISH_CONTENT.directory?
  failures << "Generated locale content is missing; run a multilingual build before the parity audit"
else
  russian_routes = RUSSIAN_CONTENT.glob("**/*.md").to_h do |path|
    [path.relative_path_from(RUSSIAN_CONTENT).to_s, path]
  end
  english_routes = ENGLISH_CONTENT.glob("**/*.md").to_h do |path|
    [path.relative_path_from(ENGLISH_CONTENT).to_s, path]
  end
  common_routes = (russian_routes.keys & english_routes.keys).sort

  common_routes.each do |relative|
    russian = parse_frontmatter.call(russian_routes.fetch(relative))
    english = parse_frontmatter.call(english_routes.fetch(relative))

    PARITY_FIELDS.each do |field|
      russian_present = meaningful.call(russian[field])
      english_present = meaningful.call(english[field])
      next unless russian_present || english_present

      if english_present && !russian_present
        expect.call(
          DERIVED_RELATIONSHIP_FIELDS.include?(field),
          "#{relative}: generated EN has #{field}, but generated RU does not"
        )
        next
      end

      unless english_present
        next if DERIVED_RELATIONSHIP_FIELDS.include?(field)

        russian_targets = reference_targets.call(russian[field])
        known_targets = russian_targets.select do |target|
          !AstariaTranslations.english_title_for(target).to_s.empty?
        end
        expect.call(
          !russian_targets.empty? && known_targets.empty?,
          "#{relative}: generated EN silently loses #{field} from RU"
        )
        next
      end

      expect.call(
        value_shape.call(russian[field]) == value_shape.call(english[field]),
        "#{relative}: generated #{field} changes shape between RU and EN"
      ) unless DERIVED_RELATIONSHIP_FIELDS.include?(field)
      if NUMERIC_FACT_FIELDS.include?(field)
        expect.call(
          numeric_facts.call(russian[field]) == numeric_facts.call(english[field]),
          "#{relative}: generated #{field} contains different numeric facts in RU and EN"
        )
      end
    end
  end

  puts "Compared #{common_routes.size} generated RU/EN page pairs"
end

puts "Checked #{checks} translation metadata parity invariants across #{translation_pairs} authored pairs"
if failures.empty?
  puts "Russian and English metadata parity is valid"
  exit 0
end

failures.each { |failure| warn "- #{failure}" }
abort "Found #{failures.length} translation metadata parity problems"
