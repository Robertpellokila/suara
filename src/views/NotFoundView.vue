<script setup>
/**
 * NotFoundView — 404 page for unmatched routes.
 */
import { RouterLink } from 'vue-router'
import BaseButton from '../base/BaseButton.vue'
</script>

<template>
  <div class="not-found">
    <div class="container not-found__inner">
      <div class="not-found__code">404</div>
      <h1 class="not-found__title">Halaman tidak ditemukan</h1>
      <p class="not-found__message">
        Halaman yang Anda cari tidak ada atau telah dipindahkan.
      </p>
      <RouterLink :to="{ name: 'home' }">
        <BaseButton variant="primary">Kembali ke Beranda</BaseButton>
      </RouterLink>
    </div>
  </div>
</template>

<style scoped>
.not-found {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 60vh;
  text-align: center;
}

.not-found__inner {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-3);
}

.not-found__code {
  font-size: clamp(4rem, 15vw, 8rem);
  font-weight: var(--fw-bold);
  color: var(--color-primary-100);
  line-height: 1;
}

.not-found__title {
  font-size: var(--fs-2xl);
  font-weight: var(--fw-semibold);
}

.not-found__message {
  color: var(--color-text-secondary);
  max-width: 400px;
  margin-bottom: var(--space-4);
}
</style>
