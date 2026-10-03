import { NextRequest, NextResponse } from "next/server";

function proxied(raw: string, base: string) {
  try {
    const abs = new URL(raw, base).toString();
    return `/api/stream?url=${encodeURIComponent(abs)}`;
  } catch {
    return raw;
  }
}

export async function GET(req: NextRequest) {
  const target = req.nextUrl.searchParams.get("url");
  if (!target) return new NextResponse("missing url", { status: 400 });
  let parsed: URL;
  try {
    parsed = new URL(target);
  } catch {
    return new NextResponse("bad url", { status: 400 });
  }
  if (parsed.protocol !== "http:" && parsed.protocol !== "https:") {
    return new NextResponse("bad protocol", { status: 400 });
  }
  let upstream: Response;
  try {
    upstream = await fetch(target, { headers: { "User-Agent": "IPTV-Player-Free/1.0" } });
  } catch {
    return new NextResponse("provider unreachable", { status: 502 });
  }
  if (!upstream.ok || !upstream.body) {
    return new NextResponse(`provider error ${upstream.status}`, { status: 502 });
  }
  const contentType = upstream.headers.get("content-type") ?? "";
  const isPlaylist = target.includes(".m3u8") || target.includes(".m3u") || contentType.includes("mpegurl") || contentType.includes("x-mpegurl");
  if (isPlaylist) {
    const text = await upstream.text();
    const out = text
      .split("\n")
      .map((line) => {
        if (line.trim() === "") return line;
        if (line.trim().startsWith("#")) {
          return line.replace(/URI="([^"]+)"/g, (_m, uri: string) => `URI="${proxied(uri, target)}"`);
        }
        return proxied(line.trim(), target);
      })
      .join("\n");
    return new NextResponse(out, {
      headers: {
        "content-type": "application/vnd.apple.mpegurl",
        "Access-Control-Allow-Origin": "*",
        "Cache-Control": "no-store",
      },
    });
  }
  return new NextResponse(upstream.body, {
    headers: {
      "content-type": contentType || "application/octet-stream",
      "Access-Control-Allow-Origin": "*",
      "Cache-Control": "no-store",
    },
  });
}
