#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"

CYRILLIC = /[А-Яа-яЁё]/

STATE_NAMES = {
  "Амон-Астат" => "Amon-Astat",
  "Гилас" => "Gilas",
  "Кадир" => "Qadir",
  "Дикоземье" => "Wildlands",
  "Империя Ланг-Ан" => "Lang-An Empire",
  "Хамоа" => "Hamoa",
  "Амато" => "Amato",
  "Обитель" => "Obitelj",
  "Вактар-Йорден" => "Vaktar-Jorden",
  "Иомар" => "Iomar",
  "Громовые Кланы" => "Thunder Clans",
  "Лунаар" => "Lunaar",
  "Катахтонос" => "Katachthonos",
  "Сурадж Ка Гхар" => "Suraj Ka Ghar",
  "Вакумара" => "Vakumara",
  "Талассия" => "Thalassia"
}.freeze

# Free-standing geographic labels. These are translated rather than merely
# romanised, while culture-specific proper names retain their established form.
FEATURE_NAMES = {
  "Антра" => "Antra",
  "Пепельные земли" => "Ashlands",
  "Полуостров Таллас" => "Tallas Peninsula",
  "Хребет Грань Тьмы" => "Edge of Darkness Range",
  "Перевал Путь Забытых" => "Path of the Forgotten Pass",
  "Предгорья Битхорн" => "Bithorn Foothills",
  "о. Хтон" => "I. Chthon",
  "Закатная долина" => "Sunset Valley",
  "Пламенные горы" => "Flaming Mountains",
  "Регион Элессия" => "Elessia Region",
  "Регион Аментир" => "Amentir Region",
  "Пустыня Сехет" => "Sekhet Desert",
  "Пустыня Халисат" => "Khalisat Desert",
  "Хребет Спина Археи" => "Spine of Archaea Range",
  "Хребет Шафар" => "Shafar Range",
  "Туманный остров" => "Mist Island",
  "Хребет Зверя" => "Beast Range",
  "Хангорская долина" => "Khangor Valley",
  "Долина Кровавого Цветения" => "Valley of the Bloody Bloom",
  "Долина Гармонии" => "Valley of Harmony",
  "Вулкан Ротонуи" => "Rotonui Volcano",
  "Полуостров Туануку" => "Tuanuku Peninsula",
  "Перешеек Мост Хранителей" => "Guardians' Bridge Isthmus",
  "о. Рёст" => "I. Ryost",
  "о. Закра" => "I. Zakra",
  "Лес Шеньянь" => "Shenyan Forest",
  "Болота Забвения" => "Marshes of Oblivion",
  "о. Акасака" => "I. Akasaka",
  "Хельвандский полуостров" => "Helvand Peninsula",
  "Лес Сольвид" => "Solvid Forest",
  "Лес Иомар" => "Iomar Forest",
  "Даирские луга" => "Dair Meadows",
  "Джунгли Шанкари" => "Shankari Jungle",
  "Болота Кхали Дарти" => "Khali Darti Marshes",
  "Полуостров Хайконг" => "Haikong Peninsula",
  "о. Хао" => "I. Hao",
  "Равнина Вайтфилд" => "Whitefield Plain",
  "Морозные холмы" => "Frost Hills",
  "Джунгли Сундари" => "Sundari Jungle",
  "Золотые холмы" => "Golden Hills",
  "Сфагийские поля" => "Sphagian Fields",
  "о. Та-Сети" => "I. Ta-Seti",
  "о. Анемодис" => "I. Anemodis",
  "о. Тихос" => "I. Tikhos",
  "о. Апной" => "I. Apnoi",
  "о. Ояширо" => "I. Oyashiro",
  "о. Рюгу" => "I. Ryugu",
  "о. Фурудэ" => "I. Furude",
  "о. Вэй Бэй" => "I. Wei Bei",
  "о. Ходзё" => "I. Hojo",
  "о. Такано" => "I. Takano",
  "о. Соноши" => "I. Sonoshi",
  "о. Сономи" => "I. Sonomi",
  "Архипелаг Тикенахау" => "Tikenahau Archipelago",
  "о. Ратти" => "I. Ratti",
  "о. Саарилухта" => "I. Saariluhta",
  "Призрачные горы" => "Phantom Mountains",
  "Веданский лес" => "Vedan Forest",
  "Вельдранская тайга" => "Veldran Taiga",
  "Морозный предел Кайланы" => "Kailana's Frostbound Expanse",
  "Ледяная пустошь Винтры" => "Wintra's Icy Wastes",
  "Гора Атафет" => "Mount Atafet",
  "Горный хребет Северный Венец" => "Northern Crown Range",
  "Равнина Аксай-Джин" => "Aksai Jin Plain",
  "Регион Ладвакхар" => "Ladvakhar Region",
  "Нефритовый лес" => "Jade Forest",
  "Джунгли Минь-Тао" => "Min-Tao Jungle",
  "Джунгли Аконда" => "Akonda Jungle",
  "Лес Синьшу" => "Xinshu Forest",
  "Горный хребет Сурьяван" => "Suryavan Range",
  "Топи Нирагхат" => "Niraghat Marshes",
  "Лес Тафоа" => "Tafoa Forest",
  "Луга Тамано" => "Tamano Meadows",
  "Дымовая Чаща" => "Smoke Thicket",
  "Хвойничье предгорье" => "Khvoinichye Foothills",
  "Сребролесье" => "Silverwood",
  "Безмолвная падь" => "Silent Hollow",
  "Девичьи Холмы" => "Maiden Hills",
  "Йотунские холмы" => "Jotun Hills",
  "Лес Рунмарк" => "Runemark Forest",
  "Солёный берег" => "Salt Coast",
  "Регион Аркенхель" => "Arkenhel Region",
  "Арвудский лес" => "Arwood Forest",
  "Иллиорская тайга" => "Illior Taiga",
  "Сайлорский лес" => "Sailor Forest",
  "Лес Штормвуд" => "Stormwood Forest",
  "Регион Ардфрост" => "Ardfrost Region",
  "Лес Грейсвуд" => "Gracewood Forest",
  "Лернейский лес" => "Lernaean Forest",
  "Лес Ксанфор" => "Xanphor Forest",
  "Мирионские холмы" => "Myrion Hills",
  "Эвдийские топи" => "Evdian Marshes",
  "Лакедонский лес" => "Lakedon Forest",
  "Регион Мериссия" => "Merissia Region",
  "Нагорье Хетна" => "Hetna Highlands",
  "Пустыня Руфусэтти" => "Rufusett Desert",
  "Долина Последнего Восхода" => "Valley of the Last Sunrise",
  "Тлеющий перевал " => "Smouldering Pass ",
  "Холмы Миражей" => "Hills of Mirages",
  "Дарийские пещеры" => "Darian Caves",
  "Лес Клыков" => "Fang Forest",
  "Рунные луга" => "Runic Meadows",
  "Лес Хельм" => "Helm Forest",
  "Лес Фэнлинь" => "Fenglin Forest",

  "р. Неда" => "R. Neda",
  "Закатное море" => "Sunset Sea",
  "Сумеречный пролив" => "Twilight Strait",
  "р. Горсафон" => "R. Gorsaphon",
  "р. Эйрафон" => "R. Eiraphon",
  "р. Изгелуат" => "R. Izgeluat",
  "Штормовой залив" => "Storm Bay",
  "Хтоническое море" => "Chthonic Sea",
  "Рассветное море" => "Dawn Sea",
  "р. Тавропос" => "R. Tavropos",
  "оз. Митра" => "L. Mitra",
  "р. Хапи" => "R. Hapi",
  "оз. Нехмет" => "L. Nekhmet",
  "р. Мвиди" => "R. Mvidi",
  "оз. Кафер" => "L. Kafer",
  "р. Сатис" => "R. Satis",
  "Залив Фиальсахра" => "Fialsakhra Bay",
  "р. Макаба" => "R. Makaba",
  "оз. Джамсар" => "L. Jamsar",
  "оз. Шаради" => "L. Sharadi",
  "оз. Кхарим" => "L. Kharim",
  "оз. Зураиф" => "L. Zuraif",
  "оз. Рашах" => "L. Rashah",
  "оз. Альсалим" => "L. Alsalim",
  "оз. Суэйд" => "L. Suwayd",
  "р. Айлиз" => "R. Ailiz",
  "р. Улын-Гол" => "R. Ulyn-Gol",
  "оз. Шуан" => "L. Shuang",
  "оз. Жень" => "L. Zhen",
  "оз. Чанг" => "L. Chang",
  "р. Тяо Хэ" => "R. Tiao He",
  "Белый пролив" => "White Strait",
  "р. Мангайа" => "R. Mangaia",
  "р. Нид" => "R. Nid",
  "оз. Хорниндаль" => "L. Hornindal",
  "оз. Нордавеллир" => "L. Nordavellir",
  "р. Кайла" => "R. Kaila",
  "оз. Сильвиан" => "L. Sylvian",
  "оз. Лок Линделл" => "L. Loch Lindell",
  "р. Мураин" => "R. Murain",
  "Багровый залив" => "Crimson Bay",
  "оз. Сю Ху" => "L. Xu Hu",
  "оз. Шинда" => "L. Shinda",
  "Триглавское озеро" => "Lake Triglav",
  "р. Красивая" => "Beautiful R.",
  "оз. Валарен" => "L. Valaren",
  "Воющий пролив" => "Howling Strait",
  "оз. Альсваннет" => "L. Alsvannet",
  "оз. Тисфьёрд" => "L. Tisfjord",
  "оз. Риелин" => "L. Rielin",
  "Оазис Таше" => "Tashe Oasis",
  "Залив Варульвик" => "Varulvik Bay",
  "р. Бхаратхи" => "R. Bharathi",
  "Залив слёз Лианны" => "Liana's Tears Bay",
  "Бухта Хладвига" => "Khladwig Bay",
  "р. Лефтерия" => "R. Lefteria",
  "р. Зурвасуд" => "R. Zurvasud",
  "р. Морвинар" => "R. Morvinar",
  "р. Эльвендурн" => "R. Elvendurn",
  "р. Эльдра" => "R. Eldra",
  "р. Эрдалвинн" => "R. Erdalvinn",
  "р. Рави" => "R. Ravi",
  "р. Лаойа" => "R. Laoya",
  "р. Тавойа" => "R. Tavoya",
  "р. Кумокава" => "R. Kumokawa",
  "р. Йоки" => "R. Yoki",
  "р. Айни" => "R. Aini",
  "р. Лина" => "R. Lina",
  "р. Сигна" => "R. Signa",
  "р. Ульвия" => "R. Ulvia",
  "р. Тальва" => "R. Talva",
  "р. Скельда" => "R. Skelda",
  "р. Рисса" => "R. Rissa",
  "р. Арвиннель" => "R. Arvinnel",
  "р. Морн" => "R. Morn",
  "р. Эйл" => "R. Eil",
  "р. Файра" => "R. Faira",
  "р. Умбра" => "R. Umbra",
  "р. Найтли" => "R. Nightly",
  "р. Тэнбрия" => "R. Tenbria",
  "р. Вэйлбрук" => "R. Valebrook",
  "р. Лоурин" => "R. Lourin",
  "р. Брайс" => "R. Bryce",
  "р. Элси" => "R. Elsie",
  "р. Сноувэйл" => "R. Snowvale",
  "р. Ариадна" => "R. Ariadne",
  "р. Эгидрия" => "R. Aegidria",
  "р. Фесса" => "R. Fessa",
  "р. Эмбра" => "R. Embra",
  "р. Навидра" => "R. Navidra",
  "р. Сахрия" => "R. Sakhria",
  "р. Урх" => "R. Urkh",
  "р. Бай Хэ" => "R. Bai He",
  "р. Юйлин" => "R. Yulin"
}.freeze

BURG_OVERRIDES = {
  "Гарнизон Пасть Дракона" => "Dragon's Maw Garrison",
  "Великая Кузня" => "Great Forge",
  "Форт Мирион" => "Fort Myrion",
  "Храм Ситы" => "Temple of Sita",
  "Храм Дар Мараат" => "Temple of Dar Maraat",
  "Храм Винтерхейм" => "Temple of Winterheim",
  "Храм Ишнаалар" => "Temple of Ishnaalar",
  "Гарнизон Фирлэйн" => "Firlaine Garrison",
  "Храм Керналуин" => "Temple of Kernaluin",
  "Храм Меркаты" => "Temple of Mercate",
  "Волчья Пристань" => "Wolf's Haven",
  "Забытая Роща" => "Forgotten Grove",
  "Ночная бухта" => "Night Bay",
  "Лазурный" => "Azure",
  "Блэкси Шор" => "Blacksea Shore",
  "Блэкроу" => "Blackrow",
  "Дарклоу" => "Darklow",
  "Ноквилл" => "Knockville",
  "Эшвик" => "Ashwick",
  "д. Холлоуфен" => "v. Hollowfen",
  "д. Гримсайд" => "v. Grimside",
  "д. Кроуфелл" => "v. Crowfell",
  "д. Рэйнли" => "v. Rainley",
  "д. Вельдроу" => "v. Veldrow",
  "д. Морхейм" => "v. Morheim",
  "д. Гримлэйн" => "v. Grimlane",
  "Грэйлок" => "Greylock",
  "Тарнвейл" => "Tarnvale",
  "Кинлэйн" => "Kinlane",
  "Фарвуд" => "Farwood",
  "Тарфолл" => "Tarfall",
  "Хайрок" => "Highrock",
  "Сильверстад" => "Silverstad",
  "Бьёрнвик" => "Bjornvik",
  "Хольмсвик" => "Holmsvik",
  "Вигсхольм" => "Vigsholm",
  "Торнвальд" => "Thornwald",
  "Эйндаль" => "Eindal",
  "Эстерхольм" => "Esterholm",
  "Сваннхольм" => "Svannholm",
  "Сольберг" => "Solberg",
  "Хельсвик" => "Helsvik",
  "Луннвальд" => "Lunnwald",
  "Ульвдален" => "Ulvdalen",
  "Нордалунд" => "Nordalund",
  "Гелион" => "Helion",
  "Геспий" => "Hespios",
  "д. Орфея" => "v. Orphea",
  "д. Проксидия" => "v. Proxidia",
  "д. Эфалия" => "v. Ephalia",
  "д. Страфалия" => "v. Straphalia",
  "Тарфилос" => "Tarphilos",
  "д. Талмирия" => "v. Talmiria",
  "д. Ксандрия" => "v. Xandria",
  "д. Ликсия" => "v. Lyxia",
  "д. Арфена" => "v. Arphena",
  "Химерон" => "Chimeron",
  "д. Тирестия" => "v. Tirestia",
  "Лесоводье" => "Lesovodye",
  "Сцион" => "Scion",
  "Фалькон" => "Phalcon",
  "Мира" => "Myra"
}.freeze

PINYIN_NAMES = {
  "Джу-Суо" => "Dju-Suo",
  "Цинь-Яо" => "Qin-Yao",
  "Юйфу" => "Yufu",
  "д. Байтан" => "v. Baitan",
  "Цинь-Фан" => "Qin-Fan",
  "д. Мохуа" => "v. Mohua",
  "д. Юньтао" => "v. Yuntao",
  "Чанг-Ша" => "Chang-Sha",
  "Лань-Ша" => "Lan-Sha",
  "д. Фэй-Лю" => "v. Fei-Liu",
  "Сян-Чен" => "Xiang-Chen",
  "Син-Юнь" => "Xin-Yun",
  "д. Чень-Ю" => "v. Chen-Yu",
  "Найян" => "Naiyan",
  "д. Вэйган" => "v. Weigan",
  "Лунь-Хай" => "Lun-Hai",
  "Сяолань" => "Xiaolan",
  "Шань-Лу" => "Shan-Lu",
  "д. Тай-Линь" => "v. Tai-Lin",
  "Юйцзин" => "Yujing",
  "Шиюй" => "Shiyu",
  "д. Хуан-До" => "v. Huang-Do",
  "Линь-Чжоу" => "Lin-Zhou",
  "д. Мэй-Инь" => "v. Mei-Yin",
  "д. Байли" => "v. Baili",
  "Лэй-Си" => "Lei-Si",
  "д. Хао-Ши" => "v. Hao-Shi",
  "Синьфан" => "Xinfang",
  "Лэй-Хао" => "Lei-Hao",
  "Яо-Шень" => "Yao-Shen",
  "Лан-Цзы" => "Lan-Zi",
  "Линфу" => "Linfu",
  "Бао-Хай" => "Bao-Hai",
  "д. Мэйсу" => "v. Meisu",
  "Цин-Ха" => "Qin-Ha",
  "д. Ян-Чунь" => "v. Yang-Chun",
  "д. Сян-Че" => "v. Xiang-Che",
  "д. Вэй-Нин" => "v. Wei-Ning",
  "д. Минчуань" => "v. Minchuan",
  "д. Дань-Ся" => "v. Dan-Xia",
  "д. Дзинь-Сяо" => "v. Jin-Xiao"
}.freeze

TRANSLITERATION = {
  "А" => "A", "а" => "a", "Б" => "B", "б" => "b",
  "В" => "V", "в" => "v", "Г" => "G", "г" => "g",
  "Д" => "D", "д" => "d", "Е" => "E", "е" => "e",
  "Ё" => "Yo", "ё" => "yo", "Ж" => "Zh", "ж" => "zh",
  "З" => "Z", "з" => "z", "И" => "I", "и" => "i",
  "Й" => "Y", "й" => "y", "К" => "K", "к" => "k",
  "Л" => "L", "л" => "l", "М" => "M", "м" => "m",
  "Н" => "N", "н" => "n", "О" => "O", "о" => "o",
  "П" => "P", "п" => "p", "Р" => "R", "р" => "r",
  "С" => "S", "с" => "s", "Т" => "T", "т" => "t",
  "У" => "U", "у" => "u", "Ф" => "F", "ф" => "f",
  "Х" => "Kh", "х" => "kh", "Ц" => "Ts", "ц" => "ts",
  "Ч" => "Ch", "ч" => "ch", "Ш" => "Sh", "ш" => "sh",
  "Щ" => "Shch", "щ" => "shch", "Ы" => "Y", "ы" => "y",
  "Э" => "E", "э" => "e", "Ю" => "Yu", "ю" => "yu",
  "Я" => "Ya", "я" => "ya", "Ь" => "", "ь" => "",
  "Ъ" => "", "ъ" => ""
}.freeze

H_STATES = [6, 7, 9, 10, 11, 12].freeze
J_STATES = [1, 3, 14, 15].freeze

def romanise(name, state)
  village = name.start_with?("д. ")
  text = village ? name.delete_prefix("д. ") : name.dup

  {
    "Кх" => "Kh", "кх" => "kh",
    "Ай" => "Ai", "ай" => "ai",
    "Эй" => "Ei", "эй" => "ei",
    "Ия" => "Ia", "ия" => "ia"
  }.each { |russian, latin| text.gsub!(russian, latin) }

  if J_STATES.include?(state)
    text.gsub!("Дж", "J")
    text.gsub!("дж", "j")
  else
    text.gsub!("Дж", "Dj")
    text.gsub!("дж", "dj")
  end

  result = text.each_char.map { |char| TRANSLITERATION.fetch(char, char) }.join
  if H_STATES.include?(state)
    result.gsub!("Kh", "H")
    result.gsub!("kh", "h")
  end

  result = "v. #{result}" if village
  result
end

def registry_names
  root = File.expand_path("..", __dir__)
  path = File.join(root, "_translations", "en-GB", "names.yml")
  data = YAML.safe_load(File.read(path), permitted_classes: [], permitted_symbols: [], aliases: true)

  data.fetch("names").each_with_object({}) do |(russian, entry), names|
    english = entry.fetch("title")
    case russian
    when /\AГород (.+)\z/
      names[Regexp.last_match(1)] = english
    when /\AДеревня (.+)\z/
      names["д. #{Regexp.last_match(1)}"] = "v. #{english}"
    when /\AРека (.+)\z/
      names[Regexp.last_match(1)] = english.sub(/ River\z/, "")
    when /\AОзеро (.+)\z/
      names[Regexp.last_match(1)] = english.sub(/\ALake /, "")
    when /\AОстров (.+)\z/
      names[Regexp.last_match(1)] = english.sub(/ Island\z/, "")
    else
      names[russian] = english
    end
  end
end

source = File.expand_path(ARGV.fetch(0))
target = File.expand_path(ARGV[1] || source.sub(/\.map\z/i, " en-GB.map"))
abort "Source and target must be different files" if source == target
abort "Source map not found: #{source}" unless File.file?(source)

map = File.binread(source).force_encoding(Encoding::UTF_8)
abort "Source map is not valid UTF-8" unless map.valid_encoding?

burg_line = map.each_line.find { |line| line.start_with?('[0,{"cell":') }
abort "Could not locate the Azgaar burg data" unless burg_line

translations = registry_names
translations.merge!(STATE_NAMES)
translations.merge!(FEATURE_NAMES)
translations.merge!(BURG_OVERRIDES)
translations.merge!(PINYIN_NAMES)

burgs = JSON.parse(burg_line)
burgs.grep(Hash).each do |burg|
  name = burg["name"]
  next unless name&.match?(CYRILLIC)

  translations[name] ||= romanise(name, burg["state"])
end

translated = map.dup
translated.gsub!(/(?<!\\)"((?:\\.|[^"\\\r\n])*)"/) do |quoted|
  original = Regexp.last_match(1)
  english = translations[original]
  english ? %Q("#{english}") : quoted
end
translated.gsub!(/>([^<>\r\n]+)</) do |text_node|
  original = Regexp.last_match(1)
  english = translations[original]
  english ? ">#{english}<" : text_node
end

if translated.match?(CYRILLIC)
  remaining = translated.scan(/[А-Яа-яЁё][А-Яа-яЁё .-]*/).uniq
  warn "Unmapped Cyrillic strings:"
  remaining.sort.each { |name| warn "- #{name.strip.inspect}" }
  abort "Translation stopped to avoid changing non-geographic data"
end

File.binwrite(target, translated)
puts "Created #{target}"
puts "Translated #{translations.count { |russian, _english| map.include?(russian) }} unique map names"
