import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

/**
 * Favorites store — tracks which election slugs the user has favorited.
 *
 * Phase 2 uses in-memory Pinia state only. When Supabase is wired in a later
 * phase, favorites will persist to a per-user table.
 */
export const useFavoritesStore = defineStore('favorites', () => {
  /** @type {import('vue').Ref<string[]>} */
  const favorites = ref([])

  /** @type {import('vue').ComputedRef<Set<string>>} */
  const favoriteSet = computed(() => new Set(favorites.value))

  const count = computed(() => favorites.value.length)

  function isFavorite(slug) {
    return favoriteSet.value.has(slug)
  }

  function toggle(slug) {
    if (favoriteSet.value.has(slug)) {
      favorites.value = favorites.value.filter((s) => s !== slug)
    } else {
      favorites.value = [...favorites.value, slug]
    }
  }

  function clear() {
    favorites.value = []
  }

  return {
    favorites,
    favoriteSet,
    count,
    isFavorite,
    toggle,
    clear,
  }
})
