import { mkdir, writeFile } from "fs/promises";
import { dirname, join } from "path";
import { fileURLToPath } from "url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const outFile = join(root, "public", "free-channels.json");

const FALLBACK_COUNTRIES = ["in", "us", "uk", "pk", "ae", "sa", "ca", "au", "de", "fr"];

function attr(line, key) {
  const needle = `${key}="`;
  const start = line.indexOf(needle);
  if (start < 0) return "";
  const rest = line.slice(start + needle.length);
  const end = rest.indexOf('"');
  return end < 0 ? "" : rest.slice(0, end);
}

function parseM3u(content) {
  const lines = content.split("\n").map((l) => l.trim()).filter(Boolean);
  const out = [];
  let name = "";
  let logo = "";
  let group = "";
  for (const line of lines) {
    if (line.startsWith("#EXTINF")) {
      const idx = line.lastIndexOf(",");
      name = idx >= 0 ? line.slice(idx + 1).trim() : "";
      logo = attr(line, "tvg-logo");
      group = attr(line, "group-title") || "General";
    } else if (!line.startsWith("#") && line.startsWith("http")) {
      if (name) out.push({ n: name, u: line, l: logo, g: group });
      name = "";
      logo = "";
      group = "";
    }
  }
  return out;
}

function parseUrls(content) {
  const urls = new Set();
  for (const raw of content.split("\n")) {
    const line = raw.trim();
    if (line && !line.startsWith("#") && line.startsWith("http")) urls.add(line);
  }
  return urls;
}

async function countryCodes() {
  try {
    const res = await fetch("https://api.github.com/repos/iptv-org/iptv/contents/streams", {
      headers: { "User-Agent": "FaizanTV/1.0" }
    });
    if (!res.ok) throw new Error(`github api ${res.status}`);
    const files = await res.json();
    const codes = files.map((f) => f.name).filter((n) => /^[a-z]{2}\.m3u$/.test(n)).map((n) => n.slice(0, 2));
    if (codes.length > 0) return codes;
    throw new Error("empty");
  } catch {
    return FALLBACK_COUNTRIES;
  }
}

async function pool(items, size, fn) {
  const out = new Array(items.length);
  let i = 0;
  await Promise.all(
    Array.from({ length: Math.min(size, items.length) }, async () => {
      while (i < items.length) {
        const idx = i++;
        out[idx] = await fn(items[idx], idx);
      }
    })
  );
  return out;
}

const names = new Intl.DisplayNames(["en"], { type: "region" });

const indexRes = await fetch("https://iptv-org.github.io/iptv/index.m3u");
if (!indexRes.ok) throw new Error(`index fetch failed: ${indexRes.status}`);
const channels = parseM3u(await indexRes.text());
console.log(`all channels: ${channels.length}`);

const codes = await countryCodes();
console.log(`country playlists: ${codes.length}`);

const byUrl = new Map();
for (const c of channels) {
  if (!byUrl.has(c.u)) byUrl.set(c.u, c);
  c.c = [];
}

await pool(codes, 12, async (cc) => {
  try {
    const res = await fetch(`https://iptv-org.github.io/iptv/countries/${cc}.m3u`);
    if (!res.ok) return;
    for (const url of parseUrls(await res.text())) {
      const ch = byUrl.get(url);
      if (ch && !ch.c.includes(cc.toUpperCase())) ch.c.push(cc.toUpperCase());
    }
  } catch {}
});

const counts = {};
for (const c of channels) {
  for (const cc of c.c) counts[cc] = (counts[cc] ?? 0) + 1;
}
const countries = Object.entries(counts)
  .map(([cc, count]) => {
    let name = cc;
    try {
      name = names.of(cc) ?? cc;
    } catch {}
    return { cc, name, count };
  })
  .sort((a, b) => b.count - a.count);

console.log(`tagged countries: ${countries.length}`);

await mkdir(join(root, "public"), { recursive: true });
await writeFile(outFile, JSON.stringify({ updated: new Date().toISOString(), count: channels.length, countries, channels }));
console.log(`wrote ${outFile}`);
