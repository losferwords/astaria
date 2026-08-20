#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "date"
require "fileutils"
require "json"
require "pathname"
require "yaml"
require_relative "astaria_translations"

ROOT = File.expand_path("..", __dir__)
DEST = ENV.fetch("ASTARIA_QUARTZ_CONTENT", File.join(ROOT, "_quartz", "content"))
BUILD_LOCALE = AstariaTranslations.locale
USE_APPROVED_ROUTES = ENV.fetch("ASTARIA_USE_APPROVED_ROUTES", "false") == "true"
ONLY_TRANSLATED = ENV.fetch("ASTARIA_ONLY_TRANSLATED", "false") == "true"

PUBLIC_ROOTS = [
  "Энциклопедия",
  "Хронология",
  "Карты"
].freeze

PRIVATE_PATH_PREFIXES = [
  File.join(ROOT, "Энциклопедия", "Секреты"),
  File.join(ROOT, "Энциклопедия", "Идеи")
].freeze

CATEGORY_ROUTES = {
  "Бестиарий" => "bestiary",
  "Боги" => "gods",
  "Знания" => "lore",
  "Имитеи" => "imitei",
  "Кухня" => "cuisine",
  "Литература" => "literature",
  "Места" => "places",
  "Народы" => "peoples",
  "Организации" => "organizations",
  "Персонажи" => "characters",
  "Предметы" => "items",
  "События" => "events",
  "Страны" => "countries",
  "Флора" => "flora"
}.freeze

COUNTRY_ORDER = [
  "Гилас",
  "Громовые Кланы",
  "Иомар",
  "Катахтонос",
  "Империя Ланг-Ан",
  "Лунаар",
  "Амон-Астат",
  "Кадир",
  "Талассия",
  "Хамоа",
  "Дикоземье",
  "Вактар-Йорден",
  "Сурадж Ка Гхар",
  "Вакумара",
  "Амато",
  "Обитель"
].freeze

COUNTRY_BY_PEOPLE = {
  "Эллийцы" => "Гилас",
  "Гойдаир" => "Громовые Кланы",
  "Надаир" => "Иомар",
  "Хтониды" => "Катахтонос",
  "Джу" => "Империя Ланг-Ан",
  "Лудаир" => "Лунаар",
  "Хефат" => "Амон-Астат",
  "Кадийцы" => "Кадир",
  "Талассийцы" => "Талассия",
  "Манаи" => "Хамоа",
  "Авгарцы" => "Дикоземье",
  "Вактары" => "Вактар-Йорден",
  "Раджати" => "Сурадж Ка Гхар",
  "Ваку" => "Вакумара",
  "Эдзо" => "Амато",
  "Венды" => "Обитель"
}.freeze

FAMILY_NAME_FIRST_COUNTRIES = [
  "Империя Ланг-Ан",
  "Амато"
].freeze

PEOPLE_ORDER = [
  "Эллийцы",
  "Гойдаир",
  "Надаир",
  "Хтониды",
  "Джу",
  "Лудаир",
  "Хефат",
  "Кадийцы",
  "Талассийцы",
  "Манаи",
  "Авгарцы",
  "Вактары",
  "Раджати",
  "Ваку",
  "Эдзо",
  "Венды"
].freeze

IMITEI_ORDER = [
  "Идеал",
  "Горец",
  "Друид",
  "Профитис",
  "Аватар",
  "Тень",
  "Светоносный",
  "Мститель",
  "Наварх",
  "Хранитель",
  "Мектиг",
  "Вознесённый",
  "Ракша",
  "Шаман",
  "Онмёдзи",
  "Страж"
].freeze

GOD_ORDER = [
  "Гиперион I",
  "Тарун",
  "Церунна",
  "Тиресий",
  "Дракон Ланг-Ан",
  "Мерката",
  "Аст",
  "Альзаман",
  "Калипсо",
  "Икатерра",
  "Хангор",
  "Винтра",
  "Шубханкари",
  "Руфу",
  "Ицунэ",
  "Велисса"
].freeze

CATEGORY_TITLE_ORDER = {
  "Страны" => COUNTRY_ORDER,
  "Народы" => PEOPLE_ORDER,
  "Имитеи" => IMITEI_ORDER,
  "Боги" => GOD_ORDER
}.freeze

CATEGORY_DESCRIPTIONS = {
  "Бестиарий" => "Виды существ, чудовищ и разумных народов, с которыми делят мир смертные и боги.",
  "Боги" => "Пантеоны, культы и бессмертные силы, вмешивающиеся в судьбы народов.",
  "Знания" => "Законы мира, ремёсла, магия и открытия древних цивилизаций.",
  "Имитеи" => "Люди, сумевшие превзойти человеческие пределы и изменить ход истории.",
  "Кухня" => "Блюда, напитки и продукты, через которые раскрываются культуры Астарии.",
  "Литература" => "Саги, хроники, предания и тексты, которыми Астария помнит своё прошлое.",
  "Места" => "Города, земли и забытые уголки, где начинаются путешествия.",
  "Народы" => "Культуры и традиции народов, населяющих берега Хтонического моря.",
  "Организации" => "Ордены, культы, гильдии и тайные союзы со своими целями.",
  "Персонажи" => "Герои, правители, странники и те, чьи решения меняют Астарию.",
  "Предметы" => "Реликвии, оружие и вещи, сохранившие след великих событий.",
  "События" => "Войны, открытия и переломные мгновения истории мира.",
  "Страны" => "Государства Астарии, их устройство, противоречия и место в мире.",
  "Флора" => "Растения Астарии, их свойства, происхождение и место в культурах мира."
}.freeze

SIGNIFICANCE_LABELS = {
  0 => "Эпохальное",
  1 => "Переломное",
  2 => "Важное",
  3 => "Заметное"
}.freeze

SIGNIFICANCE_LABELS_EN = {
  0 => "Epoch-defining",
  1 => "Transformative",
  2 => "Major",
  3 => "Notable"
}.freeze

ASSET_REWRITES = {
  "Assets/Maps/states.png" => "Assets/Maps/Web/states-web.jpg",
  "Assets/Maps/heightmap.png" => "Assets/Maps/Web/heightmap-web.jpg",
  "Assets/Maps/biomes.png" => "Assets/Maps/Web/biomes-web.jpg"
}.freeze

INFOBOX_FIELDS = [
  ["native_name", "Имя на родном языке"],
  ["location_type", "Тип места"],
  ["settlement_type", "Тип поселения"],
  ["organization_type", "Тип организации"],
  ["item_type", "Тип предмета"],
  ["condition_type", "Тип явления"],
  ["profession_type", "Направление"],
  ["medium", "Форма / носитель"],
  ["species", "Вид"],
  ["current_era", "Текущая эпоха"],
  ["birth_year", "Год рождения"],
  ["death_year", "Год смерти"],
  ["current_location", "Текущее местоположение"],
  ["birth_place", "Место рождения"],
  ["parents", "Родители"],
  ["siblings", "Братья и сёстры"],
  ["children", "Дети"],
  ["partner", "Партнёр"],
  ["country", "Страна"],
  ["region", "Регион"],
  ["parent_location", "Часть территории"],
  ["water", "Воды"],
  ["mouth", "Устье"],
  ["continents", "Материки"],
  ["seas", "Моря"],
  ["population", "Население"],
  ["foundation", "Основание"],
  ["independence", "Независимость"],
  ["capital", "Столица"],
  ["headquarters", "Штаб-квартира"],
  ["ruler", "Глава"],
  ["founder", "Основатель"],
  ["founders", "Основатели"],
  ["creator", "Создатель"],
  ["creation_date", "Создание"],
  ["authors", "Авторы"],
  ["origin", "Происхождение"],
  ["ethnicity", "Народ"],
  ["imitei", "Путь Имитея"],
  ["occupation", "Род занятий"],
  ["organizations", "Организации"],
  ["deity", "Покровитель"],
  ["deities", "Божества"],
  ["faiths", "Верования"],
  ["religions", "Религии"],
  ["church", "Вера/культ"],
  ["government", "Форма правления"],
  ["domains", "Сферы влияния"],
  ["symbols", "Священные символы"],
  ["eyes", "Глаза"],
  ["hair", "Волосы"],
  ["skin", "Кожа / окрас"],
  ["height", "Рост"],
  ["weight", "Вес"],
  ["distinguishing_features", "Особые приметы"],
  ["dimensions", "Размеры"],
  ["habitat", "Среда обитания"],
  ["average_height", "Средний рост"],
  ["average_length", "Средняя длина"],
  ["average_weight", "Средний вес"],
  ["lifespan", "Продолжительность жизни"],
  ["course", "Течение"],
  ["rarity", "Редкость"],
  ["historical_date", "Дата"],
  ["starting_date", "Начало"],
  ["ending_date", "Завершение"],
  ["year", "Год"],
  ["endingYear", "Год завершения"],
  ["conflict_location", "Место событий"],
  ["belligerents", "Стороны"],
  ["significance", "Значимость"],
  ["parent_peoples", "Родственные народы"],
  ["child_locations", "Включает"],
  ["inhabiting_peoples", "Народы"],
  ["inhabiting_species", "Обитатели"],
  ["trade_route", "Торговые связи"],
  ["associated_places", "Связанные места"],
  ["related_places", "Связанные места"],
  ["related_conflicts", "Связанные конфликты"],
  ["associated_organizations", "Связанные организации"],
  ["related_organizations", "Связанные организации"],
  ["aligned_organization", "Связанная организация"],
  ["known_practitioners", "Известные представители"],
  ["known_individuals", "Известные особи"],
  ["historical_figures", "Известные личности"],
  ["notable_people", "Известные личности"],
  ["important_people", "Важные личности"],
  ["other_people", "Другие участники"],
  ["known_members", "Известные участники"],
  ["central_characters", "Центральные персонажи"],
  ["affected_people", "Кого затрагивает"],
  ["related_peoples", "Связанные народы"],
  ["related_ethnicities", "Связанные народы"],
  ["related_species", "Связанные виды"],
  ["associated_peoples", "Связанные народы"],
  ["related_professions", "Связанные профессии"],
  ["related_items", "Связанные предметы"],
  ["related_myths", "Связанные предания"],
  ["controlled_territories", "Контролируемые территории"],
  ["contested_territories", "Спорные территории"],
  ["contested_by", "Претенденты"],
  ["opposes", "Противники"]
].freeze

INFOBOX_LABELS_EN = {
  "native_name" => "Native name",
  "location_type" => "Location type",
  "settlement_type" => "Settlement type",
  "organization_type" => "Organisation type",
  "item_type" => "Item type",
  "condition_type" => "Phenomenon type",
  "profession_type" => "Path",
  "medium" => "Medium",
  "species" => "Species",
  "current_era" => "Current era",
  "birth_year" => "Year of birth",
  "death_year" => "Year of death",
  "current_location" => "Current location",
  "birth_place" => "Place of birth",
  "parents" => "Parents",
  "siblings" => "Siblings",
  "children" => "Children",
  "partner" => "Partner",
  "country" => "Realm",
  "region" => "Region",
  "parent_location" => "Part of",
  "water" => "Adjacent waters",
  "mouth" => "Mouth",
  "continents" => "Continents",
  "seas" => "Seas",
  "population" => "Population",
  "foundation" => "Founded",
  "independence" => "Independence",
  "capital" => "Capital",
  "headquarters" => "Headquarters",
  "ruler" => "Ruler",
  "founder" => "Founder",
  "founders" => "Founders",
  "creator" => "Creator",
  "creation_date" => "Created",
  "authors" => "Authors",
  "origin" => "Origin",
  "ethnicity" => "People",
  "imitei" => "Imithei Path",
  "occupation" => "Occupation",
  "organizations" => "Organisations",
  "deity" => "Patron deity",
  "deities" => "Deities",
  "faiths" => "Faiths",
  "religions" => "Religions",
  "church" => "Faith / cult",
  "government" => "Government",
  "domains" => "Domains",
  "symbols" => "Sacred symbols",
  "eyes" => "Eyes",
  "hair" => "Hair",
  "skin" => "Skin / colouring",
  "height" => "Height",
  "weight" => "Weight",
  "distinguishing_features" => "Distinguishing features",
  "dimensions" => "Dimensions",
  "habitat" => "Habitat",
  "average_height" => "Average height",
  "average_length" => "Average length",
  "average_weight" => "Average weight",
  "lifespan" => "Lifespan",
  "course" => "Course",
  "rarity" => "Rarity",
  "historical_date" => "Date",
  "starting_date" => "Begins",
  "ending_date" => "Ends",
  "year" => "Year",
  "endingYear" => "Final year",
  "conflict_location" => "Location",
  "belligerents" => "Belligerents",
  "significance" => "Significance",
  "parent_peoples" => "Kindred peoples",
  "child_locations" => "Includes",
  "inhabiting_peoples" => "Peoples",
  "inhabiting_species" => "Inhabitants",
  "trade_route" => "Trade links",
  "associated_places" => "Associated places",
  "related_places" => "Related places",
  "related_conflicts" => "Related conflicts",
  "associated_organizations" => "Associated organisations",
  "related_organizations" => "Related organisations",
  "aligned_organization" => "Aligned organisation",
  "known_practitioners" => "Known practitioners",
  "known_individuals" => "Known individuals",
  "historical_figures" => "Historical figures",
  "notable_people" => "Notable figures",
  "important_people" => "Important figures",
  "other_people" => "Other participants",
  "known_members" => "Known members",
  "central_characters" => "Central characters",
  "affected_people" => "People affected",
  "related_peoples" => "Related peoples",
  "related_ethnicities" => "Related peoples",
  "related_species" => "Related species",
  "associated_peoples" => "Associated peoples",
  "related_professions" => "Related paths",
  "related_items" => "Related items",
  "related_myths" => "Related legends",
  "controlled_territories" => "Territories",
  "contested_territories" => "Contested territories",
  "contested_by" => "Claimed by",
  "opposes" => "Adversaries"
}.freeze

INFOBOX_VALUE_TRANSLATIONS = {
  "Military" => "Воинское",
  "Religious" => "Религиозное",
  "Arcane" => "Мистическое",
  "Paper" => "Бумага",
  "Illicit, Rebel" => "Тайная повстанческая",
  "Religious, Organised Religion" => "Организованная религия",
  "Religious, Cult" => "Религиозный культ",
  "Druidic Circle" => "Друидический круг",
  "Consumable, Magical" => "Магический расходуемый предмет",
  "Weapon, Melee" => "Оружие ближнего боя"
}.freeze

# The prose itself lives in `_translations/en-GB/pages`. This table contains
# only generator-owned interface copy and universally approved proper names.
# Longer phrases are replaced first so a short label cannot alter a sentence
# before its complete translation is applied.
EN_OUTPUT_REPLACEMENTS = {
  "Мифологическая энциклопедия Астарии — мира богов, героев и древних цивилизаций." => "The mythological encyclopaedia of Astaria — a world of gods, heroes and ancient civilisations.",
  "Мир древних цивилизаций и опасных богов, где судьбы народов меняют герои, сумевшие превзойти человеческие пределы." => "A world of ancient civilisations and perilous gods, where heroes who have surpassed mortal limits reshape the fate of nations.",
  "Виды существ, чудовищ и разумных народов, с которыми делят мир смертные и боги." => "Creatures, monsters and sapient peoples who share the world with mortals and gods.",
  "Пантеоны, культы и бессмертные силы, вмешивающиеся в судьбы народов." => "Pantheons, cults and immortal powers that intervene in the fate of nations.",
  "Законы мира, ремёсла, магия и открытия древних цивилизаций." => "The laws of the world, its crafts, magic and the discoveries of ancient civilisations.",
  "Люди, сумевшие превзойти человеческие пределы и изменить ход истории." => "Mortals who surpassed human limits and changed the course of history.",
  "Блюда, напитки и продукты, через которые раскрываются культуры Астарии." => "Dishes, drinks and ingredients through which the cultures of Astaria reveal themselves.",
  "Саги, хроники, предания и тексты, которыми Астария помнит своё прошлое." => "Sagas, chronicles, legends and writings through which Astaria remembers its past.",
  "Города, земли и забытые уголки, где начинаются путешествия." => "Cities, lands and forgotten corners where journeys begin.",
  "Культуры и традиции народов, населяющих берега Хтонического моря." => "The cultures and traditions of the peoples who inhabit the shores of the Chthonic Sea.",
  "Ордены, культы, гильдии и тайные союзы со своими целями." => "Orders, cults, guilds and secret alliances pursuing purposes of their own.",
  "Герои, правители, странники и те, чьи решения меняют Астарию." => "Heroes, rulers, wanderers and all whose choices change Astaria.",
  "Реликвии, оружие и вещи, сохранившие след великих событий." => "Relics, weapons and objects that still bear the mark of great events.",
  "Войны, открытия и переломные мгновения истории мира." => "Wars, discoveries and turning points in the history of the world.",
  "Государства Астарии, их устройство, противоречия и место в мире." => "The realms of Astaria: their societies, conflicts and place in the world.",
  "Растения Астарии, их свойства, происхождение и место в культурах мира." => "The plants of Astaria, their properties, origins and place among its cultures.",
  "Летописцы готовят первые материалы. Пока можно продолжить путь по карте или вернуться к оглавлению." => "The chroniclers are preparing the first entries. For now, explore the map or return to the contents.",
  "Попробуйте изменить запрос или открыть другой раздел Энциклопедии." => "Try a different query or open another part of the Encyclopaedia.",
  "Народы, страны, личности и существа — всё, из чего соткан живой мир." => "Peoples, realms, figures and creatures — all the threads from which a living world is woven.",
  "Океаны, государства и забытые уголки на одной интерактивной карте." => "Oceans, realms and forgotten corners gathered upon a single interactive map.",
  "Каждый раз Астария открывает другой путь — через страну, героя, божество, место или существо." => "Each visit reveals another path through Astaria — a realm, a hero, a deity, a place or a creature.",
  "Всякая легенда начинается с первого шага." => "Every legend begins with a first step.",
  "Статья об этом месте пока готовится." => "The entry for this place is still being prepared.",
  "Статья готовится к публикации" => "This entry is being prepared for publication",
  "Раздел ещё пополняется" => "This section is still growing",
  "Ничего не найдено" => "Nothing found",
  "Пять дверей в Астарию" => "Five Doors into Astaria",
  "Куда отправиться дальше?" => "Where will you travel next?",
  "Добро пожаловать в Астарию" => "Welcome to Astaria",
  "Воин с огненным клинком встречает чудовищ Астарии" => "A warrior with a burning blade faces the monsters of Astaria",
  "Водопады и озеро Астарии" => "Waterfalls and a lake in Astaria",
  "Политическая карта Астарии" => "Political map of Astaria",
  "Древний город во время великого вторжения" => "An ancient city during the great invasion",
  "Открыть хронологию Астарии" => "Open the history of Astaria",
  "Исследовать интерактивную карту Астарии" => "Explore the interactive map of Astaria",
  "Разделы энциклопедии" => "Encyclopaedia sections",
  "Энциклопедия" => "Encyclopaedia",
  "Популярные разделы" => "Popular sections",
  "Основные разделы" => "Main sections",
  "Оглавление мира" => "A World in Chapters",
  "Начать путешествие" => "Begin the journey",
  "Открыть карту" => "Open the map",
  "Исследовать мир" => "Explore the world",
  "Сквозь эпохи" => "Across the Ages",
  "Хронология" => "Timeline",
  "Первые свидетельства об археях" => "First evidence of the Archaeans",
  "Основание Талассии" => "Foundation of Thalassia",
  "Нынешняя эпоха" => "The present age",
  "Увидеть всю историю" => "See the whole history",
  "Все разделы" => "All sections",
  "Другие пути" => "Other paths",
  "Открыть статью" => "Read the entry",
  "Отправная точка" => "Starting point",
  "Герб государства" => "Realm crest",
  "Герб:" => "Crest:",
  "Государство Астарии" => "Realm of Astaria",
  "Государство" => "Realm",
  "Божество" => "Deity",
  "Существа" => "Creatures",
  "Существо" => "Creature",
  "Другие земли" => "Other lands",
  "Найти статью в разделе…" => "Find an entry in this section…",
  "Найти статью в разделе" => "Find an entry in",
  "Поиск по разделу" => "Search within",
  "Показано:" => "Showing:",
  "Сбросить" => "Clear",
  "На главную" => "Home",
  "Хлебные крошки" => "Breadcrumbs",
  "Путь Имитея" => "Imithei Path",
  "Сведения" => "Details",
  "Имя на родном языке" => "Native name",
  "Год рождения" => "Year of birth",
  "Текущее местоположение" => "Current location",
  "Место рождения" => "Place of birth",
  "Братья и сёстры" => "Siblings",
  "Родители" => "Parents",
  "Страна" => "Realm",
  "Народ" => "People",
  "Рост" => "Height",
  "Вес" => "Weight",
  "Глаза" => "Eyes",
  "Волосы" => "Hair",
  "Кожа / окрас" => "Skin / colouring",
  "Среда обитания" => "Habitat",
  "Средняя длина" => "Average length",
  "Средний вес" => "Average weight",
  "Продолжительность жизни" => "Lifespan",
  "Часть территории" => "Part of",
  "Включает" => "Includes",
  "Бестиарий" => "Bestiary",
  "Боги" => "Gods",
  "Знания" => "Lore",
  "Имитеи" => "Imithei",
  "Кухня" => "Cuisine",
  "Литература" => "Literature",
  "Места" => "Places",
  "Народы" => "Peoples",
  "Организации" => "Organisations",
  "Персонажи" => "Characters",
  "Предметы" => "Items",
  "События" => "Events",
  "Страны" => "Realms",
  "Флора" => "Flora",
  "Личность" => "Figure",
  "Место" => "Place",
  "Астария" => "Astaria",
  "Архея" => "Archaea",
  "Археи" => "Archaeans",
  "Гилас" => "Gilas",
  "Империя Ланг-Ан" => "Lang-An Empire",
  "Вактар-Йорден" => "Vaktar-Jorden",
  "Дикоземье" => "Wildlands",
  "Громовые Кланы" => "Thunder Clans",
  "Амон-Астат" => "Amon-Astat",
  "Джу" => "Dju",
  "Гойдаир" => "Goidair",
  "Вактары" => "Vaktars",
  "Вознесённый" => "Ascended",
  "Горец" => "Highlander",
  "Аватар" => "Avatar",
  "Дракон Ланг-Ан" => "Lang-An",
  "Нуа Си" => "Nuwa Xi",
  "Лисандра мак Рейн" => "Lisandra mac Rayne",
  "Деревня Эрвин" => "Erwin",
  "Эрвин" => "Erwin",
  "Зов Бури" => "Call of Thunder",
  "Война Жаждущих" => "War of the Thirsty",
  "Долина Кровавого Цветения" => "Valley of Blood-Blossom",
  "Горный хребет Зверя" => "Beast Mountains",
  "Хангорская долина" => "Khangorian Valley",
  "Река Тяо Хэ" => "Tiao He",
  "Горный хребет Шафар" => "Shafar Mountains",
  "Рассветное море" => "Dawn Sea",
  "Город Линфу" => "Linfu",
  "Деревня Минчуань" => "Minchuan",
  "Лес Шеньянь" => "Shenyan",
  "Озеро Чанг" => "Lake Chang",
  "Озеро Шуан" => "Lake Shuan",
  "Мэй Ву" => "Mei Wu",
  "НЭ" => "NE",
  "ХЭ" => "ChE",
  "год Новой Эры" => "year of the New Era",
  "империя ланг-ан" => "lang-an",
  "громовые кланы" => "thunder clans",
  "вактар-йорден" => "vaktar-jorden",
  "дикоземье" => "Wildlands",
  "народы" => "peoples",
  "организации" => "organisations",
  "предметы" => "items",
  "события" => "events",
  "страны" => "realms",
  "литература" => "literature",
  "знания" => "lore",
  "имитеи" => "imithei",
  "кухня" => "cuisine",
  "боги" => "gods",
  "флора" => "flora",
  "персонажи" => "characters",
  "бестиарий" => "bestiary",
  "места" => "places",
  " из " => " of ",
  "лет" => "years",
  "места на карте" => "places on the map"
}.freeze

def localize_output(text)
  return text unless BUILD_LOCALE == "en-GB"

  protected_links = {}
  text = text.gsub(/\[\[([^|\]]+)(?:\|([^\]]+))?\]\]/) do
    target = Regexp.last_match(1).strip
    label = Regexp.last_match(2)&.strip
    approved = AstariaTranslations.name_for(target)
    translated_target = approved&.fetch("title", nil).to_s.strip
    translated_target = EN_OUTPUT_REPLACEMENTS.fetch(target, "").to_s.strip if translated_target.empty?
    if translated_target.empty? && label && !label.match?(/[А-Яа-яЁё]/)
      translated_target = label.gsub(/[*_`]/, "").strip
    end
    translated_target = target if translated_target.empty?
    if label&.match?(/[А-Яа-яЁё]/)
      label = EN_OUTPUT_REPLACEMENTS
        .sort_by { |source, _translation| -source.length }
        .reduce(label) { |result, (source, translation)| result.gsub(source, translation) }
      label = translated_target if label.match?(/[А-Яа-яЁё]/) && !translated_target.match?(/[А-Яа-яЁё]/)
    end

    token = "ASTARIAWIKILINK#{protected_links.length}TOKEN"
    protected_links[token] = "[[#{translated_target}#{label ? "|#{label}" : ""}]]"
    token
  end

  localized = EN_OUTPUT_REPLACEMENTS
    .sort_by { |source, _translation| -source.length }
    .reduce(text) { |result, (source, translation)| result.gsub(source, translation) }
    .gsub(/^lang:\s*ru\s*$/, "lang: en-GB")
  protected_links.reduce(localized) do |result, (token, link)|
    result.gsub(token, link)
  end
end

def write_output(path, text)
  File.write(path, localize_output(text))
end

# Canonical notes store the relationship on the object that naturally owns it:
# a person names their country and Imitei path, while a landmark names its parent
# location. Quartz derives the reverse sidebar collections at build time so that
# authors do not have to maintain the same fact in two different files.
AUTO_INVERSE_RELATIONSHIPS = [
  {
    source_categories: ["Персонажи"],
    source_fields: ["imitei"],
    target_categories: ["Имитеи"],
    target_field: "known_practitioners"
  },
  {
    source_categories: ["Персонажи"],
    source_fields: ["country", "origin", "organizations"],
    target_categories: ["Страны"],
    target_field: "important_people"
  },
  {
    source_categories: ["Персонажи"],
    source_fields: ["current_location"],
    target_categories: ["Места"],
    target_field: "important_people"
  },
  {
    source_categories: ["Персонажи"],
    source_fields: ["birth_place"],
    target_categories: ["Места"],
    target_field: "notable_people"
  },
  {
    source_categories: ["Персонажи"],
    source_fields: ["organizations", "aligned_organization"],
    target_categories: ["Организации"],
    target_field: "known_members"
  },
  {
    source_categories: ["Персонажи"],
    source_fields: ["species"],
    target_categories: ["Бестиарий"],
    target_field: "known_individuals"
  },
  {
    source_categories: ["Места"],
    source_fields: ["parent_location"],
    target_categories: ["Места"],
    target_field: "child_locations"
  },
  {
    source_categories: ["Места"],
    source_fields: ["country"],
    target_categories: ["Страны"],
    target_field: "controlled_territories"
  },
  {
    source_categories: ["Бестиарий", "Флора"],
    source_fields: ["habitat"],
    target_categories: ["Места"],
    target_field: "inhabiting_species"
  },
  {
    source_categories: ["Имитеи"],
    source_fields: ["associated_organizations"],
    target_categories: ["Организации", "Страны"],
    target_field: "related_professions"
  },
  {
    source_categories: ["Имитеи"],
    source_fields: ["associated_places"],
    target_categories: ["Места"],
    target_field: "related_professions"
  },
  {
    source_categories: ["Боги"],
    source_fields: ["faiths", "religions", "country"],
    target_categories: ["Организации", "Страны"],
    target_field: "deities"
  },
  {
    source_categories: ["Организации", "Страны"],
    source_fields: ["deities"],
    target_categories: ["Боги"],
    target_field: "faiths"
  },
  {
    source_categories: ["Организации"],
    source_fields: ["headquarters"],
    target_categories: ["Места"],
    target_field: "related_organizations"
  },
  {
    source_categories: ["Организации"],
    source_fields: ["country"],
    target_categories: ["Страны"],
    target_field: "associated_organizations"
  },
  {
    source_categories: ["События"],
    source_fields: ["conflict_location"],
    target_categories: ["Места"],
    target_field: "related_conflicts"
  }
].freeze

CURRENT_ASTARIAN_YEAR = Date.today.year - 1920

TRANSLITERATION = {
  "а" => "a", "б" => "b", "в" => "v", "г" => "g", "д" => "d",
  "е" => "e", "ё" => "yo", "ж" => "zh", "з" => "z", "и" => "i",
  "й" => "y", "к" => "k", "л" => "l", "м" => "m", "н" => "n",
  "о" => "o", "п" => "p", "р" => "r", "с" => "s", "т" => "t",
  "у" => "u", "ф" => "f", "х" => "kh", "ц" => "ts", "ч" => "ch",
  "ш" => "sh", "щ" => "shch", "ъ" => "", "ы" => "y", "ь" => "",
  "э" => "e", "ю" => "yu", "я" => "ya"
}.freeze

def frontmatter_for(path)
  text = File.read(path)
  return [{}, text] unless text.start_with?("---\n")

  _before, yaml_text, body = text.split(/^---\s*$/, 3)
  data = YAML.safe_load(
    yaml_text || "",
    permitted_classes: [Date, Time],
    aliases: true
  ) || {}
  [data, body || ""]
rescue Psych::SyntaxError => error
  warn "Skipping #{path}: invalid YAML (#{error.message})"
  [{}, text]
end

def publishable_markdown?(path)
  return false if PRIVATE_PATH_PREFIXES.any? { |prefix| path.start_with?("#{prefix}/") }

  data, = frontmatter_for(path)
  data["quartz"] == true
end

def extract_asset_path(value)
  value.to_s[/\[\[([^|\]#]+)(?:[|\]#])?/, 1]
end

def slugify(value)
  transliterated = value.to_s.downcase.each_char.map do |char|
    TRANSLITERATION.fetch(char, char)
  end.join

  transliterated
    .gsub(/[^a-z0-9]+/, "-")
    .gsub(/\A-+|-+\z/, "")
end

def normalize_reference(value)
  value.to_s
    .split("#", 2)
    .first
    .to_s
    .tr("\\", "/")
    .split("/")
    .last
    .to_s
    .sub(/\.md\z/i, "")
    .downcase
    .tr("ё", "е")
    .gsub(/\s+/, " ")
    .strip
end

def relative_href(from_route, to_route)
  from_dir = File.dirname(from_route)
  from_dir = "." if from_dir == "."

  if to_route == "index"
    depth = from_dir == "." ? 0 : from_dir.split("/").length
    return depth.zero? ? "./" : "../" * depth
  end

  relative = Pathname.new(to_route).relative_path_from(Pathname.new(from_dir)).to_s
  relative == "." ? "../#{File.basename(to_route)}" : relative
end

def build_reference_lookup(records)
  lookup = {}
  records.each do |record|
    data = record[:data]
    keys = [
      data["title"],
      data["canonical_title"],
      data["public_slug"],
      File.basename(record[:source], ".md")
    ]
    keys.concat(Array(data["aliases"]))
    keys.compact.each do |key|
      normalized = normalize_reference(key)
      lookup[normalized] ||= record unless normalized.empty?
    end
  end
  lookup
end

def record_category(record)
  record[:data]["category"].to_s.empty? ? source_category(record[:source]).to_s : record[:data]["category"].to_s
end

def canonical_relationship_records
  excluded_prefixes = PRIVATE_PATH_PREFIXES.map { |prefix| "#{prefix}/" }
  Dir.glob(File.join(ROOT, "Энциклопедия", "**", "*.md")).sort.map do |source|
    next if excluded_prefixes.any? { |prefix| source.start_with?(prefix) }

    data, = frontmatter_for(source)
    next if data["title"].to_s.strip.empty?

    { source: source, data: data }
  end.compact
end

def canonical_reference_lookup
  @canonical_reference_lookup ||= build_reference_lookup(canonical_relationship_records)
end

def append_unique_reference!(data, field, title)
  title = title.to_s.strip
  return if title.empty?

  values = Array(data[field]).compact
  identities = values.flat_map { |value| reference_names(value) }.map { |value| normalize_reference(value) }
  return if identities.include?(normalize_reference(title))

  data[field] = values + ["[[#{title}]]"]
end

def reference_already_listed?(data, fields, title)
  identity = normalize_reference(title)
  fields.any? do |field|
    reference_names(data[field]).any? { |value| normalize_reference(value) == identity }
  end
end

def enrich_inverse_relationships!(published_records, canonical_records)
  published_lookup = build_reference_lookup(published_records)
  canonical_lookup = build_reference_lookup(canonical_records)

  canonical_records.each do |source_record|
    source_category_name = record_category(source_record)
    source_title = source_record[:data]["title"].to_s.strip
    next if source_title.empty?

    AUTO_INVERSE_RELATIONSHIPS.each do |rule|
      next unless rule[:source_categories].include?(source_category_name)

      rule[:source_fields].each do |field|
        reference_names(source_record[:data][field]).each do |target_name|
          canonical_target = canonical_lookup[normalize_reference(target_name)]
          next unless canonical_target
          next unless rule[:target_categories].include?(record_category(canonical_target))
          next if canonical_target[:source] == source_record[:source]

          published_target = published_lookup[normalize_reference(canonical_target[:data]["title"])]
          next unless published_target

          published_source = published_lookup[normalize_reference(source_title)]
          next if BUILD_LOCALE == "en-GB" && published_source.nil?
          if rule[:target_field] == "important_people" && reference_already_listed?(
            published_target[:data],
            %w[notable_people historical_figures known_individuals],
            source_title
          )
            next
          end

          append_unique_reference!(published_target[:data], rule[:target_field], source_title)
        end
      end
    end
  end
end

def image_slug(data)
  raw = data["portrait_image"] ||
    data["cover_image"] ||
    data["female_portrait"] ||
    data["male_portrait"] ||
    data["flag_image"]
  path = extract_asset_path(raw)
  return nil unless path

  base = File.basename(path, File.extname(path))
  base = base.sub(/_(landscape|male|female|m|f)\z/i, "")
  slugify(base)
end

def source_category(path)
  encyclopedia = File.join(ROOT, "Энциклопедия")
  return nil unless path.start_with?("#{encyclopedia}/")

  relative = path.delete_prefix("#{encyclopedia}/")
  parts = relative.split("/")
  parts.length > 1 ? parts.first : nil
end

def article_slug(data)
  if USE_APPROVED_ROUTES
    approved = AstariaTranslations.public_slug_for(data)
    return slugify(approved) unless approved.empty?
  end

  explicit = data["public_slug"].to_s.strip
  return slugify(explicit) unless explicit.empty?

  image_slug(data) || slugify(data["title"])
end

def legacy_article_slug(data)
  explicit = data["public_slug"].to_s.strip
  return slugify(explicit) unless explicit.empty?

  image_slug(data) || slugify(data["title"])
end

def localized_source(source, data, body)
  return [data, body] unless BUILD_LOCALE == "en-GB"

  translation = AstariaTranslations.translation_for(source)
  unless translation
    relative = Pathname.new(source).relative_path_from(Pathname.new(ROOT))
    raise "Missing en-GB translation: #{relative}"
  end

  translated_data, translated_body, = translation
  canonical_title = data["title"].to_s
  localized_data = data.merge(translated_data)
  approved = AstariaTranslations.name_for(canonical_title)
  if approved
    localized_data["title"] = approved.fetch("title")
    localized_data["public_slug"] = approved.fetch("slug")
    localized_data["native_name"] = approved["native_name"] if approved.key?("native_name")
  end
  localized_data["aliases"] = Array(translated_data["aliases"])
  localized_data["aliases"] << localized_data["title"]
  localized_data["aliases"] = localized_data["aliases"].compact.map(&:to_s).uniq
  localized_data["lang"] = "en-GB"
  localized_data["canonical_title"] = canonical_title
  # Map coordinates remain canonical data. Keeping them in the Russian source
  # prevents the two language overlays from drifting apart when a marker moves.
  localized_body = if data["type"] == "map"
    "#{translated_body}\n#{body}"
  else
    translated_body
  end
  [localized_data, localized_body]
end

def public_route(source, data)
  explicit = data["public_slug"].to_s.strip
  return "index" if explicit == "index"
  return "map" if source.start_with?(File.join(ROOT, "Карты")) || data["type"] == "map"

  if source.start_with?(File.join(ROOT, "Хронология"))
    return "timeline/index" if data["type"] == "timeline" || explicit == "timeline"
    return "timeline/#{article_slug(data)}"
  end

  category = source_category(source)
  category_route = CATEGORY_ROUTES.fetch(category, slugify(category || "articles"))
  "#{category_route}/#{article_slug(data)}"
end

def legacy_public_route(source, data)
  explicit = data["public_slug"].to_s.strip
  return "index" if explicit == "index"
  return "map" if source.start_with?(File.join(ROOT, "Карты")) || data["type"] == "map"

  if source.start_with?(File.join(ROOT, "Хронология"))
    return "timeline/index" if data["type"] == "timeline" || explicit == "timeline"
    return "timeline/#{legacy_article_slug(data)}"
  end

  category = source_category(source)
  category_route = CATEGORY_ROUTES.fetch(category, slugify(category || "articles"))
  "#{category_route}/#{legacy_article_slug(data)}"
end

def target_path(route)
  File.join(DEST, "#{route}.md")
end

def display_value(value)
  case value
  when Array
    value.map { |item| display_value(item) }.reject(&:empty?).join(", ")
  else
    value.to_s
      .gsub(/\[\[([^|\]]+)\|([^\]]+)\]\]/, '\\2')
      .gsub(/\[\[([^\]]+)\]\]/, '\\1')
      .strip
  end
end

def display_category(category)
  return category unless BUILD_LOCALE == "en-GB"

  EN_OUTPUT_REPLACEMENTS.fetch(category, category)
end

def display_public_title(value)
  text = value.to_s
  return text unless BUILD_LOCALE == "en-GB"

  approved = AstariaTranslations.name_for(text)
  return approved.fetch("title") if approved

  EN_OUTPUT_REPLACEMENTS.fetch(text, text)
end

def astaria_year_number(value)
  return value.to_i if value.is_a?(Numeric)

  match = value.to_s.strip.match(/\A(-?\d+)\s*(ХЭ|НЭ)?/i)
  return nil unless match

  number = match[1].to_i
  era = match[2].to_s.upcase
  era == "ХЭ" ? -number.abs : number
end

def astaria_year_label(value)
  number = astaria_year_number(value)
  return display_value(value) if number.nil?

  "#{number.abs} #{number.negative? ? "ХЭ" : "НЭ"}"
end

def age_label(age)
  return age == 1 ? "year" : "years" if BUILD_LOCALE == "en-GB"

  mod100 = age % 100
  mod10 = age % 10
  return "лет" if (11..14).cover?(mod100)
  return "год" if mod10 == 1
  return "года" if (2..4).cover?(mod10)

  "лет"
end

def english_reference_label(target, explicit_label, lookup)
  label = explicit_label.to_s.strip
  return label if !label.empty? && !label.match?(/[А-Яа-яЁё]/)

  record = lookup[normalize_reference(target)]
  return record[:data]["title"].to_s if record

  approved = AstariaTranslations.name_for(target)
  return approved.fetch("title") if approved

  replacement = EN_OUTPUT_REPLACEMENTS[target.to_s]
  return replacement unless replacement.to_s.empty?

  nil
end

def english_measurement_value(value)
  text = value.to_s.strip
  match = text.match(/\A(\d+(?:[.,]\s*\d+)?)\s*(м|кг)\z/i)
  return text unless match

  number = match[1].gsub(/,\s*/, ".")
  unit = match[2].downcase == "м" ? "m" : "kg"
  "#{number} #{unit}"
end

def render_inline_value(value, route, lookup)
  raw = if BUILD_LOCALE == "en-GB"
    value.to_s
  else
    INFOBOX_VALUE_TRANSLATIONS.fetch(value.to_s, value.to_s)
  end
  return "" if raw.strip.empty?

  if BUILD_LOCALE == "en-GB" && !raw.include?("[[")
    raw = english_measurement_value(raw)
    raw = EN_OUTPUT_REPLACEMENTS
      .sort_by { |source, _translation| -source.length }
      .reduce(raw) { |result, (source, translation)| result.gsub(source, translation) }
    if raw.match?(/[А-Яа-яЁё]/)
      raw = english_reference_label(value.to_s, nil, lookup).to_s
      return "" if raw.empty?
    end
  end

  rendered = +""
  index = 0
  raw.to_enum(:scan, /\[\[([^|\]]+)(?:\|([^\]]+))?\]\]/).each do
    match = Regexp.last_match
    rendered << CGI.escapeHTML(raw[index...match.begin(0)].to_s)
    target = match[1]
    record = lookup[normalize_reference(target)]
    label = match[2]
    if BUILD_LOCALE == "en-GB"
      label = english_reference_label(target, label, lookup)
      return "" if label.to_s.empty?
    end
    label = match[1] if label.to_s.empty?
    rendered << if record && record[:route] != route
      href = relative_href(route, record[:route])
      %(<a class="astaria-infobox-link" href="#{CGI.escapeHTML(href)}">#{CGI.escapeHTML(label)}</a>)
    elsif record
      %(<span class="astaria-infobox-reference astaria-self-reference">#{CGI.escapeHTML(label)}</span>)
    else
      %(<span class="astaria-infobox-reference" title="Статья готовится к публикации">#{CGI.escapeHTML(label)}</span>)
    end
    index = match.end(0)
  end
  rendered << CGI.escapeHTML(raw[index..].to_s)
  rendered.strip
end

def render_value(value, route, lookup)
  case value
  when Array
    items = value.map { |item| render_value(item, route, lookup) }.reject(&:empty?)
    return "" if items.empty?
    return items.join(", ") if items.length <= 3

    if items.length > 6
      visible = items.first(5).map { |item| "<li>#{item}</li>" }.join
      hidden = items.drop(5).map { |item| "<li>#{item}</li>" }.join
      remaining = items.length - 5
      more_label = BUILD_LOCALE == "en-GB" ? "#{remaining} more" : "Ещё #{remaining}"
      return %(<ul class="astaria-infobox-list">#{visible}</ul><details class="astaria-infobox-more"><summary>#{more_label}</summary><ul class="astaria-infobox-list">#{hidden}</ul></details>)
    end

    list_items = items.map { |item| "<li>#{item}</li>" }.join
    %(<ul class="astaria-infobox-list">#{list_items}</ul>)
  else
    render_inline_value(value, route, lookup)
  end
end

def render_infobox_value(key, data, route, lookup)
  if key == "native_name"
    return CGI.escapeHTML(data[key].to_s.strip)
  end

  # The Imithei hero already presents these three defining facts. Repeating
  # them in the adjacent profile made both locales noisier and allowed the two
  # presentations to drift independently.
  return "" if imitei_page?(data) && %w[profession_type country people].include?(key)

  # A world's explicit continent list is the meaningful public hierarchy.
  # The inverse parent-location index derives the same entries as generic
  # child locations, which would otherwise duplicate them in the sidebar.
  return "" if key == "child_locations" && !Array(data["continents"]).empty?

  return "" if key == "imitei" && (data[key] == false || data[key].to_s.strip.empty?)

  if key == "population" && data[key].to_s.match?(/\A\d+\z/)
    separator = BUILD_LOCALE == "en-GB" ? "," : "\u202f"
    return CGI.escapeHTML(data[key].to_s.reverse.scan(/.{1,3}/).join(separator).reverse)
  end

  if key == "significance"
    return "" unless data["timeline"] == true || data["type"].to_s == "historical-event"

    if BUILD_LOCALE == "en-GB"
      label = SIGNIFICANCE_LABELS_EN.fetch(data[key].to_i, "Chronicle")
      return CGI.escapeHTML("#{label} event")
    end

    label = SIGNIFICANCE_LABELS.fetch(data[key].to_i, "Летописное")
    return CGI.escapeHTML("#{label} событие")
  end

  if key == "birth_year"
    year = astaria_year_number(data[key])
    return render_value(data[key], route, lookup) if year.nil?

    death_year = astaria_year_number(data["death_year"])
    recorded_age = astaria_year_number(data["age_at_death"])
    age = if death_year
      recorded_age || death_year - year
    else
      CURRENT_ASTARIAN_YEAR - year
    end
    age_text = if death_year
      BUILD_LOCALE == "en-GB" ? "#{age} #{age_label(age)} at death" : "#{age} #{age_label(age)} на момент смерти"
    else
      "#{age} #{age_label(age)}"
    end
    age_note = age.negative? ? "" : %(<span class="astaria-infobox-note">#{age_text}</span>)
    return "#{CGI.escapeHTML(astaria_year_label(year))}#{age_note}"
  end

  return "" if key == "year" && (data["historical_date"] || data["starting_date"])
  return "" if key == "endingYear" && data["ending_date"]

  if %w[year endingYear death_year].include?(key)
    return CGI.escapeHTML(astaria_year_label(data[key]))
  end

  render_value(data[key], route, lookup)
end

def public_asset_url(asset_path)
  asset_path.split("/").map { |part| part.downcase.tr(" ", "-") }.join("/")
end

def render_image_tag(asset_path, css_class, alt_text: nil, fetchpriority: nil)
  url = public_asset_url(asset_path)
  alt = alt_text.to_s.strip
  alt = File.basename(asset_path, File.extname(asset_path)).tr("_-", " ") if alt.empty?
  priority = fetchpriority ? %( fetchpriority="#{CGI.escapeHTML(fetchpriority)}") : ""
  %(<img class="#{css_class}" src="#{CGI.escapeHTML(url)}" alt="#{CGI.escapeHTML(alt)}"#{priority}>)
end

# CommonMark ends a raw HTML block at a blank line. Optional fragments inside
# generated cards used to leave whitespace-only rows, so the remaining nested
# tags were occasionally rendered as visible source code. Keep generated UI
# fragments contiguous while leaving ordinary article Markdown untouched.
def markdown_safe_html(html)
  html.lines.reject { |line| line.strip.empty? }.join.strip
end

def render_asset_embeds(body)
  body.gsub(/!\[\[([^|\]#]+)(?:[|#][^\]]*)?\]\]/) do |match|
    raw_path = Regexp.last_match(1).strip
    unless raw_path.start_with?("Assets/Images/") || raw_path.start_with?("Assets/Maps/")
      next match
    end

    asset_path = ASSET_REWRITES.fetch(raw_path, raw_path)
    render_image_tag(asset_path, "astaria-inline-image")
  end
end

def render_public_wikilinks(body, route, lookup)
  body.gsub(/(?<!!)\[\[([^\]|#]+)(?:#[^\]|]+)?(?:\|([^\]]+))?\]\]/) do
    target = Regexp.last_match(1).strip
    record = lookup[normalize_reference(target)]
    label = Regexp.last_match(2)
    label = record[:data]["title"] if label.to_s.empty? && BUILD_LOCALE == "en-GB" && record
    label = File.basename(target) if label.to_s.empty?
    label = label.strip
    escaped_label = CGI.escapeHTML(label)

    if record && record[:route] != route
      href = relative_href(route, record[:route])
      %(<a class="astaria-inline-link" href="#{CGI.escapeHTML(href)}">#{escaped_label}</a>)
    elsif record
      %(<span class="astaria-self-reference">#{escaped_label}</span>)
    else
      %(<span class="astaria-unpublished-reference" title="Статья готовится к публикации">#{escaped_label}</span>)
    end
  end
end

def remove_markdown_callouts(body)
  cleaned = []
  skipping_callout = false

  body.each_line do |line|
    if line.match?(/^>\s*\[![^\]]+\]/)
      skipping_callout = true
      next
    end

    if skipping_callout && line.start_with?(">")
      next
    end

    skipping_callout = false
    cleaned << line
  end

  cleaned.join
end

def description_from_body(body, data)
  explicit = data["description"].to_s
    .gsub(/\*\*([^*]+)\*\*/, '\1')
    .gsub(/__([^_]+)__/, '\1')
    .strip
  return explicit unless explicit.empty?
  return "Интерактивная карта Астарии с поиском по местам, масштабированием и слоями границ, рельефа и биомов." if data["type"] == "map"

  body_without_callouts = remove_markdown_callouts(body)
  main_section = body_without_callouts.match(/^## (?:Основной текст|Main text)\s*\n+(.*?)(?=^## |\z)/m)
  text = main_section ? main_section[1] : cleanup_public_body(body_without_callouts, data)
  text = text.gsub(/```.*?```/m, " ")
  text = text.gsub(/%%.*?%%/m, " ")
  text = text.gsub(/!\[\[[^\]]+\]\]/, " ")
  text = text.gsub(/\[\[([^|\]]+)\|([^\]]+)\]\]/, '\\2')
  text = text.gsub(/\[\[([^\]]+)\]\]/, '\\1')
  text = text.gsub(/\*\*([^*]+)\*\*/, '\1')
  text = text.gsub(/__([^_]+)__/, '\1')
  text = text.gsub(/^\s*[#>|*-]+\s*/, "")
  text = text.gsub(/<[^>]+>/, " ")
  text = text.gsub(/\s+/, " ").strip
  title = data["title"].to_s.strip
  if !title.empty? && text.match?(/\A#{Regexp.escape(title)}(?=\s|[,;:.!—–-]|\z)/u)
    text = text.sub(/\A#{Regexp.escape(title)}/u, "")
      .sub(/\A\s*(?:[,;:.!—–-]\s*)+/, "")
      .strip
    text = text.sub(/\A([«„“"']*)([а-яё])/u) do
      "#{Regexp.last_match(1)}#{Regexp.last_match(2).upcase}"
    end
  end
  if text.empty?
    return BUILD_LOCALE == "en-GB" ? "Encyclopaedia of Astaria." : "Энциклопедия мира Астарии."
  end

  return text if text.length <= 180

  shortened = text[0, 177].sub(/\s+\S*\z/, "").strip
  "#{shortened}…"
end

def article_count_label(count)
  mod100 = count % 100
  mod10 = count % 10
  return "статей" if (11..14).cover?(mod100)
  return "статья" if mod10 == 1
  return "статьи" if (2..4).cover?(mod10)

  "статей"
end

def place_count_label(count)
  mod100 = count % 100
  mod10 = count % 10
  return "мест" if (11..14).cover?(mod100)
  return "место" if mod10 == 1
  return "места" if (2..4).cover?(mod10)

  "мест"
end

def sidebar_image(data)
  return nil if data["public_slug"].to_s.strip == "index"

  raw = data["portrait_image"] || data["flag_image"]
  path = extract_asset_path(raw)
  path && ASSET_REWRITES.fetch(path, path)
end

def crest_image(data)
  return nil if data["public_slug"].to_s.strip == "index"

  path = extract_asset_path(data["crest_image"])
  path && ASSET_REWRITES.fetch(path, path)
end

def cover_image(data)
  raw = data["cover_image"]
  path = extract_asset_path(raw)
  return nil unless path

  path = ASSET_REWRITES.fetch(path, path)
  path == sidebar_image(data) ? nil : path
end

def imitei_page?(data)
  data["category"].to_s == "Имитеи" && data["type"].to_s == "profession"
end

def imitei_portrait(data, role)
  raw = data["#{role}_portrait"]
  path = extract_asset_path(raw)
  path && ASSET_REWRITES.fetch(path, path)
end

def imitei_portraits_ready?(data)
  imitei_page?(data) && imitei_portrait(data, "female") && imitei_portrait(data, "male")
end

def imitei_portrait_roles(data, lookup)
  deity_name = reference_names(data["deity"]).first
  raise "Imitei #{data["title"]}: deity is missing" if deity_name.to_s.empty?

  deity = lookup[normalize_reference(deity_name)] || canonical_reference_lookup[normalize_reference(deity_name)]
  raise "Imitei #{data["title"]}: deity #{deity_name.inspect} has no canonical metadata" unless deity

  gender = display_value(deity[:data]["gender"]).downcase
  primary = if gender.match?(/\A(?:женск|female)/)
    "female"
  elsif gender.match?(/\A(?:мужск|male)/)
    "male"
  else
    raise "Imitei #{data["title"]}: deity #{deity_name.inspect} has no supported gender"
  end

  [primary, primary == "female" ? "male" : "female"]
end

def primary_article_image(data, lookup)
  if imitei_portraits_ready?(data)
    primary_role = imitei_portrait_roles(data, lookup).first
    return imitei_portrait(data, primary_role)
  end

  sidebar_image(data) ||
    cover_image(data) ||
    imitei_portrait(data, "female") ||
    imitei_portrait(data, "male")
end

def timeline_image(data)
  raw = data["timeline_image"] || data["cover_image"]
  path = extract_asset_path(raw)
  path && ASSET_REWRITES.fetch(path, path)
end

def build_cover(data)
  image_path = cover_image(data)
  return "" unless image_path

  <<~HTML
    <figure class="astaria-cover-frame">
    #{render_image_tag(image_path, "astaria-cover-image", alt_text: data["title"], fetchpriority: "high")}
    </figure>
  HTML
end

def build_imitei_hero(route, data, body, lookup)
  female_portrait = imitei_portrait(data, "female")
  male_portrait = imitei_portrait(data, "male")
  return "" unless female_portrait && male_portrait

  title = data["title"].to_s
  title_size = if title.length >= 10
    "long"
  elsif title.length >= 7
    "medium"
  else
    "short"
  end
  home_href = relative_href(route, "index")
  category_route = CATEGORY_ROUTES.fetch("Имитеи")
  native_name = data["native_name"].to_s.strip
  native_html = if native_name.empty?
    ""
  else
    native_language = if native_name.match?(/[\p{Han}\p{Hiragana}\p{Katakana}]/u)
      "ja"
    elsif native_name.match?(/[А-Яа-яЁё]/)
      "ru"
    else
      "und"
    end
    %(<p class="astaria-imitei-native" lang="#{native_language}">#{CGI.escapeHTML(native_name)}</p>)
  end
  description = description_from_body(body, data)

  ui = if BUILD_LOCALE == "en-GB"
    {
      path: "Path",
      homeland: "Homeland",
      patron: "Patron deity",
      people: "People",
      female: "Female form",
      male: "Male form",
      breadcrumbs: "Breadcrumbs",
      home: "Astaria",
      category: "Imithei",
      kicker: "Imithei Path",
      portraits: "Forms of the path"
    }
  else
    {
      path: "Направление",
      homeland: "Родина пути",
      patron: "Покровитель",
      people: "Народ",
      female: "Женский образ",
      male: "Мужской образ",
      breadcrumbs: "Хлебные крошки",
      home: "Астария",
      category: "Имитеи",
      kicker: "Путь Имитея",
      portraits: "Образы пути"
    }
  end

  metadata = [
    [ui[:path], data["profession_type"]],
    [ui[:homeland], data["country"] || Array(data["associated_organizations"]).first],
    [ui[:patron], data["deity"]],
    [ui[:people], data["people"]]
  ].map do |label, value|
    text = display_value(value)
    next if text.empty?

    <<~HTML
      <div>
        <dt>#{CGI.escapeHTML(label)}</dt>
        <dd>#{CGI.escapeHTML(text)}</dd>
      </div>
    HTML
  end.compact.join
  metadata_html = metadata.empty? ? "" : %(<dl class="astaria-imitei-hero-meta">#{metadata}</dl>)

  portrait_paths = {
    "female" => female_portrait,
    "male" => male_portrait
  }
  portrait_labels = {
    "female" => ui[:female],
    "male" => ui[:male]
  }
  portraits = imitei_portrait_roles(data, lookup).each_with_index.map do |role, index|
    image_path = portrait_paths.fetch(role)
    label = portrait_labels.fetch(role)
    number = format("%02d", index + 1)
    alt = if BUILD_LOCALE == "en-GB"
      "#{label} of the “#{title}” path"
    else
      "#{label} пути «#{title}»"
    end
    <<~HTML
      <figure class="astaria-imitei-portrait" data-portrait="#{role}">
        #{render_image_tag(image_path, "astaria-imitei-portrait-image", alt_text: alt, fetchpriority: "high")}
        <figcaption><span>#{number}</span>#{CGI.escapeHTML(label)}</figcaption>
      </figure>
    HTML
  end.join

  markdown_safe_html(<<~HTML)
    <header class="astaria-imitei-hero astaria-imitei-hero-#{title_size}-title">
      <nav class="astaria-article-trail" aria-label="#{ui[:breadcrumbs]}">
        <a href="#{CGI.escapeHTML(home_href)}">#{ui[:home]}</a>
        <span aria-hidden="true">/</span>
        <a href="../#{CGI.escapeHTML(category_route)}/">#{ui[:category]}</a>
      </nav>
      <div class="astaria-imitei-hero-grid">
        <div class="astaria-imitei-hero-copy">
          <p class="astaria-imitei-kicker">#{ui[:kicker]}</p>
          <h1 class="astaria-content-title astaria-imitei-title-#{title_size}">#{CGI.escapeHTML(title)}</h1>
          #{native_html}
          <p class="astaria-imitei-lede">#{CGI.escapeHTML(description)}</p>
          #{metadata_html}
        </div>
        <div class="astaria-imitei-hero-media" aria-label="#{ui[:portraits]} “#{CGI.escapeHTML(title)}”">
          #{portraits}
        </div>
      </div>
    </header>
  HTML
end

def build_title(route, data)
  return "" if data["public_slug"].to_s.strip == "index"

  title = CGI.escapeHTML(data["title"].to_s)
  home_href = relative_href(route, "index")
  category = data["category"].to_s
  category_route = CATEGORY_ROUTES[category]
  category_crumb = if category_route
    category_href = "../#{category_route}/"
    %(<span aria-hidden="true">/</span><a href="#{CGI.escapeHTML(category_href)}">#{CGI.escapeHTML(display_category(category))}</a>)
  else
    ""
  end

  <<~HTML
    <nav class="astaria-article-trail" aria-label="Хлебные крошки">
    <a href="#{CGI.escapeHTML(home_href)}">Астария</a>
    #{category_crumb}
    </nav>
    <h1 class="astaria-content-title">#{title}</h1>
  HTML
end

def build_coverless_title(source, route, data, lookup)
  return "" if data["public_slug"].to_s.strip == "index"

  chapter_page = %w[chapter session].include?(data["type"].to_s)
  title = chapter_page ? chapter_short_title(data) : data["title"].to_s
  escaped_title = CGI.escapeHTML(title)
  home_href = relative_href(route, "index")
  category = data["category"].to_s
  category_route = CATEGORY_ROUTES[category]
  category_crumb = if category_route
    %(<span aria-hidden="true">/</span><a href="../#{CGI.escapeHTML(category_route)}/">#{CGI.escapeHTML(display_category(category))}</a>)
  else
    ""
  end
  saga = saga_landing_record(source, data, lookup)
  saga_crumb = if saga
    %(<span aria-hidden="true">/</span><a href="#{CGI.escapeHTML(relative_href(route, saga[:route]))}">#{CGI.escapeHTML(saga[:data]["title"].to_s)}</a>)
  else
    ""
  end
  kicker = case data["type"].to_s
  when "chapter", "session"
    label = BUILD_LOCALE == "en-GB" ? "Chapter" : "Глава"
    "#{label} #{format("%03d", data["chapter"].to_i)}"
  when "campaign", "document"
    BUILD_LOCALE == "en-GB" ? "An Astaria Saga" : "Сага Астарии"
  else display_category(category)
  end
  metadata = [
    data["year"] && astaria_year_label(data["year"]),
    data["season"],
    display_value(data["region"])
  ].compact.map(&:to_s).reject(&:empty?).first(3)
  metadata_html = metadata.map { |value| %(<span>#{CGI.escapeHTML(value)}</span>) }.join
  metadata_block = metadata_html.empty? ? "" : %(\n          <div class="astaria-coverless-meta">#{metadata_html}</div>)
  english_title = data["english_title"].to_s.strip
  english_title_html = if english_title.empty?
    ""
  else
    %(\n          <p class="astaria-coverless-subtitle" lang="en">#{CGI.escapeHTML(english_title)}</p>)
  end
  hero_class = chapter_page ? "astaria-coverless-hero astaria-coverless-hero-chapter" : "astaria-coverless-hero"

  <<~HTML
    <header class="#{hero_class}">
      <nav class="astaria-article-trail" aria-label="Хлебные крошки">
        <a href="#{CGI.escapeHTML(home_href)}">Астария</a>
        #{category_crumb}
        #{saga_crumb}
      </nav>
      <div class="astaria-coverless-main">
        <div>
          <p class="astaria-coverless-kicker">#{CGI.escapeHTML(kicker)}</p>
          <h1 class="astaria-content-title">#{escaped_title}</h1>#{english_title_html}#{metadata_block}
        </div>
        <div class="astaria-coverless-ornament" aria-hidden="true"><span></span><i></i></div>
      </div>
    </header>
  HTML
end

def build_sidebar(data, route, lookup)
  return "" if data["public_slug"].to_s.strip == "index"

  image_path = sidebar_image(data)
  crest_path = crest_image(data)
  rows = INFOBOX_FIELDS.map do |key, label|
    rendered = render_infobox_value(key, data, route, lookup)
    next if rendered.empty?

    label = INFOBOX_LABELS_EN.fetch(key, label) if BUILD_LOCALE == "en-GB"
    %(<div class="astaria-infobox-row"><dt>#{CGI.escapeHTML(label)}</dt><dd>#{rendered}</dd></div>)
  end.compact

  return "" if image_path.nil? && crest_path.nil? && rows.empty?

  image = if image_path
    "#{render_image_tag(image_path, "astaria-sidebar-image", alt_text: data["title"])}\n"
  else
    ""
  end

  crest = if crest_path
    "#{render_image_tag(crest_path, "astaria-crest-image", alt_text: "Герб: #{data["title"]}")}\n"
  else
    ""
  end

  heading = if imitei_page?(data)
    BUILD_LOCALE == "en-GB" ? "Path profile" : "Профиль пути"
  else
    BUILD_LOCALE == "en-GB" ? "Details" : "Сведения"
  end
  infobox = if rows.empty?
    ""
  else
    <<~HTML
      <div class="astaria-infobox">
      <p class="astaria-infobox-heading">#{heading}</p>
      <dl>
      #{rows.join("\n")}
      </dl>
      </div>
    HTML
  end

  sidebar_class = imitei_page?(data) ? "astaria-sidebar astaria-imitei-profile" : "astaria-sidebar"

  markdown_safe_html(<<~HTML)
    <aside class="#{sidebar_class}" aria-label="#{BUILD_LOCALE == "en-GB" ? "Details" : "Сведения"}: #{CGI.escapeHTML(data["title"].to_s)}">
    #{image}
    #{crest}
    #{infobox}
    </aside>
  HTML
end

def build_featured_lede(data)
  return "" unless data["featured_entry"]

  description = data["description"].to_s.strip
  return "" if description.empty?

  %(<p class="astaria-article-lede">#{CGI.escapeHTML(description)}</p>)
end

def build_astaria_journey(route, data)
  return "" unless data["featured_entry"] && data["category"] == "Места"

  category_href = lambda do |category_route|
    relative_href(route, "#{category_route}/index").sub(/index\z/, "")
  end
  destinations = if BUILD_LOCALE == "en-GB"
    [
      ["World Atlas", relative_href(route, "map"), "132 marked places, with adjustable scale and map layers."],
      ["Timeline", relative_href(route, "timeline/index"), "The events that shaped an ancient world into the one known today."],
      ["Realms", category_href.call("countries"), "States, their rulers, lands and unresolved conflicts."],
      ["Peoples", category_href.call("peoples"), "The cultures, customs and memories of those who inhabit Astaria."],
      ["Gods", category_href.call("gods"), "Immortal powers, their cults and dangerous games with mortal fate."],
      ["Characters", category_href.call("characters"), "Heroes, wanderers and creatures whose choices change the world."]
    ]
  else
    [
      ["Атлас мира", relative_href(route, "map"), "132 отмеченных места, масштаб и слои карты."],
      ["Хронология", relative_href(route, "timeline/index"), "События, которые превратили древний мир в нынешний."],
      ["Страны", category_href.call("countries"), "Государства, их правители, земли и неразрешённые противоречия."],
      ["Народы", category_href.call("peoples"), "Культуры, обычаи и память тех, кто населяет Астарию."],
      ["Боги", category_href.call("gods"), "Бессмертные силы, культы и опасные игры с судьбами смертных."],
      ["Персонажи", category_href.call("characters"), "Герои, странники и существа, чьи решения меняют мир."]
    ]
  end
  action = BUILD_LOCALE == "en-GB" ? "Explore" : "Исследовать"
  cards = destinations.each_with_index.map do |(title, href, description), index|
    <<~HTML
      <a class="astaria-journey-card" href="#{CGI.escapeHTML(href)}">
        <span>#{format("%02d", index + 1)}</span>
        <strong>#{CGI.escapeHTML(title)}</strong>
        <p>#{CGI.escapeHTML(description)}</p>
        <b>#{action} <i aria-hidden="true">→</i></b>
      </a>
    HTML
  end

  <<~HTML
    <section class="astaria-place-next" aria-labelledby="astaria-place-next-title">
      <header>
        <p>#{BUILD_LOCALE == "en-GB" ? "Choose your path" : "Выберите свой путь"}</p>
        <h2 id="astaria-place-next-title">#{BUILD_LOCALE == "en-GB" ? "Where will you travel next?" : "Куда отправиться дальше?"}</h2>
      </header>
      <div>#{cards.join("\n")}</div>
    </section>
  HTML
end

def map_markers(body, lookup)
  markers = []
  body.scan(/^\s*-\s+default,\s*(\d+),\s*(\d+),\s*\[\[([^|\]]+)(?:\|([^\]]+))?\]\]\s*$/) do |y, x, target, label|
    canonical_name = (label || target).strip
    kind = case canonical_name
    when /(?:Город|Деревня|Храм|Кузня|Обитель)/i then "settlement"
    when /(?:Озеро|Река|море|залив|пролив|перешеек)/i then "water"
    when /(?:Гор|Пустын|Лес|Джунг|Болот|Долин|луг|земл|Вулкан|Предгор)/i then "terrain"
    else "realm"
    end
    record = lookup[normalize_reference(target)]
    translated_marker_name = AstariaTranslations.english_title_for(target.strip)
    name = if BUILD_LOCALE == "en-GB" && record
      record[:data]["title"].to_s.strip
    elsif BUILD_LOCALE == "en-GB" && translated_marker_name
      translated_marker_name.to_s.strip
    else
      canonical_name
    end
    if BUILD_LOCALE == "en-GB" && record.nil? && translated_marker_name.nil?
      next if ONLY_TRANSLATED

      raise "Missing English map marker name: #{target.strip}"
    end
    markers << {
      y: y.to_f,
      x: x.to_f,
      target: target.strip,
      name: name.empty? ? canonical_name : name,
      kind: kind
    }
  end
  markers
end

def build_map_explorer(data, body, route, lookup)
  width = data["map_width"].to_f
  height = data["map_height"].to_f
  width = 7680.0 if width <= 0
  height = 4320.0 if height <= 0
  markers = map_markers(body, lookup)

  ui = if BUILD_LOCALE == "en-GB"
    {
      layers: {
        "states" => ["Boundaries", "Political map"],
        "heightmap" => ["Relief", "Physical map"],
        "biomes" => ["Biomes", "Natural regions"]
      },
      show: "Show",
      breadcrumbs: "Breadcrumbs",
      home: "Astaria",
      trail: "World Atlas",
      kicker: "Interactive atlas",
      place_count: ->(count) { count == 1 ? "location" : "locations" },
      title: "Map of Astaria",
      description: "Zoom with the mouse wheel, drag with a mouse or touch, and switch layers to explore boundaries, relief and natural regions.",
      search: "Find a place on the map",
      search_placeholder: "Find a city, river or region…",
      layer: "Map layer",
      results: "Map search results",
      guide: "Guide",
      guide_text: "Enter a name or choose a point directly on the map.",
      legend: "Map legend",
      settlements: "Settlements",
      waters: "Waters",
      landscape: "Landscape",
      regions: "Regions",
      viewport: "Interactive map. Move with the arrow keys; zoom with plus and minus.",
      close: "Close place card",
      read: "Read the entry",
      preparing: "The entry for this place is still being prepared.",
      zoom: "Map zoom",
      zoom_in: "Zoom in",
      zoom_out: "Zoom out",
      reset: "Show the whole map",
      help: "Mouse wheel — zoom · Drag — pan"
    }
  else
    {
      layers: {
        "states" => ["Границы", "Политическая карта"],
        "heightmap" => ["Рельеф", "Физическая карта"],
        "biomes" => ["Биомы", "Карта природных зон"]
      },
      show: "Показать",
      breadcrumbs: "Хлебные крошки",
      home: "Астария",
      trail: "Атлас мира",
      kicker: "Интерактивный атлас",
      place_count: ->(count) { place_count_label(count) },
      title: "Карта Астарии",
      description: "Приближайте карту колёсиком, перемещайте её мышью или касанием и переключайте слои, чтобы увидеть границы, рельеф и природные зоны.",
      search: "Найти место на карте",
      search_placeholder: "Найти город, реку или регион…",
      layer: "Слой карты",
      results: "Результаты поиска по карте",
      guide: "Путеводитель",
      guide_text: "Введите название или выберите точку прямо на карте.",
      legend: "Легенда карты",
      settlements: "Поселения",
      waters: "Воды",
      landscape: "Ландшафт",
      regions: "Регионы",
      viewport: "Интерактивная карта. Перемещайте стрелками, приближайте клавишами плюс и минус.",
      close: "Закрыть карточку места",
      read: "Читать статью",
      preparing: "Статья об этом месте пока готовится.",
      zoom: "Масштаб карты",
      zoom_in: "Приблизить",
      zoom_out: "Отдалить",
      reset: "Показать всю карту",
      help: "Колёсико — масштаб · Перетаскивание — обзор"
    }
  end

  layers = ui[:layers].map do |key, labels|
    configured_path = extract_asset_path((data["map_layers"] || {})[key])
    path = BUILD_LOCALE == "en-GB" ? AstariaTranslations.map_layer_for(key) : configured_path
    [key, labels, path]
  end

  layer_images = layers.map.with_index do |(key, labels, path), index|
    next unless path
    url_attribute = index.zero? ? %(src="#{CGI.escapeHTML(public_asset_url(path))}" fetchpriority="high") : %(data-src="#{CGI.escapeHTML(public_asset_url(path))}")
    %(<img class="astaria-map-layer#{index.zero? ? " is-active" : ""}" data-layer="#{key}" #{url_attribute} alt="#{CGI.escapeHTML(labels.last)}" decoding="async" draggable="false">)
  end.compact.join("\n")

  layer_buttons = layers.map.with_index do |(key, labels, _path), index|
    %(<button type="button" class="astaria-map-layer-button#{index.zero? ? " is-active" : ""}" data-layer="#{key}" aria-pressed="#{index.zero?}">#{CGI.escapeHTML(labels.first)}</button>)
  end.join("\n")

  marker_buttons = markers.map do |marker|
    record = lookup[normalize_reference(marker[:target])]
    href = record ? relative_href(route, record[:route]) : ""
    left = (marker[:x] / width * 100).round(4)
    # Leaflet image coordinates use a geographic Y axis: larger geoY values
    # point north. CSS `top` grows southward, so the vertical position must be
    # mirrored when the canonical marker is placed over the raster.
    top = ((height - marker[:y]) / height * 100).round(4)
    %(<button type="button" class="astaria-map-marker astaria-map-marker-#{marker[:kind]}" style="left:#{left}%;top:#{top}%" data-name="#{CGI.escapeHTML(marker[:name])}" data-kind="#{marker[:kind]}" data-x="#{left}" data-y="#{top}" data-href="#{CGI.escapeHTML(href)}" aria-label="#{ui[:show]}: #{CGI.escapeHTML(marker[:name])}"><span></span></button>)
  end.join("\n")

  home_href = relative_href(route, "index")
  <<~HTML
    <section class="astaria-map-page" aria-labelledby="astaria-map-title">
      <nav class="astaria-article-trail astaria-map-trail" aria-label="#{ui[:breadcrumbs]}"><a href="#{CGI.escapeHTML(home_href)}">#{ui[:home]}</a><span aria-hidden="true">/</span><span>#{ui[:trail]}</span></nav>
      <header class="astaria-map-heading">
        <div>
          <p class="astaria-map-kicker">#{ui[:kicker]} · #{markers.length} #{ui[:place_count].call(markers.length)}</p>
          <h1 id="astaria-map-title">#{ui[:title]}</h1>
        </div>
        <p>#{ui[:description]}</p>
      </header>
      <div class="astaria-map-explorer" data-map-width="#{width.to_i}" data-map-height="#{height.to_i}">
        <div class="astaria-map-toolbar">
          <label class="astaria-map-search-label">
            <svg aria-hidden="true" viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"></circle><path d="m20 20-4-4"></path></svg>
            <span class="sr-only">#{ui[:search]}</span>
            <input class="astaria-map-search" type="search" placeholder="#{ui[:search_placeholder]}" autocomplete="off">
          </label>
          <div class="astaria-map-layer-switcher" role="group" aria-label="#{ui[:layer]}">
            #{layer_buttons}
          </div>
        </div>
        <div class="astaria-map-shell">
          <aside class="astaria-map-panel" aria-label="#{ui[:results]}">
            <div class="astaria-map-panel-intro">
              <span>#{ui[:guide]}</span>
              <strong>#{markers.length} #{ui[:place_count].call(markers.length)} #{BUILD_LOCALE == "en-GB" ? "on the map" : "на карте"}</strong>
              <p>#{ui[:guide_text]}</p>
            </div>
            <div class="astaria-map-results" aria-live="polite"></div>
            <div class="astaria-map-legend" aria-label="#{ui[:legend]}">
              <span><i class="astaria-map-legend-settlement"></i>#{ui[:settlements]}</span>
              <span><i class="astaria-map-legend-water"></i>#{ui[:waters]}</span>
              <span><i class="astaria-map-legend-terrain"></i>#{ui[:landscape]}</span>
              <span><i class="astaria-map-legend-realm"></i>#{ui[:regions]}</span>
            </div>
          </aside>
          <div class="astaria-map-viewport" tabindex="0" aria-label="#{ui[:viewport]}">
            <div class="astaria-map-stage">
              <img class="astaria-map-preview" src="#{CGI.escapeHTML(public_asset_url(AstariaTranslations.map_layer_for("states", variant: "web")))}" alt="" aria-hidden="true" decoding="async" fetchpriority="high" draggable="false">
              #{layer_images}
              <div class="astaria-map-markers">#{marker_buttons}</div>
            </div>
            <div class="astaria-map-detail" hidden>
              <button type="button" class="astaria-map-detail-close" aria-label="#{ui[:close]}">×</button>
              <span class="astaria-map-detail-kind"></span>
              <strong class="astaria-map-detail-name"></strong>
              <a class="astaria-map-detail-link" href="">#{ui[:read]} <span aria-hidden="true">→</span></a>
              <p class="astaria-map-detail-note">#{ui[:preparing]}</p>
            </div>
            <div class="astaria-map-zoom-controls" aria-label="#{ui[:zoom]}">
              <button type="button" data-map-action="zoom-in" aria-label="#{ui[:zoom_in]}">+</button>
              <button type="button" data-map-action="zoom-out" aria-label="#{ui[:zoom_out]}">−</button>
              <button type="button" data-map-action="reset" aria-label="#{ui[:reset]}">⌂</button>
            </div>
            <p class="astaria-map-help">#{ui[:help]}</p>
          </div>
        </div>
      </div>
    </section>
  HTML
end

def timeline_year_label(year, ending_year = nil)
  year = year.to_i
  ending_year = ending_year.to_i unless ending_year.nil? || ending_year.to_s.empty?
  era = if BUILD_LOCALE == "en-GB"
    year.negative? ? "ChE" : "NE"
  else
    year.negative? ? "ХЭ" : "НЭ"
  end
  start = year.negative? ? year.abs : year
  finish = if ending_year
    ending_year.negative? ? ending_year.abs : ending_year
  end
  range = finish && finish != start ? "#{start}–#{finish}" : start.to_s
  "#{range} #{era}"
end

def timeline_events(lookup)
  paths = Dir.glob(File.join(ROOT, "Хронология", "События", "*.md"))
  paths.concat(Dir.glob(File.join(ROOT, "Энциклопедия", "События", "*.md")))

  paths.map do |path|
    data, body = frontmatter_for(path)
    next unless data["timeline"] == true
    next if data["year"].nil?
    if BUILD_LOCALE == "en-GB"
      next if ONLY_TRANSLATED && AstariaTranslations.translation_for(path).nil?

      data, body = localized_source(path, data, body)
    end

    title = data["title"].to_s
    published = lookup[normalize_reference(title)]
    {
      title: title,
      year: data["year"].to_i,
      ending_year: data["endingYear"],
      category: data["timeline_category"].to_s.strip,
      significance: data["significance"].to_i,
      significance_label: if BUILD_LOCALE == "en-GB"
        SIGNIFICANCE_LABELS_EN.fetch(data["significance"].to_i, "Chronicle")
      else
        SIGNIFICANCE_LABELS.fetch(data["significance"].to_i, "Летописное")
      end,
      description: timeline_description(body, data),
      image: timeline_image(data),
      route: published && published[:route]
    }
  end.compact.sort_by { |event| [event[:year], event[:title]] }
end

def timeline_description(body, data)
  lines = body.lines
  marker = lines.index { |line| line.match?(/^>\s*\[!timeline\]/i) }
  callout = if marker
    lines[(marker + 1)..].take_while { |line| line.start_with?(">") }.map do |line|
      line.sub(/^>\s?/, "").strip
    end.join(" ")
  else
    ""
  end
  text = callout.empty? ? description_from_body(body, data) : callout
  text = text.gsub(/\[\[([^|\]]+)\|([^\]]+)\]\]/, '\\2')
  text = text.gsub(/\[\[([^\]]+)\]\]/, '\\1')
  text = text.gsub(/\s+/, " ").strip
  return text if text.length <= 180

  "#{text[0, 177].sub(/\s+\S*\z/, "").strip}…"
end

def build_timeline_page(data, route, lookup)
  events = timeline_events(lookup)
  categories = events.map { |event| event[:category] }.reject(&:empty?).uniq.sort
  home_href = relative_href(route, "index")

  controls = categories.map do |category|
    %(<option value="#{CGI.escapeHTML(category)}">#{CGI.escapeHTML(category)}</option>)
  end.join("\n")

  ui = if BUILD_LOCALE == "en-GB"
    {
      eras: [
        ["chthonic", "Chthonic Era", "Before the Fall of Chthon"],
        ["new", "New Era", "After the Fall of Chthon"]
      ],
      historical_milestone: "Historical milestone",
      event_count: ->(count) { count == 1 ? "1 event" : "#{count} events" },
      read: "Read the chronicle",
      trail: "Timeline",
      hero_alt: "A city of Astaria during an invasion",
      hero_meta: "#{events.length} milestones · from 5025 ChE to the present day",
      title: "History of Astaria",
      lede: "A chronicle of civilisations, wars, discoveries and falls preserved in the archives of the world.",
      filters: "Timeline filters",
      search: "Find an event",
      search_placeholder: "For example, Thalassia or the Fall of Chthon…",
      event_type: "Event type",
      all_events: "All events",
      showing: "Showing: #{events.length}",
      empty_title: "No events found",
      empty_text: "Try a different query or choose another type."
    }
  else
    {
      eras: [
        ["chthonic", "Хтоническая эра", "До Падения Хтона"],
        ["new", "Новая эра", "После Падения Хтона"]
      ],
      historical_milestone: "Историческая веха",
      event_count: ->(count) { "#{count} событий" },
      read: "Читать летопись",
      trail: "Хронология",
      hero_alt: "Город Астарии во время вторжения",
      hero_meta: "#{events.length} вех · от 5025 года ХЭ до наших дней",
      title: "История Астарии",
      lede: "Летопись цивилизаций, войн, открытий и падений, сохранившихся в архивах мира.",
      filters: "Фильтры хронологии",
      search: "Поиск события",
      search_placeholder: "Например, Талассия или Падение Хтона…",
      event_type: "Тип события",
      all_events: "Все события",
      showing: "Показано: #{events.length}",
      empty_title: "Событий не найдено",
      empty_text: "Попробуйте изменить запрос или выбрать другой тип."
    }
  end

  era_sections = ui[:eras].map do |era, title, subtitle|
    era_events = if era == "chthonic"
      events.select { |event| event[:year].negative? }
    else
      events.reject { |event| event[:year].negative? }
    end
    cards = era_events.map do |event|
      event_title = CGI.escapeHTML(event[:title])
      heading = if event[:route]
        href = relative_href(route, event[:route])
        %(<h3><a href="#{CGI.escapeHTML(href)}">#{event_title}</a></h3>)
      else
        %(<h3>#{event_title}</h3>)
      end
      image = if event[:image]
        %(<img src="#{CGI.escapeHTML(public_asset_url(event[:image]))}" alt="" loading="lazy">)
      else
        ""
      end
      category = event[:category].empty? ? ui[:historical_milestone] : event[:category]
      search_value = [event[:title], category, event[:significance_label], event[:description]].join(" ").downcase.tr("ё", "е")
      markdown_safe_html(<<~HTML)
        <li class="astaria-timeline-event" data-era="#{era}" data-category="#{CGI.escapeHTML(category)}" data-search="#{CGI.escapeHTML(search_value)}">
          <div class="astaria-timeline-year"><span>#{timeline_year_label(event[:year], event[:ending_year])}</span></div>
          <article class="astaria-timeline-card astaria-timeline-significance-#{event[:significance]}">
            #{image}
            <div>
              <p class="astaria-timeline-meta"><span>#{CGI.escapeHTML(category)}</span><span>#{CGI.escapeHTML(event[:significance_label])}</span></p>
              #{heading}
              <div>#{CGI.escapeHTML(event[:description])}</div>
              #{event[:route] ? %(<a class="astaria-timeline-read" href="#{CGI.escapeHTML(relative_href(route, event[:route]))}">#{ui[:read]} <span aria-hidden="true">→</span></a>) : ""}
            </div>
          </article>
        </li>
      HTML
    end.join("\n")

    <<~HTML
      <section class="astaria-timeline-era" data-timeline-era="#{era}">
        <header><p>#{CGI.escapeHTML(subtitle)}</p><h2>#{CGI.escapeHTML(title)}</h2><span>#{ui[:event_count].call(era_events.length)}</span></header>
        <ol class="astaria-timeline-list">#{cards}</ol>
      </section>
    HTML
  end.join("\n")

  <<~HTML
    <section class="astaria-timeline-page" aria-labelledby="astaria-timeline-title">
      <nav class="astaria-article-trail"><a href="#{CGI.escapeHTML(home_href)}">#{BUILD_LOCALE == "en-GB" ? "Astaria" : "Астария"}</a><span aria-hidden="true">/</span><span>#{ui[:trail]}</span></nav>
      <header class="astaria-timeline-hero">
        <img src="../assets/images/acheus_invasion.jpg" alt="#{ui[:hero_alt]}" fetchpriority="high">
        <div class="astaria-timeline-hero-shade"></div>
        <div>
          <p>#{ui[:hero_meta]}</p>
          <h1 id="astaria-timeline-title">#{ui[:title]}</h1>
          <span>#{ui[:lede]}</span>
        </div>
      </header>
      <div class="astaria-timeline-controls" role="search" aria-label="#{ui[:filters]}">
        <label><span>#{ui[:search]}</span><input class="astaria-timeline-search" type="search" placeholder="#{ui[:search_placeholder]}" autocomplete="off"></label>
        <label><span>#{ui[:event_type]}</span><select class="astaria-timeline-category"><option value="">#{ui[:all_events]}</option>#{controls}</select></label>
        <p class="astaria-timeline-count" aria-live="polite">#{ui[:showing]}</p>
      </div>
      <div class="astaria-timeline-empty" hidden><strong>#{ui[:empty_title]}</strong><span>#{ui[:empty_text]}</span></div>
      <div class="astaria-timeline-eras">#{era_sections}</div>
    </section>
  HTML
end

def build_article_footer(route, data)
  return "" if data["public_slug"].to_s.strip == "index"

  category = data["category"].to_s
  category_route = CATEGORY_ROUTES[category]
  category_link = if category_route
    href = "../#{category_route}/"
    %(<a href="#{CGI.escapeHTML(href)}">#{CGI.escapeHTML(display_category(category))}</a>)
  end

  links = [%(<a href="#{CGI.escapeHTML(relative_href(route, "index"))}">Астария</a>), category_link].compact.join("\n")
  <<~HTML
    <footer class="astaria-article-footer">
    #{links}
    </footer>
  HTML
end

def cleanup_public_body(body, data)
  image_paths = [
    sidebar_image(data),
    cover_image(data),
    crest_image(data),
    imitei_portrait(data, "female"),
    imitei_portrait(data, "male")
  ].compact

  body = body.gsub(/\r\n?/, "\n")
  body = body.gsub(/%%.*?%%\s*/m, "")
  body = body.sub(/\A\s*# .+?\n+/, "")
  body = body.gsub(/^## (?:Основной текст|Main text)\s*\n+/, "")
  body = body.gsub(/^## Образы\s*\n+/, "") if imitei_page?(data)
  body = body.gsub(/^## Связи\s*\n+```dataview\n.*?```\s*/m, "")
  body = body.gsub(/```dataview\n.*?```\s*/m, "")
  body = body.gsub(/^## Главы\s*\n*/, "") if saga_landing?(data)
  body = body.gsub(/^> \[!info\] Домены\s*\n(?:>.*\n?)+/i, "") if data["domains"]
  body = body.gsub(/^## Куда отправиться дальше\s*\n.*\z/m, "") if data["featured_entry"]
  unless data["english_title"].to_s.strip.empty?
    english_title = Regexp.escape(data["english_title"].to_s.strip)
    body = body.sub(/\A\s*\*#{english_title}\*\s*\n+/, "")
  end
  body = body.gsub(/^(\s*[-*+] .+)\n(?:\s*\n)+(?=\s*[-*+] )/, "\\1\n") while body.match?(/^(\s*[-*+] .+)\n(?:\s*\n)+(?=\s*[-*+] )/)

  image_paths.each do |image_path|
    body = body.gsub(/^\s*!\[\[#{Regexp.escape(image_path)}(?:\|[^\]]+)?\]\]\s*\n+/, "")
  end

  body.strip
end

def saga_landing?(data)
  data["category"] == "Литература" && !Array(data["central_characters"]).empty?
end

def records_from_lookup(lookup)
  lookup.values.uniq { |record| record[:source] }
end

def saga_chapter_records(source, lookup)
  records_from_lookup(lookup).select do |record|
    record[:source] != source &&
      File.dirname(record[:source]) == File.dirname(source) &&
      %w[chapter session].include?(record[:data]["type"].to_s)
  end.sort_by { |chapter| [chapter[:data]["chapter"].to_i, chapter[:data]["title"].to_s] }
end

def saga_landing_record(source, data, lookup)
  return nil unless %w[chapter session].include?(data["type"].to_s)

  expected_title = data["saga"].to_s.strip
  records_from_lookup(lookup).find do |candidate|
    next false if candidate[:source] == source
    next false unless File.dirname(candidate[:source]) == File.dirname(source)
    next false unless saga_landing?(candidate[:data])
    next true if expected_title.empty?

    candidate_names = [
      candidate[:data]["title"],
      candidate[:data]["canonical_title"],
      *Array(candidate[:data]["aliases"])
    ].map { |name| normalize_reference(name) }
    candidate_names.include?(normalize_reference(expected_title))
  end
end

def chapter_short_title(data)
  data["title"].to_s.sub(/^(?:Глава|Chapter)\s+\d+\s*[-—:]\s*/i, "")
end

def saga_chapter_card(chapter, route)
  chapter_data = chapter[:data]
  number = chapter_data["chapter"].to_i
  meta = [
    chapter_data["year"] && astaria_year_label(chapter_data["year"]),
    chapter_data["season"],
    display_value(chapter_data["region"])
  ].compact.map(&:to_s).reject(&:empty?).join(" · ")
  english_title = chapter_data["english_title"].to_s.strip
  english_html = english_title.empty? ? "" : %(<em lang="en">#{CGI.escapeHTML(english_title)}</em>)
  meta_html = meta.empty? ? "" : %(<small>#{CGI.escapeHTML(meta)}</small>)
  [
    %(<a class="astaria-saga-chapter-card" href="#{CGI.escapeHTML(relative_href(route, chapter[:route]))}">),
    %(<span>#{format("%03d", number)}</span>),
    "<div>",
    %(<strong>#{CGI.escapeHTML(chapter_short_title(chapter_data))}</strong>),
    english_html,
    meta_html,
    "</div>",
    %(<b aria-hidden="true">→</b>),
    "</a>"
  ].reject(&:empty?).join("\n")
end

def saga_chapter_region_groups(chapters)
  chapters.chunk_while do |left, right|
    display_value(left[:data]["region"]) == display_value(right[:data]["region"])
  end.to_a
end

def build_saga_chapters(source, route, data, lookup)
  return "" unless saga_landing?(data)

  english = BUILD_LOCALE == "en-GB"
  chapters = saga_chapter_records(source, lookup)
  content = if chapters.empty?
    character_links = Array(data["central_characters"]).first(4).map do |character|
      render_value(character, route, lookup)
    end.join
    links = if character_links.empty?
      ""
    else
      label = english ? "Saga characters" : "Герои саги"
      %(<nav class="astaria-saga-character-links" aria-label="#{label}">#{character_links}</nav>)
    end
    <<~HTML
      <div class="astaria-saga-empty">
        <div class="astaria-saga-empty-mark" aria-hidden="true"><span>✦</span></div>
        <div>
          <strong>#{english ? "The chronicle is still unfolding" : "Летопись ещё раскрывается"}</strong>
          <p>#{english ? "No chapters have been published yet. You can begin with the saga’s characters — their fates are already woven into the Encyclopaedia." : "Главы пока не опубликованы. Начать знакомство с сагой можно с её героев — их судьбы уже вплетены в Энциклопедию."}</p>
          #{links}
        </div>
      </div>
    HTML
  else
    if chapters.length > 24
      groups = saga_chapter_region_groups(chapters)
      region_links = groups.each_with_index.map do |group, index|
        region = display_value(group.first[:data]["region"])
        region = english ? "Prologue" : "Пролог" if region.empty?
        first_number = group.first[:data]["chapter"].to_i
        last_number = group.last[:data]["chapter"].to_i
        range = first_number == last_number ? format("%03d", first_number) : "#{format("%03d", first_number)}–#{format("%03d", last_number)}"
        %(<a href="#chapters-region-#{index + 1}"><strong>#{CGI.escapeHTML(region)}</strong><small>#{range}</small></a>)
      end.join
      regions = groups.each_with_index.map do |group, index|
        region = display_value(group.first[:data]["region"])
        region = english ? "Prologue" : "Пролог" if region.empty?
        first_number = group.first[:data]["chapter"].to_i
        last_number = group.last[:data]["chapter"].to_i
        singular = english ? "Chapter" : "Глава"
        plural = english ? "Chapters" : "Главы"
        range = first_number == last_number ? "#{singular} #{format("%03d", first_number)}" : "#{plural} #{format("%03d", first_number)}–#{format("%03d", last_number)}"
        cards = group.map { |chapter| saga_chapter_card(chapter, route) }.join
        <<~HTML
          <section class="astaria-saga-chapter-range" id="chapters-region-#{index + 1}">
            <header><p>#{CGI.escapeHTML(range)}</p><h3>#{CGI.escapeHTML(region)}</h3></header>
            <div class="astaria-saga-chapter-grid">#{cards}</div>
          </section>
        HTML
      end.join
      label = english ? "Saga regions" : "Регионы саги"
      %(<nav class="astaria-saga-range-nav" aria-label="#{label}">#{region_links}</nav>#{regions})
    else
      cards = chapters.map { |chapter| saga_chapter_card(chapter, route) }.join
      %(<div class="astaria-saga-chapter-grid">#{cards}</div>)
    end
  end

  count_label = if english
    chapters.empty? ? "Chapters are being prepared for publication" : "Chapters available: #{chapters.length}"
  else
    chapters.empty? ? "Главы готовятся к публикации" : "Доступно глав: #{chapters.length}"
  end
  chronicle_label = english ? "A Journey’s Chronicle" : "Летопись путешествия"
  chapters_label = english ? "Chapters" : "Главы"
  <<~HTML
    <section class="astaria-saga-chapters" aria-labelledby="astaria-saga-chapters-title">
      <header>
        <div><p>#{chronicle_label}</p><h2 id="astaria-saga-chapters-title">#{chapters_label}</h2></div>
        <span>#{CGI.escapeHTML(count_label)}</span>
      </header>
      #{content}
    </section>
  HTML
end

def build_chapter_navigation(source, route, data, lookup)
  saga = saga_landing_record(source, data, lookup)
  return "" unless saga

  chapters = saga_chapter_records(saga[:source], lookup)
  current_index = chapters.index { |chapter| File.expand_path(chapter[:source]) == File.expand_path(source) }
  return "" unless current_index

  previous = current_index.positive? ? chapters[current_index - 1] : nil
  following = current_index < chapters.length - 1 ? chapters[current_index + 1] : nil
  english = BUILD_LOCALE == "en-GB"
  previous_label = english ? "← Previous chapter" : "← Предыдущая глава"
  following_label = english ? "Next chapter →" : "Следующая глава →"
  saga_label = english ? "Return to the saga" : "Вернуться к саге"
  navigation_label = english ? "Chapter navigation" : "Навигация по главам"
  previous_link = if previous
    %(<a class="astaria-chapter-nav-previous" href="#{CGI.escapeHTML(relative_href(route, previous[:route]))}"><small>#{previous_label}</small><strong>#{CGI.escapeHTML(chapter_short_title(previous[:data]))}</strong></a>)
  else
    %(<span aria-hidden="true"></span>)
  end
  following_link = if following
    %(<a class="astaria-chapter-nav-next" href="#{CGI.escapeHTML(relative_href(route, following[:route]))}"><small>#{following_label}</small><strong>#{CGI.escapeHTML(chapter_short_title(following[:data]))}</strong></a>)
  else
    %(<span aria-hidden="true"></span>)
  end

  saga_link = %(<a class="astaria-chapter-nav-saga" href="#{CGI.escapeHTML(relative_href(route, saga[:route]))}"><small>#{saga_label}</small><strong>#{CGI.escapeHTML(saga[:data]["title"].to_s)}</strong></a>)
  [
    %(<nav class="astaria-chapter-navigation" aria-label="#{navigation_label}">),
    previous_link,
    saga_link,
    following_link,
    "</nav>"
  ].join("\n")
end

def english_metadata_value(value, lookup, preserve_cyrillic: false)
  case value
  when Array
    value.map { |item| english_metadata_value(item, lookup, preserve_cyrillic: preserve_cyrillic) }.compact
  when Hash
    value.each_with_object({}) do |(key, item), result|
      translated = english_metadata_value(item, lookup, preserve_cyrillic: key.to_s == "native_name")
      result[key] = translated unless translated.nil? || translated.respond_to?(:empty?) && translated.empty?
    end
  when String
    unresolved = false
    translated = value.gsub(/\[\[([^|\]]+)(?:\|([^\]]+))?\]\]/) do
      target = Regexp.last_match(1).strip
      label = english_reference_label(target, Regexp.last_match(2), lookup)
      if label.to_s.empty?
        unresolved = true
        ""
      else
        "[[#{label}]]"
      end
    end
    return nil if unresolved

    translated = EN_OUTPUT_REPLACEMENTS
      .sort_by { |source, _translation| -source.length }
      .reduce(translated) { |result, (source, replacement)| result.gsub(source, replacement) }
    translated = english_measurement_value(translated)
    return nil if !preserve_cyrillic && translated.match?(/[А-Яа-яЁё]/)

    translated
  else
    value
  end
end

def generated_frontmatter(data, body, lookup)
  public_data = data.reject do |key, _value|
    %w[ready quartz canonical_title legacy_public_route].include?(key) || key.to_s.start_with?("secret_")
  end
  aliases = Array(public_data["aliases"])
  aliases << public_data["title"] if public_data["title"]
  aliases << data["legacy_public_route"] if data["legacy_public_route"]
  public_data["aliases"] = aliases.compact.map(&:to_s).uniq
  public_data["description"] = description_from_body(body, data)
  public_data = english_metadata_value(public_data, lookup) if BUILD_LOCALE == "en-GB"

  yaml = YAML.dump(public_data).sub(/\A---\s*\n/, "")
  "---\n#{yaml}---\n"
end

def write_public_article(source, route, data, body, lookup)
  destination = target_path(route)
  FileUtils.mkdir_p(File.dirname(destination))
  lede = ""
  journey = ""
  chapters = ""
  chapter_navigation = ""
  source_category_name = source_category(source)
  if data["category"].to_s.empty? && CATEGORY_ROUTES.key?(source_category_name)
    data = data.merge("category" => source_category_name)
  end

  if data["type"] == "map"
    clean_body = build_map_explorer(data, body, route, lookup)
    cover = ""
    title = ""
    sidebar = ""
  elsif data["type"] == "timeline"
    clean_body = build_timeline_page(data, route, lookup)
    cover = ""
    title = ""
    sidebar = ""
  elsif imitei_portraits_ready?(data)
    clean_body = cleanup_public_body(body, data)
    clean_body = render_asset_embeds(clean_body)
    clean_body = render_public_wikilinks(clean_body, route, lookup)
    cover = ""
    title = build_imitei_hero(route, data, body, lookup)
    sidebar = build_sidebar(data, route, lookup)
  else
    clean_body = cleanup_public_body(body, data)
    clean_body = render_asset_embeds(clean_body)
    clean_body = render_public_wikilinks(clean_body, route, lookup)
    cover = build_cover(data)
    has_visual = !cover.empty? || !sidebar_image(data).nil? || !crest_image(data).nil?
    title = has_visual ? build_title(route, data) : build_coverless_title(source, route, data, lookup)
    lede = build_featured_lede(data)
    sidebar = build_sidebar(data, route, lookup)
    journey = build_astaria_journey(route, data)
    chapters = build_saga_chapters(source, route, data, lookup)
    chapter_navigation = build_chapter_navigation(source, route, data, lookup)
  end
  footer = build_article_footer(route, data)
  sections = [cover, title, lede, sidebar, clean_body, chapter_navigation, chapters, journey, footer].map(&:strip).reject(&:empty?)
  text = "#{generated_frontmatter(data, body, lookup)}\n#{sections.join("\n\n")}\n"
  unless data["type"] == "map"
    ASSET_REWRITES.each { |old_path, new_path| text = text.gsub(old_path, new_path) }
  end
  write_output(destination, text)

  {
    source: source,
    path: destination,
    route: route,
    title: data["title"].to_s,
    category: source_category(source),
    description: description_from_body(body, data),
    image_path: primary_article_image(data, lookup),
    cover_path: cover_image(data),
    sidebar_path: sidebar_image(data),
    crest_path: crest_image(data),
    data: data
  }
end

def asset_paths_from_markdown(path)
  text = File.read(path)
  paths = []

  text.scan(/!?\[\[([^\]]*Assets\/(?:Images|Maps)\/[^\]|#]+)(?:[|#][^\]]*)?\]\]/) do |match|
    paths << match.first.strip
  end
  text.scan(/\]\((Assets\/(?:Images|Maps)\/[^)]+)\)/) do |match|
    paths << match.first.strip
  end

  paths.uniq
end

def copy_asset(relative)
  source = File.join(ROOT, relative)
  return unless File.file?(source)

  destination = File.join(DEST, relative)
  FileUtils.mkdir_p(File.dirname(destination))
  FileUtils.cp(source, destination)
end

def reference_names(value)
  Array(value).flat_map do |item|
    matches = item.to_s.scan(/\[\[([^|\]]+)(?:\|[^\]]+)?\]\]/).flatten
    matches.empty? ? [display_value(item)] : matches
  end.reject(&:empty?)
end

def entry_country(entry)
  data = entry[:data]
  if entry[:category] == "Места"
    # A related people does not make a continent, island or wilderness part
    # of that people's present-day realm. Place cards therefore show a realm
    # only when the canonical relationship names the realm itself.
    names = [data["country"], data["related"]].flat_map { |value| reference_names(value) }
    return names.find { |name| COUNTRY_ORDER.include?(name) }
  end

  direct_values = [data["country"], data["origin"], data["organizations"], data["ethnicity"], data["related_ethnicities"], data["related"]]
  names = direct_values.flat_map { |value| reference_names(value) }
  names.each do |name|
    return name if COUNTRY_ORDER.include?(name)
    mapped = COUNTRY_BY_PEOPLE[name]
    return mapped if mapped
  end
  nil
end

def creature_character?(entry)
  return false unless entry[:category] == "Персонажи"

  data = entry[:data]
  return true if display_value(data["character_group"]) == "Существа"

  reference_names(data["species"]).any?
end

def character_group(entry)
  return "Существа" if creature_character?(entry)

  entry_country(entry) || "Другие земли"
end

def character_group_sort_key(group)
  return COUNTRY_ORDER.index(group) if COUNTRY_ORDER.include?(group)
  return COUNTRY_ORDER.length if group == "Существа"

  COUNTRY_ORDER.length + 1
end

def character_name_sort_key(entry, group)
  title = entry[:title].to_s.strip
  words = title.split(/\s+/)
  words.pop while words.length > 1 && words.last.match?(/\A[IVXLCDM]+\z/i)

  family_name = if FAMILY_NAME_FIRST_COUNTRIES.include?(group)
    words.first
  elsif words.length > 1
    words.last
  else
    title
  end

  [family_name.to_s.downcase.tr("ё", "е"), title.downcase.tr("ё", "е")]
end

def sort_character_group_entries(entries, group, country_entry)
  ruler = reference_names(country_entry&.dig(:data, "ruler")).first
  ruler_identity = normalize_reference(ruler)

  entries.sort_by do |entry|
    canonical_title = entry[:data]["canonical_title"].to_s.strip
    entry_identity = canonical_title.empty? ? entry[:title] : canonical_title
    ruler_rank = !ruler_identity.empty? && normalize_reference(entry_identity) == ruler_identity ? 0 : 1
    [ruler_rank, *character_name_sort_key(entry, group)]
  end
end

def entry_sort_key(entry)
  return [-1, entry[:title].downcase] if entry[:data]["featured_entry"]
  return [COUNTRY_ORDER.length, entry[:title].downcase] if creature_character?(entry)

  title_order = CATEGORY_TITLE_ORDER[entry[:category]]
  title_index = title_order&.index(entry[:title])
  return [title_index, entry[:title].downcase] unless title_index.nil?

  country = if entry[:category] == "Страны"
    entry[:title]
  else
    entry_country(entry)
  end
  country_index = COUNTRY_ORDER.index(country) || COUNTRY_ORDER.length
  [country_index, entry[:title].downcase]
end

def category_card(entry, route)
  href = if entry[:route].start_with?("#{route}/")
    entry[:route].delete_prefix("#{route}/")
  elsif entry[:route] == "index"
    "../"
  else
    "../#{entry[:route]}"
  end

  variant = if entry[:category] == "Страны"
    "country"
  elsif entry[:category] == "Места"
    "place"
  elsif %w[Боги Имитеи Персонажи].include?(entry[:category]) || entry[:sidebar_path]
    "portrait"
  else
    "cover"
  end

  image = if entry[:image_path]
    crest = if entry[:crest_path]
      %(<img class="astaria-category-card-crest" src="#{CGI.escapeHTML(public_asset_url(entry[:crest_path]))}" alt="Герб государства #{CGI.escapeHTML(entry[:title])}" loading="lazy">)
    else
      ""
    end
    %(<div class="astaria-category-card-image"><img src="#{CGI.escapeHTML(public_asset_url(entry[:image_path]))}" alt="" loading="lazy">#{crest}</div>)
  else
    initial = entry[:title].each_char.find { |char| char.match?(/[[:alpha:]]/) } || "✦"
    %(<div class="astaria-category-card-image astaria-category-card-placeholder" aria-hidden="true">#{CGI.escapeHTML(initial)}</div>)
  end

  country = entry_country(entry)
  country_label = display_public_title(country)
  featured = entry[:data]["featured_entry"]
  eyebrow = if featured
    %(<small>Отправная точка</small>)
  elsif entry[:category] == "Страны"
    subtitle = entry[:data]["card_subtitle"].to_s.strip
    subtitle = Array(entry[:data]["aliases"]).find { |value| value.to_s.match?(/[А-Яа-яЁё]/) }.to_s if subtitle.empty?
    subtitle = "Государство Астарии" if subtitle.empty?
    %(<small>#{CGI.escapeHTML(subtitle)}</small>)
  elsif creature_character?(entry)
    species = reference_names(entry[:data]["species"]).first || "Существо"
    %(<small>#{CGI.escapeHTML(display_public_title(species))}</small>)
  elsif entry[:category] == "Места" && !entry[:data]["card_subtitle"].to_s.strip.empty?
    %(<small>#{CGI.escapeHTML(entry[:data]["card_subtitle"].to_s.strip)}</small>)
  elsif country
    %(<small>#{CGI.escapeHTML(country_label)}</small>)
  else
    ""
  end
  featured_class = featured ? " astaria-category-card-featured" : ""
  action = featured ? "Начать путешествие" : "Открыть статью"
  search_value = [
    entry[:title],
    entry[:description],
    entry[:category],
    entry[:data]["type"],
    country_label,
    display_value(entry[:data]["aliases"])
  ].compact.join(" ").downcase.tr("ё", "е").gsub(/\s+/, " ").strip
  meta_rank = entry_sort_key(entry).first
  markdown_safe_html(<<~HTML)
    <a class="astaria-category-card astaria-category-card-#{variant}#{featured_class}" href="#{CGI.escapeHTML(href)}" data-search="#{CGI.escapeHTML(search_value)}" data-meta-rank="#{meta_rank}">
      #{image}
      <div class="astaria-category-card-copy">
        #{eyebrow}
        <h3>#{CGI.escapeHTML(entry[:title])}</h3>
        <p>#{CGI.escapeHTML(entry[:description])}</p>
        <span>#{action} <b aria-hidden="true">→</b></span>
      </div>
    </a>
  HTML
end

def write_category_indexes(entries)
  grouped = entries.group_by { |entry| entry[:category] }
  CATEGORY_ROUTES.each do |category, route|
    category_entries = grouped.fetch(category, []).reject do |entry|
      %w[chapter session].include?(entry[:data]["type"].to_s)
    end
    route = CATEGORY_ROUTES.fetch(category)
    sorted_entries = category_entries.sort_by { |entry| entry_sort_key(entry) }
    cards = sorted_entries.map { |entry| category_card(entry, route) }
    displayed_card_count = cards.length
    description = CATEGORY_DESCRIPTIONS.fetch(category, "Статьи энциклопедии Астарии.")
    listing = if cards.empty?
      <<~HTML
        <div class="astaria-category-empty">
          <span aria-hidden="true">✦</span>
          <h2>Раздел ещё пополняется</h2>
          <p>Летописцы готовят первые материалы. Пока можно продолжить путь по карте или вернуться к оглавлению.</p>
          <div><a href="../map">Открыть карту</a><a href="../">На главную</a></div>
        </div>
      HTML
    elsif category == "Персонажи"
      country_entries = entries.select { |entry| entry[:category] == "Страны" }.each_with_object({}) do |entry, index|
        index[entry[:title]] = entry
        canonical_title = entry[:data]["canonical_title"].to_s.strip
        index[canonical_title] = entry unless canonical_title.empty?
      end
      published_entries = entries.each_with_object({}) do |entry, index|
        index[normalize_reference(entry[:title])] = entry
        canonical_title = entry[:data]["canonical_title"].to_s.strip
        index[normalize_reference(canonical_title)] = entry unless canonical_title.empty?
      end
      displayed_card_count = 0
      groups = sorted_entries.group_by { |entry| character_group(entry) }
        .sort_by { |group, _group_entries| character_group_sort_key(group) }
        .map do |group, group_entries|
        country_entry = country_entries[group]
        ruler_title = reference_names(country_entry&.dig(:data, "ruler")).first
        ruler_entry = published_entries[normalize_reference(ruler_title)]
        ruler_is_external_figure = ruler_entry &&
          !group_entries.include?(ruler_entry) &&
          %w[Боги Персонажи].include?(ruler_entry[:category])
        visible_group_entries = ruler_is_external_figure ? group_entries + [ruler_entry] : group_entries
        ordered_group_entries = sort_character_group_entries(visible_group_entries, group, country_entry)
        displayed_card_count += ordered_group_entries.length
        group_cards = ordered_group_entries.map { |entry| category_card(entry, route) }.join("\n")
        group_label = display_public_title(group)
        group_heading = if country_entry
          href = "../#{country_entry[:route]}"
          %(<a href="#{CGI.escapeHTML(href)}">#{CGI.escapeHTML(group_label)} <span aria-hidden="true">↗</span></a>)
        else
          CGI.escapeHTML(group_label)
        end
        <<~HTML
          <section class="astaria-category-group">
            <header><h2>#{group_heading}</h2></header>
            <div class="astaria-category-grid">#{group_cards}</div>
          </section>
        HTML
      end
      %(<div class="astaria-category-groups">#{groups.join("\n")}</div>)
    else
      %(<div class="astaria-category-grid">#{cards.join("\n")}</div>)
    end
    category_title = display_category(category)
    controls = if cards.empty?
      ""
    else
      <<~HTML
        <div class="astaria-category-tools" role="search" aria-label="Поиск по разделу #{CGI.escapeHTML(category_title)}">
          <label class="astaria-category-search-label">
            <svg aria-hidden="true" viewBox="0 0 24 24"><circle cx="11" cy="11" r="7"></circle><path d="m20 20-4-4"></path></svg>
            <span class="sr-only">Найти статью в разделе #{CGI.escapeHTML(category_title)}</span>
            <input class="astaria-category-search" type="search" placeholder="Найти статью в разделе…" autocomplete="off">
          </label>
          <p class="astaria-category-count" aria-live="polite">Показано: #{displayed_card_count} из #{displayed_card_count}</p>
          <button class="astaria-category-clear" type="button" hidden>Сбросить</button>
        </div>
        <div class="astaria-category-no-results" hidden>
          <strong>Ничего не найдено</strong>
          <span>Попробуйте изменить запрос или открыть другой раздел Энциклопедии.</span>
        </div>
      HTML
    end
    body = <<~MARKDOWN
      ---
      title: #{JSON.generate(category_title)}
      lang: ru
      description: #{JSON.generate(description)}
      aliases:
        - #{JSON.generate(category)}
      ---

      <section class="astaria-category-page" aria-labelledby="astaria-category-title">
        <nav class="astaria-article-trail"><a href="../">Астария</a><span aria-hidden="true">/</span><span>Энциклопедия</span></nav>
        <header class="astaria-category-header">
          <h1 id="astaria-category-title">#{category_title}</h1>
          <div>#{description}</div>
        </header>
        #{controls}
        #{listing}
      </section>
    MARKDOWN

    destination = File.join(DEST, route, "index.md")
    FileUtils.mkdir_p(File.dirname(destination))
    write_output(destination, body)
  end
end

DISCOVERY_DOORS = [
  ["Страны", "Государство", "wide"],
  ["Боги", "Божество", "portrait"],
  ["Персонажи", "Личность", "portrait"],
  ["Места", "Место", "wide"],
  ["Бестиарий", "Бестиарий", "wide"]
].freeze

def home_discovery_item(entries, category, label, variant)
  candidates = entries.select do |entry|
    entry[:category] == category && entry[:image_path] && !entry[:data]["featured_entry"]
  end.sort_by { |entry| entry_sort_key(entry) }.map do |entry|
    {
      href: entry[:route],
      image: public_asset_url(entry[:image_path]),
      title: entry[:title],
      label: label,
      variant: variant
    }
  end
  return "" if candidates.empty?

  fallback = candidates.first
  payload = CGI.escapeHTML(JSON.generate(candidates))
  <<~HTML
    <div class="astaria-discovery-item" data-discovery-candidates="#{payload}">
      <a class="astaria-discovery-card astaria-discovery-#{variant}" href="#{CGI.escapeHTML(fallback[:href])}">
        <img src="#{CGI.escapeHTML(fallback[:image])}" alt="#{CGI.escapeHTML(fallback[:title])}" loading="lazy">
        <span><small>#{CGI.escapeHTML(label)}</small><b>#{CGI.escapeHTML(fallback[:title])}</b></span>
      </a>
    </div>
  HTML
end

def home_discovery_grid(entries)
  DISCOVERY_DOORS.map do |category, label, variant|
    home_discovery_item(entries, category, label, variant)
  end.reject(&:empty?).join("\n")
end

def write_index(entries)
  discovery_grid = home_discovery_grid(entries)
  body = <<~MARKDOWN
    ---
    title: Астария
    lang: ru
    description: Мифологическая энциклопедия Астарии — мира богов, героев и древних цивилизаций.
    aliases:
      - Астария
    ---

    <div class="astaria-home">
      <section class="astaria-home-hero" aria-label="Добро пожаловать в Астарию">
        <img src="assets/images/avatar-on-north.jpg" alt="Воин с огненным клинком встречает чудовищ Астарии" fetchpriority="high">
        <div class="astaria-home-hero-shade"></div>
      </section>

      <section class="astaria-home-intro" aria-labelledby="astaria-home-title">
        <div class="astaria-home-ornament" aria-hidden="true"><span></span></div>
        <p class="astaria-home-era"><span>106</span> год Новой Эры</p>
        <h1 id="astaria-home-title">Астария</h1>
        <p class="astaria-home-lede">Мир древних цивилизаций и опасных богов, где судьбы народов меняют герои, сумевшие превзойти человеческие пределы.</p>
        <div class="astaria-home-actions">
          <a class="astaria-home-button astaria-home-button-primary" href="places/astaria">Начать путешествие <span aria-hidden="true">→</span></a>
          <a class="astaria-home-button astaria-home-button-quiet" href="map">Открыть карту</a>
        </div>
      </section>

      <section class="astaria-home-portals" aria-label="Основные разделы">
        <article class="astaria-portal astaria-portal-visual astaria-portal-encyclopedia">
          <div class="astaria-portal-image">
            <img src="assets/images/silvian_lake.jpg" alt="Водопады и озеро Астарии" loading="lazy">
          </div>
          <div class="astaria-portal-copy">
            <p class="astaria-portal-kicker">Оглавление мира</p>
            <h2>Энциклопедия</h2>
            <p>Народы, страны, личности и существа — всё, из чего соткан живой мир.</p>
            <div class="astaria-topic-links" aria-label="Популярные разделы">
              <a href="countries/">Страны</a>
              <a href="characters/">Персонажи</a>
              <a href="gods/">Боги</a>
            </div>
            <details class="astaria-home-directory">
              <summary>Все разделы <span aria-hidden="true">⌄</span></summary>
              <nav aria-label="Разделы энциклопедии">
                <a href="places/">Места</a>
                <a href="countries/">Страны</a>
                <a href="peoples/">Народы</a>
                <a href="characters/">Персонажи</a>
                <a href="gods/">Боги</a>
                <a href="bestiary/">Бестиарий</a>
                <a href="imitei/">Имитеи</a>
                <a href="organizations/">Организации</a>
                <a href="lore/">Знания</a>
                <a href="items/">Предметы</a>
                <a href="events/">События</a>
                <a href="literature/">Литература</a>
                <a href="flora/">Флора</a>
                <a href="cuisine/">Кухня</a>
              </nav>
            </details>
          </div>
        </article>
        <article class="astaria-portal astaria-portal-visual astaria-portal-map">
          <a class="astaria-portal-hit" href="map" aria-label="Исследовать интерактивную карту Астарии">
            <div class="astaria-portal-image">
              <img src="assets/maps/web/states-web.jpg" alt="Политическая карта Астарии" loading="lazy">
              <span class="astaria-map-pin astaria-map-pin-one" aria-hidden="true"></span>
              <span class="astaria-map-pin astaria-map-pin-two" aria-hidden="true"></span>
              <span class="astaria-map-pin astaria-map-pin-three" aria-hidden="true"></span>
            </div>
            <div class="astaria-portal-copy">
              <p class="astaria-portal-kicker">132 места на карте</p>
              <h2>Исследовать мир</h2>
              <p>Океаны, государства и забытые уголки на одной интерактивной карте.</p>
              <span class="astaria-portal-link">Открыть карту <b aria-hidden="true">→</b></span>
            </div>
          </a>
        </article>
        <article class="astaria-portal astaria-portal-visual astaria-portal-timeline">
          <a class="astaria-portal-hit" href="timeline/" aria-label="Открыть хронологию Астарии">
            <div class="astaria-portal-image">
              <img src="assets/images/acheus_invasion.jpg" alt="Древний город во время великого вторжения" loading="lazy">
            </div>
            <div class="astaria-portal-copy">
              <p class="astaria-portal-kicker">Сквозь эпохи</p>
              <h2>Хронология</h2>
              <ol class="astaria-mini-timeline">
                <li><span>5025 ХЭ</span> Первые свидетельства об археях</li>
                <li><span>426 ХЭ</span> Основание Талассии</li>
                <li><span>106 НЭ</span> Нынешняя эпоха</li>
              </ol>
              <span class="astaria-portal-link">Увидеть всю историю <b aria-hidden="true">→</b></span>
            </div>
          </a>
        </article>
      </section>

      <section class="astaria-home-discover" aria-labelledby="astaria-discover-title">
        <div class="astaria-home-section-heading">
          <div>
            <p class="astaria-portal-kicker">Пять дверей в Астарию</p>
            <h2 id="astaria-discover-title">Куда отправиться дальше?</h2>
          </div>
          <div class="astaria-discovery-heading-actions">
            <p>Каждый раз Астария открывает другой путь — через страну, героя, божество, место или существо.</p>
            <button class="astaria-discovery-shuffle" type="button"><span aria-hidden="true">↻</span> Другие пути</button>
          </div>
        </div>
        <div class="astaria-discovery-grid">#{discovery_grid}</div>
        <p class="astaria-discovery-status sr-only" aria-live="polite"></p>
      </section>

      <footer class="astaria-home-footer">
        <span aria-hidden="true">✦</span>
        <p>Всякая легенда начинается с первого шага.</p>
        <span aria-hidden="true">✦</span>
      </footer>
    </div>
  MARKDOWN

  write_output(File.join(DEST, "index.md"), body)
end

FileUtils.rm_rf(DEST)
FileUtils.mkdir_p(DEST)

entries = []
routes = {}
records = []

PUBLIC_ROOTS.each do |root|
  Dir.glob(File.join(ROOT, root, "**", "*.md")).sort.each do |source|
    next unless publishable_markdown?(source)
    if BUILD_LOCALE == "en-GB" && ONLY_TRANSLATED
      next unless AstariaTranslations.translation_for(source)
    end

    data, body = frontmatter_for(source)
    legacy_route = legacy_public_route(source, data)
    data, body = localized_source(source, data, body)
    route = public_route(source, data)
    data["legacy_public_route"] = legacy_route if legacy_route != route
    if routes.key?(route)
      raise "Duplicate public route #{route.inspect}: #{routes[route]} and #{source}"
    end

    routes[route] = source
    records << { source: source, route: route, data: data, body: body }
  end
end

enrich_inverse_relationships!(records, canonical_relationship_records)
reference_lookup = build_reference_lookup(records)
records.each do |record|
  entries << write_public_article(
    record[:source],
    record[:route],
    record[:data],
    record[:body],
    reference_lookup
  )
end

write_category_indexes(entries)
write_index(entries) unless entries.any? { |entry| entry[:route] == "index" }

asset_paths = entries.flat_map do |entry|
  asset_paths_from_markdown(entry[:source]) + asset_paths_from_markdown(entry[:path])
end
asset_paths.concat(timeline_events(reference_lookup).map { |event| event[:image] }.compact)
asset_paths.map! { |relative| ASSET_REWRITES.fetch(relative, relative) }
asset_paths.concat([
  "Assets/Images/Avatar on north.jpg",
  "Assets/Images/Acheus_Invasion.jpg",
  "Assets/Images/Silvian_Lake.jpg",
  "Assets/Images/bg.jpg",
  "Assets/Maps/Web/states-web.jpg",
  "Assets/Maps/states.png",
  "Assets/Maps/heightmap.png",
  "Assets/Maps/biomes.png"
])
AstariaTranslations.map_layers.each_key do |key|
  asset_paths << AstariaTranslations.map_layer_for(key)
end
asset_paths << AstariaTranslations.map_layer_for("states", variant: "web")
asset_paths.uniq.sort.each { |relative| copy_asset(relative) }

puts "Prepared #{entries.size} published notes in #{DEST}"
puts entries.sort_by { |entry| entry[:route] }.map { |entry| "  /#{entry[:route]} <- #{entry[:title]}" }
