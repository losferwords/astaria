.PHONY: quartz-sync quartz-build quartz-serve site serve

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
