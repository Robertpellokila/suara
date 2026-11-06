<script setup>
/**
 * SearchBar — accessible search input with clear button.
 * Emits update:query for v-model compatibility.
 */
import { computed } from 'vue'

const props = defineProps({
  modelValue: { type: String, default: '' },
  placeholder: { type: String, default: 'Cari pemilihan…' },
  label: { type: String, default: 'Cari pemilihan' },
})

const emit = defineEmits(['update:modelValue'])

const value = computed({
  get: () => props.modelValue,
  set: (v) => emit('update:modelValue', v),
})

function clear() {
  emit('update:modelValue', '')
}
</script>

<template>
  <div class="search">
    <label class="search__label sr-only" for="search-input">{{ label }}</label>
    <div class="search__field">
      <svg class="search__icon" viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
        <circle cx="11" cy="11" r="8" />
        <line x1="21" y1="21" x2="16.65" y2="16.65" />
      </svg>
      <input
        id="search-input"
        v-model="value"
        type="search"
        class="search__input"
        :placeholder="placeholder"
        :aria-label="label"
      />
      <button
        v-if="value"
        type="button"
        class="search__clear"
        aria-label="Hapus pencarian"
        @click="clear"
      >
        <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
          <line x1="6" y1="6" x2="18" y2="18" />
          <line x1="18" y1="6" x2="6" y2="18" />
        </svg>
      </button>
    </div>
  </div>
</template>

<style scoped>
.search {
  width: 100%;
}

.search__field {
  position: relative;
  display: flex;
  align-items: center;
}

.search__icon {
  position: absolute;
  left: var(--space-4);
  color: var(--color-text-secondary);
  pointer-events: none;
  flex-shrink: 0;
}

.search__input {
  width: 100%;
  min-height: 48px;
  padding: 0 var(--space-12) 0 var(--space-12);
  font-size: var(--fs-base);
  color: var(--color-text-primary);
  background: var(--color-surface);
  border: 1.5px solid var(--color-border);
  border-radius: var(--radius-xl);
  transition: border-color var(--transition-fast), box-shadow var(--transition-fast);
  appearance: none;
  -webkit-appearance: none;
}

.search__input::placeholder {
  color: var(--color-text-secondary);
}

.search__input:focus {
  border-color: var(--color-primary-500);
  box-shadow: 0 0 0 3px var(--color-primary-100);
  outline: none;
}

/* Hide default search clear (webkit) */
.search__input::-webkit-search-cancel-button {
  display: none;
}

.search__clear {
  position: absolute;
  right: var(--space-3);
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border-radius: var(--radius-md);
  color: var(--color-text-secondary);
  background: transparent;
  transition: all var(--transition-fast);
}

.search__clear:hover {
  background: var(--color-surface-hover);
  color: var(--color-text-primary);
}
</style>
