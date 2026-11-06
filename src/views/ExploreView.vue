<script setup>
/**
 * ExploreView — shows only the elections the current user is eligible for.
 *
 * Phase 2: displays mock eligible items with search/filter. In production this
 * list comes from a backend call that checks identity verification, org
 * membership, and event eligibility — NOT a public catalog of all events.
 *
 * If the user is not logged in or not verified, an appropriate empty state is
 * shown.
 */
import { computed, ref } from 'vue'
import { getEligibleItems, electionStatuses, electionTypes } from '../data/items'
import { useItemFilter } from '../composables/useItemFilter'
import SearchBar from '../shared/SearchBar.vue'
import ItemCard from '../shared/ItemCard.vue'
import EmptyState from '../shared/EmptyState.vue'

// Phase 2 mock: simulate a logged-in, verified user
const isLoggedIn = ref(true)
const isVerified = ref(true)

const eligibleItems = computed(() => getEligibleItems())

const { query, filtered, hasResults, statusFilter, typeFilter } = useItemFilter(
  eligibleItems,
  { searchFields: ['title', 'description', 'organization'] },
)

const statusOptions = [
  { value: 'all', label: 'Semua Status' },
  { value: electionStatuses.ACTIVE, label: 'Aktif' },
  { value: electionStatuses.SCHEDULED, label: 'Terjadwal' },
  { value: electionStatuses.COMPLETED, label: 'Selesai' },
]

const typeOptions = [
  { value: 'all', label: 'Semua Jenis' },
  { value: electionTypes.SCHOOL_WIDE, label: 'Sekolah' },
  { value: electionTypes.CLASS_LEVEL, label: 'Kelas' },
  { value: electionTypes.GRADE_LEVEL, label: 'Angkatan' },
  { value: electionTypes.CUSTOM_GROUP, label: 'Grup Khusus' },
]
</script>

<template>
  <div class="explore">
    <div class="container">
      <header class="explore__header">
        <h1 class="explore__title">Pemilihan Tersedia</h1>
        <p class="explore__subtitle">
          Hanya pemilihan yang Anda berhak ikuti yang ditampilkan di sini.
        </p>
      </header>

      <!-- Not logged in / not verified state -->
      <EmptyState
        v-if="!isLoggedIn"
        title="Anda belum masuk"
        message="Masuk untuk melihat pemilihan yang tersedia untuk Anda."
      />
      <EmptyState
        v-else-if="!isVerified"
        title="Identitas belum terverifikasi"
        message="Verifikasi identitas Anda terlebih dahulu untuk melihat pemilihan yang berhak Anda ikuti."
      />

      <template v-else>
        <!-- Filters -->
        <div class="explore__filters">
          <SearchBar v-model="query" placeholder="Cari pemilihan, organisasi…" />
          <div class="explore__selects">
            <label class="filter-select">
              <span class="sr-only">Filter berdasarkan status</span>
              <select v-model="statusFilter" aria-label="Filter berdasarkan status">
                <option v-for="opt in statusOptions" :key="opt.value" :value="opt.value">
                  {{ opt.label }}
                </option>
              </select>
            </label>
            <label class="filter-select">
              <span class="sr-only">Filter berdasarkan jenis</span>
              <select v-model="typeFilter" aria-label="Filter berdasarkan jenis">
                <option v-for="opt in typeOptions" :key="opt.value" :value="opt.value">
                  {{ opt.label }}
                </option>
              </select>
            </label>
          </div>
        </div>

        <!-- Results count -->
        <p class="explore__count" v-if="hasResults">
          {{ filtered.length }} pemilihan ditemukan
        </p>

        <!-- Grid -->
        <div v-if="hasResults" class="explore__grid">
          <ItemCard
            v-for="item in filtered"
            :key="item.slug"
            :item="item"
          />
        </div>

        <!-- Empty search -->
        <EmptyState
          v-else
          title="Tidak ada pemilihan ditemukan"
          message="Coba ubah kata kunci pencarian atau filter Anda."
        />
      </template>
    </div>
  </div>
</template>

<style scoped>
.explore {
  padding: var(--space-8) 0 var(--space-16);
  min-height: 60vh;
}

.explore__header {
  text-align: center;
  margin-bottom: var(--space-8);
}

.explore__title {
  font-size: var(--fs-3xl);
  font-weight: var(--fw-bold);
  margin-bottom: var(--space-2);
}

.explore__subtitle {
  color: var(--color-text-secondary);
  font-size: var(--fs-lg);
}

.explore__filters {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
  margin-bottom: var(--space-6);
}

.explore__selects {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-3);
}

.filter-select {
  flex: 1;
  min-width: 140px;
}

.filter-select select {
  width: 100%;
  min-height: 48px;
  padding: 0 var(--space-4);
  font-size: var(--fs-base);
  color: var(--color-text-primary);
  background: var(--color-surface);
  border: 1.5px solid var(--color-border);
  border-radius: var(--radius-lg);
  cursor: pointer;
  appearance: none;
  -webkit-appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='none' stroke='%2364748B' stroke-width='2'%3E%3Cpath d='M4 6l4 4 4-4'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 16px center;
  padding-right: var(--space-10);
}

.filter-select select:focus {
  border-color: var(--color-primary-500);
  box-shadow: 0 0 0 3px var(--color-primary-100);
  outline: none;
}

.explore__count {
  font-size: var(--fs-sm);
  color: var(--color-text-secondary);
  margin-bottom: var(--space-4);
}

.explore__grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: var(--space-5);
}

@media (min-width: 640px) {
  .explore__grid { grid-template-columns: repeat(2, 1fr); }
}

@media (min-width, 1024px) {
  .explore__grid { grid-template-columns: repeat(3, 1fr); }
}

@media (min-width: 768px) {
  .explore__filters {
    flex-direction: row;
    align-items: center;
  }
  .explore__selects {
    flex-shrink: 0;
  }
  .filter-select {
    flex: none;
    min-width: 180px;
  }
}
</style>
