.PHONY: quartz-sync quartz-build quartz-serve site serve translations-check translations-complete-check multilingual-build multilingual-preview multilingual-preview-serve multilingual-serve

PORT ?= 8080
WSPORT ?= 3001

quartz-sync:
	ruby _scripts/sync_quartz_content.rb

quartz-build: quartz-sync
	cd _quartz && NODE_OPTIONS=--max-old-space-size=8192 node quartz/bootstrap-cli.mjs build -d content -o public

quartz-serve: quartz-sync
	cd _quartz && NODE_OPTIONS=--max-old-space-size=8192 node quartz/bootstrap-cli.mjs build -d content -o public --serve --port $(PORT) --wsPort $(WSPORT)

site: quartz-build

serve: quartz-serve

translations-check:
	ruby _scripts/validate_astaria_translations.rb

translations-complete-check:
	ruby _scripts/validate_astaria_translations.rb --complete

multilingual-build: translations-complete-check
	ASTARIA_LOCALE=ru ASTARIA_USE_APPROVED_ROUTES=true ASTARIA_QUARTZ_CONTENT=_quartz/content-ru ruby _scripts/sync_quartz_content.rb
	cd _quartz && ASTARIA_LOCALE=ru ASTARIA_MULTILINGUAL=true NODE_OPTIONS=--max-old-space-size=8192 node quartz/bootstrap-cli.mjs build -d content-ru -o build/ru
	ASTARIA_LOCALE=en-GB ASTARIA_USE_APPROVED_ROUTES=true ASTARIA_QUARTZ_CONTENT=_quartz/content-en ruby _scripts/sync_quartz_content.rb
	cd _quartz && ASTARIA_LOCALE=en-GB ASTARIA_MULTILINGUAL=true NODE_OPTIONS=--max-old-space-size=8192 node quartz/bootstrap-cli.mjs build -d content-en -o build/en
	ruby _scripts/merge_quartz_locales.rb
	ruby _scripts/audit_multilingual_build.rb
	ruby _scripts/audit_translation_parity.rb
	ruby _scripts/audit_quartz_build.rb

multilingual-preview: translations-check
	ASTARIA_LOCALE=ru ASTARIA_USE_APPROVED_ROUTES=true ASTARIA_QUARTZ_CONTENT=_quartz/content-ru ruby _scripts/sync_quartz_content.rb
	cd _quartz && ASTARIA_LOCALE=ru ASTARIA_MULTILINGUAL=true NODE_OPTIONS=--max-old-space-size=8192 node quartz/bootstrap-cli.mjs build -d content-ru -o build/ru
	ASTARIA_LOCALE=en-GB ASTARIA_ONLY_TRANSLATED=true ASTARIA_USE_APPROVED_ROUTES=true ASTARIA_QUARTZ_CONTENT=_quartz/content-en ruby _scripts/sync_quartz_content.rb
	cd _quartz && ASTARIA_LOCALE=en-GB ASTARIA_MULTILINGUAL=true NODE_OPTIONS=--max-old-space-size=8192 node quartz/bootstrap-cli.mjs build -d content-en -o build/en
	ruby _scripts/merge_quartz_locales.rb
	ruby _scripts/audit_multilingual_build.rb --preview
	ruby _scripts/audit_translation_parity.rb
	ruby _scripts/audit_quartz_build.rb --preview

multilingual-preview-serve: multilingual-preview
	PORT=$(PORT) ruby _scripts/serve_quartz.rb

multilingual-serve: multilingual-build
	PORT=$(PORT) ruby _scripts/serve_quartz.rb
