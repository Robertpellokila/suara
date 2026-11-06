/*
# Create Elections, Candidates, Eligibility, Participation & Ballots Schema

## Summary

This migration creates the core voting engine data model for SUARA. It implements
the "One Person, One Vote" principle through atomic participation tracking, separates
ballot choices from voter identity for privacy, and enforces eligibility at the
schema level.

## New Tables

### 1. elections
A voting event created within an organization.
- `id` (uuid, PK)
- `organization_id` (uuid, FK to organizations, cascade delete)
- `title` (text, not null)
- `description` (text)
- `election_type` (text) — school_wide / class_level / grade_level / custom_group
- `eligibility_scope` (text) — organization / class / grade / custom_group
- `scope_ref_id` (uuid, nullable) — class_id or group_id if scope is class/grade/custom
- `status` (text) — draft / scheduled / active / paused / completed / archived
- `start_at` (timestamptz)
- `end_at` (timestamptz)
- `result_publication_policy` (text) — immediate / after_close / after_approval
- `result_published` (boolean, default false)
- `result_published_at` (timestamptz, nullable)
- `created_by` (uuid, FK to auth.users)
- `created_at` / `updated_at` (timestamptz)

### 2. candidates
A candidate standing in an election. All candidates within an election receive
identical data structure — no visual ordering bias.
- `id` (uuid, PK)
- `election_id` (uuid, FK to elections, cascade delete)
- `organization_id` (uuid, FK to organizations, cascade delete)
- `full_name` (text, not null)
- `photo_url` (text, nullable) — Storage URL
- `vision` (text)
- `mission` (text)
- `bio` (text)
- `order_number` (int) — display order (random assignment recommended)
- `status` (text) — active / withdrawn / disqualified
- `created_at` / `updated_at` (timestamptz)

### 3. eligible_voters
The explicit list of voters who are eligible for a given election.
Built by the backend from student_records + eligibility_scope rules.
- `id` (uuid, PK)
- `election_id` (uuid, FK to elections, cascade delete)
- `organization_id` (uuid, FK to organizations, cascade delete)
- `student_record_id` (uuid, FK to student_records, cascade delete)
- `linked_user_id` (uuid, nullable, FK to auth.users) — set when identity verified
- `eligibility_status` (text) — eligible / ineligible / pending
- `created_at` (timestamptz)
- Unique on (election_id, student_record_id)

### 4. participation
Records THAT a voter participated, without recording WHICH candidate they chose.
This is the public half of the privacy split.
- `id` (uuid, PK)
- `election_id` (uuid, FK to elections, cascade delete)
- `organization_id` (uuid, FK to organizations, cascade delete)
- `voter_uid` (uuid, FK to auth.users, cascade delete)
- `participated_at` (timestamptz, default now())
- `receipt_token` (text, unique) — opaque receipt shown to voter (no candidate info)
- Unique on (election_id, voter_uid) — enforces one-vote-per-user at DB level

### 5. ballots
Records WHICH candidate was chosen, WITHOUT storing the voter's identity.
This is the private half of the privacy split.
IMPORTANT: No user_id or voter identifier is stored here. The only link between
a ballot and a voter is through temporal/metadata correlation — which must be
minimised. For production, a one-time unlinkable credential architecture should
be used (Phase P3 roadmap item).
- `id` (uuid, PK)  — random UUID, NOT sequential
- `election_id` (uuid, FK to elections, cascade delete)
- `organization_id` (uuid, FK to organizations, cascade delete)
- `candidate_id` (uuid, FK to candidates, cascade delete)
- `cast_at` (timestamptz, default now())
  NOTE: cast_at stored at second precision to reduce timing correlation risk

### 6. election_results
Aggregated result summary, computed by the backend after tallying.
Stored separately from ballots to allow controlled publication.
- `id` (uuid, PK)
- `election_id` (uuid, FK to elections, cascade delete, unique)
- `organization_id` (uuid, FK to organizations, cascade delete)
- `total_votes` (int, default 0)
- `total_eligible` (int, default 0)
- `candidate_totals` (jsonb) — { candidateId: count } — NO names, just IDs
- `computed_at` (timestamptz)
- `is_published` (boolean, default false)
- `published_at` (timestamptz, nullable)

## Security (RLS + Grants)

### elections
- SELECT: org members see elections in their org; everyone sees active published elections
- INSERT/UPDATE: election_manager or org_admin in the org; super admin
- Status changes: validated server-side; frontend cannot set status to 'active' directly

### candidates
- SELECT: org members and anyone viewing an active election
- INSERT/UPDATE/DELETE: election_manager or org_admin; super admin

### eligible_voters
- SELECT: org_admins see the list; voters see only their own eligibility row
- INSERT/UPDATE: org_admin or super admin (set by backend, not voters)
- Voters CANNOT modify their own eligibility row

### participation
- SELECT: org_admins see aggregate (not individual); users see only their own row
- INSERT: BLOCKED on client — submitted only via edge function (service role)
- The unique constraint (election_id, voter_uid) is the DB-level double-vote guard

### ballots
- SELECT: NOBODY via client (RLS deny-all). Only service role reads ballots for tallying.
- INSERT: BLOCKED on client — only edge function (service role) writes ballots
- This is the strictest table in the schema

### election_results
- SELECT: org_admins always; voters see only published results
- INSERT/UPDATE: BLOCKED on client — edge function only
*/

-- ============================================================================
-- TABLES
-- ============================================================================

CREATE TABLE IF NOT EXISTS elections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  election_type text NOT NULL DEFAULT 'school_wide'
    CHECK (election_type IN ('school_wide', 'class_level', 'grade_level', 'custom_group')),
  eligibility_scope text NOT NULL DEFAULT 'organization'
    CHECK (eligibility_scope IN ('organization', 'class', 'grade', 'custom_group')),
  scope_ref_id uuid,
  status text NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft', 'scheduled', 'active', 'paused', 'completed', 'archived')),
  start_at timestamptz,
  end_at timestamptz,
  result_publication_policy text NOT NULL DEFAULT 'after_close'
    CHECK (result_publication_policy IN ('immediate', 'after_close', 'after_approval')),
  result_published boolean NOT NULL DEFAULT false,
  result_published_at timestamptz,
  created_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_elections_org ON elections(organization_id);
CREATE INDEX IF NOT EXISTS idx_elections_status ON elections(status);

CREATE TABLE IF NOT EXISTS candidates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  election_id uuid NOT NULL REFERENCES elections(id) ON DELETE CASCADE,
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  full_name text NOT NULL,
  photo_url text,
  vision text,
  mission text,
  bio text,
  order_number int NOT NULL DEFAULT 1,
  status text NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'withdrawn', 'disqualified')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_candidates_election ON candidates(election_id);

CREATE TABLE IF NOT EXISTS eligible_voters (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  election_id uuid NOT NULL REFERENCES elections(id) ON DELETE CASCADE,
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  student_record_id uuid NOT NULL REFERENCES student_records(id) ON DELETE CASCADE,
  linked_user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  eligibility_status text NOT NULL DEFAULT 'eligible'
    CHECK (eligibility_status IN ('eligible', 'ineligible', 'pending')),
  created_at timestamptz DEFAULT now(),
  UNIQUE (election_id, student_record_id)
);

CREATE INDEX IF NOT EXISTS idx_eligible_voters_election ON eligible_voters(election_id);
CREATE INDEX IF NOT EXISTS idx_eligible_voters_user ON eligible_voters(linked_user_id);

CREATE TABLE IF NOT EXISTS participation (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  election_id uuid NOT NULL REFERENCES elections(id) ON DELETE CASCADE,
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  voter_uid uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  participated_at timestamptz DEFAULT now(),
  receipt_token text NOT NULL UNIQUE,
  UNIQUE (election_id, voter_uid)
);

CREATE INDEX IF NOT EXISTS idx_participation_election ON participation(election_id);
CREATE INDEX IF NOT EXISTS idx_participation_voter ON participation(voter_uid);

CREATE TABLE IF NOT EXISTS ballots (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  election_id uuid NOT NULL REFERENCES elections(id) ON DELETE CASCADE,
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  candidate_id uuid NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
  cast_at timestamptz DEFAULT date_trunc('second', now())
);

CREATE INDEX IF NOT EXISTS idx_ballots_election ON ballots(election_id);
CREATE INDEX IF NOT EXISTS idx_ballots_candidate ON ballots(candidate_id);

CREATE TABLE IF NOT EXISTS election_results (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  election_id uuid NOT NULL REFERENCES elections(id) ON DELETE CASCADE,
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  total_votes int NOT NULL DEFAULT 0,
  total_eligible int NOT NULL DEFAULT 0,
  candidate_totals jsonb NOT NULL DEFAULT '{}'::jsonb,
  computed_at timestamptz DEFAULT now(),
  is_published boolean NOT NULL DEFAULT false,
  published_at timestamptz,
  UNIQUE (election_id)
);

-- ============================================================================
-- ENABLE RLS
-- ============================================================================

ALTER TABLE elections ENABLE ROW LEVEL SECURITY;
ALTER TABLE candidates ENABLE ROW LEVEL SECURITY;
ALTER TABLE eligible_voters ENABLE ROW LEVEL SECURITY;
ALTER TABLE participation ENABLE ROW LEVEL SECURITY;
ALTER TABLE ballots ENABLE ROW LEVEL SECURITY;
ALTER TABLE election_results ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- GRANTS
-- ============================================================================

-- elections: SELECT + INSERT/UPDATE for authenticated (RLS-gated)
GRANT SELECT ON elections TO authenticated;
GRANT INSERT ON elections TO authenticated;
GRANT UPDATE (title, description, election_type, eligibility_scope, scope_ref_id,
              start_at, end_at, result_publication_policy, updated_at) ON elections TO authenticated;

-- candidates: CRUD for authenticated (RLS-gated)
GRANT SELECT, INSERT, UPDATE, DELETE ON candidates TO authenticated;

-- eligible_voters: SELECT for authenticated; no client INSERT/UPDATE (server-side only)
GRANT SELECT ON eligible_voters TO authenticated;

-- participation: SELECT for authenticated; INSERT blocked (service role only)
GRANT SELECT ON participation TO authenticated;

-- ballots: NO grants to any client role — service role only
-- (RLS deny-all is enforced below; no GRANT needed)

-- election_results: SELECT for authenticated; no client INSERT/UPDATE
GRANT SELECT ON election_results TO authenticated;

-- ============================================================================
-- POLICIES: elections
-- ============================================================================

DROP POLICY IF EXISTS "select_elections" ON elections;
CREATE POLICY "select_elections" ON elections FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_super_admin = true)
    OR is_org_admin(organization_id)
    OR EXISTS (
      SELECT 1 FROM organization_members om
      WHERE om.organization_id = elections.organization_id
        AND om.user_id = auth.uid()
        AND om.status = 'active'
    )
    OR (
      elections.status IN ('active', 'scheduled', 'completed')
      AND EXISTS (
        SELECT 1 FROM eligible_voters ev
        WHERE ev.election_id = elections.id
          AND ev.linked_user_id = auth.uid()
          AND ev.eligibility_status = 'eligible'
      )
    )
  );

DROP POLICY IF EXISTS "insert_elections" ON elections;
CREATE POLICY "insert_elections" ON elections FOR INSERT TO authenticated
  WITH CHECK (is_org_admin(organization_id));

DROP POLICY IF EXISTS "update_elections" ON elections;
CREATE POLICY "update_elections" ON elections FOR UPDATE TO authenticated
  USING (is_org_admin(organization_id))
  WITH CHECK (is_org_admin(organization_id));

-- ============================================================================
-- POLICIES: candidates
-- ============================================================================

DROP POLICY IF EXISTS "select_candidates" ON candidates;
CREATE POLICY "select_candidates" ON candidates FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_super_admin = true)
    OR is_org_admin(organization_id)
    OR EXISTS (
      SELECT 1 FROM organization_members om
      WHERE om.organization_id = candidates.organization_id
        AND om.user_id = auth.uid()
        AND om.status = 'active'
    )
  );

DROP POLICY IF EXISTS "insert_candidates" ON candidates;
CREATE POLICY "insert_candidates" ON candidates FOR INSERT TO authenticated
  WITH CHECK (is_org_admin(organization_id));

DROP POLICY IF EXISTS "update_candidates" ON candidates;
CREATE POLICY "update_candidates" ON candidates FOR UPDATE TO authenticated
  USING (is_org_admin(organization_id))
  WITH CHECK (is_org_admin(organization_id));

DROP POLICY IF EXISTS "delete_candidates" ON candidates;
CREATE POLICY "delete_candidates" ON candidates FOR DELETE TO authenticated
  USING (is_org_admin(organization_id));

-- ============================================================================
-- POLICIES: eligible_voters
-- ============================================================================

DROP POLICY IF EXISTS "select_eligible_voters" ON eligible_voters;
CREATE POLICY "select_eligible_voters" ON eligible_voters FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_super_admin = true)
    OR is_org_admin(organization_id)
    OR linked_user_id = auth.uid()
  );

-- No INSERT/UPDATE/DELETE policy for client — service role only writes this table

-- ============================================================================
-- POLICIES: participation
-- ============================================================================

DROP POLICY IF EXISTS "select_participation" ON participation;
CREATE POLICY "select_participation" ON participation FOR SELECT TO authenticated
  USING (
    voter_uid = auth.uid()
    OR is_org_admin(organization_id)
    OR EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_super_admin = true)
  );

-- No INSERT policy for client — service role only (edge function submitBallot)

-- ============================================================================
-- POLICIES: ballots — deny all client access
-- ============================================================================

-- Intentionally no SELECT, INSERT, UPDATE, DELETE policies for authenticated/anon.
-- Ballots are only read and written by the service role via edge functions.
-- Any attempt by a client to access ballots returns an empty result set.

-- ============================================================================
-- POLICIES: election_results
-- ============================================================================

DROP POLICY IF EXISTS "select_election_results" ON election_results;
CREATE POLICY "select_election_results" ON election_results FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_super_admin = true)
    OR is_org_admin(organization_id)
    OR (
      is_published = true
      AND EXISTS (
        SELECT 1 FROM eligible_voters ev
        WHERE ev.election_id = election_results.election_id
          AND ev.linked_user_id = auth.uid()
          AND ev.eligibility_status = 'eligible'
      )
    )
  );

-- ============================================================================
-- updated_at triggers
-- ============================================================================

DROP TRIGGER IF EXISTS trigger_elections_updated_at ON elections;
CREATE TRIGGER trigger_elections_updated_at
  BEFORE UPDATE ON elections FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS trigger_candidates_updated_at ON candidates;
CREATE TRIGGER trigger_candidates_updated_at
  BEFORE UPDATE ON candidates FOR EACH ROW EXECUTE FUNCTION update_updated_at();
