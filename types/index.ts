import type { ReactNode } from "react";
import type { Database } from "@/types/database";

export type WithChildren = { children: ReactNode };

// ---- Database helpers (use these instead of importing from database.ts directly) ----
export type { Database, Json } from "@/types/database";

type PublicSchema = Database["public"];

/** Row type of a table, e.g. `Tables<"businesses">` */
export type Tables<T extends keyof PublicSchema["Tables"]> = PublicSchema["Tables"][T]["Row"];
/** Insert payload of a table, e.g. `TablesInsert<"favorites">` */
export type TablesInsert<T extends keyof PublicSchema["Tables"]> = PublicSchema["Tables"][T]["Insert"];
/** Update payload of a table, e.g. `TablesUpdate<"stylists">` */
export type TablesUpdate<T extends keyof PublicSchema["Tables"]> = PublicSchema["Tables"][T]["Update"];
/** Postgres enum, e.g. `Enums<"appointment_status">` */
export type Enums<T extends keyof PublicSchema["Enums"]> = PublicSchema["Enums"][T];