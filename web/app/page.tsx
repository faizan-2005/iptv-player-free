"use client";

import { Clapperboard, Layers, Moon, Plus, Search, Server, Sun, Tv } from "lucide-react";
import { useEffect, useState } from "react";
import Player from "../components/player";

type Source = {
  id: string;
  name: string;
  url: string;
};

export default function Home() {
  const [dark, setDark] = useState(true);
  const [query, setQuery] = useState("");
  const [sources, setSources] = useState<Source[]>([]);
  const [activeUrl, setActiveUrl] = useState("");
  const [m3u, setM3u] = useState("");

  useEffect(() => {
    document.documentElement.classList.toggle("dark", dark);
  }, [dark]);

  function addSource() {
    if (!m3u.trim()) return;
    setSources((s) => [...s, { id: `${Date.now()}`, name: "My playlist", url: m3u.trim() }]);
    setActiveUrl(m3u.trim());
    setM3u("");
  }

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

      <div className="grid md:grid-cols-[320px_1fr] gap-4">
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
          <p className="text-xs mt-3 opacity-70">Player only. Bring your own M3U or Xtream login.</p>
          <div className="mt-4 space-y-2">
            {sources.map((s) => (
              <button
                key={s.id}
                onClick={() => setActiveUrl(s.url)}
                className="w-full flex items-center gap-2 p-3 rounded-xl border border-slate-200 dark:border-slate-800 text-left"
              >
                <Server className="w-4 h-4" />
                <span className="text-sm truncate">{s.name}</span>
              </button>
            ))}
          </div>
          <div className="flex gap-2 mt-4 text-xs opacity-70">
            <span className="flex items-center gap-1"><Tv className="w-3 h-3" /> Live</span>
            <span className="flex items-center gap-1"><Clapperboard className="w-3 h-3" /> Movies</span>
            <span className="flex items-center gap-1"><Layers className="w-3 h-3" /> Series</span>
          </div>
        </section>

        <section className="rounded-2xl border border-slate-200 dark:border-slate-800 p-4">
          {activeUrl ? <Player src={activeUrl} /> : <div className="aspect-video grid place-items-center text-sm opacity-70">Add a playlist to start</div>}
        </section>
      </div>
    </main>
  );
}
