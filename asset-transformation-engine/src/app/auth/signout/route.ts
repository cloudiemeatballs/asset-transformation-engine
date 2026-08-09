import { NextResponse } from "next/server"; import { supabaseConfigured } from "@/lib/supabase/config"; import { createSupabaseServerClient } from "@/lib/supabase/server";
export async function POST(request:Request){if(supabaseConfigured()){const db=await createSupabaseServerClient();await db.auth.signOut()}return NextResponse.redirect(new URL("/",request.url),303)}
