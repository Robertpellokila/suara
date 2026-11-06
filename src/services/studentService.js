/**
 * Student service — Data API calls for classes, student_records, import_jobs.
 */
import { supabase } from '../lib/supabase'

// ── Classes ─────────────────────────────────────────────────────────────────

export async function fetchClasses(orgId) {
  const { data, error } = await supabase
    .from('classes')
    .select('id, name, grade, academic_year, status, created_at')
    .eq('organization_id', orgId)
    .eq('status', 'active')
    .order('name')
  if (error) throw error
  return data
}

export async function createClass(orgId, payload) {
  const { data, error } = await supabase
    .from('classes')
    .insert({ ...payload, organization_id: orgId })
    .select()
    .single()
  if (error) throw error
  return data
}

export async function updateClass(classId, payload) {
  const { data, error } = await supabase
    .from('classes')
    .update(payload)
    .eq('id', classId)
    .select()
    .single()
  if (error) throw error
  return data
}

// ── Student Records ──────────────────────────────────────────────────────────

export async function fetchStudents(orgId, { classId, search } = {}) {
  let query = supabase
    .from('student_records')
    .select(`
      id, student_identifier, full_name, grade, email,
      record_status, verification_status, linked_user_id, created_at,
      classes ( id, name )
    `)
    .eq('organization_id', orgId)
    .order('full_name')

  if (classId) query = query.eq('class_id', classId)
  if (search) query = query.ilike('full_name', `%${search}%`)

  const { data, error } = await query
  if (error) throw error
  return data
}

export async function createStudent(orgId, payload) {
  const { data, error } = await supabase
    .from('student_records')
    .insert({ ...payload, organization_id: orgId })
    .select()
    .single()
  if (error) throw error
  return data
}

export async function updateStudent(studentId, payload) {
  const { data, error } = await supabase
    .from('student_records')
    .update(payload)
    .eq('id', studentId)
    .select()
    .single()
  if (error) throw error
  return data
}

export async function fetchStudentCount(orgId) {
  const { count, error } = await supabase
    .from('student_records')
    .select('id', { count: 'exact', head: true })
    .eq('organization_id', orgId)
    .eq('record_status', 'active')
  if (error) throw error
  return count ?? 0
}

// ── Import Jobs ───────────────────────────────────────────────────────────────

export async function fetchImportJobs(orgId) {
  const { data, error } = await supabase
    .from('import_jobs')
    .select(`
      id, import_type, status, original_filename,
      total_rows, valid_rows, invalid_rows, imported_rows, skipped_rows,
      created_at, created_by,
      profiles:created_by ( display_name, email )
    `)
    .eq('organization_id', orgId)
    .order('created_at', { ascending: false })
    .limit(50)
  if (error) throw error
  return data
}

export async function createImportJob(orgId, payload) {
  const { data, error } = await supabase
    .from('import_jobs')
    .insert({ ...payload, organization_id: orgId })
    .select()
    .single()
  if (error) throw error
  return data
}
