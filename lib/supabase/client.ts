import { createBrowserClient } from "@supabase/ssr";
import { env } from "@/lib/env";
import type { Database } from "@/types/database";

/** Browser client. Use only in Client Components. */
export function createClient() {
    return createBrowserClient<Database>(env.supabaseUrl, env.supabaseAnonKey);
}