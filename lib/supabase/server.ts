import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import { env } from "@/lib/env";
import type { Database } from "@/types/database";

/** Server client. Use in Server Components, Route Handlers, and Server Actions. */
export async function createClient() {
    const cookieStore = await cookies();

    return createServerClient<Database>(env.supabaseUrl, env.supabaseAnonKey, {
        cookies: {
            getAll() {
                return cookieStore.getAll();
            },
            setAll(cookiesToSet) {
                try {
                    cookiesToSet.forEach(({ name, value, options }) =>
                        cookieStore.set(name, value, options)
                    );
                } catch {
                    // Called from a Server Component; safe to ignore.
                    // Session refresh will be handled by middleware in the auth step.
                }
            },
        },
    });
}