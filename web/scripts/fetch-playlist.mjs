import { mkdir, writeFile } from "fs/promises";
import { dirname, join } from "path";
import { fileURLToPath } from "url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const outFile = join(root, "public", "free-channels.json");

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

const res = await fetch("https://iptv-org.github.io/iptv/index.m3u");
if (!res.ok) throw new Error(`playlist fetch failed: ${res.status}`);
const channels = parseM3u(await res.text());
await mkdir(join(root, "public"), { recursive: true });
await writeFile(outFile, JSON.stringify({ updated: new Date().toISOString(), count: channels.length, channels }));
console.log(`free channels: ${channels.length}`);
