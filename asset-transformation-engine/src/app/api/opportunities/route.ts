import { opportunities } from "@/data/seed"; import { NextResponse } from "next/server";
export async function GET(){return NextResponse.json({data:opportunities,meta:{illustrative:true,count:opportunities.length}})}
