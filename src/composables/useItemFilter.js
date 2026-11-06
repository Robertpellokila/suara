import { ref, computed, watch } from 'vue'

/**
 * Composable for filtering a list of election items by search query and
 * optional status/type filters. Designed to be reused across views that
 * display election lists (Explore, Home, future admin dashboards).
 *
 * @param {import('vue').Ref<any[]>} source - reactive array of items
 * @param {Object} [options]
 * @param {string[]} [options.searchFields] - fields to match against the query
 * @returns {{ query, filtered, statusFilter, typeFilter, hasResults }}
 */
export function useItemFilter(source, options = {}) {
  const searchFields = options.searchFields ?? ['title', 'description', 'organization']

  const query = ref('')
  const statusFilter = ref('all')
  const typeFilter = ref('all')

  const filtered = computed(() => {
    let result = source.value

    if (query.value.trim()) {
      const q = query.value.trim().toLowerCase()
      result = result.filter((item) =>
        searchFields.some((field) => {
          const val = item[field]
          return typeof val === 'string' && val.toLowerCase().includes(q)
        }),
      )
    }

    if (statusFilter.value !== 'all') {
      result = result.filter((item) => item.status === statusFilter.value)
    }

    if (typeFilter.value !== 'all') {
      result = result.filter((item) => item.electionType === typeFilter.value)
    }

    return result
  })

  const hasResults = computed(() => filtered.value.length > 0)

  return {
    query,
    statusFilter,
    typeFilter,
    filtered,
    hasResults,
  }
}
