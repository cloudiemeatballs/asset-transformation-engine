import { createClient } from "@supabase/supabase-js";
import { NextResponse } from "next/server";
import { buildHealthResponse } from "@/lib/health";
import { publicSupabaseConfig, supabaseConfigured } from "@/lib/supabase/config";

const DATABASE_TIMEOUT_MS = 5_000;

export async function GET() {
  const startedAt = Date.now();
  const databaseConfigured = supabaseConfigured();

  if (!databaseConfigured) {
    const result = buildHealthResponse({ databaseConfigured: false });
    return NextResponse.json(result.body, {
      status: result.httpStatus,
      headers: { "cache-control": "no-store" },
    });
  }

  let databaseReachable = false;
  let schemaVersion: string | null = null;

  try {
    const { url, key } = publicSupabaseConfig();
    const client = createClient(url, key, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), DATABASE_TIMEOUT_MS);
    const { data, error } = await client
      .rpc("operational_health")
      .abortSignal(controller.signal);
    clearTimeout(timeout);

    if (!error && data && typeof data === "object") {
      const payload = data as { database?: unknown; schemaVersion?: unknown };
      databaseReachable = payload.database === true;
      schemaVersion =
        typeof payload.schemaVersion === "string" ? payload.schemaVersion : null;
    }
  } catch {
    databaseReachable = false;
  }

  const result = buildHealthResponse({
    databaseConfigured,
    databaseReachable,
    schemaVersion,
    latencyMs: Date.now() - startedAt,
  });

  return NextResponse.json(result.body, {
    status: result.httpStatus,
    headers: { "cache-control": "no-store" },
  });
}
