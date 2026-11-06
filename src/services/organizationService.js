/**
 * Organization service — Data API calls for the organizations table.
 * All authorization is enforced server-side by RLS.
 */
import { supabase } from '../lib/supabase'

export async function fetchMyOrganizations() {
  const { data, error } = await supabase
    .from('organizations')
    .select('id, name, type, status, verified_at, created_at')
    .order('created_at', { ascending: false })
  if (error) throw error
  return data
}

export async function fetchAllOrganizations() {
  const { data, error } = await supabase
    .from('organizations')
    .select('id, name, type, status, verified_at, created_at, created_by')
    .order('created_at', { ascending: false })
  if (error) throw error
  return data
}

export async function createOrganization(payload) {
  const { data, error } = await supabase
    .from('organizations')
    .insert(payload)
    .select()
    .single()
  if (error) throw error
  return data
}

export async function updateOrganizationStatus(orgId, status) {
  const updates = { status }
  if (status === 'verified') updates.verified_at = new Date().toISOString()
  const { data, error } = await supabase
    .from('organizations')
    .update(updates)
    .eq('id', orgId)
    .select()
    .single()
  if (error) throw error
  return data
}

export async function fetchOrgMembers(orgId) {
  const { data, error } = await supabase
    .from('organization_members')
    .select(`
      id, role, status, created_at,
      profiles ( id, display_name, email )
    `)
    .eq('organization_id', orgId)
    .order('created_at', { ascending: false })
  if (error) throw error
  return data
}

export async function assignOrgMember(orgId, userId, role) {
  const { data, error } = await supabase
    .from('organization_members')
    .upsert({ organization_id: orgId, user_id: userId, role, status: 'active' }, {
      onConflict: 'organization_id,user_id',
    })
    .select()
    .single()
  if (error) throw error
  return data
}
