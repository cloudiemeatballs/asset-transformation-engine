import { opportunities } from "@/data/seed"; import { NextResponse } from "next/server";
export async function GET(_:Request,{params}:{params:Promise<{slug:string}>}){const {slug}=await params;const item=opportunities.find(o=>o.slug===slug);return item?NextResponse.json({data:item}):NextResponse.json({error:"Not found"},{status:404})}
