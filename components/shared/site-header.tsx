import { siteConfig } from "@/lib/constants";

export function SiteHeader() {
    return (
        <header className="mx-auto flex w-full max-w-5xl items-center justify-between px-5 py-5 sm:px-8">
            <span className="text-lg font-semibold tracking-tight">{siteConfig.name}</span>
        </header>
    );
}