/*
# Create Classes, Student Records & Identity Verification Schema

## Summary

This migration adds the student and voter data model for SUARA's school pilot.
It creates tables for school classes, student roster records (imported by admins),
and identity verification linkages (connecting auth accounts to student records).

## New Tables

### 1. classes
Represents a school class (e.g. "Kelas 10A"). Scoped to an organization.
- `id` (uuid, PK)
- `organization_id` (uuid, FK to organizations, cascade delete)
- `name` (text) — e.g. "10A", "XII IPA 1"
- `grade` (text) — grade level, e.g. "10", "11", "12"
- `academic_year` (text) — e.g. "2026/2027"
- `status` (text) — active / archived
- `created_by` (uuid, FK to auth.users)
- `created_at` / `updated_at` (timestamptz)
- Unique on (organization_id, name, academic_year)

### 2. student_records
The official roster of students imported by org admins. This is NOT the auth
user — it represents the identity a student must prove ownership of before
getting voting rights. One student_record can be linked to at most one auth
account (after identity verification).
- `id` (uuid, PK)
- `organization_id` (uuid, FK to organizations, cascade delete)
- `class_id` (uuid, FK to classes, nullable, set null on delete)
- `student_identifier` (text) — NIS/NISN/custom school ID (stored as plain text
  here; higher-security needs would HMAC this; kept plain for the pilot)
- `full_name` (text, not null)
- `grade` (text)
- `email` (text, nullable) — school email if available
- `record_status` (text) — active / inactive / transferred
- `verification_status` (text) — unverified / verified / rejected
- `linked_user_id` (uuid, nullable, FK to auth.users) — set after identity
  verification links the student record to an auth account
- `import_job_id` (uuid, nullable) — which import created this record
- `created_at` / `updated_at` (timestamptz)
- Unique on (organization_id, student_identifier)

### 3. identity_verifications
Records an attempt by an auth user to claim ownership of a student_record.
Backend creates this after the user submits their student identifier; an admin
or automated check then approves or rejects it.
- `id` (uuid, PK)
- `user_id` (uuid, FK to auth.users, cascade delete)
- `organization_id` (uuid, FK to organizations, cascade delete)
- `student_record_id` (uuid, FK to student_records, cascade delete)
- `status` (text) — pending / approved / rejected
- `verification_method` (text) — school_email / invitation_code / admin_manual
- `reviewed_by` (uuid, FK to auth.users, nullable)
- `reviewed_at` (timestamptz, nullable)
- `notes` (text, nullable)
- `created_at` (timestamptz)

### 4. import_jobs
Tracks bulk student roster imports initiated by org admins.
- `id` (uuid, PK)
- `organization_id` (uuid, FK to organizations, cascade delete)
- `import_type` (text) — student_roster
- `status` (text) — pending / processing / completed / failed / partial
- `original_filename` (text)
- `total_rows` (int, default 0)
- `valid_rows` (int, default 0)
- `invalid_rows` (int, default 0)
- `imported_rows` (int, default 0)
- `skipped_rows` (int, default 0)
- `error_summary` (jsonb, default '{}') — per-row error details
- `column_mapping` (jsonb, default '{}') — header → field mapping used
- `created_by` (uuid, FK to auth.users)
- `created_at` / `updated_at` (timestamptz)

## Security (RLS + Grants)

### classes
- SELECT: org members (any role) can read classes in their org; super admins see all
- INSERT/UPDATE: org_admin (or higher) in the org; super admin
- DELETE: org_admin or super admin

### student_records
- SELECT: org_admins can read roster in their org; super admins; students CANNOT
  read other students' records — a student can only see their own linked record
- INSERT/UPDATE: org_admin or super admin (bulk import runs through service role)
- Users cannot write linked_user_id or verification_status directly
  (column-level grants exclude those fields)

### identity_verifications
- SELECT: users see their own; org_admins see verifications in their org; super admin
- INSERT: authenticated users (for their own user_id only)
- UPDATE: org_admins (to review/approve/reject); super admin

### import_jobs
- SELECT: org_admins in the org; super admins
- INSERT: org_admins; super admins
- No UPDATE/DELETE via Data API (status updated server-side via service role)

## Important Notes

1. student_records.linked_user_id and verification_status are excluded from the
   authenticated UPDATE grant — users cannot self-approve their own identity.

2. The import_jobs table tracks async import progress. Frontend polls status.

3. Privacy: students cannot enumerate the roster. They can only see the record
   linked to their own user_id.
*/

-- ============================================================================
-- TABLES
-- ============================================================================

CREATE TABLE IF NOT EXISTS classes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  name text NOT NULL,
  grade text,
  academic_year text NOT NULL DEFAULT '2026/2027',
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'archived')),
  created_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE (organization_id, name, academic_year)
);

CREATE INDEX IF NOT EXISTS idx_classes_org ON classes(organization_id);

CREATE TABLE IF NOT EXISTS student_records (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  class_id uuid REFERENCES classes(id) ON DELETE SET NULL,
  student_identifier text NOT NULL,
  full_name text NOT NULL,
  grade text,
  email text,
  record_status text NOT NULL DEFAULT 'active' CHECK (record_status IN ('active', 'inactive', 'transferred')),
  verification_status text NOT NULL DEFAULT 'unverified' CHECK (verification_status IN ('unverified', 'verified', 'rejected')),
  linked_user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  import_job_id uuid,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE (organization_id, student_identifier)
);

CREATE INDEX IF NOT EXISTS idx_student_records_org ON student_records(organization_id);
CREATE INDEX IF NOT EXISTS idx_student_records_class ON student_records(class_id);
CREATE INDEX IF NOT EXISTS idx_student_records_linked_user ON student_records(linked_user_id);

CREATE TABLE IF NOT EXISTS identity_verifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  student_record_id uuid NOT NULL REFERENCES student_records(id) ON DELETE CASCADE,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  verification_method text NOT NULL DEFAULT 'admin_manual' CHECK (verification_method IN ('school_email', 'invitation_code', 'admin_manual')),
  reviewed_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  reviewed_at timestamptz,
  notes text,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_identity_ver_user ON identity_verifications(user_id);
CREATE INDEX IF NOT EXISTS idx_identity_ver_org ON identity_verifications(organization_id);

CREATE TABLE IF NOT EXISTS import_jobs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  import_type text NOT NULL DEFAULT 'student_roster',
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'partial')),
  original_filename text,
  total_rows int NOT NULL DEFAULT 0,
  valid_rows int NOT NULL DEFAULT 0,
  invalid_rows int NOT NULL DEFAULT 0,
  imported_rows int NOT NULL DEFAULT 0,
  skipped_rows int NOT NULL DEFAULT 0,
  error_summary jsonb NOT NULL DEFAULT '[]'::jsonb,
  column_mapping jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_import_jobs_org ON import_jobs(organization_id);

-- ============================================================================
-- ENABLE RLS
-- ============================================================================

ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE identity_verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE import_jobs ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- GRANTS
-- ============================================================================

-- classes: full CRUD for authenticated (gated by RLS)
GRANT SELECT, INSERT, UPDATE, DELETE ON classes TO authenticated;

-- student_records: SELECT + limited update columns (excludes linked_user_id, verification_status)
GRANT SELECT ON student_records TO authenticated;
GRANT INSERT ON student_records TO authenticated;
GRANT UPDATE (class_id, full_name, grade, email, record_status, updated_at) ON student_records TO authenticated;

-- identity_verifications: users can submit; admins can review
GRANT SELECT, INSERT ON identity_verifications TO authenticated;
GRANT UPDATE (status, reviewed_by, reviewed_at, notes) ON identity_verifications TO authenticated;

-- import_jobs: org admins can read and create; status updates are service-role only
GRANT SELECT, INSERT ON import_jobs TO authenticated;

-- ============================================================================
-- HELPER: is_org_admin — checks admin/manager/super_admin membership
-- ============================================================================
CREATE OR REPLACE FUNCTION is_org_admin(p_org_id uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_super_admin = true
  )
  OR EXISTS (
    SELECT 1 FROM organization_members om
    WHERE om.organization_id = p_org_id
      AND om.user_id = auth.uid()
      AND om.status = 'active'
      AND om.role IN ('org_admin', 'election_manager')
  );
$$;

REVOKE EXECUTE ON FUNCTION is_org_admin(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION is_org_admin(uuid) TO authenticated;

-- ============================================================================
-- POLICIES: classes
-- ============================================================================

DROP POLICY IF EXISTS "select_classes" ON classes;
CREATE POLICY "select_classes" ON classes FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_super_admin = true)
    OR EXISTS (
      SELECT 1 FROM organization_members om
      WHERE om.organization_id = classes.organization_id
        AND om.user_id = auth.uid()
        AND om.status = 'active'
    )
  );

DROP POLICY IF EXISTS "insert_classes" ON classes;
CREATE POLICY "insert_classes" ON classes FOR INSERT TO authenticated
  WITH CHECK (is_org_admin(organization_id));

DROP POLICY IF EXISTS "update_classes" ON classes;
CREATE POLICY "update_classes" ON classes FOR UPDATE TO authenticated
  USING (is_org_admin(organization_id))
  WITH CHECK (is_org_admin(organization_id));

DROP POLICY IF EXISTS "delete_classes" ON classes;
CREATE POLICY "delete_classes" ON classes FOR DELETE TO authenticated
  USING (is_org_admin(organization_id));

-- ============================================================================
-- POLICIES: student_records
-- ============================================================================

-- SELECT: org_admins see all records in their org; students see only their own linked record
DROP POLICY IF EXISTS "select_student_records" ON student_records;
CREATE POLICY "select_student_records" ON student_records FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_super_admin = true)
    OR is_org_admin(organization_id)
    OR linked_user_id = auth.uid()
  );

DROP POLICY IF EXISTS "insert_student_records" ON student_records;
CREATE POLICY "insert_student_records" ON student_records FOR INSERT TO authenticated
  WITH CHECK (is_org_admin(organization_id));

DROP POLICY IF EXISTS "update_student_records" ON student_records;
CREATE POLICY "update_student_records" ON student_records FOR UPDATE TO authenticated
  USING (is_org_admin(organization_id))
  WITH CHECK (is_org_admin(organization_id));

-- ============================================================================
-- POLICIES: identity_verifications
-- ============================================================================

DROP POLICY IF EXISTS "select_identity_verifications" ON identity_verifications;
CREATE POLICY "select_identity_verifications" ON identity_verifications FOR SELECT TO authenticated
  USING (
    user_id = auth.uid()
    OR is_org_admin(organization_id)
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_super_admin = true)
  );

DROP POLICY IF EXISTS "insert_identity_verifications" ON identity_verifications;
CREATE POLICY "insert_identity_verifications" ON identity_verifications FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "update_identity_verifications" ON identity_verifications;
CREATE POLICY "update_identity_verifications" ON identity_verifications FOR UPDATE TO authenticated
  USING (is_org_admin(organization_id))
  WITH CHECK (is_org_admin(organization_id));

-- ============================================================================
-- POLICIES: import_jobs
-- ============================================================================

DROP POLICY IF EXISTS "select_import_jobs" ON import_jobs;
CREATE POLICY "select_import_jobs" ON import_jobs FOR SELECT TO authenticated
  USING (
    is_org_admin(organization_id)
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_super_admin = true)
  );

DROP POLICY IF EXISTS "insert_import_jobs" ON import_jobs;
CREATE POLICY "insert_import_jobs" ON import_jobs FOR INSERT TO authenticated
  WITH CHECK (is_org_admin(organization_id));

-- ============================================================================
-- updated_at triggers
-- ============================================================================

DROP TRIGGER IF EXISTS trigger_classes_updated_at ON classes;
CREATE TRIGGER trigger_classes_updated_at
  BEFORE UPDATE ON classes FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS trigger_student_records_updated_at ON student_records;
CREATE TRIGGER trigger_student_records_updated_at
  BEFORE UPDATE ON student_records FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS trigger_import_jobs_updated_at ON import_jobs;
CREATE TRIGGER trigger_import_jobs_updated_at
  BEFORE UPDATE ON import_jobs FOR EACH ROW EXECUTE FUNCTION update_updated_at();
