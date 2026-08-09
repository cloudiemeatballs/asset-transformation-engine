import { buildFixtureResearchRun } from "@/research/fixtures"; import { NextResponse } from "next/server";
export async function GET(){return NextResponse.json({data:[await buildFixtureResearchRun()],meta:{fixtureProvider:true}})}
