#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "cgi"
require "json"
require "rbconfig"
require "yaml"

ROOT = File.expand_path("..", __dir__)
PUBLIC = File.join(ROOT, "_quartz", "public")
CONTENT = File.join(ROOT, "_quartz", "content")

failures = []
checks = 0

expect = lambda do |condition, message|
  checks += 1
  failures << message unless condition
end

read = lambda do |relative|
  path = File.join(PUBLIC, relative)
  expect.call(File.file?(path), "Missing built page: #{relative}")
  File.file?(path) ? File.read(path) : ""
end

parse_frontmatter = lambda do |path|
  source = File.read(path)
  match = source.match(/\A---\s*\n(.*?)\n---/m)
  data = match ? YAML.safe_load(match[1], permitted_classes: [], aliases: true) || {} : {}
  [data, source]
end

category_routes = {
  "Бестиарий" => "bestiary",
  "Боги" => "gods",
  "Знания" => "lore",
  "Имитеи" => "imitei",
  "Литература" => "literature",
  "Места" => "places",
  "Народы" => "peoples",
  "Организации" => "organizations",
  "Персонажи" => "characters",
  "Предметы" => "items",
  "События" => "events",
  "Страны" => "countries",
  "Флора" => "flora"
}

meta_country_order = [
  "Гилас", "Громовые Кланы", "Иомар", "Катахтонос",
  "Империя Ланг-Ан", "Лунаар", "Амон-Астат", "Кадир",
  "Талассия", "Хамоа", "Дикоземье", "Вактар-Йорден",
  "Сурадж Ка Гхар", "Вакумара", "Амато", "Обитель"
]
meta_people_order = [
  "Эллийцы", "Гойдаир", "Надаир", "Хтониды", "Джу", "Лудаир",
  "Хефат", "Кадийцы", "Талассийцы", "Манаи", "Авгарцы", "Вактары",
  "Раджати", "Ваку", "Эдзо", "Венды"
]
meta_imitei_order = [
  "Идеал", "Горец", "Друид", "Профитис", "Аватар", "Тень",
  "Светоносный", "Мститель", "Наварх", "Хранитель", "Мектиг",
  "Вознесённый", "Ракша", "Шаман", "Онмёдзи", "Страж"
]
meta_god_order = [
  "Гиперион I", "Тарун", "Церунна", "Тиресий", "Дракон Ланг-Ан",
  "Мерката", "Аст", "Альзаман", "Калипсо", "Икатерра", "Хангор",
  "Винтра", "Шубханкари", "Руфу", "Ицунэ", "Велисса"
]
card_titles = lambda do |html|
  html.scan(/<h3>([^<]+)<\/h3>/).flatten.map { |title| CGI.unescapeHTML(title) }
end

ready_article_notes = Dir.glob(File.join(ROOT, "Энциклопедия", "**", "*.md")).sort.map do |path|
  next if path.include?(File.join("Энциклопедия", "Секреты"))

  data, source = parse_frontmatter.call(path)
  next unless data["ready"] == true

  { path: path, data: data, source: source }
end.compact

canonical_notes = Dir.glob(File.join(ROOT, "Энциклопедия", "**", "*.md")).sort.map do |path|
  next if path.include?(File.join("Энциклопедия", "Идеи"))

  data, source = parse_frontmatter.call(path)
  next if data["title"].to_s.empty?

  { path: path, data: data, source: source }
end.compact
canonical_by_title = canonical_notes.to_h { |note| [note[:data]["title"].to_s, note] }
public_canonical_notes = canonical_notes.reject do |note|
  note[:path].include?(File.join("Энциклопедия", "Секреты")) ||
    note[:data]["secret"] == true ||
    note[:data]["private"] == true ||
    note[:data]["category"].to_s == "Секреты"
end

expect.call(
  system(RbConfig.ruby, File.join(ROOT, "_scripts", "normalize_encyclopedia_russian.rb"), "--check", out: File::NULL),
  "Encyclopedia language normalization is not idempotent"
)
expect.call(canonical_notes.none? { |note| note[:source].match?(/\b(?:синоби|шиноби)\b/i) }, "Obsolete shinobi terminology remains in the encyclopedia")
expect.call(canonical_notes.none? { |note| note[:data].key?("parent_1") || note[:data].key?("parent_2") }, "Legacy parent_1/parent_2 metadata remains")
expect.call(
  canonical_notes.none? { |note| note[:data].key?("profession") || note[:data].key?("professions") },
  "Legacy profession/professions metadata remains; use imitei and occupation"
)
expect.call(
  public_canonical_notes.none? { |note| note[:source].match?(/Маяк(?:а|е|у|ом)? Душ/i) },
  "Public encyclopedia articles must not mention the Soul Lighthouse"
)

["Ата", "Интлан", "О́ни", "Онмёдзи"].each do |title|
  note = canonical_by_title.fetch(title)
  expect.call(!note[:source].include?("_Описание пока не добавлено._"), "#{title} still has no encyclopedia description")
end

oni = canonical_by_title.fetch("О́ни")
expect.call(oni[:data]["native_name"] == "鬼", "Oni article is missing the canonical Ezo name")
expect.call(Array(oni[:data]["aliases"]).include?("鬼"), "Oni article must keep its kanji as a search alias")
expect.call(Array(oni[:data]["aliases"]).include?("Они"), "Oni article must keep the unaccented spelling as a search alias")
expect.call(oni[:source].include?("# О́ни") && oni[:source].include?("**О́ни**"), "Oni article must display the disambiguating stress mark")

amato = canonical_by_title.fetch("Амато")
expect.call(amato[:data]["ready"] == true && amato[:data]["quartz"] == true, "Amato must be published now that its art is ready")
expect.call(amato[:data]["cover_image"] == "[[Assets/Images/Amato.jpg]]", "Amato must use its canonical cover art")
expect.call(File.file?(File.join(ROOT, "Assets", "Images", "Amato.jpg")), "Amato cover art is missing")
expect.call(!amato[:source].include?("_Описание пока не добавлено._"), "Amato still has no encyclopedia description")
["Основной текст", "Острова и море", "Императорский двор", "Вера, души и божественный ветер", "Обычаи эдзо", "Туманный остров и Обитель"].each do |heading|
  expect.call(amato[:source].include?("## #{heading}"), "Amato article is missing the #{heading} section")
end
["阿魔都", "Острова Душ", "[[Они|О́ни]]", "[[Онмёдзи]]", "神風", "[[Ицунэ]]", "[[Туманный остров]]", "[[Обитель|Обителью]]"].each do |fact|
  expect.call(amato[:source].include?(fact), "Amato article is missing #{fact}")
end
amato_body = amato[:source].split(/^# Амато\s*$/, 2).last.to_s
amato_word_count = amato_body.split.size
expect.call(amato_word_count.between?(450, 800), "Amato article has an unsuitable country-overview length: #{amato_word_count} words")
expect.call(
  !amato[:source].match?(/Кристалл Души|Маяк/i),
  "Amato public article exposes secret Soul Lighthouse lore"
)

kaito = canonical_by_title.fetch("Город Кайто")
expect.call(kaito[:data]["ready"] == false && kaito[:data]["quartz"] == false, "Kaito must remain Obsidian-only until its art is ready")
expect.call(kaito[:data]["native_name"] == "海都", "Kaito article is missing its canonical Ezo name")
expect.call(kaito[:data]["settlement_type"] == "Столица", "Kaito settlement type must be written in Russian")
expect.call(!kaito[:source].include?("_Описание пока не добавлено._"), "Kaito still has no encyclopedia description")
["[[Амато]]", "[[Остров Ояширо|Ояширо]]", "[[Ицунэ]]", "[[Онмёдзи]]"].each do |fact|
  expect.call(kaito[:source].include?(fact), "Kaito article is missing #{fact}")
end
kaito_body = kaito[:source].split(/^# Город Кайто\s*$/, 2).last.to_s
kaito_word_count = kaito_body.split.size
expect.call(kaito_word_count.between?(100, 260), "Kaito article has an unsuitable capital-overview length: #{kaito_word_count} words")
expect.call(!kaito_body.match?(/\b56[\s ]?000\b/), "Kaito population must remain in the sidebar instead of the article body")
expect.call(!kaito[:source].match?(/Маяк/i), "Kaito article exposes secret Soul Lighthouse lore")

vends = canonical_by_title.fetch("Венды")
expect.call(vends[:data]["ready"] == false && vends[:data]["quartz"] == false, "Vends must remain Obsidian-only until their art is ready")
expect.call(vends[:data]["homeland"] == "[[Обитель]]", "Vends article is missing its homeland")
expect.call(vends[:data]["deity"] == "[[Велисса]]", "Vends article is missing its patron deity")
expect.call(Array(vends[:data]["parent_peoples"]).include?("[[Вактары]]"), "Vends article is missing its Vaktar ancestry")
expect.call(!vends[:source].include?("_Описание пока не добавлено._"), "Vends still have no encyclopedia description")
["[[Обитель|Обители]]", "[[Велисса|Велиссы]]", "[[Страж|Стражей]]", "[[Веданский лес|Веданского леса]]"].each do |fact|
  expect.call(vends[:source].include?(fact), "Vends article is missing #{fact}")
end
vends_body = vends[:source].split(/^# Венды\s*$/, 2).last.to_s
vends_word_count = vends_body.split.size
expect.call(vends_word_count.between?(300, 500), "Vends article has an unsuitable people-overview length: #{vends_word_count} words")
expect.call(
  !vends_body.match?(/Росс(?:ия|ии|ию)|Украин|Беларус|Польш|Серб|Хорват|Румын|Литв|богатыр|Коще/i),
  "Vends public article contains a real-world reference or unwanted folklore cliché"
)

mafka = canonical_by_title.fetch("Мафка")
expect.call(mafka[:data]["ready"] == false && mafka[:data]["quartz"] == false, "Mafka must remain Obsidian-only until her art is ready")
expect.call(!mafka[:data].key?("birth_year"), "Mafka must not have an invented chronological birth year")
{
  "occupation" => "Царица Обители",
  "age" => "На вид около 7 лет",
  "hair" => "Белые, средней длины",
  "skin" => "Бледная, румяная",
  "ethnicity" => "Неизвестно",
  "imitei" => false
}.each do |field, value|
  expect.call(mafka[:data][field] == value, "Mafka metadata is missing #{field}: #{value}")
end
["Берегини", "белое ситцевое платье", "[[Страж|Стражей]]", "[[Сигрид Дракендоттир|Сигрид]]", "просто следует доброму сердцу"].each do |fact|
  expect.call(mafka[:source].include?(fact), "Mafka public article is missing #{fact}")
end
expect.call(
  !mafka[:source].match?(/Чистое Сердце|Чёрное Сердце|Кузница Плоти|не взрослеет|нет биологических родителей|душ[ау] вне материнского тела/i),
  "Mafka public article exposes her secret origin"
)

flesh_forge = canonical_by_title.fetch("Кузница Плоти")
expect.call(!flesh_forge[:source].include?("_Описание пока не добавлено._"), "Flesh Forge still has no encyclopedia description")
["[[Шубханкари]]", "[[Ракша|Ракшей]]", "[[Хангор]]", "Весной 106 года НЭ"].each do |fact|
  expect.call(flesh_forge[:source].include?(fact), "Flesh Forge public article is missing #{fact}")
end
expect.call(
  !flesh_forge[:source].match?(/Мафк|Чистое Сердце|Чёрное Сердце|печатн.{0,20}(?:тел|плот)|душа.{0,20}Хангора|Хангор.{0,20}душа/i),
  "Flesh Forge public article exposes its secret mechanics"
)

black_heart = canonical_by_title.fetch("Чёрное Сердце")
["чёрный камень", "обсидиан", "исполнять желания", "[[Велисса|Велиссе]]"].each do |fact|
  expect.call(black_heart[:source].include?(fact), "Black Heart public article is missing #{fact}")
end
expect.call(
  !black_heart[:source].match?(/Мафк|Кузница Плоти|Чистое Сердце|Кристалл Души/i),
  "Black Heart public article exposes its secret origin"
)

{
  "Тайны Мафки" => [
    "нет биологических родителей",
    "не взрослеет",
    "душу вне материнского тела",
    "плоть и кровь",
    "единственным удачным случаем",
    "Велисса является её мамой",
    "можно ранить или убить"
  ],
  "Тайны Велиссы" => [
    "природные кристаллы Астарии",
    "[[Церунна|Церунной]]",
    "первой сумела создать душу",
    "Чистое Сердце",
    "Берегини",
    "Доброе сердце ребёнка"
  ],
  "Тайны Стражей" => [
    "Вторая клятва Стражей",
    "живое Чистое Сердце",
    "не к короне и не к династии",
    "использовать её доброту",
    "защищать её тело"
  ],
  "Тайны Хангора" => [
    "душа, привязанная",
    "по заказу [[Шубханкари]]",
    "печатному станку для живой материи",
    "не создаёт вещество из ничего",
    "создать оболочку для него самого",
    "Единственным удачным отступлением"
  ]
}.each do |title, required_facts|
  secret_note = canonical_by_title.fetch(title)
  expect.call(secret_note[:data]["secret"] == true && secret_note[:data]["private"] == true, "#{title} must remain private")
  expect.call(secret_note[:data]["quartz"] == false, "#{title} must never be published")
  required_facts.each do |fact|
    expect.call(secret_note[:source].include?(fact), "#{title} is missing #{fact}")
  end
end

black_heart_secrets = canonical_by_title.fetch("Тайны Чёрного Сердца")
["душа будущей [[Мафка|Мафки]]", "[[Кузница Плоти|Кузницы Плоти]]", "Что именно осталось в алмазе", "существует ли между ними связь"].each do |fact|
  expect.call(black_heart_secrets[:source].include?(fact), "Black Heart secrets are missing the new Mafka canon: #{fact}")
end

onmyoji = canonical_by_title.fetch("Онмёдзи")
expect.call(onmyoji[:data]["ready"] == true && onmyoji[:data]["quartz"] == true, "Onmyoji must be published now that both portraits are ready")
expect.call(onmyoji[:data]["female_portrait"] == "[[Assets/Images/Onmyoji_f.jpg]]", "Onmyoji is missing the female class portrait")
expect.call(onmyoji[:data]["male_portrait"] == "[[Assets/Images/Onmyoji_m.jpg]]", "Onmyoji is missing the male class portrait")
["Основной текст", "Способности", "Атрибуты"].each do |heading|
  expect.call(onmyoji[:source].include?("## #{heading}"), "Onmyoji article is missing the #{heading} section")
end
expect.call(!onmyoji[:source].match?(/Маяк Душ|Ветер Душ|Рассветное море/), "Onmyoji public article exposes secret Lighthouse lore")
expect.call(onmyoji[:source].split.size <= 360, "Onmyoji public article is too detailed for an Imitei overview")
expect.call(onmyoji[:data]["native_name"] == "陰陽師", "Onmyoji article is missing the canonical Ezo name")
expect.call(Array(onmyoji[:data]["aliases"]).include?("Охотник на демонов"), "Onmyoji article is missing its Common-tongue name")
expect.call(!Array(onmyoji[:data]["aliases"]).include?("Призрак"), "Onmyoji article still exposes the retired Ghost name")
expect.call(!onmyoji[:source].match?(/Призрак/), "Onmyoji public article still uses the retired Ghost name")
["神風", "божественный ветер", "потоками воздуха", "порывами ветра", "туманом"].each do |fact|
  expect.call(onmyoji[:source].include?(fact), "Onmyoji article is missing the wind ability: #{fact}")
end
["подлинное имя", "кандзи собственного имени", "не назначает платы", "сводят счёты с жизнью"].each do |fact|
  expect.call(!onmyoji[:source].include?(fact), "Onmyoji public article exposes discoverable detail: #{fact}")
end

onmyoji_secrets = canonical_by_title.fetch("Тайны Онмёдзи")
expect.call(onmyoji_secrets[:data]["secret"] == true && onmyoji_secrets[:data]["private"] == true, "Onmyoji secrets must remain private")
expect.call(onmyoji_secrets[:data]["quartz"] == false, "Onmyoji secrets must never be published")
["Маяк Душ", "Ветер Душ", "две души", "Кристалл Души", "Привязка души", "Память спасённого", "Последняя мера", "Служение и благодарность", "подлинное имя о́ни", "神風"].each do |fact|
  expect.call(onmyoji_secrets[:source].include?(fact), "Onmyoji secrets are missing #{fact}")
end
expect.call(!canonical_by_title.fetch("Ицунэ")[:source].include?("навсегда теряют зрение"), "Itsune article still claims Onmyoji are blind")
expect.call(!canonical_by_title.fetch("Ицунэ")[:source].match?(/Призрак/), "Itsune article still uses the retired Onmyoji name")
expect.call(!canonical_by_title.fetch("Ицунэ")[:source].match?(/кандзи|связывают с ним душу|соединить его с другой душой/), "Itsune article exposes the Onmyoji initiation")

published_imitei_notes = canonical_notes.select do |note|
  note[:data]["category"] == "Имитеи" &&
    note[:data]["ready"] == true &&
    note[:data]["quartz"] == true
end
all_imitei_notes = canonical_notes.select { |note| note[:data]["category"] == "Имитеи" }
all_imitei_notes.each do |note|
  title = note[:data]["title"]
  description = note[:data]["description"].to_s.strip
  expect.call(description.length.between?(70, 100), "#{title}: class summary must be a complete 70–100 character sentence")
  expect.call(description.end_with?(".") && !description.include?("…"), "#{title}: class summary must end cleanly without truncation")
end
expect.call(
  published_imitei_notes.map { |note| note[:data]["title"] }.sort ==
    meta_imitei_order.reject { |title| title == "Страж" }.sort,
  "Published Imitei notes do not follow the canonical roster"
)
renamed_imitei = {
  "Мектиг" => {
    old_titles: %w[Варвар Варвары],
    public_slug: "mektig",
    old_route: "imitei/barbarian",
    explanation: "оскорбительное название"
  },
  "Ракша" => {
    old_titles: %w[Жнец Жнецы],
    public_slug: "raksha",
    explanation: "На всеобщем языке их часто называют Жнецами"
  },
  "Профитис" => {
    old_titles: %w[Оракул Оракулы],
    public_slug: "profitis",
    old_route: "imitei/oracle",
    explanation: "на всеобщем языке более известные как Оракулы"
  }
}
renamed_imitei.each do |title, expected|
  note = canonical_by_title.fetch(title)
  expect.call(File.basename(note[:path], ".md") == title, "#{title}: canonical filename was not renamed")
  expect.call(note[:data]["public_slug"] == expected[:public_slug], "#{title}: canonical public slug is wrong")
  expected[:old_titles].each do |old_title|
    expect.call(Array(note[:data]["aliases"]).include?(old_title), "#{title}: missing historical alias #{old_title}")
    expect.call(!canonical_by_title.key?(old_title), "#{old_title}: obsolete canonical note still exists")
  end
  expect.call(note[:source].include?(expected[:explanation]), "#{title}: historical common name is not explained")
  if expected[:old_route]
    expect.call(Array(note[:data]["aliases"]).include?(expected[:old_route]), "#{title}: old public route has no redirect alias")
  end
end
expect.call(
  canonical_notes.none? { |note| note[:source].match?(/\[\[(?:Варвар|Жнец|Оракул)(?:\||\]\])/u) },
  "Canonical notes still link to obsolete Imitei titles"
)
invalid_raksha_forms = /
  молодая\ Ракши|
  ту\ самую\ Ракши|
  уставшим\ Ракши|
  великому\ Ракши|
  один\ Ракши|
  Местный\ Ракши|
  настоящ(?:ий|ая)\ (?:\[\[Ракша\|)?Ракши|
  этого\ Ракши|
  заправлял\ Ракши|
  посвятил\ себя\ в\ Ракши|
  называют\ Профитисами
/ix
expect.call(
  canonical_notes.none? { |note| note[:source].match?(invalid_raksha_forms) },
  "Canonical notes contain an invalid singular form of Ракша or a duplicated common name"
)
imitei_patrons = {
  "Идеал" => "Гиперион I",
  "Горец" => "Тарун",
  "Друид" => "Церунна",
  "Профитис" => "Тиресий",
  "Аватар" => "Дракон Ланг-Ан",
  "Тень" => "Мерката",
  "Светоносный" => "Аст",
  "Мститель" => "Альзаман",
  "Наварх" => "Калипсо",
  "Хранитель" => "Икатерра",
  "Мектиг" => "Хангор",
  "Вознесённый" => "Винтра",
  "Ракша" => "Шубханкари",
  "Шаман" => "Руфу",
  "Онмёдзи" => "Ицунэ"
}
imitei_primary_roles = {}
published_imitei_notes.each do |note|
  title = note[:data]["title"]
  deity = note[:data]["deity"].to_s[/\[\[([^|\]]+)/, 1]
  expect.call(deity == imitei_patrons.fetch(title), "#{title}: patron deity is not canonical")
  deity_note = canonical_by_title[deity]
  expect.call(!deity_note.nil?, "#{title}: patron deity article is missing")
  gender = deity_note&.dig(:data, "gender")
  expect.call(%w[Женский Мужской].include?(gender), "#{title}: patron deity has no supported gender")
  imitei_primary_roles[title] = gender == "Женский" ? "female" : "male"
  %w[female_portrait male_portrait].each do |field|
    reference = note[:data][field].to_s
    asset = reference[/\[\[(Assets\/Images\/[^|\]]+)/, 1]
    expect.call(!asset.to_s.empty?, "#{title}: #{field} is missing")
    expect.call(File.file?(File.join(ROOT, asset.to_s)), "#{title}: #{field} asset does not exist")
  end
  expect.call(!note[:data].key?("cover_image"), "#{title}: obsolete Imitei cover_image remains")
  expect.call(!note[:data].key?("gallery"), "#{title}: obsolete Imitei gallery remains")
  expect.call(!note[:source].match?(/_landscape/i), "#{title}: obsolete landscape reference remains")
end
expect.call(
  Dir.glob(File.join(ROOT, "Assets", "Images", "*_landscape.*"), File::FNM_CASEFOLD).empty?,
  "Obsolete Imitei landscape assets remain"
)

raphael = canonical_by_title.fetch("Рафаил Чалак")
expect.call(Array(raphael[:data]["aliases"]).include?("Рафаил"), "Raphael Chalak must keep his short name as an alias")

meravi = canonical_by_title.fetch("Мерави Марджари")
expect.call(File.basename(meravi[:path], ".md") == "Мерави Марджари", "Meravi Mardjari must use her full canonical filename")
expect.call(Array(meravi[:data]["aliases"]).include?("Мерави"), "Meravi Mardjari must keep her short name as an alias")
expect.call(meravi[:data]["ready"] == false && meravi[:data]["quartz"] == false, "Meravi must remain unpublished until her portrait is ready")
{
  "ethnicity" => "[[Раджати]]",
  "birth_year" => "82 НЭ",
  "age" => 24,
  "birth_place" => "[[Деревня Бадракали]]",
  "current_location" => "[[Сурадж Ка Гхар]]",
  "imitei" => "[[Ракша]]"
}.each do |field, value|
  expect.call(meravi[:data][field] == value, "Meravi Mardjari is missing #{field}: #{value}")
end
["старше Чори на семь лет", "## Сёстры", "## Дочь трактирщика", "## Путь Ракши", "тёмно-карих глазах", "алые ритуальные узоры"].each do |fact|
  expect.call(meravi[:source].include?(fact), "Meravi Mardjari article is missing #{fact}")
end
expect.call(
  canonical_notes.none? { |note| note[:source].match?(/\[\[Мерави(?:\||\]\])/u) },
  "Canonical notes still link to Meravi's obsolete short title"
)

shasha = canonical_by_title.fetch("Шаша")
{
  "species" => "[[Нага]]",
  "birth_year" => "83 НЭ",
  "eyes" => "Жёлтые, змеиные",
  "hair" => "Чёрные, густые",
  "skin" => "Зелёная"
}.each do |field, value|
  expect.call(shasha[:data][field] == value, "Shasha metadata is missing #{field}: #{value}")
end

city_body_issues = []
canonical_notes.each do |note|
  next unless note[:data]["type"] == "settlement" && note[:data]["title"].to_s.start_with?("Город ")

  body = note[:source].sub(/\A---\s*\n.*?\n---\s*\n/m, "")
  city_body_issues << note[:path] if body.match?(/^## Население\s*$/)
  city_body_issues << note[:path] if body.match?(/\b(?:около|примерно|более|свыше|до)\s+\d[\d\s ]*(?:человек|жител)/i)
end
expect.call(city_body_issues.empty?, "City population is duplicated in article bodies: #{city_body_issues.uniq.map { |path| File.basename(path) }.join(', ')}")

relation_target = lambda do |value|
  value.to_s[/\[\[([^|\]]+)/, 1]
end
canonical_notes.each do |note|
  title = note[:data]["title"].to_s
  {
    "parents" => "children",
    "children" => "parents",
    "siblings" => "siblings",
    "secret_parents" => "secret_children",
    "secret_children" => "secret_parents",
    "secret_siblings" => "secret_siblings"
  }.each do |source_key, reciprocal_key|
    Array(note[:data][source_key]).each do |value|
      target_title = relation_target.call(value)
      next if target_title.to_s.empty?

      expect.call(target_title != title, "#{title}: #{source_key} relationship points to itself")
      target = canonical_by_title[target_title]
      expect.call(!target.nil?, "#{title}: relationship points to missing character #{target_title}")
      next unless target

      reciprocal_titles = Array(target[:data][reciprocal_key]).map { |item| relation_target.call(item) }.compact
      expect.call(reciprocal_titles.include?(title), "#{title} ↔ #{target_title}: #{source_key}/#{reciprocal_key} is not reciprocal")
    end
  end

  Array(note[:data]["partner"]).each do |value|
    target_title = relation_target.call(value)
    next if target_title.to_s.empty?

    target = canonical_by_title[target_title]
    expect.call(!target.nil?, "#{title}: partner points to missing character #{target_title}")
    next unless target

    reciprocal_titles = Array(target[:data]["partner"]).map { |item| relation_target.call(item) }.compact
    expect.call(reciprocal_titles.include?(title), "#{title} ↔ #{target_title}: partner relationship is not reciprocal")
  end
end
expect.call(ready_article_notes.length >= 301, "Expected the complete ready encyclopedia corpus")
intentionally_unpublished_titles = ["Бордель Уй-Джан", "Город Награкшаса", "Тхаги"]
unpublished_ready_notes = ready_article_notes.reject { |note| note[:data]["quartz"] == true }
expect.call(
  unpublished_ready_notes.map { |note| note[:data]["title"] }.sort == intentionally_unpublished_titles.sort,
  "Unexpected ready articles excluded from Quartz: #{unpublished_ready_notes.map { |note| note[:data]["title"] }.join(', ')}"
)
published_ready_notes = ready_article_notes.select { |note| note[:data]["quartz"] == true }
catalog_ready_notes = published_ready_notes.reject do |note|
  %w[chapter session].include?(note[:data]["type"].to_s)
end

inferred_sidebar_expectations = {
  "countries/iomar.md" => {
    "important_people" => ["Аластриона Растущая", "Блейн из Руше", "Лиарин Ветреная"]
  },
  "imitei/druid.md" => {
    "known_practitioners" => ["Аластриона Растущая", "Блейн из Руше", "Лиарин Ветреная"]
  },
  "imitei/profitis.md" => {
    "known_practitioners" => ["Кассиопея Атанатос", "Левкос Неритис"]
  },
  "places/bahara-city.md" => {
    "child_locations" => ["Бордель Халык-Бындыр"]
  },
  "places/dju-suo.md" => {
    "child_locations" => ["Бордель Уй-Джан", "Таверна Красный Журавль"]
  }
}
inferred_sidebar_expectations.each do |relative, fields|
  path = File.join(CONTENT, relative)
  expect.call(File.file?(path), "Missing generated relationship target: #{relative}")
  next unless File.file?(path)

  data, = parse_frontmatter.call(path)
  fields.each do |field, expected_titles|
    actual_titles = Array(data[field]).map { |value| value.to_s[/\[\[([^|\]]+)/, 1] || value.to_s }
    expected_titles.each do |title|
      expect.call(actual_titles.include?(title), "#{relative}: #{field} is missing inferred #{title}")
    end
    expect.call(actual_titles.length == actual_titles.uniq.length, "#{relative}: #{field} contains duplicate relationships")
  end
end

expected_by_category = catalog_ready_notes.group_by { |note| note[:data]["category"] }.transform_values(&:length)
categories = category_routes.to_h { |category, route| [route, expected_by_category.fetch(category, 0)] }

categories.each do |route, expected|
  html = read.call("#{route}/index.html")
  cards = html.scan(/class="[^"]*astaria-category-card(?:\s|\")/).length
  expect.call(cards == expected, "#{route}: expected #{expected} ready article cards, found #{cards}")
  expect.call(html.include?("astaria-category-header"), "#{route}: category header is missing")
  expect.call(!html.match?(/<pre><code>.*?&lt;(?:article|div|h3|p|span)(?:\s|&gt;)/m), "#{route}: generated card HTML is rendered as visible source code")
  expect.call(!html.include?("Энциклопедия ·"), "#{route}: redundant article count is still shown in the category header")
  unless expected.zero?
    expect.call(html.include?("astaria-category-tools"), "#{route}: large catalog has no local search toolbar")
    expect.call(html.include?("astaria-category-search"), "#{route}: local category search input is missing")
    expect.call(html.scan("data-search=").length == expected, "#{route}: not every card can be found with the local filter")
    ranks = html.scan(/data-meta-rank="(-?\d+)"/).flatten.map(&:to_i)
    expect.call(ranks.length == expected, "#{route}: not every card has a canonical meta rank")
    expect.call(ranks == ranks.sort, "#{route}: cards are not sorted by canonical meta order")
  end
end

representatives = {
  "countries/gilas.html" => %w[astaria-cover-image astaria-sidebar astaria-crest-image],
  "gods/mercate.html" => %w[astaria-sidebar-image astaria-infobox],
  "characters/persephone.html" => %w[astaria-sidebar-image astaria-article-footer],
  "places/khalisat-desert.html" => %w[astaria-cover-image astaria-content-title],
  "peoples/ellians.html" => %w[astaria-cover-image astaria-content-title],
  "characters/nisa-nereid.html" => %w[astaria-sidebar-image astaria-content-title],
  "flora/larudan-tree.html" => %w[astaria-cover-image astaria-content-title]
}

representatives.each do |relative, selectors|
  html = read.call(relative)
  selectors.each do |selector|
    expect.call(html.include?(selector), "#{relative}: expected #{selector}")
  end
  expect.call(html.scan(/<h1(?:\s|>)/).length == 1, "#{relative}: expected exactly one H1")
end

countries = read.call("countries/index.html")
country_titles = card_titles.call(countries)
expected_country_titles = meta_country_order.select { |title| country_titles.include?(title) }
expect.call(country_titles == expected_country_titles, "Countries are not in canonical meta order: #{country_titles.join(', ')}")
expect.call(countries.scan("astaria-category-card-crest").length >= 5, "Country cards must show their crests")
expect.call(!countries.include?("Государство Астарии"), "Country cards still use the generic subtitle")
expect.call(!countries.include?("**"), "Country card descriptions expose Markdown emphasis markers")
["Республика героев", "Союз вольных кланов", "Друидский матриархат", "Приют хтонидов", "Морская держава"].each do |subtitle|
  expect.call(countries.include?(subtitle), "Country cards are missing the distinctive subtitle: #{subtitle}")
end

characters = read.call("characters/index.html")
character_groups = meta_country_order.map { |title| characters.index(">#{title} <span aria-hidden=\"true\">↗</span></a></h2>") }.compact
expect.call(character_groups == character_groups.sort, "Character groups are not in canonical country order")
creature_group = characters.index("Существа</h2>")
expect.call(!creature_group.nil? && creature_group > character_groups.compact.max, "Creature characters must have their own group after countries")
expect.call(!characters.include?("Лица и судьбы"), "Character groups still repeat the 'Лица и судьбы' kicker")
expect.call(!characters.match?(/astaria-category-group.*?<header>.*?\d+ (?:статья|статьи|статей)/m), "Character groups still display redundant article counts")
["gilas", "thunder-clans", "iomar", "katachthonos"].each do |slug|
  expect.call(characters.include?("data-slug=\"countries/#{slug}\""), "Character group does not link to country: #{slug}")
end
["Ниса", "Мэйлун", "Стикс"].each do |title|
  position = characters.index(">#{title}</h3>")
  expect.call(!position.nil? && position > creature_group, "#{title} must appear in the creature character group")
end

character_card_descriptions = characters.scan(/<h3>([^<]+)<\/h3>\s*<p>([^<]*)<\/p>/m).to_h do |title, description|
  [CGI.unescapeHTML(title), CGI.unescapeHTML(description).strip]
end
character_card_descriptions.each do |title, description|
  expect.call(!description.match?(/\A[,;:.—–-]/u), "#{title}: card description starts with orphaned punctuation")
  expect.call(!description.match?(/\A[а-яё]/u), "#{title}: card description starts with a lowercase letter")
end
expect.call(character_card_descriptions["Кион-Чи"]&.start_with?("Известный также"), "Kion-Qi card description is not cleaned up")
expect.call(character_card_descriptions["Ляо Шень"]&.start_with?("Придворный портной"), "Liao Shen card description is not cleaned up")

peoples = read.call("peoples/index.html")
people_titles = card_titles.call(peoples)
expected_people_titles = meta_people_order.select { |title| people_titles.include?(title) } + (people_titles - meta_people_order).sort
expect.call(people_titles == expected_people_titles, "Peoples are not in canonical meta order: #{people_titles.join(', ')}")

imitei = read.call("imitei/index.html")
imitei_titles = card_titles.call(imitei)
expected_imitei_titles = meta_imitei_order.select { |title| imitei_titles.include?(title) } + (imitei_titles - meta_imitei_order).sort
expect.call(imitei_titles == expected_imitei_titles, "Imitei are not in canonical meta order: #{imitei_titles.join(', ')}")
expect.call(imitei_titles.include?("Онмёдзи"), "Onmyoji is missing from the Imitei catalog")
%w[Мектиг Ракша Профитис].each do |title|
  expect.call(imitei_titles.include?(title), "#{title}: canonical Imitei name is missing from the catalog")
end
%w[Варвар Жнец Оракул].each do |title|
  expect.call(!imitei_titles.include?(title), "#{title}: historical common name is still used as a catalog title")
end
expect.call(imitei.scan("astaria-category-card-portrait").length == imitei_titles.length, "Every Imitei catalog card must use a portrait")
published_imitei_notes.each do |note|
  title = note[:data]["title"]
  primary_role = imitei_primary_roles.fetch(title)
  alternate_role = primary_role == "female" ? "male" : "female"
  primary_asset = note[:data]["#{primary_role}_portrait"].to_s[/\[\[([^|\]]+)/, 1]
  alternate_asset = note[:data]["#{alternate_role}_portrait"].to_s[/\[\[([^|\]]+)/, 1]
  primary_url = primary_asset.split("/").map { |part| part.downcase.tr(" ", "-") }.join("/")
  alternate_url = alternate_asset.split("/").map { |part| part.downcase.tr(" ", "-") }.join("/")
  expect.call(imitei.include?(primary_url), "#{title}: catalog card does not use the patron-matching portrait")
  expect.call(!imitei.include?(alternate_url), "#{title}: catalog card also renders the alternate portrait")
end

generated_imitei_notes = Dir.glob(File.join(CONTENT, "imitei", "*.md")).reject { |path| File.basename(path) == "index.md" }
expect.call(generated_imitei_notes.length == published_imitei_notes.length, "Not every published Imitei has a generated page")
generated_imitei_notes.each do |path|
  data, = parse_frontmatter.call(path)
  relative = "imitei/#{File.basename(path, '.md')}.html"
  html = read.call(relative)
  expect.call(html.include?("astaria-imitei-hero"), "#{relative}: class hero is missing")
  expect.call(html.scan(/class=\"astaria-imitei-portrait\"/).length == 2, "#{relative}: expected exactly two class portraits")
  portrait_roles = html.scan(/class=\"astaria-imitei-portrait\" data-portrait=\"(female|male)\"/).flatten
  primary_role = imitei_primary_roles.fetch(data["title"])
  alternate_role = primary_role == "female" ? "male" : "female"
  expect.call(portrait_roles == [primary_role, alternate_role], "#{relative}: portrait order does not follow the patron deity")
  expect.call(html.include?("astaria-imitei-profile"), "#{relative}: class profile is missing")
  expect.call(html.match?(/astaria-imitei-profile.*?<dt>Покровитель<\/dt>/m), "#{relative}: patron is missing from the vertical profile")
  expect.call(!html.include?("astaria-cover-frame"), "#{relative}: obsolete landscape cover is still rendered")
  expect.call(html.scan(/<h1(?:\s|>)/).length == 1, "#{relative}: expected exactly one H1")
  expected_description = CGI.escapeHTML(data["description"].to_s)
  expect.call(
    html.include?(%(<p class="astaria-imitei-lede">#{expected_description}</p>)),
    "#{relative}: hero does not use the curated compact summary"
  )
  expect.call(data["female_portrait"] && data["male_portrait"], "#{relative}: generated portrait metadata is incomplete")
end
onmyoji_html = read.call("imitei/onmyoji.html")
expect.call(onmyoji_html.include?("astaria-imitei-hero-medium-title"), "Onmyoji hero must use the compact title layout")
expect.call(onmyoji_html.include?("astaria-imitei-title-medium"), "Onmyoji title must not overlap its portraits")
{
  "imitei/barbarian.html" => "imitei/mektig",
  "imitei/oracle.html" => "imitei/profitis"
}.each do |old_route, canonical_route|
  redirect = read.call(old_route)
  expect.call(redirect.include?("http-equiv=\"refresh\""), "#{old_route}: legacy route is not a redirect")
  expect.call(redirect.include?(canonical_route.split("/").last), "#{old_route}: redirect does not point to #{canonical_route}")
end

amato_html = read.call("countries/amato.html")
expect.call(amato_html.include?("assets/images/amato.jpg"), "Published Amato page does not render its cover")
expect.call(amato_html.include?("astaria-cover-frame"), "Published Amato page is missing the country cover treatment")

gods = read.call("gods/index.html")
god_titles = card_titles.call(gods)
expected_god_titles = meta_god_order.select { |title| god_titles.include?(title) } + (god_titles - meta_god_order).sort
expect.call(god_titles == expected_god_titles, "Gods are not in canonical meta order: #{god_titles.join(', ')}")
god_article_paths = Dir.glob(File.join(CONTENT, "gods", "*.md")).reject { |path| File.basename(path) == "index.md" }
expect.call(god_article_paths.length == god_titles.length, "Not every published god has a generated article")
god_article_paths.each do |path|
  relative = "gods/#{File.basename(path, '.md')}.html"
  html = read.call(relative)
  expect.call(html.include?("<dt>Сферы влияния</dt>"), "#{relative}: influence spheres are missing from the infobox")
  expect.call(html.include?("<dt>Священные символы</dt>"), "#{relative}: sacred symbols are missing from the infobox")
  expect.call(!html.match?(/<h[2-6][^>]*>\s*(?:Божественные домены|Священные символы)\s*<\/h[2-6]>/), "#{relative}: god metadata is duplicated in the article body")
end

event_notes = canonical_notes.select { |note| note[:data]["category"] == "События" }
event_notes.each do |note|
  title = note[:data]["title"]
  expect.call(!note[:data]["description"].to_s.strip.empty?, "#{title}: event card needs an explicit clean description")
  expect.call(!note[:source].match?(/^>\s*\[!timeline\]/i), "#{title}: obsolete WorldAnvil timeline callout remains")
  expect.call(!note[:source].match?(/^## Основной текст\s*$/), "#{title}: obsolete short/full article split remains")
end

events = read.call("events/index.html")
expect.call(!events.match?(/\[!?timeline\]/i), "Event cards expose timeline markup")
expect.call(!events.include?("Основной текст"), "Event cards expose the obsolete main-text heading")

imitei_article = File.read(File.join(ROOT, "Энциклопедия", "Знания", "Имитей.md"))
known_imitei_section = imitei_article.split("## Известные Имитеи:", 2).last.to_s
imitei_article_positions = meta_imitei_order.map { |title| known_imitei_section.index("[[#{title}") }.compact
expect.call(imitei_article_positions == imitei_article_positions.sort, "Known Imitei list is not in canonical meta order")

bestiary = read.call("bestiary/index.html")
expect.call(bestiary.include?(">Бестиарий</h1>"), "Bestiary must keep its canonical name")
["Ниса", "Мэйлун", "Стикс"].each do |title|
  expect.call(!bestiary.include?(">#{title}</h3>"), "#{title} is an individual and must not appear in Bestiary")
end

places = read.call("places/index.html")
expect.call(places.scan("astaria-category-card-place").length >= 5, "Place cards must use the landscape place layout")
expect.call(places.include?("assets/images/silvian_lake.jpg"), "Astaria place card must use Silvian Lake")
featured_place = places.index("astaria-category-card-featured")
first_regular_place = places.index("astaria-category-card-place", featured_place.to_i + 1)
expect.call(!featured_place.nil? && !first_regular_place.nil? && featured_place < first_regular_place, "Astaria must be the first featured place card")
expect.call(places.include?("Начать путешествие"), "Featured Astaria card is missing its journey call to action")

astaria = read.call("places/astaria.html")
expect.call(astaria.scan("astaria-cover-image").length == 1, "Astaria entry page must have exactly one cover image")
expect.call(astaria.include?("assets/images/silvian_lake.jpg"), "Astaria entry page must use Silvian Lake")
expect.call(!astaria.include?("avatar-on-north"), "Astaria entry page still contains the retired home artwork")
expect.call(astaria.include?("astaria-article-lede"), "Astaria entry page is missing its introductory lede")
expect.call(astaria.scan("astaria-journey-card").length == 6, "Astaria entry page must offer six exploration paths")
expect.call(astaria.scan("astaria-cover-frame").length == 1, "Astaria cover must use the framed article layout")
expect.call(astaria.match?(/class="astaria-cover-image"[^>]*alt="Астария"[^>]*fetchpriority="high"/), "Astaria cover must provide useful alternative text and high LCP priority")
journey_styles = File.read(File.join(ROOT, "_quartz", "quartz", "styles", "custom.scss"))
expect.call(journey_styles.include?("grid-template-rows: auto auto 1fr auto"), "Astaria journey cards must keep their compact aligned row layout")
expect.call(!journey_styles.match?(/\.astaria-journey-card > span\s*\{[^}]*margin-bottom:\s*auto/m), "Astaria journey card number still creates a large vertical gap")
expect.call(journey_styles.include?("padding: 1.25rem !important"), "Astaria journey card padding can be overridden by the generic internal-link rule")
expect.call(journey_styles.match?(/\.astaria-cover-image\s*\{[^}]*width:\s*100%/m), "Article covers must align with the article content width")
expect.call(!journey_styles.match?(/\.astaria-cover-image\s*\{[^}]*margin:\s*0\s+-/m), "Article covers still use asymmetric negative margins")
expect.call(journey_styles.include?(".search .preview-container .astaria-category-grid"), "Search preview must suppress full category grids")
expect.call(
  !journey_styles.match?(/\.astaria-sidebar\.astaria-imitei-profile\s*\{[^}]*float:\s*none/m),
  "Imitei profile is forced into a horizontal full-width layout"
)
expect.call(
  !journey_styles.match?(/\.astaria-imitei-profile \.astaria-infobox dl\s*\{[^}]*display:\s*grid/m),
  "Imitei profile fields are still arranged horizontally"
)

home = read.call("index.html")
expect.call(home.scan("astaria-portal-image").length >= 3, "All three main portals must use the same visual card structure")
expect.call(home.include?("assets/images/silvian_lake.jpg"), "Encyclopedia portal must use the Astaria article cover")
{
  "places/" => "Места",
  "countries/" => "Страны",
  "peoples/" => "Народы",
  "characters/" => "Персонажи",
  "gods/" => "Боги",
  "bestiary/" => "Бестиарий",
  "imitei/" => "Имитеи",
  "organizations/" => "Организации",
  "lore/" => "Знания",
  "items/" => "Предметы",
  "events/" => "События",
  "literature/" => "Литература",
  "flora/" => "Флора"
}.each do |href, label|
  expect.call(home.match?(%r{<a href="\./#{Regexp.escape(href)}"[^>]*>#{Regexp.escape(label)}</a>}), "Home directory is missing #{label} (#{href})")
end
expect.call(journey_styles.match?(/\.astaria-home-portals\s*\{[^}]*align-items:\s*stretch/m), "Main portal cards must be equal-height")
expect.call(journey_styles.match?(/\.markdown-rendered \.astaria-portal-hit[^\{]*\{[^}]*height:\s*100%/m), "Visual portal links must fill equal-height cards")
expect.call(journey_styles.match?(/\.astaria-home-era span\s*\{[^}]*lining-nums tabular-nums/m), "Home era number must use aligned lining numerals")
expect.call(home.scan("data-discovery-candidates=").length == 5, "Home discovery block must contain five randomized thematic doors")
expect.call(home.include?("astaria-discovery-shuffle"), "Home discovery block has no shuffle control")
discovery_pools = home.scan(/data-discovery-candidates="([^"]+)"/).flatten.map do |payload|
  JSON.parse(CGI.unescapeHTML(payload))
end
expect.call(discovery_pools.length == 5 && discovery_pools.all? { |pool| pool.length > 1 }, "Every discovery door must have more than one candidate")
expect.call(discovery_pools.map { |pool| pool.first["label"] } == ["Государство", "Божество", "Личность", "Место", "Бестиарий"], "Discovery doors lost their category balance")
discovery_pools.flatten.each do |candidate|
  expect.call(File.file?(File.join(PUBLIC, "#{candidate["href"]}.html")), "Discovery candidate has no public page: #{candidate["href"]}")
  image_path = candidate["image"].sub(%r{\A\.?/}, "")
  expect.call(File.file?(File.join(PUBLIC, image_path)), "Discovery candidate has no public image: #{candidate["image"]}")
end
experience_script = File.read(File.join(ROOT, "_quartz", "quartz", "components", "scripts", "astaria.inline.ts"))
expect.call(experience_script.include?("setupAstariaDiscovery"), "Home discovery randomization is not initialized")

wind_of_change = read.call("literature/wind-of-change-saga.html")
expect.call(wind_of_change.include?("astaria-saga-chapters"), "Wind of Change has no designed chapter section")
expect.call(!wind_of_change.include?("astaria-saga-empty"), "Wind of Change still claims its published chapters are unavailable")
expect.call(wind_of_change.scan("astaria-saga-chapter-card").length == 94, "Wind of Change must publish all 94 chapters")
expect.call(wind_of_change.include?("astaria-saga-range-nav"), "Long Wind of Change contents need chapter-range navigation")
expect.call(wind_of_change.scan(/<section class="astaria-saga-chapter-range"/).length == 7, "Wind of Change must be grouped into prologue and six story regions")
%w[Гилас Амон-Астат Кадир Дикоземье Ланг-Ан Сурадж].each do |region_fragment|
  expect.call(wind_of_change.include?(region_fragment), "Wind of Change contents are missing the #{region_fragment} region group")
end
expect.call(!wind_of_change.include?("&lt;small&gt;"), "Wind of Change chapter metadata is rendered as visible HTML")
expect.call(wind_of_change.scan("astaria-saga-chapters-title").length >= 1, "Wind of Change chapter heading is missing")
expect.call(!wind_of_change.include?("<h2 id=\"главы\">Главы</h2>"), "Wind of Change still renders the old empty chapter heading")
thunder_call = read.call("literature/thunder-call-saga.html")
expect.call(thunder_call.scan("astaria-saga-chapter-card").length == 10, "Call of Thunder must publish all 10 chapters")
[
  "Before The Storm", "The Highlander's Soul", "Sailing", "The Island",
  "The New Paragon", "The Priestess", "No Mercy For Thirsty",
  "Call of Thunder", "No Way Home", "Lament of the Night"
].each do |english_title|
  expect.call(thunder_call.include?(english_title), "Call of Thunder contents are missing #{english_title}")
end
sleeping_gods = read.call("literature/poka-bogi-spyat.html")
expect.call(sleeping_gods.scan("astaria-saga-chapter-card").length == 3, "Poka Bogi Spyat must publish all three chapters")
chapter_notes = published_ready_notes.select { |note| %w[chapter session].include?(note[:data]["type"].to_s) }
expect.call(chapter_notes.length == 107, "Expected 107 public saga chapters")
chapter_notes.each do |note|
  generated = Dir.glob(File.join(CONTENT, "literature", "*.md")).find do |path|
    data, = parse_frontmatter.call(path)
    data["title"] == note[:data]["title"]
  end
  expect.call(!generated.nil?, "Published saga chapter has no generated page: #{note[:data]["title"]}")
end
highlander_soul = read.call("literature/glava-1-dusha-gortsa.html")
expect.call(highlander_soul.include?("astaria-coverless-hero"), "Coverless chapters need a designed hero")
expect.call(highlander_soul.include?("astaria-coverless-ornament"), "Coverless chapter hero needs a neutral decorative mark")
expect.call(!highlander_soul.match?(/astaria-coverless-(?:sigil|ornament)[^>]*>\s*<span>Г<\/span>/), "Coverless chapter hero still displays the ambiguous letter Г")
expect.call(highlander_soul.include?(%(<h1 class="astaria-content-title">Душа Горца</h1>)), "Chapter hero must keep the chapter number outside the title")
expect.call(highlander_soul.include?("astaria-chapter-navigation"), "Saga chapter has no previous/next navigation")
expect.call(highlander_soul.include?("astaria-coverless-subtitle"), "Call of Thunder chapter is missing its English title")
expect.call(highlander_soul.scan("The Highlander's Soul").length == 1, "English chapter title is duplicated in the public article")
expect.call(journey_styles.include?(".astaria-coverless-hero"), "Articles without a cover have no visual hero template")
expect.call(journey_styles.include?(".astaria-saga-chapter-card"), "Coverless saga chapters have no card template")
expect.call(journey_styles.include?(".astaria-chapter-navigation"), "Coverless chapters have no navigation styles")
generator_source = File.read(File.join(ROOT, "_scripts", "sync_quartz_content.rb"))
expect.call(generator_source.include?("build_coverless_title"), "Quartz generator does not apply the coverless article template")

rich_infoboxes = {
  "bestiary/nereid.html" => 5,
  "gods/mercate.html" => 10,
  "lore/chthonotema.html" => 4,
  "imitei/druid.html" => 4,
  "literature/poka-bogi-spyat.html" => 2,
  "places/astaria.html" => 4,
  "peoples/ellians.html" => 3,
  "organizations/druidism.html" => 6,
  "characters/meilong.html" => 6,
  "items/deathbringer.html" => 5,
  "events/war-of-the-thirsty.html" => 5,
  "countries/gilas.html" => 9
}

rich_infoboxes.each do |relative, minimum|
  html = read.call(relative)
  rows = html.scan("astaria-infobox-row").length
  expect.call(rows >= minimum, "#{relative}: expected at least #{minimum} useful infobox rows, found #{rows}")
  expected_heading = relative.start_with?("imitei/") ? "Профиль пути" : "Сведения"
  expect.call(html.include?(">#{expected_heading}</p>"), "#{relative}: infobox must use the '#{expected_heading}' heading")
  expect.call(!html.include?("Кратко о статье"), "#{relative}: obsolete infobox heading is still present")
end

meilong = read.call("characters/meilong.html")
["媚龍", "Дракон неустановленного вида", "104 НЭ", "Красные", "50 см", "13 кг"].each do |value|
  expect.call(meilong.include?(value), "Meilong infobox is missing #{value}")
end
expect.call(!meilong.include?(">Родители</dt>"), "Meilong's divine parentage must remain hidden")

mei_wu = read.call("characters/mei-wu.html")
expect.call(mei_wu.include?(">Родители</dt>"), "Mei Wu infobox is missing public parents")
expect.call(mei_wu.include?(">Дети</dt>"), "Mei Wu infobox is missing public children")
rhea_melit = read.call("characters/rhea-melit.html")
expect.call(rhea_melit.include?(">Родители</dt>"), "Rhea Melit infobox is missing her public parent")

selina_elliot = read.call("characters/selina-elliot.html")
expect.call(selina_elliot.include?(">Братья и сёстры</dt>"), "Selina Elliot infobox is missing her brother")
expect.call(selina_elliot.include?(">Путь Имитея</dt>"), "Selina Elliot infobox is missing her Imitei path")
expect.call(selina_elliot.scan(">Тень</a>").length == 1, "Selina Elliot must display the Shadow path only once")
expect.call(!selina_elliot.include?(">Род занятий</dt>"), "Selina Elliot has a duplicate occupation row")

areta = read.call("characters/areta.html")
expect.call(areta.include?("Авеста Кронос"), "Areta infobox is missing her public sister")
expect.call(!areta.include?("Аристея Кронос"), "Areta's secret sister leaked into Quartz")
aristea = read.call("characters/aristea-kronos.html")
expect.call(!aristea.include?(">Братья и сёстры</dt>"), "Aristea's secret siblings leaked into Quartz")

Dir.glob(File.join(CONTENT, "**", "*.md")).each do |path|
  data, = parse_frontmatter.call(path)
  expect.call(data.keys.none? { |key| key.to_s.start_with?("secret_") }, "Private relationship metadata leaked into #{path.delete_prefix("#{CONTENT}/")}")
end
expect.call(meilong.include?("astaria-infobox-note"), "Meilong infobox must show the calculated current age")
expect.call(meilong.include?("assets/images/meilong_adult.jpg"), "Meilong must use the updated adult portrait")
expect.call(read.call("bestiary/nereid.html").include?("astaria-infobox-link"), "Published infobox references must be clickable")
content_index = JSON.parse(read.call("static/contentIndex.json"))
expect.call(content_index.dig("characters/meilong", "content")&.include?("媚龍"), "Search index must include Meilong's native name")

biography_expectations = {
  "characters/lisandra-macrayne.html" => ["Рождённого под громом", "Призывателя Бурь"],
  "characters/kenneth-mac-rain.html" => ["Рунштоирму", "первый за пять лет дождь"],
  "characters/cassia.html" => ["Зов Бури", "Пока Боги Спят", "больше не считает ни одно из них неизбежным"],
  "characters/rhea-melit.html" => ["Зове Бури", "Пока Боги Спят", "похитила из архивов"],
  "characters/shani.html" => ["устроил пожар", "пустыню Сехет"],
  "characters/persephone.html" => ["повторную Танатомахию", "сохранить уцелевших воинов"]
}
biography_expectations.each do |relative, moments|
  html = read.call(relative)
  moments.each do |moment|
    expect.call(html.include?(moment), "#{relative}: saga biography is missing #{moment}")
  end
end

{
  "gods/itsune" => "逸音",
  "gods/lang-an-dragon" => "龍安"
}.each do |route, native_name|
  html = read.call("#{route}.html")
  expect.call(html.include?("<dt>Имя на родном языке</dt>"), "#{route}: native-name label is missing from the infobox")
  expect.call(html.include?(native_name), "#{route}: native name #{native_name} is missing")
  expect.call(content_index.dig(route, "content")&.include?(native_name), "Search index must include #{native_name}")
end

halyk_byndir = read.call("places/halyk-byndir.html")
expect.call(halyk_byndir.match?(/<dt>Тип места<\/dt><dd>\s*Бордель\s*<\/dd>/), "Halyk-Byndir must use the Russian place type")
dragon_temple = read.call("places/dragon-temple.html")
expect.call(dragon_temple.match?(/<dt>Тип места<\/dt><dd>\s*Храмовый комплекс\s*<\/dd>/), "Dragon Temple must use the Russian place type")
["Страна", "Часть территории", "Основание"].each do |label|
  expect.call(dragon_temple.include?("<dt>#{label}</dt>"), "Dragon Temple infobox is missing #{label}")
end
expect.call(!dragon_temple.include?("Структурные связи"), "Dragon Temple still duplicates structural metadata in its body")
published_titles = content_index.values.map { |entry| entry["title"].to_s }
published_ready_notes.each do |note|
  title = note[:data]["title"].to_s
  expect.call(published_titles.include?(title), "Ready article is missing from the public search index: #{title}")
end
intentionally_unpublished_titles.each do |title|
  expect.call(!published_titles.include?(title), "Intentionally unpublished article leaked into search: #{title}")
end
generated_article_count = category_routes.values.sum do |route|
  Dir.glob(File.join(CONTENT, route, "*.md")).count { |path| File.basename(path) != "index.md" }
end
expect.call(generated_article_count == published_ready_notes.length, "Generated article count does not match the public ready encyclopedia corpus")
generated_article_paths = category_routes.values.flat_map do |route|
  Dir.glob(File.join(CONTENT, route, "*.md")).reject { |path| File.basename(path) == "index.md" }
end
duplicate_route_basenames = generated_article_paths.group_by { |path| File.basename(path, ".md") }
  .select { |_basename, paths| paths.length > 1 }
expect.call(duplicate_route_basenames.empty?, "Article slugs are ambiguous across categories: #{duplicate_route_basenames.keys.join(', ')}")

generated_article_paths.each do |path|
  relative = path.delete_prefix("#{CONTENT}/").sub(/\.md\z/, ".html")
  html = read.call(relative)
  expect.call(html.scan(/<h1(?:\s|>)/).length == 1, "#{relative}: expected exactly one H1")
  expect.call(!html.match?(/<pre><code>.*?&lt;(?:article|div|h[1-6]|p|span|a)(?:\s|&gt;)/m), "#{relative}: raw HTML is rendered as visible source code")
  expect.call(!html.include?("[["), "#{relative}: unresolved Obsidian link is visible")
  expect.call(!html.include?("FATE / GM") && !html.include?("Механика требует ручной вычитки"), "#{relative}: private campaign material leaked into the article")
  expect.call(html.match?(/<title>.+?<\/title>/m), "#{relative}: page title is missing")
  expect.call(html.match?(/<meta name="description" content="[^"]+"/), "#{relative}: meta description is missing")
end

missing_image_notes = []
ready_article_notes.each do |note|
  data = note[:data]
  values = data.select do |key, value|
    key.to_s.match?(/(?:portrait|cover|crest|flag|timeline)_image|(?:female|male)_portrait/) && !value.to_s.strip.empty?
  end.values
  values.concat(note[:source].scan(/!\[\[([^\]]+\.(?:png|jpe?g|webp|gif|svg))(?:\|[^\]]+)?\]\]/i).flatten.map { |path| "[[#{path}]]" })
  image_paths = values.map { |value| value.to_s[/\[\[([^|\]#]+)/, 1] }.compact.uniq
  valid_images = image_paths.select { |path| File.file?(File.join(ROOT, path)) }
  missing_files = image_paths - valid_images
  expect.call(missing_files.empty?, "Ready article references missing image files: #{note[:data]["title"]} — #{missing_files.join(', ')}")
  valid_images.each do |path|
    next unless note[:data]["quartz"] == true

    built_path = File.join(PUBLIC, path.downcase.tr(" ", "-"))
    expect.call(File.file?(built_path), "Ready article image is absent from the build: #{path}")
  end
  coverless_chapter = %w[chapter session].include?(data["type"].to_s)
  missing_image_notes << note if valid_images.empty? && !coverless_chapter
end

missing_image_report = File.join(ROOT, "_quartz", "MISSING_IMAGES.md")
expect.call(File.file?(missing_image_report), "Missing-image publication report was not created")
if File.file?(missing_image_report)
  report_source = File.read(missing_image_report)
  missing_image_notes.each do |note|
    expect.call(report_source.include?(note[:data]["title"].to_s), "Missing-image report omits #{note[:data]["title"]}")
  end
  report_rows = report_source.lines.count { |line| line.match?(/^\| (?:Места|Знания|Организации|Литература) \|/) }
  expect.call(report_rows == missing_image_notes.length, "Missing-image report is stale: expected #{missing_image_notes.length} entries, found #{report_rows}")
end
expect.call(
  missing_image_notes.map { |note| note[:data]["title"] }.sort == intentionally_unpublished_titles.sort,
  "Unexpected ready articles without illustrations: #{missing_image_notes.map { |note| note[:data]["title"] }.join(', ')}"
)

expect.call(!File.exist?(File.join(ROOT, "Энциклопедия", "Знания", "Путь Клинка.md")), "Retired Path of the Blade article still exists")
expect.call(!published_titles.include?("Путь Клинка"), "Retired Path of the Blade article remains in search")
expect.call(!File.exist?(File.join(PUBLIC, "lore", "put-klinka.html")), "Retired Path of the Blade public route still exists")
avenger_source = File.read(File.join(ROOT, "Энциклопедия", "Имитеи", "Мститель.md"))
expect.call(avenger_source.include?("## Путь Клинка"), "Path of the Blade lore was not merged into Avenger")
expect.call(avenger_source.include?("650 году ХЭ"), "Avenger article lost the founding date of the Path of the Blade")
expect.call(!avenger_source.include?("[[Путь Клинка"), "Avenger article still links to the retired Path of the Blade note")
expect.call(read.call("lore/imitey.html").include?("assets/images/imithei.jpg"), "Imitei article does not use its new cover")
expect.call(read.call("literature/poka-bogi-spyat.html").include?("assets/images/eye_of_calypso.jpg"), "Poka Bogi Spyat does not reuse the Eye of Calypso cover")

{
  "Горный хребет Шан Фенг.md" => ["Горный хребет Шафар.md", "Горный хребет Шан Фенг"],
  "Врата Дракона.md" => ["Гарнизон Пасть Дракона.md", "Врата Дракона"],
  "Озеро Женг.md" => ["Озеро Жень.md", "Озеро Женг"]
}.each do |retired, (canonical, alias_name)|
  expect.call(!File.exist?(File.join(ROOT, "Энциклопедия", "Места", retired)), "Retired duplicate place still exists: #{retired}")
  canonical_source = File.read(File.join(ROOT, "Энциклопедия", "Места", canonical))
  expect.call(canonical_source.include?(alias_name), "Canonical place does not preserve retired alias: #{alias_name}")
end

index_payload = content_index.values.map { |entry| [entry["title"], entry["content"]].join(" ") }.join("\n")
expect.call(!index_payload.include?("FATE / GM"), "Private FATE blocks leaked into public search")
expect.call(!index_payload.include?("Механика требует ручной вычитки"), "Private FATE notes leaked into public search")

secret_notes = Dir.glob(File.join(ROOT, "Энциклопедия", "Секреты", "*.md")).sort
expect.call(secret_notes.length >= 27, "Expected the fully audited private Secrets corpus")
secret_notes.each do |path|
  source = File.read(path)
  match = source.match(/\A---\s*\n(.*?)\n---/m)
  data = match ? YAML.safe_load(match[1], permitted_classes: [], aliases: true) || {} : {}
  expect.call(data["quartz"] == false, "Secret note can be published by Quartz: #{File.basename(path)}")
  expect.call(data["secret"] == true, "Secret note lacks secret: true: #{File.basename(path)}")
  expect.call(data["private"] == true, "Secret note lacks private: true: #{File.basename(path)}")
end
conflict_report = File.join(ROOT, "Энциклопедия", "Секреты", "Противоречия и вопросы канона.md")
expect.call(File.file?(conflict_report), "Private canon-conflict report is missing")
if File.file?(conflict_report)
  conflict_source = File.read(conflict_report)
  expect.call(conflict_source.include?("# Противоречия и вопросы канона"), "Canon-conflict report has no structured title")
  expect.call(conflict_source.include?("## Разрешено автором"), "Canon-conflict report does not separate resolved decisions")
  expect.call(conflict_source.include?("Обнаружение и освобождение — два разных события"), "Vintre chronology decision is not recorded")
  expect.call(conflict_source.include?("Аксель Хана убил Муспельхег"), "Aksel Khan's killer decision is not recorded")
  expect.call(conflict_source.include?("только внешность Сао"), "Sao Wu's apparent-age decision is not recorded")
  expect.call(conflict_source.include?("Единственное каноническое имя генерала — **Гуань Ли**"), "Guan Li's canonical name is not recorded")
  expect.call(conflict_source.include?("ему 803 года"), "Shen Wu's current age is not recorded")
  expect.call(conflict_source.include?("поток через Маяк всегда направлен с востока на запад"), "Soul Lighthouse direction is not recorded")
  expect.call(conflict_source.include?("Калипсо]] уснула в 150 году ХЭ"), "Calypso's sleep date is not recorded")
  expect.call(conflict_source.include?("адресат сигнала — археи"), "Ast's signal addressee is not recorded")
  expect.call(conflict_source.include?("изначально принадлежала Руфу"), "Rufu's ownership of the scythe is not recorded")
  expect.call(conflict_source.include?("Ниса]] больше не находится"), "Nisa's current location decision is not recorded")
  expect.call(conflict_source.include?("опасно даже Имитеям"), "Vetal outbreak severity is not recorded")
  expect.call(conflict_source.include?("Хан не знал"), "Aksel Khan's ignorance of Vintre's plan is not recorded")
  expect.call(conflict_source.include?("### Мафка и Чистое Сердце"), "Mafka and Pure Heart canon conflict is not recorded")
  expect.call(conflict_source.include?("был ли этот перенос полным"), "Mafka's unresolved soul transfer is not recorded")
  expect.call(conflict_source.include?("связь между живой Мафкой и нынешним Чёрным Сердцем"), "Mafka's unresolved Black Heart link is not recorded")
end
dragon_legacy = File.join(ROOT, "Энциклопедия", "Секреты", "Наследие драконов.md")
dragon_legacy_source = File.read(dragon_legacy)
expect.call(dragon_legacy_source.scan(/^- \*\*-?\d+ год (?:ХЭ|НЭ)\./).length == 81, "Dragon legacy chronology lost or duplicated events")
expect.call(dragon_legacy_source.include?("**-1637 год ХЭ.** Экспедиция Друидов обнаруживает тело Винтры"), "Vintre's body discovery must be dated -1637 ХЭ")
expect.call(dragon_legacy_source.include?("**-1635 год ХЭ.** Друиды извлекают Винтру из ледяного плена"), "Vintre's recovery must be dated -1635 ХЭ")
expect.call(!dragon_legacy_source.include?("Муспельхегг"), "Muspelheg's name still has the obsolete double-g spelling")
vaktar_foundation_source = File.read(File.join(ROOT, "Хронология", "События", "Основание Вактар-Йордена.md"))
expect.call(vaktar_foundation_source.include?("Через два года после обнаружения тела [[Винтра|Винтры]]"), "Vaktar-Yorden foundation event contradicts Vintre's -1637 discovery")
aksel_secret = File.read(File.join(ROOT, "Энциклопедия", "Секреты", "Тайны Аксель Хана и Ишиды Рецу.md"))
expect.call(aksel_secret.include?("его хранитель — [[Муспельхег]]"), "Aksel Khan secret does not name Muspelheg as the attacker")
expect.call(!aksel_secret.include?("драконья самка"), "Aksel Khan secret still names a female dragon as the attacker")
sao_source = File.read(File.join(ROOT, "Энциклопедия", "Персонажи", "Сао Ву.md"))
expect.call(sao_source.include?("С виду Сао около семи лет"), "Sao Wu's apparent age is not stated clearly")
expect.call(sao_source.include?("внешность не отражает календарного возраста"), "Sao Wu's apparent age is still presented as chronological")
expect.call(!index_payload.include?("Противоречия и вопросы канона"), "Private canon-conflict report leaked into search")
expect.call(!index_payload.include?("Ванпур — заметки для ведущего"), "Private Vanpur GM note leaked into search")

nisa = read.call("characters/nisa-nereid.html")
expect.call(!nisa.include?("<dt>Значимость</dt>"), "Non-event character Nisa must not display event significance")
expect.call(nisa.include?("Город Чанг-Ша"), "Nisa's current location must be Chang-Sha")
expect.call(!nisa.include?("Город Бахара"), "Nisa's public article still presents Bakhara as her current location")
shen_wu = read.call("characters/shen-wu.html")
expect.call(shen_wu.include?(%(<span class="astaria-infobox-note">803 года</span>)), "Shen Wu's current age must be 803")

canonical_corpus = Dir.glob(File.join(ROOT, "Энциклопедия", "**", "*.md")).map { |path| File.read(path) }.join("\n")
expect.call(!canonical_corpus.include?("Ли Шу") && !canonical_corpus.include?("Ли Гуань"), "Retired names for General Guan Li remain in the canonical corpus")
expect.call(!canonical_corpus.include?("космическая цивилизация, уничтожающая"), "Ast's retired external-civilization idea remains in the canonical corpus")

public_lore_artifacts = []
public_saga_labels = []
Dir.glob(File.join(ROOT, "Энциклопедия", "**", "*.md")).sort.each do |path|
  next if path.include?(File.join("Энциклопедия", "Секреты"))
  next if path.include?(File.join("Энциклопедия", "Литература"))

  source = File.read(path)
  public_lore_artifacts << path if source.match?(/^## (?:Внешность|Последние сведения|Персонажи из backup|Поселения из backup)\s*$/)
  public_lore_artifacts << path if source.match?(/\bbackup\b/i)
  public_saga_labels << path if source.match?(/геро(?:и|ев|ям) саги|на момент главы/i)
end
expect.call(public_lore_artifacts.empty?, "Migration/update artifacts remain in lore articles: #{public_lore_artifacts.uniq.map { |path| File.basename(path) }.join(', ')}")
expect.call(public_saga_labels.empty?, "Lore articles still describe facts as campaign records: #{public_saga_labels.uniq.map { |path| File.basename(path) }.join(', ')}")

vanpur = read.call("places/vanpur.html")
%w[Урист Мусака Гилья].each do |campaign_name|
  expect.call(!vanpur.include?(campaign_name), "Public Vanpur article leaks campaign-specific material: #{campaign_name}")
end
expect.call(!vanpur.include?("Для героев"), "Public Vanpur article still contains a campaign hook section")
expect.call(!vanpur.include?("Лето 106 года НЭ"), "Public Vanpur article still contains the current campaign state")
expect.call(!File.exist?(File.join(CONTENT, "secrets")), "Private Secrets directory was copied into Quartz content")

render_page_source = File.read(File.join(ROOT, "_quartz", "quartz", "components", "renderPage.tsx"))
expect.call(render_page_source.include?("componentData.ctx.argv.serve || !cfg.baseUrl"), "Local preview must not add the production /astaria prefix to search results")

native_name_notes = []
missing_native_names = []
visible_metadata_fields = %w[
  location_type organization_type item_type condition_type profession_type
  medium species government course rarity habitat
]
english_visible_metadata = []
structural_body_notes = []
legacy_founded_notes = []
Dir.glob(File.join(ROOT, "Энциклопедия", "**", "*.md")).sort.each do |path|
  next if path.include?(File.join("Энциклопедия", "Секреты"))

  source = File.read(path)
  match = source.match(/\A---\s*\n(.*?)\n---/m)
  next unless match

  data = YAML.safe_load(match[1], permitted_classes: [], aliases: true) || {}
  visible_metadata_fields.each do |field|
    values = Array(data[field]).map(&:to_s)
    english_visible_metadata << "#{File.basename(path)}: #{field}=#{values.join(', ')}" if values.any? { |value| value.match?(/[A-Za-z]/) }
  end
  structural_body_notes << path if source.include?("## Структурные связи")
  legacy_founded_notes << path if data.key?("founded")
  cjk_aliases = Array(data["aliases"]).flat_map { |value| value.to_s.split(/\s*,\s*/) }.select { |value| value.match?(/[一-龯ぁ-んァ-ン]/) }
  next if cjk_aliases.empty?

  native_name_notes << path
  missing_native_names << path if data["native_name"].to_s.strip.empty?
end
expect.call(native_name_notes.length >= 120, "Expected the recovered native-name corpus for Lang-An, Amato, Meilong and Onmyoji")
expect.call(missing_native_names.empty?, "CJK aliases without native_name: #{missing_native_names.map { |path| File.basename(path) }.join(', ')}")
expect.call(english_visible_metadata.empty?, "English values remain in public-facing metadata: #{english_visible_metadata.join('; ')}")
expect.call(structural_body_notes.empty?, "Structural metadata is duplicated in article bodies: #{structural_body_notes.map { |path| File.basename(path) }.join(', ')}")
expect.call(legacy_founded_notes.empty?, "Legacy founded fields are not rendered by the infobox: #{legacy_founded_notes.map { |path| File.basename(path) }.join(', ')}")
uy_dzhan_data, = parse_frontmatter.call(File.join(ROOT, "Энциклопедия", "Места", "Бордель Уй-Джан.md"))
expect.call(uy_dzhan_data["location_type"] == "Бордель", "Unpublished Uy-Dzhan must retain the Russian place type")

timeline = read.call("timeline/index.html")
expect.call(timeline.scan("astaria-timeline-event").length == 26, "Timeline must contain all 26 events")
expect.call(timeline.include?("astaria-timeline-search"), "Timeline search is missing")
expect.call(timeline.include?("astaria-timeline-category"), "Timeline category filter is missing")
expect.call(!timeline.include?("[!timeline]"), "Timeline exposes raw Obsidian callout markup")
expect.call(!timeline.match?(/<pre><code>.*?&lt;(?:article|div|h3|p|span)(?:\s|&gt;)/m), "Timeline event HTML is rendered as visible source code")
expect.call(timeline.scan(/<article class="astaria-timeline-card[^"]*">\s*<img/m).length == 26, "Every timeline event must have an illustration")
expect.call(timeline.scan("astaria-timeline-meta").length == 26, "Every timeline event must show a readable significance label")
expect.call(journey_styles.match?(/\.astaria-timeline-year\s*\{[^}]*padding-right:\s*0\.85rem/m), "Timeline date needs breathing room before the rail")
expect.call(journey_styles.match?(/\.astaria-timeline-year::after\s*\{[^}]*0 0 0 4px/m), "Timeline node needs a paper halo separating it from the rail")
expect.call(journey_styles.match?(/\.astaria-timeline-year\s*\{[^}]*lining-nums tabular-nums/m), "Timeline dates must use aligned lining numerals")
%w[Эпохальное Переломное Важное Заметное].each do |label|
  expect.call(timeline.include?(label), "Timeline is missing the significance level: #{label}")
end
[
  "amon-astat_drought.jpg",
  "gunpowder.jpg",
  "archaeans.jpg",
  "orion_city.jpg",
  "katachthonos_colony.jpg"
].each do |filename|
  expect.call(timeline.include?("assets/images/#{filename}"), "Timeline is missing the requested illustration: #{filename}")
end

event_article_pages = %w[
  events/war-of-the-thirsty.html
  events/acheus-invasion.html
  events/faith-crysis-amon-astat.html
  events/chthonid-fall.html
  events/kad-kharad-disbandment.html
  timeline/foundation-of-talassia.html
]
event_article_pages.each do |relative|
  html = read.call(relative)
  expect.call(!html.match?(/<dt>Значимость<\/dt><dd>\s*\d/), "#{relative}: raw significance number is still visible")
  expect.call(html.match?(/<dt>Значимость<\/dt><dd>(?:Эпохальное|Переломное|Важное|Заметное) событие<\/dd>/), "#{relative}: readable significance label is missing")
end

timeline_source_paths = Dir.glob(File.join(ROOT, "Хронология", "События", "*.md")) + Dir.glob(File.join(ROOT, "Энциклопедия", "События", "*.md"))
timeline_sources = timeline_source_paths.map do |path|
  source = File.read(path)
  match = source.match(/\A---\s*\n(.*?)\n---/m)
  data = match ? YAML.safe_load(match[1], permitted_classes: [], aliases: true) || {} : {}
  next unless data["timeline"] == true

  [path, data]
end.compact
missing_timeline_images = []
timeline_sources.each do |path, data|
  raw_image = data["timeline_image"] || data["cover_image"]
  image_path = raw_image.to_s[/\[\[([^\]]+)\]\]/, 1]
  missing_timeline_images << File.basename(path) if image_path.to_s.empty? || !File.file?(File.join(ROOT, image_path))
  next if image_path.to_s.empty?

  built_image = File.join(PUBLIC, image_path.downcase.tr(" ", "-"))
  expect.call(File.file?(built_image), "Timeline illustration is not copied into the build: #{image_path}")
end
expect.call(timeline_sources.length == 26, "Expected 26 canonical timeline sources")
expect.call(missing_timeline_images.empty?, "Timeline events without a valid image: #{missing_timeline_images.join(', ')}")

country_notes = Dir.glob(File.join(ROOT, "Энциклопедия", "Страны", "*.md")).reject { |path| File.basename(path) == "Культ Меркаты.md" }
missing_country_subtitles = country_notes.reject do |path|
  source = File.read(path)
  match = source.match(/\A---\s*\n(.*?)\n---/m)
  data = match ? YAML.safe_load(match[1], permitted_classes: [], aliases: true) || {} : {}
  !data["card_subtitle"].to_s.strip.empty?
end
expect.call(country_notes.length >= 16, "Expected all canonical countries in the subtitle audit")
expect.call(missing_country_subtitles.empty?, "Countries without card_subtitle: #{missing_country_subtitles.map { |path| File.basename(path) }.join(', ')}")

map = read.call("map.html")
expect.call(map.scan("astaria-map-marker astaria-map-marker-").length == 132, "Map must render all 132 canonical markers")
%w[states.png heightmap.png biomes.png].each do |filename|
  expect.call(map.include?("assets/maps/#{filename}"), "Map does not use original layer #{filename}")
  source = File.join(ROOT, "Assets", "Maps", filename)
  built = File.join(PUBLIC, "assets", "maps", filename)
  expect.call(File.file?(built), "Built map layer is missing: #{filename}")
  expect.call(File.size(source) == File.size(built), "Built map layer differs from original: #{filename}") if File.file?(built)
end
states_layer = map[/<img class="astaria-map-layer[^"]*" data-layer="states"[^>]*>/]
heightmap_layer = map[/<img class="astaria-map-layer[^"]*" data-layer="heightmap"[^>]*>/]
biomes_layer = map[/<img class="astaria-map-layer[^"]*" data-layer="biomes"[^>]*>/]
expect.call(states_layer&.match?(/\ssrc="(?:\.\/)?assets\/maps\/states\.png"/), "Primary states layer must load the original image immediately")
expect.call(heightmap_layer&.match?(/\sdata-src="assets\/maps\/heightmap\.png"/) && !heightmap_layer.match?(/\ssrc=/), "Heightmap must remain lazy until selected")
expect.call(biomes_layer&.match?(/\sdata-src="assets\/maps\/biomes\.png"/) && !biomes_layer.match?(/\ssrc=/), "Biomes must remain lazy until selected")
expect.call(!experience_script.include?("scale(${state.scale})"), "Map zoom must not upscale a rasterized DOM layer")
expect.call(experience_script.include?("stage.style.width = `${renderedWidth}px`"), "Map zoom must render the original layer at its real target width")
expect.call(experience_script.include?("maximumUsefulScale"), "Map zoom must stop before exceeding source resolution")
expect.call(experience_script.include?("window.devicePixelRatio"), "Map zoom limit must account for high-density displays")
expect.call(experience_script.include?("image.dataset.src"), "Optional map layers are not loaded on demand")

marker_top = lambda do |name|
  match = map.match(/class="astaria-map-marker[^"]*"[^>]*data-name="#{Regexp.escape(name)}"[^>]*data-y="([\d.]+)"/)
  expect.call(!match.nil?, "Map marker is missing: #{name}")
  match && match[1].to_f
end
bakhara_top = marker_top.call("Город Бахара")
anderhan_top = marker_top.call("Город Андерхан")
expect.call(bakhara_top && anderhan_top && bakhara_top > anderhan_top, "Map Y axis is inverted: Bakhara must appear south of Anderhan")
expect.call(map.include?('data-name="Гарнизон Пасть Дракона"'), "Map still points to the retired Dragon Gates duplicate")
expect.call(map.include?('data-name="Горный хребет Шафар"'), "Map still points to the retired Shang Feng duplicate")
expect.call(map.include?('data-name="Озеро Жень"'), "Map still points to the retired Zheng Lake duplicate")
expect.call(journey_styles.match?(/\.astaria-map-marker > span\s*\{[^}]*opacity:\s*0\.64/m), "Map markers must be translucent over printed labels")
expect.call(journey_styles.match?(/\.astaria-map-marker\.is-selected > span\s*\{[^}]*opacity:\s*1/m), "Selected map markers must regain full opacity")

mercate_source = File.read(File.join(CONTENT, "gods", "mercate.md"))
expect.call(!mercate_source.match?(/^- Луна\n\n- Ворон/m), "Mercate symbol list still contains oversized blank gaps")

unless failures.empty?
  warn "Quartz content QA failed (#{failures.length}/#{checks}):"
  failures.each { |failure| warn "  - #{failure}" }
  exit 1
end

puts "Quartz content QA passed: #{checks} checks across #{categories.length} categories."
