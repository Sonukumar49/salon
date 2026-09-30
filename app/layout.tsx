import type { Metadata, Viewport } from "next";
import { Geist } from "next/font/google";
import { siteConfig } from "@/lib/constants";
import "./globals.css";

const geist = Geist({ subsets: ["latin"], variable: "--font-sans" });
export const metadata: Metadata = {
  title: { default: `${siteConfig.name} — ${siteConfig.tagline}`, template: `%s | ${siteConfig.name}` },
  description: siteConfig.description,
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#faf8f5",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={geist.variable}>
      <body className="min-h-dvh bg-[#faf8f5] font-sans text-stone-900 antialiased">
        {children}
      </body>
    </html>
  );
}