import { Bricolage_Grotesque, DM_Sans, Gochi_Hand } from "next/font/google";
import "./globals.css";

const display = Bricolage_Grotesque({ subsets: ["latin"], variable: "--font-display", display: "swap" });
const body = DM_Sans({ subsets: ["latin"], variable: "--font-body", display: "swap" });
const hand = Gochi_Hand({ subsets: ["latin"], weight: "400", variable: "--font-hand", display: "swap" });

export const metadata = {
  title: "Story & Vídeo Maker",
  description: "Storymaker e videomaker: stories, reels e vídeos que contam a história da sua marca.",
};

export const viewport = { width: "device-width", initialScale: 1, viewportFit: "cover" };

export default function RootLayout({ children }) {
  return (
    <html lang="pt-BR" className={`${display.variable} ${body.variable} ${hand.variable}`}>
      <body>{children}</body>
    </html>
  );
}

