export const USE_PROXY = process.env.NEXT_PUBLIC_STATIC_EXPORT !== "1";

export function playUrl(stream: string) {
  if (USE_PROXY && stream.startsWith("http")) return `/api/stream?url=${encodeURIComponent(stream)}`;
  return stream;
}
