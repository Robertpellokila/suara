<script setup>
/**
 * DetailView — single election detail page.
 *
 * Phase 2: shows mock election info. In production, eligibility is rechecked
 * on the backend before the voting flow begins. The slug is only for
 * navigation, NOT authorization.
 *
 * The voting flow (Verify → Choose → Confirm → Done) will be implemented in
 * Phase 6 (Voting Engine). This view shows the election information and a
 * placeholder for the vote action.
 */
import { computed } from 'vue'
import { useRouter, RouterLink } from 'vue-router'
import { getItemBySlug } from '../data/items'
import { useFavoritesStore } from '../stores/useFavoritesStore'
import BaseButton from '../base/BaseButton.vue'
import BaseCard from '../base/BaseCard.vue'
import EmptyState from '../shared/EmptyState.vue'

const props = defineProps({
  slug: { type: String, required: true },
})

const router = useRouter()
const favorites = useFavoritesStore()

const item = computed(() => getItemBySlug(props.slug))
const isFavorite = computed(() => item.value ? favorites.isFavorite(item.value.slug) : false)

const statusConfig = {
  draft: { label: 'Draft', class: 'status--neutral' },
  scheduled: { label: 'Terjadwal', class: 'status--info' },
  active: { label: 'Aktif', class: 'status--success' },
  paused: { label: 'Dijeda', class: 'status--warning' },
  completed: { label: 'Selesai', class: 'status--neutral' },
  archived: { label: 'Arsip', class: 'status--neutral' },
}

const typeConfig = {
  school_wide: 'Sekolah',
  class_level: 'Kelas',
  grade_level: 'Angkatan',
  custom_group: 'Grup Khusus',
}

const status = computed(() => item.value ? statusConfig[item.value.status] : null)
const typeLabel = computed(() => item.value ? typeConfig[item.value.electionType] : '')

const dateRange = computed(() => {
  if (!item.value) return ''
  const opts = { day: 'numeric', month: 'long', year: 'numeric', hour: '2-digit', minute: '2-digit' }
  const start = new Date(item.value.startAt).toLocaleDateString('id-ID', opts)
  const end = new Date(item.value.endAt).toLocaleDateString('id-ID', opts)
  return `${start} — ${end}`
})

function toggleFavorite() {
  if (item.value) favorites.toggle(item.value.slug)
}

function goBack() {
  router.push({ name: 'explore' })
}
</script>

<template>
  <div class="detail">
    <template v-if="item">
      <div class="detail__hero">
        <div class="container">
          <button type="button" class="detail__back" @click="goBack">
            <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
              <path d="M19 12H5M12 19l-7-7 7-7" />
            </svg>
            Kembali
          </button>

          <div class="detail__hero-content">
            <span class="detail__status" :class="status.class">{{ status.label }}</span>
            <h1 class="detail__title">{{ item.title }}</h1>
            <div class="detail__meta">
              <span>{{ typeLabel }}</span>
              <span class="detail__dot" aria-hidden="true">·</span>
              <span>{{ item.organization }}</span>
            </div>
          </div>
        </div>
      </div>

      <div class="container detail__body">
        <div class="detail__main">
          <BaseCard padding="lg" shadow="sm">
            <h2 class="detail__section-title">Tentang Pemilihan Ini</h2>
            <p class="detail__desc">{{ item.description }}</p>
          </BaseCard>

          <BaseCard padding="lg" shadow="sm">
            <h2 class="detail__section-title">Jadwal</h2>
            <p class="detail__schedule">{{ dateRange }}</p>
          </BaseCard>

          <BaseCard padding="lg" shadow="sm">
            <h2 class="detail__section-title">Eligibility</h2>
            <p class="detail__eligibility">
              <span class="detail__eligibility-badge" :class="{ 'badge--yes': item.eligible }">
                {{ item.eligible ? 'Anda berhak memilih' : 'Anda tidak berhak memilih pada pemilihan ini' }}
              </span>
            </p>
            <p class="detail__eligibility-note">
              Eligibility ditentukan oleh backend berdasarkan roster dan aturan event.
              Slug, QR Code, atau URL bukan bukti otorisasi.
            </p>
          </BaseCard>
        </div>

        <aside class="detail__sidebar">
          <BaseCard padding="lg" shadow="md">
            <div class="detail__action">
              <h3 class="detail__action-title">Mulai Memilih</h3>
              <p class="detail__action-desc">
                Proses voting akan memandu Anda melalui verifikasi, pemilihan kandidat,
                dan konfirmasi. Suara Anda tidak dapat diubah setelah dikirim.
              </p>
              <BaseButton
                variant="primary"
                full-width
                :disabled="!item.eligible || item.status !== 'active'"
              >
                {{ item.status === 'active' && item.eligible ? 'Mulai Voting' : 'Tidak Tersedia' }}
              </BaseButton>
              <button
                type="button"
                class="detail__fav-btn"
                :class="{ 'detail__fav-btn--active': isFavorite }"
                @click="toggleFavorite"
              >
                <svg viewBox="0 0 24 24" width="18" height="18" :fill="isFavorite ? 'currentColor' : 'none'" stroke="currentColor" stroke-width="2" aria-hidden="true">
                  <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
                </svg>
                {{ isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit' }}
              </button>
            </div>
          </BaseCard>

          <BaseCard padding="md" shadow="sm">
            <div class="detail__info">
              <h4 class="detail__info-title">Informasi</h4>
              <dl class="detail__dl">
                <div class="detail__dl-row">
                  <dt>Organisasi</dt>
                  <dd>{{ item.organization }}</dd>
                </div>
                <div class="detail__dl-row">
                  <dt>Jenis</dt>
                  <dd>{{ typeLabel }}</dd>
                </div>
                <div class="detail__dl-row">
                  <dt>Status</dt>
                  <dd>{{ status.label }}</dd>
                </div>
              </dl>
            </div>
          </BaseCard>
        </aside>
      </div>
    </template>

    <template v-else>
      <div class="container">
        <EmptyState
          title="Pemilihan tidak ditemukan"
          message="Pemilihan yang Anda cari tidak tersedia atau Anda tidak berhak mengaksesnya."
        >
          <RouterLink :to="{ name: 'explore' }">
            <BaseButton variant="primary">Kembali ke Jelajahi</BaseButton>
          </RouterLink>
        </EmptyState>
      </div>
    </template>
  </div>
</template>

<style scoped>
.detail { padding-bottom: var(--space-16); }

.detail__hero {
  background: linear-gradient(135deg, var(--color-primary-900) 0%, var(--color-primary-600) 100%);
  padding: var(--space-8) 0 var(--space-12);
  color: var(--color-neutral-0);
}

.detail__back {
  display: inline-flex;
  align-items: center;
  gap: var(--space-2);
  color: var(--color-primary-100);
  background: transparent;
  font-size: var(--fs-sm);
  font-weight: var(--fw-medium);
  padding: var(--space-2) var(--space-3);
  border-radius: var(--radius-md);
  transition: all var(--transition-fast);
}

.detail__back:hover {
  color: var(--color-neutral-0);
  background: rgba(255, 255, 255, 0.1);
}

.detail__hero-content {
  margin-top: var(--space-6);
}

.detail__status {
  display: inline-block;
  padding: var(--space-1) var(--space-3);
  border-radius: var(--radius-full);
  font-size: var(--fs-xs);
  font-weight: var(--fw-semibold);
  background: rgba(255, 255, 255, 0.15);
  color: var(--color-neutral-0);
  margin-bottom: var(--space-3);
}

.detail__title {
  font-size: clamp(1.75rem, 5vw, 2.5rem);
  font-weight: var(--fw-bold);
  color: var(--color-neutral-0);
  margin-bottom: var(--space-3);
}

.detail__meta {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  color: var(--color-primary-100);
  font-size: var(--fs-sm);
  font-weight: var(--fw-medium);
}

.detail__dot { opacity: 0.6; }

.detail__body {
  display: grid;
  grid-template-columns: 1fr;
  gap: var(--space-6);
  margin-top: calc(-1 * var(--space-6));
  position: relative;
  z-index: 1;
}

@media (min-width: 768px) {
  .detail__body {
    grid-template-columns: 1fr 340px;
    align-items: start;
  }
}

.detail__main {
  display: flex;
  flex-direction: column;
  gap: var(--space-5);
}

.detail__section-title {
  font-size: var(--fs-lg);
  font-weight: var(--fw-semibold);
  margin-bottom: var(--space-3);
}

.detail__desc {
  color: var(--color-text-secondary);
  font-size: var(--fs-base);
  line-height: var(--lh-base);
}

.detail__schedule {
  color: var(--color-text-secondary);
  font-size: var(--fs-base);
}

.detail__eligibility-badge {
  display: inline-block;
  padding: var(--space-2) var(--space-4);
  border-radius: var(--radius-full);
  font-size: var(--fs-sm);
  font-weight: var(--fw-semibold);
  background: var(--color-neutral-100);
  color: var(--color-text-secondary);
}

.badge--yes {
  background: var(--color-success-50);
  color: var(--color-success-700);
}

.detail__eligibility-note {
  margin-top: var(--space-3);
  font-size: var(--fs-xs);
  color: var(--color-text-secondary);
  line-height: var(--lh-base);
}

.detail__sidebar {
  display: flex;
  flex-direction: column;
  gap: var(--space-5);
}

.detail__action {
  text-align: center;
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.detail__action-title {
  font-size: var(--fs-xl);
  font-weight: var(--fw-semibold);
}

.detail__action-desc {
  font-size: var(--fs-sm);
  color: var(--color-text-secondary);
  line-height: var(--lh-base);
  margin-bottom: var(--space-2);
}

.detail__fav-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-2);
  padding: var(--space-2) var(--space-4);
  font-size: var(--fs-sm);
  font-weight: var(--fw-medium);
  color: var(--color-text-secondary);
  background: transparent;
  border-radius: var(--radius-md);
  transition: all var(--transition-fast);
}

.detail__fav-btn:hover {
  background: var(--color-surface-hover);
  color: var(--color-error-500);
}

.detail__fav-btn--active {
  color: var(--color-error-500);
}

.detail__info-title {
  font-size: var(--fs-sm);
  font-weight: var(--fw-semibold);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--color-text-secondary);
  margin-bottom: var(--space-3);
}

.detail__dl {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.detail__dl-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: var(--fs-sm);
}

.detail__dl-row dt {
  color: var(--color-text-secondary);
}

.detail__dl-row dd {
  font-weight: var(--fw-medium);
  color: var(--color-text-primary);
}
</style>
