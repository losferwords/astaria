# Obsidian-перенос WorldAnvil - изыскания

Дата заметки: 2026-06-10.

Цель: понять, как устроен локальный экспорт `World-Астария-2fa`, и наметить осторожный, проверяемый путь переноса лора Астарии в Obsidian без немедленной подписки.

## Короткий вывод

Экспорт WorldAnvil выглядит пригодным для автоматизированного переноса. Самое ценное лежит не в HTML, а в JSON: там есть UUID статей, заголовки, категории, типы шаблонов, основной текст, ссылки WorldAnvil, изображения, таймлайн и координаты маркеров карты.

Я бы не начинала с ручного копирования 858 статей. Верный первый шаг - сделать небольшой пробный Obsidian-vault из 5-10 связанных сущностей: страна, бог/персонаж, место, событие таймлайна, карта с несколькими маркерами. Если на этом мини-наборе будут хорошо работать ссылки, картинки, карточки, хронология и публикация, тогда можно писать конвертер для всего архива.

## Что уже есть в рабочей папке

- `.obsidian/` уже создан: текущая папка открывалась или готовилась как Obsidian vault.
- `Welcome.md` - стандартная приветственная заметка Obsidian.
- `World-Астария-2fa/` - экспорт мира из WorldAnvil.
- Текущая папка `/Users/maksimnasonov/Documents/Astaria` пока не является git-репозиторием: `git status` возвращает `fatal: not a git repository`.

## Структура экспорта WorldAnvil

На верхнем уровне `World-Астария-2fa`:

| Путь | Что найдено | Назначение |
| --- | ---: | --- |
| `World-Астария-2fa.json` | 1 JSON | Метаданные мира: название, locale, URL, счётчики, настройки отображения |
| `meta.json` | 1 JSON | Пустой JSON-массив/объект без полезных полей в текущем экспорте |
| `meta.html` | 1 HTML | Служебная HTML-страница |
| `descriptionParsed.html` | 1 HTML | HTML-описание мира |
| `displayCss.css` | 1 CSS | CSS WorldAnvil, потенциально полезен как визуальный референс |
| `articles/` | 858 JSON + 858 HTML | Основные статьи мира, каждая продублирована в структурном JSON и готовом HTML |
| `categories/` | 13 JSON | Категории WorldAnvil |
| `histories/` | 26 JSON | События хронологии |
| `timelines/` | 1 JSON | Таймлайн "История Астарии" |
| `maps/Map-Астария-79d/` | 1 map JSON, 132 marker JSON, 2 layer JSON, 2 marker group JSON | Интерактивная карта Астарии |
| `images/` | 402 JSON | Метаданные изображений, но не сами bitmap-файлы |
| `subscriber_groups/` | 6 JSON | Группы доступа WorldAnvil |
| `notebooks/` | 1 notebook JSON | Заметки/ноутбук WorldAnvil |

Метаданные мира из `World-Астария-2fa.json`:

- `title`: `Астария`
- `locale`: `ru`
- `countArticles`: `858`
- `countMaps`: `1`
- `countTimelines`: `1`
- `url`: `https://www.worldanvil.com/w/D090D181D182D0B0D180D0B8D18F-losfer`

## Типы статей

Тип статьи хорошо читается прямо из имени файла и из поля `templateType` внутри JSON.

| Тип | Количество |
| --- | ---: |
| `Settlement` | 408 |
| `Location` | 199 |
| `Person` | 115 |
| `Article` | 32 |
| `Species` | 20 |
| `Organization` | 20 |
| `Ethnicity` | 17 |
| `Profession` | 16 |
| `Item` | 10 |
| `Landmark` | 8 |
| `MilitaryConflict` | 4 |
| `Ritual` | 3 |
| `Document` | 3 |
| `Condition` | 2 |
| `Myth` | 1 |

Наблюдение: это не просто набор страниц. WorldAnvil хранит статьи по шаблонам, и для каждого шаблона есть свои дополнительные поля. Например, у `organization` есть `capital`, `leader`, `governmentSystem`, `territory`, `religion`; у `person` есть `portrait`, `gender`, `birthplace`, `titles`, `domains`, `family`, `motivation` и многое другое.

Для Obsidian это лучше переносить как:

- основной текст статьи - в Markdown-тело;
- устойчивые поля - в YAML properties;
- редкие и длинные поля - отдельными секциями внутри заметки;
- оригинальный UUID WorldAnvil - обязательно сохранять в property `wa_id`, чтобы не потерять связи.

## Состояния статей и приватность

Все 858 статей имеют `state: public` и `isWip: true`.

По `isDraft`:

- 306 статей: `isDraft: false`
- 552 статьи: `isDraft: true`

В самих статьях я не обнаружила непустых `subscribergroups`, но в мире и в папке `subscriber_groups/` группы доступа есть. Значит, при полном переносе стоит явно решить, что делать с секретами и черновиками:

- не публиковать всё автоматически;
- перенести `isDraft`, `isWip`, `state` в YAML;
- для игроко-доступного сайта использовать property вроде `publish: true`;
- для мастерских заметок использовать `publish: false`, `private: true`, `campaign: gm`.

## Ссылки внутри статей

В JSON-текстах WorldAnvil ссылки представлены в формате:

```text
@[Талассийцы](ethnicity:51fa8712-64d3-4c13-9cc4-b079122b318...)
@[Талассия](organization:292c0665-8603-4fb5-9390-564f323a2615)
```

Таких статей с WorldAnvil-ссылками в основном тексте найдено 351.

Для Obsidian нужно построить индекс:

```text
wa_id -> путь к Markdown-файлу
wa_id -> title
```

После этого ссылки можно конвертировать в wikilinks:

```text
[[Талассийцы]]
[[Талассия]]
```

Если появятся одинаковые названия, безопаснее использовать алиасы и путь:

```text
[[03 Лор/Страны/Талассия|Талассия]]
```

Obsidian официально поддерживает wikilinks `[[Page]]`, ссылки на заголовки и алиасы вида `[[Page|Custom name]]`, а также умеет обновлять внутренние ссылки при переименовании заметок.

## Изображения

В `images/` лежат только JSON-описания изображений. Например, карта мира:

- `id`: `5066626`
- `title`: `Астария  Base Map Image (Replaced: 2025-03-28 07:01:07 WA Time)`
- `filename`: `b6c4c019dfc81372c3a51a0e87470579.png`
- `url`: `https://www.worldanvil.com/uploads/maps/b6c4c019dfc81372c3a51a0e87470579.png`
- `width`: `7680`
- `height`: `4320`
- `size`: `16163520`

У статей изображения лежат в полях вроде:

- `cover`
- `portrait`
- `flag`
- `gallery`

В самих текстах иногда встречается WorldAnvil-разметка:

```text
[img:3917180|center|200|nolink]
```

Таких статей с `[img:...]` в проверенных текстовых полях найдено 11.

Вы сказали, что локальные картинки есть. Я бы сделала так:

1. Сложить bitmap-файлы в `Assets/Images/`.
2. Сохранить имена как можно ближе к WorldAnvil `filename`, чтобы проще матчить.
3. Построить индекс `image_id -> локальный файл`.
4. `cover`, `portrait`, `flag` переносить в YAML:

```yaml
cover: "[[Assets/Images/Talassia.jpg]]"
portrait: "[[Assets/Images/Mercate.jpg]]"
wa_cover_id: 1064779
```

5. В теле статьи использовать обычный Obsidian embed:

```markdown
![[Assets/Images/Talassia.jpg]]
```

## Карта

В экспорте есть одна карта:

- `title`: `Астария`
- `zoomOriginal`: `-2`
- `zoomMin`: `-3`
- `zoomMax`: `0`
- 132 маркера
- 2 слоя: `Климат`, `Рельеф`
- 2 группы маркеров: `География`, `Политика`

Пример маркера `Город Самаан`:

```yaml
title: Город Самаан
icon: fa-solid fa-location-dot
geoX: 2689
geoY: 1358
description: "[img:3917180|center|200|nolink]"
isDirectLink: false
```

Это очень хороший знак: WorldAnvil уже отдал координаты маркеров в пикселях или близкой к пикселям системе. Для карты 7680x4320 это можно перенести в Obsidian Leaflet как image map.

Подход для Obsidian:

```leaflet
id: astaria-world-map
image: [[Assets/Maps/astaria-world-map.png]]
height: 700px
minZoom: -3
maxZoom: 2
defaultZoom: -2
unit: pixels
marker:
  - default, 1358, 2689, [[Город Самаан]]
```

Координаты надо проверить на пилоте: у Leaflet порядок обычно `lat, long`, то есть для изображения может понадобиться `geoY, geoX`, а не `geoX, geoY`. Это легко проверить по 3-5 известным маркерам на карте.

Важно: плагин Obsidian Map View хорош для реальных географических координат и GIS, но для фэнтезийной карты-картинки с пиксельными координатами лучше выглядит Obsidian Leaflet. Его README прямо показывает `image: [[Image.jpg]]` и `marker: default, ... [[Note]]`, а также описывает marker links и image maps.

## Хронология

В `timelines/` есть один таймлайн:

- `title`: `История Астарии`
- `type`: `parallel`
- `description`: вводный текст о задокументированных исторических вехах

События лежат отдельно в `histories/`: 26 JSON-файлов.

Пример события `Основание Талассии`:

```yaml
title: Основание Талассии
year: "-426"
category: Founding
significance: 2
content: "Расселение хтонидов ... основание республики Талассия ..."
```

Есть события с диапазоном:

```yaml
title: Раскол Кадира
year: "-667"
endingYear: "-659"
category: Disbandment
```

Варианты для Obsidian:

1. Для простого старта: отдельные Markdown-файлы в `04 Хронология/События/` + Dataview-таблица, отсортированная по `year`.
2. Для красивого вида в Obsidian: плагин `Timelines`, который умеет fantasy years и отрицательные годы, но выглядит давно не обновлявшимся.
3. Для публикации на сайт: генерировать статический HTML/JS-таймлайн через Quartz-компонент или отдельную страницу на основе YAML событий.

Мой выбор для пилота: сначала Dataview-таблица и один красивый статический Markdown-таймлайн. Не привязываться к старому плагину, пока не станет ясно, что он действительно нужен.

## Предлагаемая структура Obsidian vault

Я бы отделила исходный экспорт от будущей вики:

```text
Astaria/
  00 README/
  01 Мир/
  02 Энциклопедия/
    Боги/
    Народы/
    Страны/
    Персонажи/
    Места/
    Предметы/
    Бестиарий/
  03 Кампании/
    Ветер Перемен/
      Игрокам/
      Мастерское/
      Сессии/
      NPC/
  04 Хронология/
    История Астарии.md
    События/
  05 Карты/
    Астария.md
  Assets/
    Images/
    Maps/
  _templates/
  _scripts/
  _source/
    WorldAnvil/
```

`_source/WorldAnvil/` можно использовать как неизменённый архив, но для git может быть лучше вынести тяжёлые исходники или большие картинки отдельно. Если репозиторий будет публичным, секреты и черновики нельзя класть туда без фильтрации.

## Формат Markdown-файла статьи

Пример для `Талассия`:

```markdown
---
title: Талассия
lang: ru
type: organization
category: Страны
tags:
  - state
wa_id: 292c0665-8603-4fb5-9390-564f323a2615
wa_url: https://www.worldanvil.com/w/.../a/...
wa_slug: D0A2D0B0D0BBD0B0D181D181D0B8D18F-article
publish: true
draft: false
wip: true
cover: "[[Assets/Images/Talassia.jpg]]"
flag: "[[Assets/Images/thalassia_crest.png]]"
---

# Талассия

![[Assets/Images/Talassia.jpg]]

Изначально Талассия являлась северо-западной республикой империи [[Хтониды|хтонидов]], названной в честь [[Полуостров Таллас|полуострова Таллас]]...
```

## Двуязычность

Я бы не делала две версии языка в одном файле. Это быстро станет тяжёлым для чтения и плохо дружит с git-диффами.

Лучше:

```text
02 Энциклопедия/
  Страны/
    Талассия.md
  Countries/
    Talassia.md
```

Или:

```text
content/
  ru/
    страны/талассия.md
  en/
    countries/talassia.md
```

В каждой статье хранить связи:

```yaml
lang: ru
translation_key: talassia
translation_of: null
translations:
  en: "[[Talassia]]"
```

Для LLM-перевода важны правила:

- переводить только тело и читательские заголовки;
- не менять `wa_id`, `translation_key`, ссылки и технические properties;
- имена собственные вести через глоссарий;
- для ссылок использовать уже существующий английский файл, если он есть;
- перевод сохранять отдельным коммитом, чтобы было легко ревьюить.

## Публикация без подписки Obsidian

На 2026-06-10 актуальная картина такая:

- Obsidian Publish - официальный платный хостинг заметок как wiki/knowledge base.
- Obsidian Sync - официальный платный sync между устройствами.
- Для теста подписка не обязательна: Obsidian хранит заметки локально как Markdown-файлы, а публиковать можно через статический сайт.

Наиболее подходящий бесплатный маршрут для Астарии:

1. Obsidian как редактор локального vault.
2. Git как история и переносимость.
3. Quartz как статический сайт из Markdown.
4. GitHub Pages, Cloudflare Pages, Netlify или Vercel как хостинг.

Quartz прямо ориентирован на публикацию Obsidian vault, поддерживает wikilinks, frontmatter, graph view, поиск, backlinks, callouts и часть Obsidian-flavored Markdown. Для Obsidian community plugins поддержка зависит от Quartz community plugins; Leaflet упомянут как поддерживаемый через community plugin.

## Git и переносимость

Так как текущая папка пока не git-репозиторий, я бы делала так:

1. Не коммитить сырой WorldAnvil-экспорт сразу вслепую.
2. Создать `.gitignore` для временных файлов Obsidian и возможных тяжёлых артефактов.
3. Решить, коммитим ли `_source/WorldAnvil`.
4. Если картинки большие, рассмотреть Git LFS или отдельное хранилище.
5. После пробного импорта сделать первый чистый коммит:

```text
Initialize Astaria Obsidian vault
```

6. Затем отдельные коммиты:

```text
Import pilot lore articles
Add pilot world map
Add Astaria timeline pilot
```

Плагин Obsidian Git может помочь делать commit/pull/push из интерфейса Obsidian, но на старте достаточно обычного git в терминале или IDE.

## Плагины Obsidian для теста

Минимальный набор:

- Dataview - таблицы и списки по YAML properties.
- Obsidian Leaflet - карта-картинка с маркерами.
- Obsidian Git - позже, когда появится репозиторий.
- Style Settings + тема - только если выбранная тема это использует.

Опционально:

- Timelines - проверить на 26 событиях, но осторожно: GitHub-релиз у популярного `Darakah/obsidian-timelines` старый.
- Canvas - для визуальных связей мифологии, пантеонов и политических конфликтов.
- Templater - если понадобится быстро создавать новые статьи по шаблонам.

## Что я бы сделала для пилота

Пилот должен ответить на вопрос: "Будет ли Obsidian достаточно приятен для Астарии?"

Я бы взяла такой набор:

1. `Organization-Талассия-665.json`
   - страна/организация;
   - есть `cover`, `flag`, связи с хтонидами, Гиласом и Падением Хтона.

2. `Person-Мерката-9e8.json`
   - богиня/персонаж;
   - есть `cover`, `portrait`, связи с Лунааром, Антрой, Таруном и Церунной.

3. `HistoricalEntry-Основание Талассии-260.json`
   - событие таймлайна;
   - хорошо проверяет отрицательные годы и ссылки на статьи.

4. `Map-Астария-79d.json` + 5-10 маркеров
   - например `Город Самаан`, `Талассия`, `Гилас`, `Кадир`, `Остров Хтон`;
   - проверка координат и кликабельности маркеров.

5. Одна обзорная страница:
   - `Астария.md`;
   - ссылки на карту, таймлайн, страны, богов.

Для пилота нужно автоматически:

- создать Markdown-файлы;
- перенести YAML properties;
- сконвертировать WorldAnvil-ссылки в Obsidian wikilinks;
- подставить локальные картинки или временно оставить WA URL;
- сделать Dataview-страницу "Страны";
- сделать страницу карты с Leaflet-блоком;
- сделать страницу хронологии.

## Главные технические задачи конвертера

1. Прочитать все `articles/*.json`.
2. Построить индекс:

```text
wa_id -> title
wa_id -> templateType
wa_id -> target markdown path
```

3. Нормализовать имена файлов:

- оставить русские названия допустимо;
- убрать символы, конфликтующие с Obsidian links: `# | ^ : %% [[ ]]`;
- при дублях добавлять тип или короткий UUID.

4. Конвертировать WorldAnvil-ссылки:

```text
@[текст](type:uuid) -> [[Target|текст]]
```

5. Конвертировать базовую разметку:

- `\r\n` -> обычные переносы;
- `[img:id|...]` -> `![[локальный-файл]]`;
- HTML из `.html` использовать только как резерв или для сверки визуальной структуры.

6. Сохранить служебные поля:

```yaml
wa_id:
wa_url:
wa_slug:
wa_template:
wa_category:
wa_state:
wa_draft:
wa_wip:
```

7. Отдельно обработать:

- `histories/*.json` -> события;
- `maps/**/*.json` -> карта и маркеры;
- `images/*.json` -> индекс изображений.

## Риски

- Изображения в экспорте сейчас только как JSON-метаданные. Нужны локальные bitmap-файлы или отдельный скачанный image backup.
- 552 статьи помечены как draft. Нельзя автоматически публиковать всё.
- WorldAnvil HTML может содержать оформление, которое не стоит переносить буквально. Лучше переносить семантику.
- Некоторые статьи могут иметь одинаковые названия или слишком похожие сущности.
- Карта потребует проверки порядка координат и масштаба.
- Community-плагины Obsidian прекрасны, но при публикации через Quartz не вся интерактивность переносится автоматически.

## Рекомендуемая последовательность

1. Сохранить `World-Астария-2fa` как read-only исходник.
2. Создать папку будущей вики и базовую структуру.
3. Подготовить локальные картинки для 5-10 пилотных статей.
4. Написать маленький конвертер только для выбранных файлов.
5. Открыть результат в Obsidian и проверить:

- читаемость статьи;
- кликабельные ссылки;
- картинки;
- Dataview-таблицы;
- Leaflet-карту;
- таймлайн.

6. Поднять локальный Quartz preview и проверить сайт.
7. Только после этого масштабировать конвертер на все 858 статей.

## Источники по инструментам

- Obsidian Publish: https://obsidian.md/help/publish
- Obsidian Sync: https://obsidian.md/help/sync
- Obsidian internal links: https://obsidian.md/help/links
- Obsidian properties/YAML: https://obsidian.md/help/properties
- Dataview plugin: https://community.obsidian.md/plugins/dataview
- Obsidian Git plugin: https://community.obsidian.md/plugins/obsidian-git
- Map View plugin: https://community.obsidian.md/plugins/obsidian-map-view
- Obsidian Leaflet: https://github.com/javalent/obsidian-leaflet
- Obsidian Timelines: https://github.com/Darakah/obsidian-timelines
- Quartz: https://quartz.jzhao.xyz/
- Quartz hosting: https://quartz.jzhao.xyz/hosting
- Quartz Obsidian compatibility: https://quartz.jzhao.xyz/features/obsidian-compatibility
- Quartz internationalization: https://quartz.jzhao.xyz/features/i18n

## Моё предложение

Я бы следующим шагом не трогала все 858 статей. Я бы сделала маленькую "витрину Астарии" в Obsidian: Талассия, Мерката, Основание Талассии, страница карты и обзорная главная страница. Это даст честное ощущение инструмента: не по абстрактному туториалу, а по живой ткани Вашего мира.
