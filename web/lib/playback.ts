const VERCEL_PROXY = "https://web-amber-one-93.vercel.app";
const isStatic = process.env.NEXT_PUBLIC_STATIC_EXPORT === "1";

const PROXY_BASE = isStatic ? VERCEL_PROXY : "";

export function proxyUrl(target: string) {
  return `${PROXY_BASE}/api/stream?url=${encodeURIComponent(target)}`;
}

export function playUrl(stream: string) {
  if (stream.startsWith("http")) return proxyUrl(stream);
  return stream;
}
