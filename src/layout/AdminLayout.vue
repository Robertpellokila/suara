<script setup>
/**
 * AdminLayout — wraps all /admin/* routes with a sidebar nav.
 * Checks auth and role on mount; redirects if not authorized.
 */
import { computed } from 'vue'
import { RouterLink, RouterView, useRouter } from 'vue-router'
import { useAuthStore } from '../stores/useAuthStore'

const auth = useAuthStore()
const router = useRouter()

const navSections = computed(() => {
  const sections = []

  if (auth.isSuperAdmin) {
    sections.push({
      title: 'Super Admin',
      links: [
        { name: 'admin-super', label: 'Organisasi', icon: 'building' },
      ],
    })
  }

  if (auth.activeOrgs.length > 0 || auth.isSuperAdmin) {
    sections.push({
      title: 'Manajemen',
      links: [
        { name: 'admin-overview', label: 'Ringkasan', icon: 'grid' },
      ],
    })
  }

  return sections
})

async function handleSignOut() {
  await auth.signOut()
  router.push({ name: 'home' })
}
</script>

<template>
  <div class="admin-layout">
    <aside class="admin-sidebar">
      <div class="admin-sidebar__header">
        <RouterLink :to="{ name: 'home' }" class="admin-sidebar__brand">
          <svg viewBox="0 0 32 32" fill="none" width="28" height="28" aria-hidden="true">
            <rect width="32" height="32" rx="8" fill="var(--color-primary-500)" />
            <path d="M10 9h9a3 3 0 0 1 3 3v3a3 3 0 0 1-3 3h-2l3 5h-3l-3-5h-1v5h-3V9z" fill="white" />
          </svg>
          <span class="admin-sidebar__brand-name">SUARA</span>
        </RouterLink>
        <span class="admin-sidebar__label">Admin Panel</span>
      </div>

      <nav class="admin-sidebar__nav" aria-label="Navigasi admin">
        <div v-for="section in navSections" :key="section.title" class="admin-nav-section">
          <p class="admin-nav-section__title">{{ section.title }}</p>
          <RouterLink
            v-for="link in section.links"
            :key="link.name"
            :to="{ name: link.name }"
            class="admin-nav-link"
            active-class="admin-nav-link--active"
          >
            <svg v-if="link.icon === 'building'" viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M3 21h18M5 21V7l7-4 7 4v14M9 21V12h6v9" /></svg>
            <svg v-else-if="link.icon === 'grid'" viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><rect x="3" y="3" width="7" height="7" rx="1" /><rect x="14" y="3" width="7" height="7" rx="1" /><rect x="3" y="14" width="7" height="7" rx="1" /><rect x="14" y="14" width="7" height="7" rx="1" /></svg>
            <svg v-else-if="link.icon === 'users'" viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" /><circle cx="9" cy="7" r="4" /><path d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75" /></svg>
            <svg v-else-if="link.icon === 'book'" viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20" /><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z" /></svg>
            <svg v-else viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M9 11l3 3L22 4" /><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11" /></svg>
            <span>{{ link.label }}</span>
          </RouterLink>
        </div>
      </nav>

      <div class="admin-sidebar__user">
        <div class="admin-sidebar__avatar">{{ auth.initials }}</div>
        <div class="admin-sidebar__user-info">
          <p class="admin-sidebar__user-name">{{ auth.displayName }}</p>
          <p class="admin-sidebar__user-role">{{ auth.isSuperAdmin ? 'Super Admin' : 'Admin' }}</p>
        </div>
        <button type="button" class="admin-sidebar__signout" aria-label="Keluar" @click="handleSignOut">
          <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9" /></svg>
        </button>
      </div>
    </aside>

    <main class="admin-main">
      <RouterView />
    </main>
  </div>
</template>

<style scoped>
.admin-layout {
  display: flex;
  min-height: 100vh;
}

.admin-sidebar {
  width: 240px;
  flex-shrink: 0;
  background: var(--color-neutral-900);
  display: flex;
  flex-direction: column;
  position: sticky;
  top: 0;
  height: 100vh;
  overflow-y: auto;
}

.admin-sidebar__header {
  padding: var(--space-5) var(--space-4) var(--space-4);
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.admin-sidebar__brand {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  text-decoration: none;
  margin-bottom: var(--space-1);
}

.admin-sidebar__brand-name {
  color: var(--color-neutral-0);
  font-weight: var(--fw-bold);
  font-size: var(--fs-lg);
  letter-spacing: 0.05em;
}

.admin-sidebar__label {
  color: var(--color-neutral-400);
  font-size: var(--fs-xs);
  font-weight: var(--fw-medium);
  text-transform: uppercase;
  letter-spacing: 0.08em;
}

.admin-sidebar__nav {
  flex: 1;
  padding: var(--space-4);
  display: flex;
  flex-direction: column;
  gap: var(--space-6);
}

.admin-nav-section__title {
  color: var(--color-neutral-400);
  font-size: var(--fs-xs);
  font-weight: var(--fw-semibold);
  text-transform: uppercase;
  letter-spacing: 0.08em;
  margin-bottom: var(--space-2);
  padding-left: var(--space-3);
}

.admin-nav-link {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  padding: var(--space-2) var(--space-3);
  border-radius: var(--radius-md);
  color: var(--color-neutral-300);
  font-size: var(--fs-sm);
  font-weight: var(--fw-medium);
  text-decoration: none;
  transition: all var(--transition-fast);
}

.admin-nav-link:hover {
  color: var(--color-neutral-0);
  background: rgba(255, 255, 255, 0.08);
}

.admin-nav-link--active {
  color: var(--color-neutral-0);
  background: var(--color-primary-500);
}

.admin-sidebar__user {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  padding: var(--space-4);
  border-top: 1px solid rgba(255, 255, 255, 0.08);
}

.admin-sidebar__avatar {
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

.admin-sidebar__user-info {
  flex: 1;
  min-width: 0;
}

.admin-sidebar__user-name {
  color: var(--color-neutral-0);
  font-size: var(--fs-sm);
  font-weight: var(--fw-medium);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.admin-sidebar__user-role {
  color: var(--color-neutral-400);
  font-size: var(--fs-xs);
}

.admin-sidebar__signout {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border-radius: var(--radius-md);
  color: var(--color-neutral-400);
  background: transparent;
  transition: all var(--transition-fast);
  flex-shrink: 0;
}

.admin-sidebar__signout:hover {
  color: var(--color-neutral-0);
  background: rgba(255, 255, 255, 0.08);
}

.admin-main {
  flex: 1;
  min-width: 0;
  background: var(--color-bg);
  overflow-y: auto;
}

@media (max-width: 767px) {
  .admin-layout {
    flex-direction: column;
  }
  .admin-sidebar {
    width: 100%;
    height: auto;
    position: static;
  }
  .admin-sidebar__nav {
    flex-direction: row;
    flex-wrap: wrap;
    gap: var(--space-2);
  }
  .admin-nav-section {
    display: contents;
  }
  .admin-nav-section__title {
    display: none;
  }
}
</style>
