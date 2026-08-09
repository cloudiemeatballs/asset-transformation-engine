import { families } from "@/data/seed"; import { NextResponse } from "next/server";
export async function GET(){return NextResponse.json({data:families,meta:{illustrative:true,count:families.length}})}
