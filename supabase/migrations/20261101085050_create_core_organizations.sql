/*
# Create Core Organization & Membership Schema

## Summary

This migration establishes the foundational multi-tenant architecture for SUARA,
a digital voting platform. It creates the tables needed for user profiles,
organization registry, and organization membership — all with row-level security
to enforce tenant isolation.

## New Tables

### 1. profiles
- `id` (uuid, PK, references auth.users) — one-to-one with Supabase Auth users
- `display_name` (text) — user's display name
- `email` (text) — copied from auth.users for convenience
- `account_status` (text, default 'active') — active / suspended / pending
- `is_super_admin` (boolean, default false) — platform-level super admin flag
- `created_at` / `updated_at` (timestamptz)

### 2. organizations
- `id` (uuid, PK)
- `name` (text, not null) — organization display name
- `type` (text, not null, default 'school') — school / campus / community / organization
- `status` (text, not null, default 'pending') — pending / verified / suspended
- `verified_at` (timestamptz, nullable) — when super admin verified the org
- `created_by` (uuid, references auth.users) — who created the org
- `created_at` / `updated_at` (timestamptz)

### 3. organization_members
- `id` (uuid, PK)
- `organization_id` (uuid, FK to organizations, cascade delete)
- `user_id` (uuid, FK to auth.users, cascade delete)
- `role` (text, not null, default 'voter') — super_admin / org_admin / election_manager / class_coordinator / voter
- `status` (text, not null, default 'active') — active / suspended / revoked
- `permissions` (jsonb, default '{}') — extensible permission map
- `created_at` / `updated_at` (timestamptz)
- Unique constraint on (organization_id, user_id)

### 4. audit_logs
- `id` (uuid, PK)
- `organization_id` (uuid, FK to organizations, nullable, cascade delete)
- `actor_uid` (uuid, FK to auth.users, nullable)
- `action` (text, not null)
- `target_type` (text)
- `target_id` (uuid, nullable)
- `metadata` (jsonb, default '{}')
- `created_at` (timestamptz)

## Security (RLS + Grants)

### profiles
- SELECT: users read only their own profile; super admins read all
- UPDATE: users update own profile only; is_super_admin column excluded from
  the Data API UPDATE grant — users cannot self-escalate

### organizations
- SELECT: super admins see all; org members see their own orgs; others see
  verified orgs only (public listing)
- INSERT/UPDATE: super admins only

### organization_members
- SELECT: super admins see all; users see own memberships; org_admins see
  members of their org
- INSERT/UPDATE/DELETE: super admins only

### audit_logs
- SELECT: super admins see all; org members see logs for their org
- INSERT: authenticated users (actor must be current user)
- No UPDATE or DELETE — audit logs are immutable

## Important Notes

1. is_super_admin is NOT writable by users through the Data API. Only the
   service role (edge functions) or a SQL migration can set it.

2. Organization verification is a super-admin-only operation.

3. The handle_new_user trigger auto-creates a profile row on signup.

4. The is_org_member helper function is used by future child-table RLS policies.
*/

-- ============================================================================
-- TABLES (created first, before any policies that cross-reference them)
-- ============================================================================

CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name text DEFAULT '',
  email text DEFAULT '',
  account_status text NOT NULL DEFAULT 'active' CHECK (account_status IN ('active', 'suspended', 'pending')),
  is_super_admin boolean NOT NULL DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS organizations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  type text NOT NULL DEFAULT 'school' CHECK (type IN ('school', 'campus', 'community', 'organization')),
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'verified', 'suspended')),
  verified_at timestamptz,
  created_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_organizations_status ON organizations(status);
CREATE INDEX IF NOT EXISTS idx_organizations_type ON organizations(type);

CREATE TABLE IF NOT EXISTS organization_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role text NOT NULL DEFAULT 'voter' CHECK (role IN ('super_admin', 'org_admin', 'election_manager', 'class_coordinator', 'voter')),
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'revoked')),
  permissions jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE (organization_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_org_members_org ON organization_members(organization_id);
CREATE INDEX IF NOT EXISTS idx_org_members_user ON organization_members(user_id);

CREATE TABLE IF NOT EXISTS audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid REFERENCES organizations(id) ON DELETE CASCADE,
  actor_uid uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  action text NOT NULL,
  target_type text,
  target_id uuid,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_audit_logs_org ON audit_logs(organization_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action);

-- ============================================================================
-- ENABLE RLS ON ALL TABLES
-- ============================================================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- GRANTS
-- ============================================================================

-- profiles: SELECT to authenticated; UPDATE excluding is_super_admin
GRANT SELECT ON profiles TO authenticated;
GRANT UPDATE (display_name, email, account_status, updated_at) ON profiles TO authenticated;

-- organizations: SELECT to authenticated; INSERT/UPDATE to authenticated (gated by RLS)
GRANT SELECT ON organizations TO authenticated;
GRANT INSERT, UPDATE ON organizations TO authenticated;

-- organization_members: SELECT to authenticated; INSERT/UPDATE/DELETE to authenticated (gated by RLS)
GRANT SELECT ON organization_members TO authenticated;
GRANT INSERT, UPDATE, DELETE ON organization_members TO authenticated;

-- audit_logs: SELECT and INSERT to authenticated
GRANT SELECT ON audit_logs TO authenticated;
GRANT INSERT ON audit_logs TO authenticated;

-- ============================================================================
-- POLICIES (after all tables exist so cross-references resolve)
-- ============================================================================

-- profiles SELECT
DROP POLICY IF EXISTS "select_own_profile" ON profiles;
CREATE POLICY "select_own_profile"
  ON profiles FOR SELECT TO authenticated
  USING (
    auth.uid() = id
    OR EXISTS (
      SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_super_admin = true
    )
  );

-- profiles UPDATE (own profile only, NOT is_super_admin via column grant)
DROP POLICY IF EXISTS "update_own_profile" ON profiles;
CREATE POLICY "update_own_profile"
  ON profiles FOR UPDATE TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- organizations SELECT
DROP POLICY IF EXISTS "select_organizations" ON organizations;
CREATE POLICY "select_organizations"
  ON organizations FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_super_admin = true)
    OR EXISTS (
      SELECT 1 FROM organization_members om
      WHERE om.organization_id = organizations.id
        AND om.user_id = auth.uid()
        AND om.status = 'active'
    )
    OR organizations.status = 'verified'
  );

-- organizations INSERT (super admin only)
DROP POLICY IF EXISTS "insert_organizations" ON organizations;
CREATE POLICY "insert_organizations"
  ON organizations FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_super_admin = true)
  );

-- organizations UPDATE (super admin only)
DROP POLICY IF EXISTS "update_organizations" ON organizations;
CREATE POLICY "update_organizations"
  ON organizations FOR UPDATE TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_super_admin = true)
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_super_admin = true)
  );

-- organization_members SELECT
DROP POLICY IF EXISTS "select_org_members" ON organization_members;
CREATE POLICY "select_org_members"
  ON organization_members FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_super_admin = true)
    OR organization_members.user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM organization_members om2
      WHERE om2.organization_id = organization_members.organization_id
        AND om2.user_id = auth.uid()
        AND om2.role = 'org_admin'
        AND om2.status = 'active'
    )
  );

-- organization_members INSERT (super admin only)
DROP POLICY IF EXISTS "insert_org_members" ON organization_members;
CREATE POLICY "insert_org_members"
  ON organization_members FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_super_admin = true)
  );

-- organization_members UPDATE (super admin only)
DROP POLICY IF EXISTS "update_org_members" ON organization_members;
CREATE POLICY "update_org_members"
  ON organization_members FOR UPDATE TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_super_admin = true)
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_super_admin = true)
  );

-- organization_members DELETE (super admin only)
DROP POLICY IF EXISTS "delete_org_members" ON organization_members;
CREATE POLICY "delete_org_members"
  ON organization_members FOR DELETE TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_super_admin = true)
  );

-- audit_logs SELECT
DROP POLICY IF EXISTS "select_audit_logs" ON audit_logs;
CREATE POLICY "select_audit_logs"
  ON audit_logs FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_super_admin = true)
    OR (
      audit_logs.organization_id IS NOT NULL
      AND EXISTS (
        SELECT 1 FROM organization_members om
        WHERE om.organization_id = audit_logs.organization_id
          AND om.user_id = auth.uid()
          AND om.status = 'active'
      )
    )
  );

-- audit_logs INSERT (actor must be current user)
DROP POLICY IF EXISTS "insert_audit_logs" ON audit_logs;
CREATE POLICY "insert_audit_logs"
  ON audit_logs FOR INSERT TO authenticated
  WITH CHECK (actor_uid = auth.uid());

-- ============================================================================
-- HELPER FUNCTION: is_org_member
-- ============================================================================
CREATE OR REPLACE FUNCTION is_org_member(
  p_org_id uuid,
  p_role_filter text DEFAULT NULL
)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM organization_members om
    JOIN profiles p ON p.id = om.user_id
    WHERE om.organization_id = p_org_id
      AND om.user_id = auth.uid()
      AND om.status = 'active'
      AND (
        p_role_filter IS NULL
        OR om.role = p_role_filter
        OR om.role = 'super_admin'
      )
  )
  OR EXISTS (
    SELECT 1 FROM profiles p
    WHERE p.id = auth.uid() AND p.is_super_admin = true
  );
$$;

REVOKE EXECUTE ON FUNCTION is_org_member(uuid, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION is_org_member(uuid, text) TO authenticated;

-- ============================================================================
-- TRIGGER: auto-create profile on user signup
-- ============================================================================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
    NEW.email
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================================================
-- updated_at triggers
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_profiles_updated_at ON profiles;
CREATE TRIGGER trigger_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS trigger_organizations_updated_at ON organizations;
CREATE TRIGGER trigger_organizations_updated_at
  BEFORE UPDATE ON organizations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS trigger_org_members_updated_at ON organization_members;
CREATE TRIGGER trigger_org_members_updated_at
  BEFORE UPDATE ON organization_members
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
