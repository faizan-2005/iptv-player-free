import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "IPTV Player Free",
  description: "Player only. Bring your own playlist."
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body>{children}</body>
    </html>
  );
}
