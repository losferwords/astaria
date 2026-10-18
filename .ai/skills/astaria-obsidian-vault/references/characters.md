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
- `imitei`: the Imitei role if the character is an Imitei; otherwise use `false`.
- A readable description in the same style as existing Encyclopedia character profiles.
- A private `%% FATE / GM ... %%` block with aspects, skills, and stunts appropriate to the character's power level; use [Astaria Fate Core](../../astaria-fate-core/SKILL.md).

For age calculation, treat `НЭ` years as ordinary positive years. For `ХЭ`, calculate age across the era boundary carefully because years count backward toward zero.

Relationships use `country` or `origin`, `current_location`, `birth_place`, `imitei`, `organizations` and `species` when applicable. Publication and inferred reciprocal links follow [Quartz rules](quartz.md).
