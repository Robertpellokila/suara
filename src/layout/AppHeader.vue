<script setup>
import { ref, computed } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { useAuthStore } from '../stores/useAuthStore'

const mobileOpen = ref(false)
const userMenuOpen = ref(false)
const auth = useAuthStore()
const router = useRouter()

const navLinks = [
  { name: 'Beranda', to: { name: 'home' } },
  { name: 'Jelajahi', to: { name: 'explore' } },
  { name: 'Tentang', to: { name: 'about' } },
]

function closeMobile() {
  mobileOpen.value = false
}

function closeUserMenu() {
  userMenuOpen.value = false
}

async function handleSignOut() {
  closeUserMenu()
  closeMobile()
  await auth.signOut()
  router.push({ name: 'home' })
}
</script>

<template>
  <header class="header">
    <div class="header__inner container">
      <RouterLink :to="{ name: 'home' }" class="header__brand" @click="closeMobile">
        <svg class="header__logo" viewBox="0 0 32 32" fill="none" aria-hidden="true">
          <rect width="32" height="32" rx="8" fill="var(--color-primary-500)" />
          <path
            d="M10 9h9a3 3 0 0 1 3 3v3a3 3 0 0 1-3 3h-2l3 5h-3l-3-5h-1v5h-3V9z"
            fill="var(--color-neutral-0)"
          />
        </svg>
        <span class="header__name">SUARA</span>
      </RouterLink>

      <nav class="header__nav" aria-label="Navigasi utama">
        <RouterLink
          v-for="link in navLinks"
          :key="link.name"
          :to="link.to"
          class="header__link"
          active-class="header__link--active"
        >
          {{ link.name }}
        </RouterLink>
      </nav>

      <div class="header__actions">
        <!-- Logged in: user menu -->
        <div v-if="auth.isAuthenticated" class="header__user">
          <button
            type="button"
            class="header__user-btn"
            :aria-expanded="userMenuOpen"
            aria-haspopup="true"
            aria-label="Menu pengguna"
            @click="userMenuOpen = !userMenuOpen"
          >
            <span class="header__avatar">{{ auth.initials }}</span>
            <span class="header__user-name">{{ auth.displayName }}</span>
            <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M6 9l6 6 6-6" /></svg>
          </button>
          <Transition name="dropdown">
            <div v-if="userMenuOpen" class="header__user-menu" role="menu">
              <div class="header__user-info">
                <span class="header__user-email">{{ auth.user?.email }}</span>
                <span v-if="auth.isSuperAdmin" class="header__badge">Super Admin</span>
              </div>
              <RouterLink
                v-if="auth.isSuperAdmin || auth.activeOrgs.length"
                :to="{ name: 'admin-overview' }"
                class="header__menu-item"
                role="menuitem"
                @click="closeUserMenu"
              >
                <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><rect x="3" y="3" width="7" height="7" /><rect x="14" y="3" width="7" height="7" /><rect x="14" y="14" width="7" height="7" /><rect x="3" y="14" width="7" height="7" /></svg>
                Panel Admin
              </RouterLink>
              <button type="button" class="header__menu-item" role="menuitem" @click="handleSignOut">
                <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9" /></svg>
                Keluar
              </button>
            </div>
          </Transition>
        </div>

        <!-- Not logged in: login button -->
        <RouterLink v-else :to="{ name: 'login' }" class="header__login">
          Masuk
        </RouterLink>

        <button
          type="button"
          class="header__toggle"
          :aria-expanded="mobileOpen"
          aria-controls="mobile-nav"
          aria-label="Buka menu navigasi"
          @click="mobileOpen = !mobileOpen"
        >
          <svg v-if="!mobileOpen" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
            <line x1="4" y1="6" x2="20" y2="6" />
            <line x1="4" y1="12" x2="20" y2="12" />
            <line x1="4" y1="18" x2="20" y2="18" />
          </svg>
          <svg v-else viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
            <line x1="6" y1="6" x2="18" y2="18" />
            <line x1="18" y1="6" x2="6" y2="18" />
          </svg>
        </button>
      </div>
    </div>

    <Transition name="mobile">
      <nav
        v-if="mobileOpen"
        id="mobile-nav"
        class="header__mobile-nav"
        aria-label="Navigasi mobile"
      >
        <RouterLink
          v-for="link in navLinks"
          :key="link.name"
          :to="link.to"
          class="header__mobile-link"
          active-class="header__mobile-link--active"
          @click="closeMobile"
        >
          {{ link.name }}
        </RouterLink>
        <div v-if="auth.isAuthenticated" class="header__mobile-section">
          <div class="header__mobile-user">
            <span class="header__avatar">{{ auth.initials }}</span>
            <div>
              <p class="header__mobile-user-name">{{ auth.displayName }}</p>
              <p class="header__mobile-user-email">{{ auth.user?.email }}</p>
            </div>
          </div>
          <button type="button" class="header__mobile-signout" @click="handleSignOut">
            Keluar
          </button>
        </div>
        <RouterLink v-else :to="{ name: 'login' }" class="header__mobile-link" @click="closeMobile">
          Masuk
        </RouterLink>
      </nav>
    </Transition>
  </header>
</template>

<style scoped>
.header {
  position: sticky;
  top: 0;
  z-index: var(--z-sticky);
  background: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
  transition: box-shadow var(--transition-base);
}

.header__inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 64px;
  gap: var(--space-4);
}

.header__brand {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  color: var(--color-text-primary);
  font-weight: var(--fw-bold);
  font-size: var(--fs-lg);
  text-decoration: none;
  flex-shrink: 0;
}

.header__logo {
  width: 32px;
  height: 32px;
  border-radius: var(--radius-md);
  flex-shrink: 0;
}

.header__name {
  letter-spacing: 0.05em;
}

.header__nav {
  display: flex;
  align-items: center;
  gap: var(--space-1);
}

.header__link {
  padding: var(--space-2) var(--space-4);
  border-radius: var(--radius-md);
  color: var(--color-text-secondary);
  font-weight: var(--fw-medium);
  font-size: var(--fs-sm);
  text-decoration: none;
  transition: all var(--transition-fast);
}

.header__link:hover {
  color: var(--color-text-primary);
  background: var(--color-surface-hover);
}

.header__link--active {
  color: var(--color-primary-500);
  background: var(--color-primary-50);
}

.header__actions {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  flex-shrink: 0;
}

.header__login {
  padding: var(--space-2) var(--space-5);
  border-radius: var(--radius-lg);
  background: var(--color-primary-500);
  color: var(--color-neutral-0);
  font-size: var(--fs-sm);
  font-weight: var(--fw-semibold);
  text-decoration: none;
  transition: background var(--transition-fast);
  min-height: 40px;
  display: flex;
  align-items: center;
}

.header__login:hover {
  background: var(--color-primary-600);
  color: var(--color-neutral-0);
}

.header__user {
  position: relative;
}

.header__user-btn {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-1) var(--space-2) var(--space-1) var(--space-1);
  border-radius: var(--radius-lg);
  background: transparent;
  transition: background var(--transition-fast);
  min-height: 40px;
}

.header__user-btn:hover {
  background: var(--color-surface-hover);
}

.header__avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border-radius: var(--radius-full);
  background: var(--color-primary-500);
  color: var(--color-neutral-0);
  font-size: var(--fs-xs);
  font-weight: var(--fw-bold);
  flex-shrink: 0;
}

.header__user-name {
  font-size: var(--fs-sm);
  font-weight: var(--fw-medium);
  color: var(--color-text-primary);
  max-width: 120px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.header__user-menu {
  position: absolute;
  top: calc(100% + var(--space-2));
  right: 0;
  min-width: 220px;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg);
  padding: var(--space-2);
  z-index: var(--z-dropdown);
}

.header__user-info {
  padding: var(--space-2) var(--space-3);
  border-bottom: 1px solid var(--color-border);
  margin-bottom: var(--space-2);
}

.header__user-email {
  display: block;
  font-size: var(--fs-sm);
  color: var(--color-text-primary);
  font-weight: var(--fw-medium);
  word-break: break-all;
}

.header__badge {
  display: inline-block;
  margin-top: var(--space-1);
  padding: 2px var(--space-2);
  border-radius: var(--radius-full);
  background: var(--color-primary-50);
  color: var(--color-primary-600);
  font-size: var(--fs-xs);
  font-weight: var(--fw-semibold);
}

.header__menu-item {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  width: 100%;
  padding: var(--space-2) var(--space-3);
  border-radius: var(--radius-md);
  color: var(--color-text-secondary);
  font-size: var(--fs-sm);
  font-weight: var(--fw-medium);
  background: transparent;
  transition: all var(--transition-fast);
}

.header__menu-item:hover {
  background: var(--color-surface-hover);
  color: var(--color-text-primary);
}

.dropdown-enter-active,
.dropdown-leave-active {
  transition: opacity var(--transition-fast), transform var(--transition-fast);
}

.dropdown-enter-from,
.dropdown-leave-to {
  opacity: 0;
  transform: translateY(-4px);
}

.header__mobile-section {
  margin-top: var(--space-2);
  padding-top: var(--space-3);
  border-top: 1px solid var(--color-border);
}

.header__mobile-user {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  padding: var(--space-2);
}

.header__mobile-user-name {
  font-size: var(--fs-sm);
  font-weight: var(--fw-semibold);
  color: var(--color-text-primary);
}

.header__mobile-user-email {
  font-size: var(--fs-xs);
  color: var(--color-text-secondary);
}

.header__mobile-signout {
  display: block;
  width: 100%;
  padding: var(--space-3) var(--space-2);
  border-radius: var(--radius-md);
  color: var(--color-error-600);
  font-size: var(--fs-sm);
  font-weight: var(--fw-medium);
  background: transparent;
  text-align: left;
  transition: background var(--transition-fast);
}

.header__mobile-signout:hover {
  background: var(--color-error-50);
}

.header__toggle {
  display: none;
  align-items: center;
  justify-content: center;
  width: 44px;
  height: 44px;
  border-radius: var(--radius-md);
  color: var(--color-text-primary);
  background: transparent;
  transition: background var(--transition-fast);
}

.header__toggle:hover {
  background: var(--color-surface-hover);
}

.header__mobile-nav {
  display: flex;
  flex-direction: column;
  padding: var(--space-2) var(--space-4) var(--space-4);
  background: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
}

.header__mobile-link {
  display: block;
  padding: var(--space-3) var(--space-2);
  border-radius: var(--radius-md);
  color: var(--color-text-secondary);
  font-weight: var(--fw-medium);
  font-size: var(--fs-base);
  text-decoration: none;
}

.header__mobile-link:hover,
.header__mobile-link--active {
  color: var(--color-primary-500);
  background: var(--color-primary-50);
}

.mobile-enter-active,
.mobile-leave-active {
  transition: opacity var(--transition-base), transform var(--transition-base);
}

.mobile-enter-from,
.mobile-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}

@media (max-width: 767px) {
  .header__nav {
    display: none;
  }
  .header__toggle {
    display: flex;
  }
}

@media (min-width: 768px) {
  .header__mobile-nav {
    display: none;
  }
}
</style>
