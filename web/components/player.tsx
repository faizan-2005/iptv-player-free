"use client";

import Hls from "hls.js";
import { Captions, Gauge, Layers, Maximize, Minimize, Pause, PictureInPicture2, Play, Volume2, VolumeX, X } from "lucide-react";
import { useCallback, useEffect, useRef, useState } from "react";

type Level = { index: number; label: string };

function fmt(s: number) {
  if (!isFinite(s) || s < 0) return "0:00";
  const h = Math.floor(s / 3600);
  const m = Math.floor((s % 3600) / 60);
  const sec = Math.floor(s % 60);
  const mm = h > 0 ? String(m).padStart(2, "0") : String(m);
  return `${h > 0 ? `${h}:` : ""}${mm}:${String(sec).padStart(2, "0")}`;
}

function posKey(src: string) {
  let h = 0;
  for (let i = 0; i < src.length; i++) h = (h * 31 + src.charCodeAt(i)) >>> 0;
  return `ftv-pos-${h}`;
}

const RATES = [0.5, 0.75, 1, 1.25, 1.5, 2];

export default function Player({ src }: { src: string }) {
  const wrapRef = useRef<HTMLDivElement>(null);
  const videoRef = useRef<HTMLVideoElement>(null);
  const hlsRef = useRef<Hls | null>(null);
  const hideTimer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const saveTimer = useRef(0);

  const [playing, setPlaying] = useState(false);
  const [muted, setMuted] = useState(false);
  const [volume, setVolume] = useState(1);
  const [rate, setRate] = useState(1);
  const [time, setTime] = useState(0);
  const [dur, setDur] = useState(0);
  const [buffered, setBuffered] = useState(0);
  const [levels, setLevels] = useState<Level[]>([]);
  const [quality, setQuality] = useState(-1);
  const [audioCount, setAudioCount] = useState(0);
  const [audioTrack, setAudioTrack] = useState(0);
  const [controls, setControls] = useState(true);
  const [menu, setMenu] = useState<"none" | "speed" | "quality" | "audio">("none");
  const [resumeAt, setResumeAt] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [theater, setTheater] = useState(false);
  const [portrait, setPortrait] = useState(false);
  const [vp, setVp] = useState({ w: 0, h: 0 });

  const poke = useCallback(() => {
    setControls(true);
    if (hideTimer.current) clearTimeout(hideTimer.current);
    hideTimer.current = setTimeout(() => {
      setControls(false);
      setMenu("none");
    }, 3500);
  }, []);

  useEffect(() => {
    const updVp = () => setVp({ w: window.innerWidth, h: window.innerHeight });
    updVp();
    const mq = window.matchMedia("(orientation: portrait)");
    const upd = () => setPortrait(mq.matches);
    upd();
    mq.addEventListener("change", upd);
    window.addEventListener("resize", updVp);
    window.addEventListener("orientationchange", updVp);
    return () => {
      mq.removeEventListener("change", upd);
      window.removeEventListener("resize", updVp);
      window.removeEventListener("orientationchange", updVp);
    };
  }, []);

  useEffect(() => {
    document.body.style.overflow = theater ? "hidden" : "";
    return () => {
      document.body.style.overflow = "";
    };
  }, [theater]);

  useEffect(() => {
    const video = videoRef.current;
    if (!video || !src) return;
    setError("");
    setResumeAt(0);
    setQuality(-1);
    setLevels([]);
    hlsRef.current?.destroy();
    hlsRef.current = null;

    try {
      const saved = Number(localStorage.getItem(posKey(src)) ?? 0);
      if (saved > 10) setResumeAt(saved);
    } catch {}

    const fail = (msg: string) => {
      setLoading(false);
      setError(msg);
    };
    const onMeta = () => setDur(video.duration || 0);
    const onPlay = () => {
      setPlaying(true);
      setLoading(false);
    };
    const onPause = () => setPlaying(false);
    const onWaiting = () => {
      if (!video.paused) setLoading(true);
    };
    const onCanPlay = () => setLoading(false);
    const onLoadStart = () => {
      setLoading(true);
      setPlaying(false);
    };
    const onVol = () => {
      setMuted(video.muted);
      setVolume(video.volume);
    };
    const onRate = () => setRate(video.playbackRate);
    const onTime = () => {
      setTime(video.currentTime);
      if (video.buffered.length > 0) setBuffered(video.buffered.end(video.buffered.length - 1));
      const now = Date.now();
      if (now - saveTimer.current > 5000 && video.duration > 0) {
        saveTimer.current = now;
        try {
          localStorage.setItem(posKey(src), String(Math.floor(video.currentTime)));
        } catch {}
      }
    };
    video.addEventListener("timeupdate", onTime);
    video.addEventListener("error", () => fail("Stream nahi chal raha. Dusra channel try karo."));
    document.addEventListener("fullscreenchange", () => setTheater(document.fullscreenElement != null));

    video.addEventListener("loadedmetadata", onMeta);
    video.addEventListener("play", onPlay);
    video.addEventListener("pause", onPause);
    video.addEventListener("waiting", onWaiting);
    video.addEventListener("canplay", onCanPlay);
    video.addEventListener("loadstart", onLoadStart);
    video.addEventListener("volumechange", onVol);
    video.addEventListener("ratechange", onRate);
    video.addEventListener("timeupdate", onTime);
    video.addEventListener("error", () => fail("Stream nahi chal raha. Dusra channel try karo."));

    video.playsInline = true;
    if (video.canPlayType("application/vnd.apple.mpegurl")) {
      video.src = src;
      startPlayback();
    } else if (Hls.isSupported()) {
      const hls = new Hls({ maxBufferLength: 30 });
      hlsRef.current = hls;
      hls.on(Hls.Events.MANIFEST_PARSED, (_e, data) => {
        setLevels(data.levels.map((l, i) => ({ index: i, label: l.height ? `${l.height}p` : `${Math.round(l.bitrate / 1000)}k` })));
        startPlayback();
      });
      hls.on(Hls.Events.AUDIO_TRACKS_UPDATED, (_e, data) => setAudioCount(data.audioTracks.length));
      hls.on(Hls.Events.AUDIO_TRACK_SWITCHED, (_e, data) => setAudioTrack(data.id));
      hls.on(Hls.Events.ERROR, (_e, data) => {
        if (data.fatal) {
          fail("Stream nahi chal raha. Dusra channel try karo.");
        }
      });
      hls.loadSource(src);
      hls.attachMedia(video);
    } else {
      video.src = src;
      startPlayback();
    }
    poke();

    return () => {
      hlsRef.current?.destroy();
      hlsRef.current = null;
      video.removeEventListener("loadedmetadata", onMeta);
      video.removeEventListener("play", onPlay);
      video.removeEventListener("pause", onPause);
      video.removeEventListener("waiting", onWaiting);
      video.removeEventListener("canplay", onCanPlay);
      video.removeEventListener("loadstart", onLoadStart);
      video.removeEventListener("volumechange", onVol);
      video.removeEventListener("ratechange", onRate);
      video.removeEventListener("timeupdate", onTime);
      if (hideTimer.current) clearTimeout(hideTimer.current);
      try {
        localStorage.setItem(posKey(src), String(Math.floor(video.currentTime)));
      } catch {}
    };
  }, [src, poke]);

  function startPlayback() {
    const video = videoRef.current;
    if (!video) return;
    video.muted = false;
    video.play().catch(() => {
      video.muted = true;
      video.play().catch(() => {});
    });
  }

  function togglePlay() {
    const v = videoRef.current;
    if (!v) return;
    if (v.paused) v.play().catch(() => {});
    else v.pause();
    poke();
  }

  function toggleControls() {
    setControls((c) => {
      if (c) {
        if (hideTimer.current) clearTimeout(hideTimer.current);
        setMenu("none");
        return false;
      }
      poke();
      return true;
    });
  }

  function changeVolume(v: number) {
    const video = videoRef.current;
    if (!video) return;
    video.volume = v;
    video.muted = v === 0;
    poke();
  }

  function toggleMute() {
    const video = videoRef.current;
    if (!video) return;
    video.muted = !video.muted;
    if (!video.muted && video.volume === 0) video.volume = 1;
    poke();
  }

  function changeRate(r: number) {
    const video = videoRef.current;
    if (!video) return;
    video.playbackRate = r;
    setMenu("none");
    poke();
  }

  function changeQuality(i: number) {
    const hls = hlsRef.current;
    if (hls) hls.currentLevel = i;
    setQuality(i);
    setMenu("none");
    poke();
  }

  function changeAudio(i: number) {
    const hls = hlsRef.current;
    if (hls) hls.audioTrack = i;
    setMenu("none");
    poke();
  }

  function toggleFull() {
    const next = !theater;
    setTheater(next);
    setMenu("none");
    try {
      const o = screen.orientation as ScreenOrientation & { lock?: (o: string) => Promise<void>; unlock?: () => void };
      if (next) o.lock?.("landscape").catch(() => {});
      else o.unlock?.();
    } catch {}
    poke();
  }

  function togglePip() {
    const video = videoRef.current as HTMLVideoElement & { webkitSetPresentationMode?: (m: string) => void };
    if (!video) return;
    try {
      if (document.pictureInPictureElement) document.exitPictureInPicture().catch(() => {});
      else if (video.requestPictureInPicture) video.requestPictureInPicture().catch(() => {});
      else video.webkitSetPresentationMode?.("picture-in-picture");
    } catch {}
    poke();
  }

  function doResume() {
    const video = videoRef.current;
    if (!video) return;
    video.currentTime = Math.min(resumeAt, (video.duration || resumeAt + 1) - 5);
    setResumeAt(0);
    video.play().catch(() => {});
    poke();
  }

  const live = dur === 0 || !isFinite(dur);

  const land = theater && portrait && vp.w > 0;
  const shell = theater
    ? "fixed inset-0 z-[100] bg-black grid place-items-center overflow-hidden"
    : "relative w-full aspect-video bg-black overflow-hidden";
  const stage = land ? "shrink-0 rotate-90" : "w-full h-full";
  const stageStyle = land ? { width: vp.h, height: vp.w } : undefined;

  return (
    <div ref={wrapRef} className={`${shell} select-none`} onMouseMove={poke}>
      <div className={`relative ${stage} bg-black overflow-hidden`} style={stageStyle}>
      <video ref={videoRef} playsInline className="w-full h-full" onClick={toggleControls} />

      {loading && error === "" && (
        <div className="absolute inset-0 grid place-items-center pointer-events-none">
          <span className="w-16 h-16 rounded-full border-4 border-white/20 border-t-white animate-spin" />
        </div>
      )}

      {muted && playing && error === "" && (
        <button onClick={toggleMute} className="absolute top-3 right-3 flex items-center gap-2 bg-black/70 px-4 py-3 text-white text-lg font-bold" aria-label="Sound on karo">
          <VolumeX className="w-6 h-6" /> Sound On
        </button>
      )}

      {!playing && !loading && error === "" && (
        <button onClick={togglePlay} className="absolute inset-0 grid place-items-center" aria-label="Play">
          <span className="p-6 rounded-none bg-blue-600 text-white shadow-xl">
            <Play className="w-12 h-12 fill-current" />
          </span>
        </button>
      )}

      {resumeAt > 0 && error === "" && (
        <div className="absolute inset-x-0 bottom-24 flex justify-center pointer-events-none px-4">
          <div className="pointer-events-auto flex items-center gap-2 bg-black/80 p-2 pl-4 max-w-full">
            <span className="text-white text-lg font-semibold truncate">{fmt(resumeAt)} se dekho?</span>
            <button onClick={doResume} className="px-5 py-3 bg-blue-600 text-white text-lg font-bold shrink-0">Resume</button>
            <button onClick={() => setResumeAt(0)} className="p-3 text-white shrink-0" aria-label="Band karo">
              <X className="w-5 h-5" />
            </button>
          </div>
        </div>
      )}

      <div
        className={`absolute inset-x-0 bottom-0 transition-opacity ${controls ? "opacity-100" : "opacity-0 pointer-events-none"}`}
        onClick={(e) => e.stopPropagation()}
      >
        <div className="bg-gradient-to-t from-black/90 via-black/50 to-transparent px-3 sm:px-4 pt-8 pb-3">
          {!live && (
            <div className="flex items-center gap-3 text-white text-base font-semibold">
              <span>{fmt(time)}</span>
              <input
                type="range"
                min={0}
                max={dur || 0}
                step={1}
                value={Math.min(time, dur || 0)}
                onChange={(e) => {
                  const v = videoRef.current;
                  if (v) v.currentTime = Number(e.target.value);
                }}
                className="ftv-seek flex-1"
                aria-label="Seek"
              />
              <span>{fmt(dur)}</span>
            </div>
          )}
          {live && (
            <div className="h-1 rounded bg-white/20 overflow-hidden mb-2">
              <div className="h-full bg-red-600 animate-pulse w-full" />
            </div>
          )}
          <div className="flex items-center gap-1 sm:gap-2 text-white">
            <button onClick={togglePlay} className="p-3 min-w-[56px] min-h-[56px] grid place-items-center" aria-label={playing ? "Pause" : "Play"}>
              {playing ? <Pause className="w-7 h-7 fill-current" /> : <Play className="w-7 h-7 fill-current" />}
            </button>
            <button onClick={toggleMute} className="p-3 min-w-[56px] min-h-[56px] grid place-items-center" aria-label="Mute">
              {muted || volume === 0 ? <VolumeX className="w-6 h-6" /> : <Volume2 className="w-6 h-6" />}
            </button>
            <input
              type="range"
              min={0}
              max={1}
              step={0.05}
              value={muted ? 0 : volume}
              onChange={(e) => changeVolume(Number(e.target.value))}
              className="ftv-vol hidden sm:block w-24"
              aria-label="Volume"
            />
            <div className="flex-1" />
            <button onClick={() => setMenu(menu === "speed" ? "none" : "speed")} className="p-3 min-w-[56px] min-h-[56px] grid place-items-center relative" aria-label="Speed">
              <Gauge className="w-6 h-6" />
              <span className="absolute bottom-1 text-[10px] font-bold">{rate}x</span>
            </button>
            {levels.length > 1 && (
              <button onClick={() => setMenu(menu === "quality" ? "none" : "quality")} className="p-3 min-w-[56px] min-h-[56px] grid place-items-center" aria-label="Quality">
                <Layers className="w-6 h-6" />
              </button>
            )}
            {audioCount > 1 && (
              <button onClick={() => setMenu(menu === "audio" ? "none" : "audio")} className="p-3 min-w-[56px] min-h-[56px] grid place-items-center" aria-label="Audio">
                <Captions className="w-6 h-6" />
              </button>
            )}
            <button onClick={togglePip} className="p-3 min-w-[56px] min-h-[56px] hidden sm:grid place-items-center" aria-label="Picture in picture">
              <PictureInPicture2 className="w-6 h-6" />
            </button>
            <button onClick={toggleFull} className="p-3 min-w-[56px] min-h-[56px] grid place-items-center" aria-label="Fullscreen">
              {theater ? <Minimize className="w-6 h-6" /> : <Maximize className="w-6 h-6" />}
            </button>
          </div>
        </div>
      </div>

      {menu !== "none" && (
        <div className="absolute right-2 bottom-24 bg-black/90 p-2 min-w-[180px] max-w-[70%] max-h-[50%] overflow-auto" onClick={(e) => e.stopPropagation()}>
          {menu === "speed" &&
            RATES.map((r) => (
              <button key={r} onClick={() => changeRate(r)} className={`block w-full text-left px-4 py-3 text-white text-lg font-semibold ${r === rate ? "bg-blue-600" : ""}`}>
                {r}x
              </button>
            ))}
          {menu === "quality" && (
            <>
              <button onClick={() => changeQuality(-1)} className={`block w-full text-left px-4 py-3 text-white text-lg font-semibold ${quality === -1 ? "bg-blue-600" : ""}`}>
                Auto
              </button>
              {levels.map((l) => (
                <button key={l.index} onClick={() => changeQuality(l.index)} className={`block w-full text-left px-4 py-3 text-white text-lg font-semibold ${quality === l.index ? "bg-blue-600" : ""}`}>
                  {l.label}
                </button>
              ))}
            </>
          )}
          {menu === "audio" &&
            Array.from({ length: audioCount }).map((_, i) => (
              <button key={i} onClick={() => changeAudio(i)} className={`block w-full text-left px-4 py-3 text-white text-lg font-semibold ${audioTrack === i ? "bg-blue-600" : ""}`}>
                Audio {i + 1}
              </button>
            ))}
        </div>
      )}

      {error !== "" && (
        <div className="absolute inset-0 grid place-items-center bg-black/80 p-6 text-center">
          <p className="text-white text-lg font-semibold">{error}</p>
        </div>
      )}
      </div>
    </div>
  );
}
