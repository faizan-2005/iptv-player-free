"use client";

import { ArrowLeft, Moon, Sun, Tv } from "lucide-react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { Suspense, useEffect, useState } from "react";
import Player from "../../components/player";
import { playUrl } from "../../lib/playback";

function PlayInner() {
  const params = useSearchParams();
  const stream = params.get("stream") ?? "";
  const title = params.get("title") ?? "Now Playing";
  const [dark, setDark] = useState(true);

  useEffect(() => {
    document.documentElement.classList.toggle("dark", dark);
  }, [dark]);

  const src = playUrl(stream);

  return (
    <main className="min-h-screen max-w-6xl mx-auto px-4 pb-16 text-lg overflow-x-clip">
      <header className="flex items-center justify-between py-5 gap-3">
        <div className="flex items-center gap-3 min-w-0">
          <Link href="/" className="p-3 rounded-2xl border border-slate-300 dark:border-slate-700 min-w-[52px] min-h-[52px] grid place-items-center shrink-0" aria-label="Wapas">
            <ArrowLeft className="w-6 h-6" />
          </Link>
          <span className="p-3 rounded-2xl bg-blue-600 text-white shrink-0">
            <Tv className="w-7 h-7" />
          </span>
          <h1 className="text-2xl font-bold truncate min-w-0">Faizan TV</h1>
        </div>
        <button
          onClick={() => setDark((d) => !d)}
          className="p-3 rounded-2xl border border-slate-300 dark:border-slate-700 min-w-[52px] min-h-[52px] grid place-items-center shrink-0"
          aria-label="Theme badlo"
        >
          {dark ? <Sun className="w-6 h-6" /> : <Moon className="w-6 h-6" />}
        </button>
      </header>

      {stream ? (
        <section className="border border-slate-200 dark:border-slate-800 p-4 sm:p-6">
          <h2 className="text-2xl font-bold truncate mb-4">{title}</h2>
          <Player key={src} src={src} />
        </section>
      ) : (
        <section className="border border-slate-200 dark:border-slate-800 p-8 text-center">
          <Tv className="w-12 h-12 mx-auto opacity-40" />
          <p className="text-xl font-semibold mt-3">Koi stream nahi mila</p>
          <Link href="/" className="inline-block mt-4 px-6 py-3 rounded-2xl bg-blue-600 text-white text-lg font-semibold">
            Home jao
          </Link>
        </section>
      )}
    </main>
  );
}

export default function PlayPage() {
  return (
    <Suspense>
      <PlayInner />
    </Suspense>
  );
}
