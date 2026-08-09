export type HealthBody = {
  status: "ready" | "degraded" | "demo";
  application: "asset-transformation-engine";
  databaseConfigured: boolean;
  databaseReachable: boolean | null;
  authenticationRequired: boolean;
  schemaVersion: string | null;
  latencyMs: number | null;
  checkedAt: string;
};

type HealthInput = {
  databaseConfigured: boolean;
  databaseReachable?: boolean;
  schemaVersion?: string | null;
  latencyMs?: number;
};

export function buildHealthResponse(input: HealthInput): {
  body: HealthBody;
  httpStatus: 200 | 503;
} {
  const status = !input.databaseConfigured
    ? "demo"
    : input.databaseReachable
      ? "ready"
      : "degraded";

  return {
    body: {
      status,
      application: "asset-transformation-engine",
      databaseConfigured: input.databaseConfigured,
      databaseReachable: input.databaseConfigured
        ? Boolean(input.databaseReachable)
        : null,
      authenticationRequired: input.databaseConfigured,
      schemaVersion: input.schemaVersion ?? null,
      latencyMs: input.latencyMs ?? null,
      checkedAt: new Date().toISOString(),
    },
    httpStatus: status === "degraded" ? 503 : 200,
  };
}
