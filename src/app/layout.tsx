import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "P2P Storage Marketplace",
  description:
    "Rent spare garages, rooms and warehouse space from verified hosts across Nairobi and Mombasa.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen antialiased">
        <header className="border-b border-stone-200">
          <nav className="mx-auto flex max-w-5xl items-center justify-between px-4 py-4">
            <a className="text-lg font-semibold" href="/">
              P2P Storage
            </a>
          </nav>
        </header>
        <main className="mx-auto max-w-5xl px-4 py-10">{children}</main>
      </body>
    </html>
  );
}
