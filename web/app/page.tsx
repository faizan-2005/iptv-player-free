"use client";

import { Clapperboard, Layers, Moon, Play, Plus, Search, Server, Sun, Tv } from "lucide-react";
import { useEffect, useMemo, useState } from "react";
import Player from "../components/player";

type Channel = {
  name: string;
  url: string;
  logo: string;
  group: string;
};

function parseM3u(content: string): Channel[] {
  const lines = content.split("\n").map((l) => l.trim()).filter(Boolean);
  const out: Channel[] = [];
  let name = "";
  let logo = "";
  let group = "";
  const attr = (line: string, key: string) => {
    const needle = `${key}="`;
    const start = line.indexOf(needle);
    if (start < 0) return "";
    const rest = line.slice(start + needle.length);
    const end = rest.indexOf('"');
    return end < 0 ? "" : rest.slice(0, end);
  };
  for (const line of lines) {
    if (line.startsWith("#EXTINF")) {
      const idx = line.lastIndexOf(",");
      name = idx >= 0 ? line.slice(idx + 1).trim() : "";
      logo = attr(line, "tvg-logo");
      group = attr(line, "group-title") || "General";
    } else if (!line.startsWith("#")) {
      if (line.startsWith("http") || line.startsWith("/api/stream?url=")) {
        out.push({ name: name || `Channel ${out.length + 1}`, url: line, logo, group });
      }
      name = "";
      logo = "";
      group = "";
    }
  }
  return out;
}

export default function Home() {
  const [dark, setDark] = useState(true);
  const [query, setQuery] = useState("");
  const [channels, setChannels] = useState<Channel[]>([]);
  const [activeUrl, setActiveUrl] = useState("");
  const [activeTitle, setActiveTitle] = useState("");
  const [m3u, setM3u] = useState("");
  const [loading, setLoading] = useState(false);
  const [proxy, setProxy] = useState(true);
  const [loadError, setLoadError] = useState("");

  const playSrc = proxy && activeUrl.startsWith("http") ? `/api/stream?url=${encodeURIComponent(activeUrl)}` : activeUrl;

  useEffect(() => {
    document.documentElement.classList.toggle("dark", dark);
  }, [dark]);

  async function addSource() {
    const url = m3u.trim();
    if (!url) return;
    setLoading(true);
    setLoadError("");
    try {
      let text = "";
      try {
        text = await (await fetch(url)).text();
      } catch {
        text = await (await fetch(`/api/stream?url=${encodeURIComponent(url)}`)).text();
      }
      if (!text.includes("#EXTINF") && !text.includes("#EXTM3U")) {
        throw new Error("bad playlist");
      }
      const parsed = parseM3u(text);
      setChannels(parsed);
      if (parsed.length > 0) {
        setActiveUrl(parsed[0].url);
        setActiveTitle(parsed[0].name);
      }
    } catch {
      setChannels([]);
      setLoadError("Playlist load nahi hui. URL check karo ya dusra M3U try karo.");
    } finally {
      setLoading(false);
      setM3u("");
    }
  }

  const filtered = useMemo(() => {
    const q = query.toLowerCase();
    return channels.filter((c) => c.name.toLowerCase().includes(q)).slice(0, 300);
  }, [channels, query]);

  return (
    <main className="min-h-screen p-4 max-w-5xl mx-auto">
      <header className="flex items-center justify-between py-4">
        <div className="flex items-center gap-2">
          <Tv className="w-6 h-6" />
          <h1 className="text-xl font-semibold">IPTV Player Free</h1>
        </div>
        <button
          onClick={() => setDark((d) => !d)}
          className="p-2 rounded-xl border border-slate-200 dark:border-slate-800"
          aria-label="Toggle theme"
        >
          {dark ? <Sun className="w-5 h-5" /> : <Moon className="w-5 h-5" />}
        </button>
      </header>

      <div className="grid md:grid-cols-[340px_1fr] gap-4">
        <section className="rounded-2xl border border-slate-200 dark:border-slate-800 p-4">
          <div className="flex items-center gap-2 border rounded-xl px-3 py-2">
            <Search className="w-4 h-4" />
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Search channels"
              className="bg-transparent outline-none w-full text-sm"
            />
          </div>
          <div className="flex gap-2 mt-3">
            <input
              value={m3u}
              onChange={(e) => setM3u(e.target.value)}
              placeholder="Paste M3U URL"
              className="flex-1 bg-transparent border border-slate-200 dark:border-slate-800 rounded-xl px-3 py-2 text-sm outline-none"
            />
            <button onClick={addSource} className="p-2 rounded-xl bg-blue-600 text-white" aria-label="Add source">
              <Plus className="w-5 h-5" />
            </button>
          </div>
          <p className="text-xs mt-3 opacity-70">Player only. Bring your own M3U. {loading ? "Loading..." : `${channels.length} channels`}</p>
          {loadError !== "" && <p className="text-xs text-red-500 mt-1">{loadError}</p>}
          <div className="mt-4 space-y-2 max-h-[520px] overflow-auto">
            {filtered.map((c) => (
              <button
                key={c.url}
                onClick={() => {
                  setActiveUrl(c.url);
                  setActiveTitle(c.name);
                }}
                className="w-full flex items-center gap-2 p-2 rounded-xl border border-slate-200 dark:border-slate-800 text-left"
              >
                <span className="p-2 rounded-lg bg-slate-100 dark:bg-slate-800">
                  <Play className="w-4 h-4" />
                </span>
                <span className="min-w-0">
                  <span className="block text-sm truncate">{c.name}</span>
                  <span className="block text-xs opacity-60">{c.group}</span>
                </span>
              </button>
            ))}
          </div>
          <div className="flex gap-2 mt-4 text-xs opacity-70">
            <span className="flex items-center gap-1"><Tv className="w-3 h-3" /> Live</span>
            <span className="flex items-center gap-1"><Clapperboard className="w-3 h-3" /> Movies</span>
            <span className="flex items-center gap-1"><Layers className="w-3 h-3" /> Series</span>
            <span className="flex items-center gap-1"><Server className="w-3 h-3" /> M3U</span>
          </div>
        </section>

        <section className="rounded-2xl border border-slate-200 dark:border-slate-800 p-4">
          {activeUrl ? (
            <>
              <div className="flex items-center justify-between mb-2 gap-2">
                <h2 className="text-sm font-medium truncate">{activeTitle}</h2>
                <button
                  onClick={() => setProxy((p) => !p)}
                  className={`text-xs px-3 py-1 rounded-full border ${proxy ? "bg-blue-600 text-white border-blue-600" : "border-slate-300 dark:border-slate-700"}`}
                >
                  Proxy {proxy ? "On" : "Off"}
                </button>
              </div>
              <Player key={playSrc} src={playSrc} />
            </>
          ) : (
            <div className="aspect-video grid place-items-center text-sm opacity-70">Add a playlist to start</div>
          )}
        </section>
      </div>
    </main>
  );
}
