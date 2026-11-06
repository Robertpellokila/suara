<script setup>
/**
 * AdminOverviewView — dashboard landing for org admin.
 * Shows organization summary stats and quick links.
 */
import { ref, onMounted, computed } from 'vue'
import { RouterLink } from 'vue-router'
import { useAuthStore } from '../../stores/useAuthStore'
import { fetchElections } from '../../services/electionService'
import { fetchStudentCount } from '../../services/studentService'
import { fetchClasses } from '../../services/studentService'
import BaseCard from '../../base/BaseCard.vue'

const auth = useAuthStore()
const loading = ref(true)
const stats = ref({ students: 0, classes: 0, elections: 0, activeElections: 0 })
const recentElections = ref([])
const error = ref(null)

const currentOrg = computed(() =>
  auth.activeOrgs.find((m) => m.organizations?.status === 'verified')?.organizations ?? null
)

const statusConfig = {
  draft: { label: 'Draft', cls: 'status--neutral' },
  scheduled: { label: 'Terjadwal', cls: 'status--info' },
  active: { label: 'Aktif', cls: 'status--success' },
  paused: { label: 'Dijeda', cls: 'status--warning' },
  completed: { label: 'Selesai', cls: 'status--neutral' },
  archived: { label: 'Arsip', cls: 'status--neutral' },
}

onMounted(async () => {
  if (!currentOrg.value) {
    loading.value = false
    return
  }
  try {
    const orgId = currentOrg.value.id
    const [studentCount, classes, elections] = await Promise.all([
      fetchStudentCount(orgId),
      fetchClasses(orgId),
      fetchElections(orgId),
    ])
    stats.value = {
      students: studentCount,
      classes: classes.length,
      elections: elections.length,
      activeElections: elections.filter((e) => e.status === 'active').length,
    }
    recentElections.value = elections.slice(0, 5)
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="overview">
    <header class="admin-page-header">
      <h1 class="admin-page-title">Ringkasan</h1>
      <p class="admin-page-subtitle">
        {{ currentOrg?.name ?? 'Belum ada organisasi yang ditugaskan' }}
      </p>
    </header>

    <div v-if="!currentOrg && !loading" class="overview__empty">
      <BaseCard padding="lg" shadow="sm">
        <p class="overview__empty-text">Anda belum ditugaskan ke organisasi yang terverifikasi. Hubungi Super Admin untuk mendapatkan akses.</p>
      </BaseCard>
    </div>

    <template v-else>
      <div class="overview__stats">
        <BaseCard padding="md" shadow="sm">
          <p class="stat__label">Total Siswa</p>
          <p class="stat__value">{{ loading ? '—' : stats.students.toLocaleString('id-ID') }}</p>
        </BaseCard>
        <BaseCard padding="md" shadow="sm">
          <p class="stat__label">Kelas Aktif</p>
          <p class="stat__value">{{ loading ? '—' : stats.classes }}</p>
        </BaseCard>
        <BaseCard padding="md" shadow="sm">
          <p class="stat__label">Total Pemilihan</p>
          <p class="stat__value">{{ loading ? '—' : stats.elections }}</p>
        </BaseCard>
        <BaseCard padding="md" shadow="sm">
          <p class="stat__label">Pemilihan Aktif</p>
          <p class="stat__value stat__value--highlight">{{ loading ? '—' : stats.activeElections }}</p>
        </BaseCard>
      </div>

      <div class="overview__grid">
        <BaseCard padding="md" shadow="sm">
          <h2 class="overview__section-title">Pemilihan Terbaru</h2>
          <div v-if="loading" class="overview__loading">Memuat...</div>
          <div v-else-if="recentElections.length === 0" class="overview__empty-section">
            Belum ada pemilihan.
          </div>
          <ul v-else class="overview__election-list">
            <li v-for="election in recentElections" :key="election.id" class="overview__election-item">
              <div>
                <p class="overview__election-title">{{ election.title }}</p>
                <p class="overview__election-meta">
                  {{ new Date(election.created_at).toLocaleDateString('id-ID') }}
                </p>
              </div>
              <span class="status-badge" :class="statusConfig[election.status]?.cls">
                {{ statusConfig[election.status]?.label ?? election.status }}
              </span>
            </li>
          </ul>
        </BaseCard>

      </div>
    </template>
  </div>
</template>

<style scoped>
.overview { padding: var(--space-6); }

.admin-page-header { margin-bottom: var(--space-6); }
.admin-page-title { font-size: var(--fs-2xl); font-weight: var(--fw-bold); }
.admin-page-subtitle { color: var(--color-text-secondary); font-size: var(--fs-base); margin-top: var(--space-1); }

.overview__stats {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: var(--space-4);
  margin-bottom: var(--space-6);
}

@media (min-width: 768px) {
  .overview__stats { grid-template-columns: repeat(4, 1fr); }
}

.stat__label { font-size: var(--fs-sm); color: var(--color-text-secondary); margin-bottom: var(--space-2); }
.stat__value { font-size: var(--fs-3xl); font-weight: var(--fw-bold); color: var(--color-text-primary); }
.stat__value--highlight { color: var(--color-primary-500); }

.overview__grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: var(--space-5);
}

@media (min-width: 1024px) {
  .overview__grid { grid-template-columns: 2fr 1fr; }
}

.overview__section-title { font-size: var(--fs-lg); font-weight: var(--fw-semibold); margin-bottom: var(--space-4); }
.overview__loading, .overview__empty-section { color: var(--color-text-secondary); font-size: var(--fs-sm); padding: var(--space-4) 0; }

.overview__election-list { display: flex; flex-direction: column; gap: var(--space-3); }
.overview__election-item { display: flex; align-items: center; justify-content: space-between; gap: var(--space-3); padding: var(--space-3) 0; border-bottom: 1px solid var(--color-border); }
.overview__election-item:last-child { border-bottom: none; }
.overview__election-title { font-size: var(--fs-sm); font-weight: var(--fw-medium); color: var(--color-text-primary); }
.overview__election-meta { font-size: var(--fs-xs); color: var(--color-text-secondary); margin-top: var(--space-1); }

.status-badge { display: inline-block; padding: 2px var(--space-3); border-radius: var(--radius-full); font-size: var(--fs-xs); font-weight: var(--fw-semibold); white-space: nowrap; }
.status--success { background: var(--color-success-50); color: var(--color-success-700); }
.status--info { background: var(--color-primary-50); color: var(--color-primary-600); }
.status--warning { background: var(--color-warning-50); color: var(--color-warning-600); }
.status--neutral { background: var(--color-neutral-100); color: var(--color-text-secondary); }

.overview__quick-links { display: flex; flex-direction: column; gap: var(--space-2); }
.quick-link { display: flex; align-items: center; gap: var(--space-3); padding: var(--space-3); border-radius: var(--radius-md); color: var(--color-text-primary); font-size: var(--fs-sm); font-weight: var(--fw-medium); text-decoration: none; transition: background var(--transition-fast); }
.quick-link:hover { background: var(--color-surface-hover); color: var(--color-primary-500); }

.overview__empty { max-width: 480px; }
.overview__empty-text { color: var(--color-text-secondary); font-size: var(--fs-base); }
</style>
