"use client";

import { Heart, Moon, Play, Plus, Search, Sun, Tv, X } from "lucide-react";
import { useEffect, useMemo, useState } from "react";
import Player from "../components/player";

type Channel = {
  name: string;
  url: string;
  logo: string;
  group: string;
};

type Tab = "free" | "mine";

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
    } else if (!line.startsWith("#") && line.startsWith("http")) {
      if (name) out.push({ name, url: line, logo, group });
      name = "";
      logo = "";
      group = "";
    }
  }
  return out;
}

function loadFavs(): string[] {
  try {
    return JSON.parse(localStorage.getItem("fav-channels") ?? "[]");
  } catch {
    return [];
  }
}

export default function Home() {
  const [dark, setDark] = useState(true);
  const [tab, setTab] = useState<Tab>("free");
  const [query, setQuery] = useState("");
  const [group, setGroup] = useState("All");
  const [onlyFav, setOnlyFav] = useState(false);
  const [favs, setFavs] = useState<string[]>([]);
  const [free, setFree] = useState<Channel[]>([]);
  const [mine, setMine] = useState<Channel[]>([]);
  const [active, setActive] = useState<Channel | null>(null);
  const [m3u, setM3u] = useState("");
  const [loading, setLoading] = useState(false);
  const [loadError, setLoadError] = useState("");

  useEffect(() => {
    document.documentElement.classList.toggle("dark", dark);
  }, [dark]);

  useEffect(() => {
    setFavs(loadFavs());
    fetch("free-channels.json")
      .then((r) => (r.ok ? r.json() : null))
      .then((d) => {
        if (d && Array.isArray(d.channels)) {
          setFree(d.channels.map((c: { n: string; u: string; l: string; g: string }) => ({ name: c.n, url: c.u, logo: c.l, group: c.g })));
        }
      })
      .catch(() => {});
  }, []);

  function toggleFav(url: string) {
    setFavs((f) => {
      const next = f.includes(url) ? f.filter((x) => x !== url) : [...f, url];
      localStorage.setItem("fav-channels", JSON.stringify(next));
      return next;
    });
  }

  async function addSource() {
    const url = m3u.trim();
    if (!url) return;
    setLoading(true);
    setLoadError("");
    try {
      const text = await (await fetch(url)).text();
      if (!text.includes("#EXTM3U")) throw new Error("bad playlist");
      const parsed = parseM3u(text);
      setMine(parsed);
      setTab("mine");
      setGroup("All");
      if (parsed.length > 0) setActive(parsed[0]);
    } catch {
      setLoadError("Playlist load nahi hui. URL check karo ya Android app use karo.");
    } finally {
      setLoading(false);
      setM3u("");
    }
  }

  const list = tab === "free" ? free : mine;
  const groups = useMemo(() => ["All", ...Array.from(new Set(list.map((c) => c.group))).slice(0, 60)], [list]);
  const filtered = useMemo(() => {
    const q = query.toLowerCase();
    return list
      .filter((c) => (group === "All" || c.group === group) && (q === "" || c.name.toLowerCase().includes(q)) && (!onlyFav || favs.includes(c.url)))
      .slice(0, 400);
  }, [list, query, group, onlyFav, favs]);

  return (
    <main className="min-h-screen max-w-6xl mx-auto px-4 pb-16 text-lg">
      <header className="flex items-center justify-between py-5">
        <div className="flex items-center gap-3">
          <span className="p-3 rounded-2xl bg-blue-600 text-white">
            <Tv className="w-7 h-7" />
          </span>
          <div>
            <h1 className="text-2xl font-bold leading-tight">IPTV Player Free</h1>
            <p className="text-sm opacity-60">Player only. Apni playlist lao.</p>
          </div>
        </div>
        <button
          onClick={() => setDark((d) => !d)}
          className="p-3 rounded-2xl border border-slate-300 dark:border-slate-700 min-w-[52px] min-h-[52px] grid place-items-center"
          aria-label="Theme badlo"
        >
          {dark ? <Sun className="w-6 h-6" /> : <Moon className="w-6 h-6" />}
        </button>
      </header>

      <div className="grid gap-5 lg:grid-cols-[380px_1fr]">
        <section className="order-2 lg:order-1 rounded-3xl border border-slate-200 dark:border-slate-800 p-4 sm:p-5">
          <div className="grid grid-cols-2 gap-2 p-1 rounded-2xl bg-slate-100 dark:bg-slate-900">
            <button
              onClick={() => setTab("free")}
              className={`py-3 rounded-xl text-lg font-semibold ${tab === "free" ? "bg-white dark:bg-slate-800 shadow" : "opacity-60"}`}
            >
              Free Channels
            </button>
            <button
              onClick={() => setTab("mine")}
              className={`py-3 rounded-xl text-lg font-semibold ${tab === "mine" ? "bg-white dark:bg-slate-800 shadow" : "opacity-60"}`}
            >
              My Playlist
            </button>
          </div>

          <div className="flex items-center gap-2 border-2 rounded-2xl px-4 py-3 mt-4">
            <Search className="w-6 h-6 shrink-0 opacity-60" />
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Channel dhoondo"
              className="bg-transparent outline-none w-full text-lg"
            />
            {query !== "" && (
              <button onClick={() => setQuery("")} aria-label="Search saaf karo">
                <X className="w-6 h-6 opacity-60" />
              </button>
            )}
          </div>

          <div className="flex gap-2 mt-4">
            <input
              value={m3u}
              onChange={(e) => setM3u(e.target.value)}
              placeholder="Apna M3U link paste karo"
              className="flex-1 min-w-0 bg-transparent border-2 border-slate-200 dark:border-slate-700 rounded-2xl px-4 py-3 text-lg outline-none"
            />
            <button onClick={addSource} className="p-3 rounded-2xl bg-blue-600 text-white min-w-[56px] min-h-[56px] grid place-items-center" aria-label="Playlist jodo">
              <Plus className="w-7 h-7" />
            </button>
          </div>
          {loading && <p className="text-base mt-2 opacity-70">Load ho raha hai...</p>}
          {loadError !== "" && <p className="text-base text-red-500 mt-2">{loadError}</p>}

          <div className="flex items-center gap-2 mt-4">
            <button
              onClick={() => setOnlyFav((v) => !v)}
              className={`flex items-center gap-2 px-4 py-2 rounded-full border-2 text-base font-semibold ${onlyFav ? "bg-red-500 text-white border-red-500" : "border-slate-300 dark:border-slate-700"}`}
            >
              <Heart className={`w-5 h-5 ${onlyFav ? "fill-current" : ""}`} /> Fav ({favs.length})
            </button>
            <span className="text-base opacity-60">{filtered.length} channels</span>
          </div>

          <div className="flex gap-2 mt-3 overflow-x-auto pb-2 -mx-1 px-1">
            {groups.map((g) => (
              <button
                key={g}
                onClick={() => setGroup(g)}
                className={`shrink-0 px-4 py-2 rounded-full text-base font-semibold border-2 ${group === g ? "bg-blue-600 text-white border-blue-600" : "border-slate-300 dark:border-slate-700"}`}
              >
                {g}
              </button>
            ))}
          </div>

          <div className="mt-3 space-y-2 max-h-[60vh] lg:max-h-[560px] overflow-auto">
            {filtered.map((c) => {
              const isFav = favs.includes(c.url);
              const isActive = active?.url === c.url;
              return (
                <div
                  key={c.url}
                  className={`flex items-center gap-3 p-3 rounded-2xl border-2 min-h-[72px] ${isActive ? "border-blue-600" : "border-slate-200 dark:border-slate-800"}`}
                >
                  <button onClick={() => setActive(c)} className="flex items-center gap-3 flex-1 min-w-0 text-left" aria-label={c.name}>
                    {c.logo ? (
                      <img src={c.logo} alt="" loading="lazy" className="w-12 h-12 rounded-xl object-contain bg-white shrink-0" />
                    ) : (
                      <span className="p-3 rounded-xl bg-slate-100 dark:bg-slate-800 shrink-0">
                        <Play className="w-6 h-6" />
                      </span>
                    )}
                    <span className="min-w-0">
                      <span className="block text-lg font-semibold truncate">{c.name}</span>
                      <span className="block text-sm opacity-60 truncate">{c.group}</span>
                    </span>
                  </button>
                  <button onClick={() => toggleFav(c.url)} className="p-3 shrink-0" aria-label="Favorite">
                    <Heart className={`w-7 h-7 ${isFav ? "fill-red-500 text-red-500" : "opacity-50"}`} />
                  </button>
                </div>
              );
            })}
            {filtered.length === 0 && <p className="text-center text-lg opacity-60 py-8">Kuch nahi mila</p>}
          </div>
        </section>

        <section className="order-1 lg:order-2 lg:sticky lg:top-4 self-start rounded-3xl border border-slate-200 dark:border-slate-800 p-4 sm:p-5">
          {active ? (
            <>
              <h2 className="text-xl font-bold mb-3 truncate">{active.name}</h2>
              <Player key={active.url} src={active.url} />
              <p className="text-sm opacity-60 mt-3">Kuch streams browser me block ho sakte hai. Sab kuch Android app me chalega.</p>
            </>
          ) : (
            <div className="aspect-video grid place-items-center text-center">
              <div>
                <Tv className="w-12 h-12 mx-auto opacity-40" />
                <p className="text-xl font-semibold mt-3">Koi channel chuno</p>
                <p className="text-base opacity-60">Neeche list se play dabao</p>
              </div>
            </div>
          )}
        </section>
      </div>
    </main>
  );
}
