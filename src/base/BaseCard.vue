<script setup>
/**
 * BaseCard — surface container with padding, border, radius, and shadow.
 * Slots: default (body), header (optional header area)
 */
defineProps({
  padding: {
    type: String,
    default: 'md',
    validator: (v) => ['none', 'sm', 'md', 'lg'].includes(v),
  },
  shadow: {
    type: String,
    default: 'sm',
    validator: (v) => ['none', 'xs', 'sm', 'md', 'lg'].includes(v),
  },
  hoverable: { type: Boolean, default: false },
})
</script>

<template>
  <div
    class="card"
    :class="[
      `card--p-${padding}`,
      `card--shadow-${shadow}`,
      { 'card--hover': hoverable },
    ]"
  >
    <header v-if="$slots.header" class="card__header">
      <slot name="header" />
    </header>
    <slot />
  </div>
</template>

<style scoped>
.card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  transition: box-shadow var(--transition-base), border-color var(--transition-base), transform var(--transition-base);
}

.card--p-none { padding: 0; }
.card--p-sm { padding: var(--space-4); }
.card--p-md { padding: var(--space-6); }
.card--p-lg { padding: var(--space-8); }

.card--shadow-none { box-shadow: none; }
.card--shadow-xs { box-shadow: var(--shadow-xs); }
.card--shadow-sm { box-shadow: var(--shadow-sm); }
.card--shadow-md { box-shadow: var(--shadow-md); }
.card--shadow-lg { box-shadow: var(--shadow-lg); }

.card--hover:hover {
  box-shadow: var(--shadow-lg);
  border-color: var(--color-primary-200);
  transform: translateY(-2px);
}

.card__header {
  padding-bottom: var(--space-4);
  margin-bottom: var(--space-4);
  border-bottom: 1px solid var(--color-border);
}
</style>
