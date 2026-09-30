import { SiteHeader } from "@/components/shared/site-header";
import { HeroPlaceholder } from "@/components/shared/hero-placeholder";

export default function HomePage() {
  return (
    <div className="flex min-h-dvh flex-col">
      <SiteHeader />
      <main className="flex flex-1 flex-col">
        <HeroPlaceholder />
      </main>
    </div>
  );
}