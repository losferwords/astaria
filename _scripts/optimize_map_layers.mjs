#!/usr/bin/env node
import { createRequire } from 'node:module';
import { readFile, writeFile, mkdir, stat } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import { fileURLToPath } from 'node:url';
import { resolve, dirname } from 'node:path';
import { execFileSync } from 'node:child_process';
const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const require = createRequire(resolve(root, '_quartz/package.json'));
const sharp = require('sharp');
sharp.concurrency(2);
const layers = JSON.parse(execFileSync('ruby', ['-ryaml', '-rjson', '-e', 'puts JSON.generate(YAML.safe_load(File.read(ARGV[0])))', resolve(root, '_translations/map-layers.yml')])).layers;
const cachePath = resolve(root, 'Assets/Maps/Web/manifest.json');
let previous = {};
try { previous = JSON.parse(await readFile(cachePath, 'utf8')); } catch {}
const next = {};
for (const [layer, locales] of Object.entries(layers)) for (const [locale, config] of Object.entries(locales)) {
  const input = await readFile(resolve(root, config.source));
  const sha256 = createHash('sha256').update(input).digest('hex');
  const key = `${layer}/${locale}`;
  const metadata = await sharp(input).metadata();
  if (metadata.width * 9 !== metadata.height * 16) throw new Error(`Unexpected map aspect ratio: ${config.source}`);
  next[key] = { sha256, outputs: {} };
  for (const [variant, width, quality] of [['web', 7680, 90], ['preview', 1920, 82]]) {
    const path = config[variant];
    if (!path || path === config.source) throw new Error(`Missing derivative path: ${key}/${variant}`);
    const settings = { path, width, quality, format: 'webp', effort: 5 };
    const old = previous[key];
    const output = resolve(root, path);
    let exists = false;
    try { exists = (await stat(output)).size === old?.outputs?.[variant]?.bytes; } catch {}
    let bytes;
    if (old?.sha256 === sha256 && JSON.stringify(old.outputs?.[variant]?.settings) === JSON.stringify(settings) && exists) {
      bytes = old.outputs[variant].bytes;
    } else {
      await mkdir(dirname(output), { recursive: true });
      const result = await sharp(input).resize({ width, withoutEnlargement: true }).webp({ quality, effort: 5 }).toFile(output);
      bytes = result.size;
      console.log(`${path}: ${(bytes / 1048576).toFixed(2)} MiB`);
    }
    next[key].outputs[variant] = { settings, bytes };
  }
  const tilesPath = config.tiles;
  if (!tilesPath) throw new Error(`Missing tiles configuration: ${key}`);
  const tileRoot = dirname(resolve(root, tilesPath));
  const grids = [
    { id: 'detail', tileWidth: 3072, tileHeight: 2048 },
    { id: 'wide', tileWidth: Math.ceil(metadata.width / 2), tileHeight: Math.ceil(metadata.height / 2) }
  ];
  const settings = { version: 1, lossless: true, effort: 0, grids };
  const oldTiles = previous[key]?.tiles;
  const paths = [];
  for (const grid of grids) {
    grid.columns = Math.ceil(metadata.width / grid.tileWidth);
    grid.rows = Math.ceil(metadata.height / grid.tileHeight);
    for (let y = 0; y < grid.rows; y++) for (let x = 0; x < grid.columns; x++) paths.push(`${grid.id}/${x}-${y}.webp`);
  }
  let cached = oldTiles?.sha256 === sha256 && JSON.stringify(oldTiles.settings) === JSON.stringify(settings);
  if (cached) {
    for (const path of paths) {
      try { if (!(await stat(resolve(tileRoot, path))).size) cached = false; } catch { cached = false; }
    }
  }
  let totalBytes = cached ? oldTiles.bytes : 0;
  if (!cached) {
    const { data, info } = await sharp(input).raw().toBuffer({ resolveWithObject: true });
    for (const grid of grids) {
      await mkdir(resolve(tileRoot, grid.id), { recursive: true });
      for (let y = 0; y < grid.rows; y++) for (let x = 0; x < grid.columns; x++) {
        const left = x * grid.tileWidth, top = y * grid.tileHeight;
        const width = Math.min(grid.tileWidth, metadata.width - left);
        const height = Math.min(grid.tileHeight, metadata.height - top);
        const result = await sharp(data, { raw: info }).extract({ left, top, width, height })
          .webp({ lossless: true, effort: 0 }).toFile(resolve(tileRoot, `${grid.id}/${x}-${y}.webp`));
        totalBytes += result.size;
      }
      console.log(`${key}: lossless ${grid.id} tiles encoded`);
    }
  }
  const descriptor = { version: 1, width: metadata.width, height: metadata.height, sourceSha256: sha256, grids };
  const descriptorText = JSON.stringify(descriptor, null, 2) + '\n';
  let existing = '';
  try { existing = await readFile(resolve(root, tilesPath), 'utf8'); } catch {}
  if (existing !== descriptorText) await writeFile(resolve(root, tilesPath), descriptorText);
  next[key].tiles = { sha256, settings, bytes: totalBytes, paths };
}
const text = JSON.stringify(next, null, 2) + '\n';
if (JSON.stringify(previous) !== JSON.stringify(next)) await writeFile(cachePath, text);
console.log('Map web assets are up to date. Original PNG files preserved.');
