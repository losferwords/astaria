#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("..", __dir__)
ENCYCLOPEDIA = File.join(ROOT, "Энциклопедия")

PEOPLE_TARGETS = {
  "Эллийцы" => /\Aэллий/iu,
  "Гойдаир" => /\Aгойдаир/iu,
  "Надаир" => /\Aнадаир/iu,
  "Хтониды" => /\Aхтонид/iu,
  "Джу" => /\Aджу\z/iu,
  "Лудаир" => /\Aлудаир/iu,
  "Хефат" => /\Aхефат/iu,
  "Кадийцы" => /\Aкадий/iu,
  "Талассийцы" => /\Aталассий/iu,
  "Манаи" => /\Aманаи/iu,
  "Авгарцы" => /\Aавгар/iu,
  "Вактары" => /\Aвактар/iu,
  "Раджати" => /\Aраджати/iu,
  "Ваку" => /\Aваку\z/iu,
  "Эдзо" => /\Aэдзо\z/iu,
  "Венды" => /\Aвенд/iu,
  "Археи" => /\Aархе(?:и|ев|ям|ями|ях|йск)/iu
}.freeze

IMITEI_TARGETS = %w[
  Идеал Горец Друид Профитис Аватар Тень Светоносный Мститель Наварх
  Хранитель Мектиг Вознесённый Ракша Шаман Онмёдзи Страж
  Сау Имитей Оракул Варвар Жнец
].freeze

WIKILINK = /\[\[([^|\]]+)(?:\|([^\]]+))?\]\]/

def uppercase_first(value)
  value.sub(/\A([а-яё])/iu) { Regexp.last_match(1).upcase }
end

def lowercase_first(value)
  value.sub(/\A([а-яё])/iu) { Regexp.last_match(1).downcase }
end

def sentence_start?(prefix)
  tail = prefix.split(/[.!?…]/).last.to_s
  tail.gsub!(/(?:^|\s)[#>*_`~\-—«»“”'()\[\]]+/, " ")
  !tail.match?(/[[:alnum:]А-Яа-яЁё]/u)
end

def normalize_wikilinks(line)
  line.gsub(WIKILINK) do
    link_match = Regexp.last_match
    target = link_match[1]
    alias_text = link_match[2]
    visible = alias_text || target

    if IMITEI_TARGETS.include?(target)
      normalized = uppercase_first(visible)
    elsif (form = PEOPLE_TARGETS[target]) && visible.match?(form)
      normalized = sentence_start?(link_match.pre_match) ? uppercase_first(visible) : lowercase_first(visible)
    else
      next link_match[0]
    end

    if alias_text || normalized != target
      "[[#{target}|#{normalized}]]"
    else
      "[[#{target}]]"
    end
  end
end

def normalize_prose_line(line)
  line = normalize_wikilinks(line)
  line.gsub!(/\bимите(й|я|ю|ем|и|ев|ям|ями|ях)\b/iu) { |word| uppercase_first(word) }
  line.gsub!(/(?<=\d) - (?=\d)/, "–")
  line.gsub!(/ - /, " — ")
  line.gsub!(/(?<=\S) {2,}(?=\S)/, " ")
  line.gsub!(/\bне смотря на\b/iu, "несмотря на")
  line.gsub!(/\bв течении\b/iu, "в течение")
  line.gsub!(/\bполустров/iu) { |word| word.sub(/полустров/i, "полуостров") }
  line.gsub!(/\bтеплющ/iu) { |word| word.sub(/теплющ/i, "теплящ") }
  line.gsub!(/\b([НХ])\.\s*Э\./u, "\\1Э")
  line.gsub!(/"([^"\n]+)"/, "«\\1»") unless line.match?(/<[a-z][^>]*=/i)
  line.gsub!(/(\d),\s+(\d)(?=\s*(?:м|см|кг)\b)/iu, "\\1,\\2")
  line.gsub!(/(?<=\d)(?=(?:м|см|кг)\b)/iu, " ")
  line
end

changed = []
check_only = ARGV.include?("--check")
Dir.glob(File.join(ENCYCLOPEDIA, "**", "*.md")).sort.each do |path|
  next if path.include?(File.join(ENCYCLOPEDIA, "Идеи"))

  source = File.read(path)
  match = source.match(/\A---\s*\n.*?\n---\s*\n/m)
  prefix = match ? match[0] : ""
  body = match ? source.delete_prefix(prefix) : source
  in_fence = false
  in_private_comment = false

  normalized_body = body.lines.map do |line|
    if line.lstrip.start_with?("```")
      in_fence = !in_fence
      next line
    end

    if line.include?("%%")
      marker_count = line.scan("%%").length
      was_private = in_private_comment
      in_private_comment = !in_private_comment if marker_count.odd?
      next line if was_private || in_private_comment || marker_count.positive?
    end

    in_fence || in_private_comment ? line : normalize_prose_line(line)
  end.join

  # Dimensions are metadata as well as prose, so normalize their spacing in the
  # complete note after protected prose blocks have already been preserved.
  normalized = +"#{prefix}#{normalized_body}"
  normalized.gsub!(/(\d),\s+(\d)(?=\s*(?:м|см|кг)(?:\b|"))/iu, "\\1,\\2")
  normalized.gsub!(/(?<=\d)(?=(?:м|см|кг)(?:\b|"))/iu, " ")
  normalized.gsub!(/\bимите(й|я|ю|ем|и|ев|ям|ями|ях)\b/iu) { |word| uppercase_first(word) }
  normalized.gsub!(/[ \t]+(?=\n|\z)/, "")
  next if normalized == source

  changed << path.delete_prefix("#{ROOT}/")
  File.write(path, normalized) unless check_only
end

if check_only && changed.any?
  warn "Найдены ненормализованные статьи:"
  changed.each { |path| warn "- #{path}" }
  exit 1
end

puts check_only ? "Языковая нормализация: OK" : "Нормализовано файлов: #{changed.length}"
