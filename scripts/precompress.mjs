import { readdir, readFile, writeFile } from "node:fs/promises";
import { join } from "node:path";
import { brotliCompress, constants } from "node:zlib";
import { promisify } from "node:util";

const compress = promisify(brotliCompress);

const MINIMUM_BYTES = 256;
const WORTHWHILE_RATIO = 0.9;
const PROBE_RATIO = 0.95;
const PROBE_QUALITY = 5;

// a cheap pass says whether the slow one is worth running, so already-compressed
// formats fall out on their own rather than from a list of extensions
const probe = (source) => compress(source, { params: { [constants.BROTLI_PARAM_QUALITY]: PROBE_QUALITY } });

const pack = (source) =>
  compress(source, {
    params: {
      [constants.BROTLI_PARAM_QUALITY]: constants.BROTLI_MAX_QUALITY,
      [constants.BROTLI_PARAM_SIZE_HINT]: source.length,
    },
  });

async function* walk(dir) {
  for (const entry of await readdir(dir, { withFileTypes: true })) {
    const path = join(dir, entry.name);
    if (entry.isDirectory()) yield* walk(path);
    else if (entry.isFile() && !entry.name.endsWith(".br")) yield path;
  }
}

const root = process.argv[2] ?? "public";
const results = [];

for await (const path of walk(root)) {
  const source = await readFile(path);
  if (source.length < MINIMUM_BYTES) continue;
  if ((await probe(source)).length > source.length * PROBE_RATIO) continue;

  const compressed = await pack(source);
  if (compressed.length > source.length * WORTHWHILE_RATIO) continue;

  await writeFile(`${path}.br`, compressed);
  results.push(source.length - compressed.length);
}

const saved = results.reduce((total, bytes) => total + bytes, 0);
console.log(`precompressed ${results.length} files, ${(saved / 1024).toFixed(1)}KB smaller on the wire`);
