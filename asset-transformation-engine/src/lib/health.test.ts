import { describe, expect, it } from "vitest";
import { buildHealthResponse } from "./health";

describe("buildHealthResponse", () => {
  it("reports demo mode when Supabase is not configured", () => {
    const result = buildHealthResponse({ databaseConfigured: false });
    expect(result.httpStatus).toBe(200);
    expect(result.body).toMatchObject({
      status: "demo",
      databaseReachable: null,
      authenticationRequired: false,
    });
  });

  it("reports ready only after a successful database probe", () => {
    const result = buildHealthResponse({
      databaseConfigured: true,
      databaseReachable: true,
      schemaVersion: "0007",
      latencyMs: 42,
    });
    expect(result.httpStatus).toBe(200);
    expect(result.body).toMatchObject({
      status: "ready",
      databaseReachable: true,
      schemaVersion: "0007",
      latencyMs: 42,
    });
  });

  it("returns 503 when configuration exists but the database probe fails", () => {
    const result = buildHealthResponse({
      databaseConfigured: true,
      databaseReachable: false,
    });
    expect(result.httpStatus).toBe(503);
    expect(result.body.status).toBe("degraded");
  });
});
