import { createClient } from '@supabase/supabase-js'

/**
 * Supabase client singleton.
 *
 * Reads VITE_-prefixed env vars that are injected at build time. The anon key
 * is safe for the frontend — all access control is enforced by RLS policies
 * and edge functions (which use the service role key server-side).
 */
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables. Check .env for VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY.')
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true,
  },
})
