import { createClient } from "@supabase/supabase-js";

const url = process.env.NEXT_PUBLIC_SUPABASE_URL ?? "";
const publishable = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY ?? "";
const legacy = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? "";
const key = publishable.length > 0 ? publishable : legacy;

export function supabaseEnabled() {
  return url.length > 0 && key.length > 0;
}

export function getSupabase() {
  if (!supabaseEnabled()) return null;
  return createClient(url, key);
}
