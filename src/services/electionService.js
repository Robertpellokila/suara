/**
 * Election service — Data API calls for elections, candidates, eligible_voters.
 */
import { supabase } from '../lib/supabase'

// ── Elections ────────────────────────────────────────────────────────────────

export async function fetchElections(orgId) {
  const { data, error } = await supabase
    .from('elections')
    .select('id, title, description, election_type, eligibility_scope, status, start_at, end_at, result_published, created_at')
    .eq('organization_id', orgId)
    .order('created_at', { ascending: false })
  if (error) throw error
  return data
}

export async function fetchElectionById(electionId) {
  const { data, error } = await supabase
    .from('elections')
    .select(`
      id, title, description, election_type, eligibility_scope,
      scope_ref_id, status, start_at, end_at,
      result_publication_policy, result_published, result_published_at,
      created_at, organization_id
    `)
    .eq('id', electionId)
    .maybeSingle()
  if (error) throw error
  return data
}

export async function createElection(orgId, payload) {
  const { data, error } = await supabase
    .from('elections')
    .insert({ ...payload, organization_id: orgId })
    .select()
    .single()
  if (error) throw error
  return data
}

export async function updateElection(electionId, payload) {
  const { data, error } = await supabase
    .from('elections')
    .update(payload)
    .eq('id', electionId)
    .select()
    .single()
  if (error) throw error
  return data
}

export async function fetchMyEligibleElections(userId) {
  const { data, error } = await supabase
    .from('eligible_voters')
    .select(`
      eligibility_status,
      elections (
        id, title, description, election_type, status,
        start_at, end_at, result_published,
        organizations ( id, name, type )
      )
    `)
    .eq('linked_user_id', userId)
    .eq('eligibility_status', 'eligible')
  if (error) throw error
  return (data ?? [])
    .map((row) => ({ ...row.elections, eligibility_status: row.eligibility_status }))
    .filter(Boolean)
}

// ── Candidates ───────────────────────────────────────────────────────────────

export async function fetchCandidates(electionId) {
  const { data, error } = await supabase
    .from('candidates')
    .select('id, full_name, photo_url, vision, mission, bio, order_number, status')
    .eq('election_id', electionId)
    .eq('status', 'active')
    .order('order_number')
  if (error) throw error
  return data
}

export async function createCandidate(electionId, orgId, payload) {
  const { data, error } = await supabase
    .from('candidates')
    .insert({ ...payload, election_id: electionId, organization_id: orgId })
    .select()
    .single()
  if (error) throw error
  return data
}

export async function updateCandidate(candidateId, payload) {
  const { data, error } = await supabase
    .from('candidates')
    .update(payload)
    .eq('id', candidateId)
    .select()
    .single()
  if (error) throw error
  return data
}

export async function deleteCandidate(candidateId) {
  const { error } = await supabase.from('candidates').delete().eq('id', candidateId)
  if (error) throw error
}

// ── Eligible Voters ──────────────────────────────────────────────────────────

export async function fetchEligibleVoterCount(electionId) {
  const { count, error } = await supabase
    .from('eligible_voters')
    .select('id', { count: 'exact', head: true })
    .eq('election_id', electionId)
    .eq('eligibility_status', 'eligible')
  if (error) throw error
  return count ?? 0
}

export async function fetchParticipationCount(electionId) {
  const { count, error } = await supabase
    .from('participation')
    .select('id', { count: 'exact', head: true })
    .eq('election_id', electionId)
  if (error) throw error
  return count ?? 0
}

// ── Results ──────────────────────────────────────────────────────────────────

export async function fetchElectionResults(electionId) {
  const { data, error } = await supabase
    .from('election_results')
    .select('*')
    .eq('election_id', electionId)
    .maybeSingle()
  if (error) throw error
  return data
}
