"use client";

import { ArrowLeft, Moon, Sun, Tv } from "lucide-react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { Suspense, useEffect, useState } from "react";
import Player from "../../components/player";

function PlayInner() {
  const params = useSearchParams();
  const stream = params.get("stream") ?? "";
  const title = params.get("title") ?? "Now Playing";
  const [dark, setDark] = useState(true);
  const [proxy, setProxy] = useState(true);

  useEffect(() => {
    document.documentElement.classList.toggle("dark", dark);
  }, [dark]);

  const playSrc = proxy && stream.startsWith("http") ? `/api/stream?url=${encodeURIComponent(stream)}` : stream;

  return (
    <main className="min-h-screen max-w-6xl mx-auto px-4 pb-16 text-lg">
      <header className="flex items-center justify-between py-5 gap-3">
        <div className="flex items-center gap-3 min-w-0">
          <Link href="/" className="p-3 rounded-2xl border border-slate-300 dark:border-slate-700 min-w-[52px] min-h-[52px] grid place-items-center shrink-0" aria-label="Wapas">
            <ArrowLeft className="w-6 h-6" />
          </Link>
          <span className="p-3 rounded-2xl bg-blue-600 text-white shrink-0">
            <Tv className="w-7 h-7" />
          </span>
          <h1 className="text-2xl font-bold truncate">Faizan TV</h1>
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
        <section className="rounded-3xl border border-slate-200 dark:border-slate-800 p-4 sm:p-5">
          <div className="flex items-center justify-between gap-2 mb-3">
            <h2 className="text-xl font-bold truncate">{title}</h2>
            <button
              onClick={() => setProxy((p) => !p)}
              className={`shrink-0 text-base font-semibold px-4 py-2 rounded-full border-2 ${proxy ? "bg-blue-600 text-white border-blue-600" : "border-slate-300 dark:border-slate-700"}`}
            >
              Proxy {proxy ? "On" : "Off"}
            </button>
          </div>
          <Player key={playSrc} src={playSrc} />
          <p className="text-sm opacity-60 mt-3">CORS error aaye to Proxy On rakho. Kuch streams browser me block ho sakte hai. Sab kuch Android app me chalega.</p>
        </section>
      ) : (
        <section className="rounded-3xl border border-slate-200 dark:border-slate-800 p-8 text-center">
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
