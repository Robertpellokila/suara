<script setup>
import { RouterLink } from 'vue-router'

const year = new Date().getFullYear()

const links = [
  { name: 'Beranda', to: { name: 'home' } },
  { name: 'Jelajahi', to: { name: 'explore' } },
  { name: 'Tentang', to: { name: 'about' } },
]
</script>

<template>
  <footer class="footer">
    <div class="container footer__inner">
      <div class="footer__brand">
        <svg class="footer__logo" viewBox="0 0 32 32" fill="none" aria-hidden="true">
          <rect width="32" height="32" rx="8" fill="var(--color-primary-500)" />
          <path
            d="M10 9h9a3 3 0 0 1 3 3v3a3 3 0 0 1-3 3h-2l3 5h-3l-3-5h-1v5h-3V9z"
            fill="var(--color-neutral-0)"
          />
        </svg>
        <div class="footer__text">
          <span class="footer__name">SUARA</span>
          <span class="footer__tagline">One Person. One Vote. Every Voice Matters.</span>
        </div>
      </div>

      <nav class="footer__nav" aria-label="Navigasi footer">
        <RouterLink
          v-for="link in links"
          :key="link.name"
          :to="link.to"
          class="footer__link"
        >
          {{ link.name }}
        </RouterLink>
      </nav>
    </div>

    <div class="container footer__bottom">
      <p class="footer__copyright">© {{ year }} SUARA. Semua hak dilindungi.</p>
    </div>
  </footer>
</template>

<style scoped>
.footer {
  margin-top: auto;
  background: var(--color-neutral-900);
  padding: var(--space-12) var(--space-4) var(--space-6);
}

.footer__inner {
  display: flex;
  flex-direction: column;
  gap: var(--space-6);
}

.footer__brand {
  display: flex;
  align-items: center;
  gap: var(--space-3);
}

.footer__logo {
  width: 36px;
  height: 36px;
  border-radius: var(--radius-md);
  flex-shrink: 0;
}

.footer__text {
  display: flex;
  flex-direction: column;
  gap: var(--space-1);
}

.footer__name {
  color: var(--color-neutral-0);
  font-weight: var(--fw-bold);
  font-size: var(--fs-lg);
  letter-spacing: 0.05em;
}

.footer__tagline {
  color: var(--color-neutral-400);
  font-size: var(--fs-sm);
}

.footer__nav {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-4);
}

.footer__link {
  color: var(--color-neutral-300);
  font-size: var(--fs-sm);
  font-weight: var(--fw-medium);
  text-decoration: none;
  transition: color var(--transition-fast);
}

.footer__link:hover {
  color: var(--color-neutral-0);
}

.footer__bottom {
  margin-top: var(--space-8);
  padding-top: var(--space-4);
  border-top: 1px solid var(--color-secondary-700);
}

.footer__copyright {
  color: var(--color-neutral-400);
  font-size: var(--fs-xs);
}

@media (min-width: 768px) {
  .footer__inner {
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
  }
}

@media (min-width: 1024px) {
  .footer {
    padding: var(--space-16) var(--space-4) var(--space-8);
  }
}
</style>
