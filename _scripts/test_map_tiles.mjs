#!/usr/bin/env node
import assert from 'node:assert/strict';
import { createRequire } from 'node:module';
import { mkdtemp, rm, readFile, stat } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
const require = createRequire(resolve('_quartz/package.json'));
const dir = await mkdtemp(join(tmpdir(), 'astaria-tile-test-'));
try {
  const out = join(dir, 'tiles.mjs');
  await require('esbuild').build({ entryPoints: ['_quartz/quartz/components/scripts/astaria-map-tiles.ts'], outfile: out, bundle: true, platform: 'node', format: 'esm' });
  const { visibleTiles } = await import(pathToFileURL(out));
  const descriptor = { width: 11520, height: 6480, grids: [
    { id: 'detail', tileWidth: 3072, tileHeight: 2048, columns: 4, rows: 4 },
    { id: 'wide', tileWidth: 5760, tileHeight: 3240, columns: 2, rows: 2 },
  ] };
  let checks = 0;
  // Measured desktop, Retina 6K, 4K, phone and expanded-phone visible extents, plus oversized fallback.
  for (const [width, height] of [[769,488],[1728,1117],[3008,1692],[1920,1080],[768,1663],[8000,5000],[11520,6480]]) {
    for (const cx of [0,1000,3072,5760,6144,10000,11520]) for (const cy of [0,1000,2048,3240,4096,6480]) {
      const left = Math.max(0, Math.min(cx-width/2, descriptor.width-width));
      const top = Math.max(0, Math.min(cy-height/2, descriptor.height-height));
      const rect = { left, top, right: left+width, bottom: top+height };
      const tiles = visibleTiles(descriptor, rect);
      assert.ok(tiles.length > 0 && tiles.length <= 4, 'At most four visible HD images');
      const area = tiles.reduce((sum,t) => sum+Math.max(0,Math.min(t.left+t.width,rect.right)-Math.max(t.left,rect.left))*Math.max(0,Math.min(t.top+t.height,rect.bottom)-Math.max(t.top,rect.top)),0);
      assert.equal(area,width*height,'HD selection must cover the entire visible rectangle');
      checks++;
    }
  }
  assert.equal(visibleTiles(descriptor,{left:0,top:0,right:3072,bottom:2048}).length,1,'Exact boundaries do not fetch neighbours');
  console.log(`Tile selection passed: ${checks} coverage/count scenarios and exact-edge check`);
  if (process.argv.includes('--pixels')) {
    const sharp = require('sharp');
    sharp.concurrency(2);
    const cache = JSON.parse(await readFile('Assets/Maps/Web/manifest.json', 'utf8'));
    let count = 0, bytes = 0;
    for (const [key, entry] of Object.entries(cache)) {
      const [layer, locale] = key.split('/');
      const suffix = locale === 'ru' ? 'ru' : 'en';
      const prefix = `Assets/Maps/Web/${layer}_${suffix}-tiles`;
      const descriptor = JSON.parse(await readFile(`${prefix}/tiles.json`, 'utf8'));
      const { data, info } = await sharp(`Assets/Maps/${layer}_${suffix}.png`).ensureAlpha().raw().toBuffer({resolveWithObject:true});
      for (const grid of descriptor.grids) for (let y=0;y<grid.rows;y++) for(let x=0;x<grid.columns;x++) {
        const left=x*grid.tileWidth,top=y*grid.tileHeight;
        const width=Math.min(grid.tileWidth,info.width-left),height=Math.min(grid.tileHeight,info.height-top);
        const path=`${prefix}/${grid.id}/${x}-${y}.webp`;
        const expected=await sharp(data,{raw:info}).extract({left,top,width,height}).raw().toBuffer();
        const decoded=await sharp(path).ensureAlpha().raw().toBuffer();
        assert.ok(expected.equals(decoded), `Original pixels changed: ${path}`);
        count++; bytes+=(await stat(path)).size;
      }
      console.log(`Pixel equality verified: ${key}`);
    }
    console.log(`${count} tiles match PNG pixels exactly; total ${(bytes/1048576).toFixed(1)} MiB across all grids/locales/layers`);
  }
} finally { await rm(dir,{recursive:true,force:true}); }
