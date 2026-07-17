# Astaria Meta And FATE Reference

This file contains service context for Codex/Violet. It is not player-facing lore and should not be copied into public articles unless the user explicitly asks.

Source: `meta.json` provided by the user on June 10, 2026. The user may delete that JSON later; this Markdown file is the retained working reference.

## World Meta

- Current in-world year: derive from the real calendar year as `real year - 1920`. In 2026, Astaria is in `106 НЭ`; in 2027, it becomes `107 НЭ`, and so on.
- Main currency: silver.
- The campaign currently uses `FATE Core System`.

## Calendar And Eras

Astaria uses two main eras:

- `Хтоническая Эра`, abbreviated `ХЭ` or `Х.Э.`. This is analogous to BCE. Years count backward from the zero year of the New Era. For example, 1000 ХЭ happened 1000 years before the beginning of the New Era.
- `Новая Эра`, abbreviated `НЭ` or `Н.Э.`. This is analogous to CE. It starts at year 0 and continues to the current date.

The transition from the Chthonic Era to the New Era was the catastrophic event known as `Падение Хтона`.

## Encyclopedia Character Requirements

When creating a new character article in `Энциклопедия/Персонажи/`, fill these fields by default. If the user has not provided exact values, make conservative assumptions and keep the article `ready: false`, unless the missing value is too important to invent.

- `ethnicity`: the character's people, for example `[[Раджати]]`, `[[Авгарцы]]`, `[[Джу]]`.
- `eyes`: eye colour.
- `height`: in compact format such as `1.8м`.
- `weight`: in compact format such as `54кг`.
- `skin`: skin tone, for example `светлая`, `смуглая`, `загорелая`.
- `hair`: hair type and colour, for example `длинные тёмные`, `короткие светлые`.
- `birth_year`: in era format such as `76 НЭ` or `-115 ХЭ`.
- `age`: calculated from the current Astaria year.
- `age_as_of`: the Astaria year used for the age calculation, for example `106 НЭ`.
- `birth_place`: a location appropriate for the character's ethnicity and biography.
- `current_location`: the character's current known location.
- `imitei`: the Imitei role if the character is an Imitei; otherwise use `false`.
- A readable description in the same style as existing Encyclopedia character profiles.
- A private `%% FATE / GM ... %%` block with aspects, skills, and stunts appropriate to the character's power level.

For age calculation, treat `НЭ` years as ordinary positive years. For `ХЭ`, calculate age across the era boundary carefully because years count backward toward zero.

## Cultural Reference Map

Use these analogues as creative reference points for tone, clothing, architecture, names, social values, and historical flavour. They are not one-to-one real-world copies.

| Country or culture | Reference and values |
| --- | --- |
| Гилас | Ancient Sparta analogue; values courage and martial valour. |
| Громовые Кланы | Ancient Scotland analogue; worship a thunder god and command weather. |
| Иомар | Irish Celtic analogue; worship a goddess of hunting and value nature and forest creatures. |
| Катахтонос | Atlantis analogue; descendants of a once-mighty nation destroyed by its own hunger for knowledge. |
| Империя Ланг-Ан | Ancient China analogue; worship a real fire dragon and value harmony and spiritual balance. |
| Лунаар | Medieval England analogue; worship a goddess of Night and dreams; excellent archers. |
| Амон-Астат | Ancient Egypt analogue; worship a Sun God and bring light and healing. |
| Кадир | Ancient Persia analogue; especially revere time and can command it like sand in an hourglass. |
| Талассия | Ancient Greece analogue; a seafaring country worshipping a goddess of luck and adventure. |
| Хамоа | Polynesian peoples analogue; worship a water goddess and are especially skilled at healing and peaceful life. |
| Дикоземье | Mongol tribes analogue; craftspeople and strong warriors, worship a smith-god and value masculinity. |
| Вактар-Йорден | Ancient Scandinavian/Viking analogue; worship the queen of dragons and use ice/cold magic. |
| Сурадж Ка Гхар | Ancient India analogue; followers of a goddess of blood and destruction who periodically becomes a goddess of dance and creation. |
| Вакумара | African tribes analogue; worship a God of Death and perform mysterious rituals over the body of their deity. |
| Амато | Ancient Japan analogue; worship a wind goddess who carries souls from the living realm to the dead realm. |
| Обитель | Ancient south-western Slavic analogue; worship a goddess of beauty, love, and earth. |

## Correct Demonyms And Forms Of Address

Use the following forms when writing lore, dialogue, summaries, and FATE aspects. Avoid the forbidden forms unless the user explicitly asks for an in-world mistake, insult, or foreigner error.

| Country or culture | Avoid | Prefer |
| --- | --- | --- |
| Гилас | гиласец | житель Гиласа; эллиец; эллийка |
| Громовые Кланы | гойдаирец | житель Громовых Кланов; гойдаир, not declined |
| Иомар | иомарец | житель Иомара; надаир, not declined |
| Катахтонос | катахтоносец | житель Катахтоноса; хтонид; хтонидка |
| Империя Ланг-Ан | ланг-анец | житель Империи Ланг-Ан; джу, not declined |
| Лунаар | - | лунаарец; житель Лунаара; лудаир, not declined |
| Амон-Астат | амон-астатец | житель Амон-Астата; хефат, not declined |
| Кадир | кадирец | житель Кадира; кадиец; кадийка |
| Талассия | - | талассиец; талассийка |
| Хамоа | хамоанец | житель Хамоа; манаи, not declined |
| Дикоземье | - | дикоземец; житель Дикоземья; авгарец; авгарка |
| Вактар-Йорден | вактар-йорденец | житель Вактар-Йордена; вактар; вактарка |
| Сурадж Ка Гхар | сурадж ка гхарец | житель Сурадж Ка Гхара; раджати, not declined |
| Вакумара | вакумарец | житель Вакумара; ваку, not declined |
| Амато | аматец | житель Амато; эдзо, not declined |
| Обитель | обителец | житель Обители; венд; венда |

## FATE Core In Astaria

Astaria character sheets use `FATE Core System`.

Skill caps:

- Ordinary characters: maximum skill level `+4`.
- Imitei: maximum skill level `+5`.
- Gods: maximum skill level `+6`.

When generating NPCs or known-character sheets, treat the cap as a guideline unless the user requests a specific power level.

## Aspect Structure

Astaria characters use five aspects:

1. `Концепция`: the most important broad character aspect. It says who the character is, what they do, why they get up in the morning, and what duty/status/calling follows them.
2. `Проблема`: what complicates the character's life. It should generate interesting chaos, should not be easy to ignore, should not completely paralyse the character, and should not simply repeat the concept.
3. `Зов Крови`: the character's connection to one Astaria people/country. For an Imitei, this describes where they are on the path to becoming an Imitei, or what kind of Imitei they already are: divine helper, free wanderer, etc. It reflects gradual transformation into an Imitei of their culture.
4. `Свободный аспект`: any additional aspect that reveals the character.
5. `Свободный аспект`: any additional aspect that reveals the character.

Good Astaria aspects should be:

- specific enough to invoke in play;
- double-edged enough to compel;
- culturally grounded when the aspect is about origin, faith, duty, bloodline, divine calling, or homeland;
- phrased as a vivid short statement, not as a dry tag.

## Skills

| Skill | Meaning |
| --- | --- |
| Атлетика | Physical conditioning and body control. A nimble character relies on Атлетика. |
| Бой | All melee combat in the same zone, armed or unarmed. |
| Внимательность | Perception, noticing details, searching for clues, observation. |
| Воля | Mental endurance, analogous to Телосложение for the mind. |
| Врачевание | First aid and long-term treatment of physical consequences. |
| Выживание | Surviving in the wilderness, tracking, understanding animals. |
| Знания | Education, scholarship, and general informedness. |
| Ловкость рук | Stealing, entering inaccessible places, sleight of hand, tricks. |
| Обман | Misleading and deceiving people. |
| Провокация | Producing negative emotions: command, fear, shame. |
| Ремесло | Making objects, weapons, armour, mechanisms, and knowing their properties. |
| Скрытность | Avoiding detection while still or moving. |
| Стрельба | Ranged weapon use in conflict and against ordinary targets. |
| Телосложение | Natural physical power, strength, endurance. A strong character relies on Телосложение. |
| Харизма | Producing positive emotions: being liked, trusted, and building relationships. |
| Эмпатия | Reading and interpreting changes in mood and behaviour. |

## Stunt Generation

The JSON did not include custom Astaria stunt rules, so use standard Fate Core style unless the user adds a house rule later.

Useful Russian stunt templates:

- `Поскольку я [особая подготовка/происхождение/дар], я получаю +2 к [навык], когда [действие] в ситуации [условие].`
- `Поскольку я [роль/традиция], один раз за сцену я могу [эффект], если [ограничение].`
- `Когда я [триггер], я могу использовать [навык A] вместо [навык B], чтобы [действие], если [условие].`

Prefer stunts that:

- attach to one skill;
- have a clear trigger and limit;
- feel rooted in culture, profession, divine patronage, or personal history;
- are useful in play without becoming always-on bonuses to everything.

## Suggested Private FATE Block For Character Notes

Use this block in private or GM-facing character notes. If a note may later be published to players, keep this inside an Obsidian comment or move it to a separate GM note.

```markdown
%% FATE / GM
aspects:
  concept:
  trouble:
  call_of_blood:
  free_1:
  free_2:
skills:
  +4:
  +3:
  +2:
  +1:
stunts:
  - name:
    text:
stress:
  physical:
  mental:
consequences:
  mild:
  moderate:
  severe:
notes:
%%
```
