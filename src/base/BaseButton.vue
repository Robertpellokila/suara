<script setup>
/**
 * BaseButton — the single button primitive used across SUARA.
 *
 * Variants:  primary | secondary | outline | ghost
 * States:    loading, disabled
 *
 * Touch targets are always >= 44px high for accessibility.
 */
import { computed } from 'vue'

const props = defineProps({
  variant: {
    type: String,
    default: 'primary',
    validator: (v) => ['primary', 'secondary', 'outline', 'ghost'].includes(v),
  },
  type: {
    type: String,
    default: 'button',
  },
  disabled: { type: Boolean, default: false },
  loading: { type: Boolean, default: false },
  fullWidth: { type: Boolean, default: false },
})

const emit = defineEmits(['click'])

const isDisabled = computed(() => props.disabled || props.loading)

function onClick(e) {
  if (isDisabled.value) {
    e.preventDefault()
    return
  }
  emit('click', e)
}
</script>

<template>
  <button
    :type="type"
    :disabled="isDisabled"
    :aria-busy="loading"
    class="btn"
    :class="[`btn--${variant}`, { 'btn--full': fullWidth, 'btn--loading': loading }]"
    @click="onClick"
  >
    <svg
      v-if="loading"
      class="btn__spinner"
      viewBox="0 0 24 24"
      width="18"
      height="18"
      aria-hidden="true"
    >
      <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="3" fill="none" stroke-linecap="round" stroke-dasharray="50 20" />
    </svg>
    <slot />
  </button>
</template>

<style scoped>
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-2);
  min-height: 44px;
  padding: 0 var(--space-5);
  font-size: var(--fs-base);
  font-weight: var(--fw-semibold);
  font-family: inherit;
  border-radius: var(--radius-lg);
  cursor: pointer;
  transition: all var(--transition-fast);
  white-space: nowrap;
  border: 1.5px solid transparent;
}

.btn:disabled {
  cursor: not-allowed;
  opacity: 0.55;
}

.btn--primary {
  background: var(--color-primary-500);
  color: var(--color-neutral-0);
  border-color: var(--color-primary-500);
}

.btn--primary:not(:disabled):hover {
  background: var(--color-primary-600);
  border-color: var(--color-primary-600);
  box-shadow: var(--shadow-md);
}

.btn--secondary {
  background: var(--color-primary-50);
  color: var(--color-primary-600);
  border-color: var(--color-primary-100);
}

.btn--secondary:not(:disabled):hover {
  background: var(--color-primary-100);
  border-color: var(--color-primary-200);
}

.btn--outline {
  background: transparent;
  color: var(--color-primary-500);
  border-color: var(--color-primary-200);
}

.btn--outline:not(:disabled):hover {
  background: var(--color-primary-50);
  border-color: var(--color-primary-300);
}

.btn--ghost {
  background: transparent;
  color: var(--color-text-secondary);
  border-color: transparent;
}

.btn--ghost:not(:disabled):hover {
  background: var(--color-surface-hover);
  color: var(--color-text-primary);
}

.btn--full {
  width: 100%;
}

.btn__spinner {
  animation: spin 0.7s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

@media (prefers-reduced-motion: reduce) {
  .btn__spinner {
    animation-duration: 1.5s;
  }
}
</style>
