"use client";

import Hls from "hls.js";
import { useEffect, useRef, useState } from "react";

export default function Player({ src }: { src: string }) {
  const ref = useRef<HTMLVideoElement>(null);
  const [error, setError] = useState("");

  useEffect(() => {
    const video = ref.current;
    if (!video || !src) return;
    setError("");
    video.srcObject = null;
    video.removeAttribute("src");
    if (video.canPlayType("application/vnd.apple.mpegurl")) {
      video.src = src;
      const onErr = () => setError("Stream failed to load. Provider may be offline or blocking this stream.");
      video.addEventListener("error", onErr);
      return () => video.removeEventListener("error", onErr);
    }
    if (Hls.isSupported()) {
      const hls = new Hls();
      hls.on(Hls.Events.ERROR, (_e, data) => {
        if (data.fatal) {
          setError(data.type === Hls.ErrorTypes.NETWORK_ERROR ? "Network blocked or provider offline. Try toggling Proxy." : "This stream cannot be played in browser.");
        }
      });
      hls.loadSource(src);
      hls.attachMedia(video);
      return () => hls.destroy();
    }
    video.src = src;
  }, [src]);

  return (
    <div>
      <video ref={ref} controls playsInline autoPlay muted className="w-full aspect-video rounded-xl bg-black" />
      {error !== "" && <p className="text-sm text-red-500 mt-2">{error}</p>}
    </div>
  );
}
