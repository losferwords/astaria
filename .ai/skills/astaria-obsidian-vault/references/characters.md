# Character article requirements

Use for creating or completing character articles. For an existing character, distinguish unknown values from new author-approved inventions. Deliberately withheld details in the Losfy/Losfer/Misty line remain unknown; follow `.ai/context/losfy-losfer-misty.md`.

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
- `imitei`: the publicly confirmed Imitei role; otherwise use `false`. Keep concealed affiliation in `secret_imitei` or private GM text, never in this ordinary public field.
- A readable description in the same style as existing Encyclopedia character profiles.
- A private `%% FATE / GM ... %%` block with aspects, skills, and stunts appropriate to the character's power level; use [Astaria Fate Core](../../astaria-fate-core/SKILL.md).

For age calculation, treat `НЭ` years as ordinary positive years. For `ХЭ`, calculate age across the era boundary carefully because years count backward toward zero.

Relationships use `country` or `origin`, `current_location`, `birth_place`, `imitei`, `organizations` and `species` when applicable. Publication and inferred reciprocal links follow [Quartz rules](quartz.md).

## Public Imitei register

Maintain the public Imitei register only in the `affected_people` sidebar list of `Энциклопедия/Знания/Имитей.md` and its existing English overlay, without duplicates. Do not add a parallel list or an `Известные Имитеи` section to the article body.

- Include a character only when an ordinary public `imitei` field or unhidden canonical prose explicitly confirms their Imitei path. An unpublished character article (`quartz: false`) is eligible on the same terms; listing the character does not authorize publishing their article or changing its flags.
- Exclude wholly private or secret character articles (`private: true` or `secret: true`), facts from `Энциклопедия/Секреты/`, `secret_*` fields, `%% ... %%` comments and GM mechanics. Do not reveal concealed affiliation, including concealed partial membership. Аристея Кронос is an explicit exclusion while her affiliation remains secret, even if it is known to the author or to an agent.
- A related path link, unusual ability, family relationship, training, aspiration or rumour is insufficient. If public text and metadata conflict, or membership is ambiguous, leave the character out until clarified; do not repair the uncertainty by importing private knowledge.
- Order the flat sidebar list by the confirmed path in `IMITEI_ORDER` from `_scripts/sync_quartz_content.rb`, paired with its traditional homeland in `COUNTRY_ORDER`: Идеалы, Горцы, Друиды, Профитисы and so on. This ordering does not establish a character's birthplace or citizenship. Within each path, follow the Characters catalog: its homeland's ruler first, then `character_name_sort_key` (family name, then full name; family name comes first in Lang-An and Amato).
- When an affected character is created, renamed, deleted, gains or loses a public affiliation, or that affiliation becomes secret or openly confirmed, update `affected_people` in Russian and English. Remove stale names and links, preserve the approved English names and keep ordering identical across locales. Publicly documented historical or former affiliation may remain; do not imply that an explicitly former Imitei still holds the status.
- Keep checks proportional: review the affected profiles and list entries, and verify links, privacy, ordering and matching locale membership. A complete vault-wide reconciliation is a separate task, not a routine requirement on every turn.
