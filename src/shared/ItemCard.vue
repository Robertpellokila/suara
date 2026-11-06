<script setup>
/**
 * ItemCard — displays a single election summary.
 *
 * Shows title, organization, type, status, date, eligibility badge, favorite
 * toggle, and a link to the detail page. All candidates in an election receive
 * identical visual treatment — this card does NOT display candidate info.
 */
import { computed } from 'vue'
import { RouterLink } from 'vue-router'
import { useFavoritesStore } from '../stores/useFavoritesStore'
import { electionStatuses, electionTypes } from '../data/items'

const props = defineProps({
  item: { type: Object, required: true },
})

const favorites = useFavoritesStore()

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

const status = computed(() => statusConfig[props.item.status] ?? statusConfig.draft)
const typeLabel = computed(() => typeConfig[props.item.electionType] ?? '—')
const isFavorite = computed(() => favorites.isFavorite(props.item.slug))

const dateRange = computed(() => {
  const start = new Date(props.item.startAt).toLocaleDateString('id-ID', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  })
  const end = new Date(props.item.endAt).toLocaleDateString('id-ID', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  })
  return start === end ? start : `${start} — ${end}`
})

function toggleFavorite() {
  favorites.toggle(props.item.slug)
}
</script>

<template>
  <RouterLink :to="{ name: 'detail', params: { slug: item.slug } }" class="item-card">
    <div class="item-card__image">
      <img :src="item.image" :alt="`Pemilihan ${item.title}`" loading="lazy" />
      <span class="item-card__status" :class="status.class">{{ status.label }}</span>
    </div>

    <div class="item-card__body">
      <div class="item-card__meta">
        <span class="item-card__type">{{ typeLabel }}</span>
        <span class="item-card__dot" aria-hidden="true">·</span>
        <span class="item-card__date">{{ dateRange }}</span>
      </div>

      <h3 class="item-card__title">{{ item.title }}</h3>
      <p class="item-card__org">{{ item.organization }}</p>
      <p class="item-card__desc">{{ item.description }}</p>

      <div class="item-card__footer">
        <span class="item-card__eligibility" :class="{ 'eligibility--yes': item.eligible }">
          {{ item.eligible ? 'Anda berhak memilih' : 'Tidak eligible' }}
        </span>
        <button
          type="button"
          class="item-card__fav"
          :class="{ 'item-card__fav--active': isFavorite }"
          :aria-label="isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit'"
          :aria-pressed="isFavorite"
          @click.prevent="toggleFavorite"
        >
          <svg viewBox="0 0 24 24" width="20" height="20" :fill="isFavorite ? 'currentColor' : 'none'" stroke="currentColor" stroke-width="2">
            <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
          </svg>
        </button>
      </div>
    </div>
  </RouterLink>
</template>

<style scoped>
.item-card {
  display: flex;
  flex-direction: column;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-xl);
  overflow: hidden;
  text-decoration: none;
  color: inherit;
  transition: box-shadow var(--transition-base), border-color var(--transition-base), transform var(--transition-base);
}

.item-card:hover {
  box-shadow: var(--shadow-lg);
  border-color: var(--color-primary-200);
  transform: translateY(-4px);
}

.item-card__image {
  position: relative;
  height: 180px;
  overflow: hidden;
  background: var(--color-secondary-100);
}

.item-card__image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform var(--transition-slow);
}

.item-card:hover .item-card__image img {
  transform: scale(1.05);
}

.item-card__status {
  position: absolute;
  top: var(--space-3);
  left: var(--space-3);
  padding: var(--space-1) var(--space-3);
  border-radius: var(--radius-full);
  font-size: var(--fs-xs);
  font-weight: var(--fw-semibold);
  backdrop-filter: blur(8px);
  background: rgba(255, 255, 255, 0.92);
}

.status--success { color: var(--color-success-700); }
.status--warning { color: var(--color-warning-600); }
.status--info { color: var(--color-primary-600); }
.status--neutral { color: var(--color-text-secondary); }

.item-card__body {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
  padding: var(--space-5);
}

.item-card__meta {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  font-size: var(--fs-xs);
  color: var(--color-text-secondary);
  font-weight: var(--fw-medium);
}

.item-card__dot {
  opacity: 0.5;
}

.item-card__title {
  font-size: var(--fs-lg);
  font-weight: var(--fw-semibold);
  color: var(--color-text-primary);
  line-height: var(--lh-tight);
}

.item-card__org {
  font-size: var(--fs-sm);
  color: var(--color-primary-500);
  font-weight: var(--fw-medium);
}

.item-card__desc {
  font-size: var(--fs-sm);
  color: var(--color-text-secondary);
  line-height: var(--lh-base);
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.item-card__footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: var(--space-2);
  padding-top: var(--space-3);
  border-top: 1px solid var(--color-border);
}

.item-card__eligibility {
  font-size: var(--fs-xs);
  font-weight: var(--fw-semibold);
  padding: var(--space-1) var(--space-3);
  border-radius: var(--radius-full);
  background: var(--color-neutral-100);
  color: var(--color-text-secondary);
}

.eligibility--yes {
  background: var(--color-success-50);
  color: var(--color-success-700);
}

.item-card__fav {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border-radius: var(--radius-md);
  color: var(--color-neutral-400);
  background: transparent;
  transition: all var(--transition-fast);
}

.item-card__fav:hover {
  background: var(--color-surface-hover);
  color: var(--color-error-500);
}

.item-card__fav--active {
  color: var(--color-error-500);
}
</style>
