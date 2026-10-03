const isStatic = process.env.STATIC_EXPORT === "1";

/** @type {import('next').NextConfig} */
const nextConfig = {
  ...(isStatic ? { output: "export", basePath: "/iptv-player-free", images: { unoptimized: true } } : {}),
  reactStrictMode: true
};

export default nextConfig;
