<script setup>
/**
 * EmptyState — consistent placeholder for empty/search/verification scenarios.
 * Slot: icon (optional custom icon), default (description)
 */
defineProps({
  title: { type: String, required: true },
  message: { type: String, default: '' },
})
</script>

<template>
  <div class="empty-state">
    <div class="empty-state__icon">
      <slot name="icon">
        <svg viewBox="0 0 64 64" width="64" height="64" fill="none" aria-hidden="true">
          <rect x="8" y="14" width="48" height="36" rx="4" stroke="var(--color-border-strong)" stroke-width="2" />
          <line x1="8" y1="24" x2="56" y2="24" stroke="var(--color-border-strong)" stroke-width="2" />
          <circle cx="14" cy="19" r="2" fill="var(--color-border-strong)" />
          <circle cx="20" cy="19" r="2" fill="var(--color-border-strong)" />
          <line x1="24" y1="36" x2="40" y2="36" stroke="var(--color-border-strong)" stroke-width="2" stroke-linecap="round" />
          <line x1="24" y1="42" x2="34" y2="42" stroke="var(--color-border-strong)" stroke-width="2" stroke-linecap="round" />
        </svg>
      </slot>
    </div>
    <h3 class="empty-state__title">{{ title }}</h3>
    <p v-if="message" class="empty-state__message">{{ message }}</p>
    <div v-if="$slots.default" class="empty-state__action">
      <slot />
    </div>
  </div>
</template>

<style scoped>
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  padding: var(--space-12) var(--space-6);
  gap: var(--space-3);
}

.empty-state__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 96px;
  height: 96px;
  border-radius: var(--radius-full);
  background: var(--color-primary-50);
  margin-bottom: var(--space-2);
}

.empty-state__title {
  font-size: var(--fs-xl);
  font-weight: var(--fw-semibold);
  color: var(--color-text-primary);
}

.empty-state__message {
  font-size: var(--fs-base);
  color: var(--color-text-secondary);
  max-width: 420px;
  line-height: var(--lh-base);
}

.empty-state__action {
  margin-top: var(--space-4);
}
</style>
