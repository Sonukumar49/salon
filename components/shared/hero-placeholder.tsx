import { Button } from "@/components/ui/button";
import { siteConfig } from "@/lib/constants";

export function HeroPlaceholder() {
    return (
        <section className="mx-auto flex w-full max-w-5xl flex-1 flex-col justify-center px-5 pb-16 sm:px-8">
            <p className="mb-4 text-xs font-medium uppercase tracking-[0.2em] text-amber-800/80">
                Salon discovery, reimagined
            </p>
            <h1 className="max-w-2xl text-4xl font-semibold leading-[1.1] tracking-tight sm:text-6xl">
                {siteConfig.tagline}
            </h1>
            <p className="mt-5 max-w-xl text-base leading-relaxed text-stone-600 sm:text-lg">
                The closest salon isn&apos;t always the best fit. We help you find the one that matches your hair, your budget, and your style.
            </p>
            <div className="mt-8 flex flex-col gap-3 sm:flex-row">
                <Button size="lg" className="h-12 rounded-full bg-stone-900 px-8 hover:bg-stone-800">
                    Get started
                </Button>
                <Button size="lg" variant="outline" className="h-12 rounded-full border-stone-300 px-8">
                    How it works
                </Button>
            </div>
            <ul className="mt-12 flex flex-wrap gap-x-6 gap-y-2 text-sm text-stone-500">
                <li>Verified salons</li>
                <li>Transparent pricing</li>
                <li>Real reviews</li>
            </ul>
        </section>
    );
}