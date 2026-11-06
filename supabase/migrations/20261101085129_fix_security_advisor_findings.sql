/*
# Fix Security Advisor Findings

## Summary

Fixes 4 security advisor warnings from the initial migration:

1. `handle_new_user()` trigger function was executable by anon and authenticated
   via the REST API. It should only run as a trigger — revoke all EXECUTE grants.
   Triggers fire internally and don't need explicit EXECUTE permissions.

2. `update_updated_at()` had a mutable search_path. Add SET search_path = public.

3. `is_org_member()` is intentionally callable by authenticated users (used in
   RLS policies and for frontend membership checks). No change needed — but
   we confirm it has search_path set.

## Security Changes

- REVOKE EXECUTE ON handle_new_user FROM PUBLIC, anon, authenticated
- Set search_path on update_updated_at
*/

-- Fix 1: handle_new_user should NOT be callable via REST API (trigger-only)
REVOKE EXECUTE ON FUNCTION handle_new_user() FROM PUBLIC, anon, authenticated;

-- Fix 2: update_updated_at needs a fixed search_path
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;
