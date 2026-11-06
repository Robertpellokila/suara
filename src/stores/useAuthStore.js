import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { supabase } from '../lib/supabase'

/**
 * Auth store — manages the current user's session, profile, and organization
 * memberships.
 *
 * Data flow:
 * 1. User signs up / logs in via Supabase Auth (email/password).
 * 2. The handle_new_user trigger creates a profile row automatically.
 * 3. This store loads the profile + organization_memberships after auth.
 * 4. Route guards and the header use this store to show/hide UI.
 *
 * Authorization is ALWAYS enforced server-side by RLS. This store only reflects
 * what the backend allows — it does not grant access on its own.
 */
export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const profile = ref(null)
  const memberships = ref([])
  const loading = ref(true)
  const error = ref(null)

  const isAuthenticated = computed(() => !!user.value)
  const isSuperAdmin = computed(() => !!profile.value?.is_super_admin)
  const displayName = computed(() => profile.value?.display_name || user.value?.email?.split('@')[0] || '')
  const initials = computed(() => {
    const name = displayName.value
    if (!name) return '?'
    const parts = name.split(' ').filter(Boolean)
    if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase()
    return name.slice(0, 2).toUpperCase()
  })

  const activeOrgs = computed(() =>
    memberships.value.filter((m) => m.status === 'active')
  )

  /**
   * Fetch the user's profile and organization memberships from the database.
   * Called after auth state changes.
   */
  async function loadUserData() {
    if (!user.value) {
      profile.value = null
      memberships.value = []
      return
    }

    try {
      const [profileRes, memberRes] = await Promise.all([
        supabase
          .from('profiles')
          .select('id, display_name, email, account_status, is_super_admin')
          .eq('id', user.value.id)
          .maybeSingle(),
        supabase
          .from('organization_members')
          .select(`
            id,
            organization_id,
            role,
            status,
            permissions,
            organizations ( id, name, type, status )
          `)
          .eq('user_id', user.value.id),
      ])

      if (profileRes.error) throw profileRes.error
      if (memberRes.error) throw memberRes.error

      profile.value = profileRes.data
      memberships.value = memberRes.data || []
    } catch (err) {
      error.value = err.message
      profile.value = null
      memberships.value = []
    }
  }

  /**
   * Initialize the auth store — restores session on page load.
   * Must be called once from main.js or App.vue onMounted.
   */
  async function init() {
    loading.value = true
    try {
      const { data: { session } } = await supabase.auth.getSession()
      user.value = session?.user || null
      if (user.value) await loadUserData()
    } catch (err) {
      error.value = err.message
    } finally {
      loading.value = false
    }

    // Listen for auth state changes — wrap async in IIFE to avoid deadlock
    supabase.auth.onAuthStateChange((_event, session) => {
      (async () => {
        user.value = session?.user || null
        if (user.value) {
          await loadUserData()
        } else {
          profile.value = null
          memberships.value = []
        }
        loading.value = false
      })()
    })
  }

  async function signUp(email, password, displayName) {
    error.value = null
    try {
      const { data, error: signUpError } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: { display_name: displayName },
        },
      })
      if (signUpError) throw signUpError
      return { data, error: null }
    } catch (err) {
      error.value = err.message
      return { data: null, error: err }
    }
  }

  async function signIn(email, password) {
    error.value = null
    try {
      const { data, error: signInError } = await supabase.auth.signInWithPassword({
        email,
        password,
      })
      if (signInError) throw signInError
      user.value = data.user
      await loadUserData()
      return { data, error: null }
    } catch (err) {
      error.value = err.message
      return { data: null, error: err }
    }
  }

  async function signOut() {
    error.value = null
    try {
      const { error: signOutError } = await supabase.auth.signOut()
      if (signOutError) throw signOutError
      user.value = null
      profile.value = null
      memberships.value = []
    } catch (err) {
      error.value = err.message
    }
  }

  async function updateDisplayName(newName) {
    if (!user.value) return
    try {
      const { error: updateError } = await supabase
        .from('profiles')
        .update({ display_name: newName })
        .eq('id', user.value.id)
      if (updateError) throw updateError
      profile.value = { ...profile.value, display_name: newName }
    } catch (err) {
      error.value = err.message
    }
  }

  return {
    user,
    profile,
    memberships,
    loading,
    error,
    isAuthenticated,
    isSuperAdmin,
    displayName,
    initials,
    activeOrgs,
    init,
    signUp,
    signIn,
    signOut,
    updateDisplayName,
  }
})
