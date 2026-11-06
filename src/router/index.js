import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/useAuthStore'

/**
 * Public routes for the SUARA frontend.
 *
 * Route guards here only assist navigation — they do NOT authorize access to
 * election data. Authorization is always enforced by the backend.
 */

const routes = [
  {
    path: '/',
    name: 'home',
    component: () => import('../views/HomeView.vue'),
    meta: { title: 'SUARA — One Person. One Vote. Every Voice Matters.' },
  },
  {
    path: '/login',
    name: 'login',
    component: () => import('../views/LoginView.vue'),
    meta: { title: 'Masuk — SUARA', guestOnly: true },
  },
  {
    path: '/register',
    name: 'register',
    component: () => import('../views/RegisterView.vue'),
    meta: { title: 'Daftar — SUARA', guestOnly: true },
  },
  {
    path: '/explore',
    name: 'explore',
    component: () => import('../views/ExploreView.vue'),
    meta: { title: 'Explore Elections — SUARA' },
  },
  {
    path: '/explore/:slug',
    name: 'detail',
    component: () => import('../views/DetailView.vue'),
    props: true,
    meta: { title: 'Election Details — SUARA' },
  },
  {
    path: '/about',
    name: 'about',
    component: () => import('../views/AboutView.vue'),
    meta: { title: 'About — SUARA' },
  },
  {
    path: '/admin',
    component: () => import('../layout/AdminLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'admin-overview',
        component: () => import('../views/admin/AdminOverviewView.vue'),
        meta: { title: 'Ringkasan Admin — SUARA' },
      },
      {
        path: 'organizations',
        name: 'admin-super',
        component: () => import('../views/admin/AdminSuperView.vue'),
        meta: { title: 'Registry Organisasi — SUARA', requiresSuperAdmin: true },
      },
    ],
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'not-found',
    component: () => import('../views/NotFoundView.vue'),
    meta: { title: 'Page Not Found — SUARA' },
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(_to, _from, savedPosition) {
    return savedPosition ?? { top: 0 }
  },
})

router.beforeEach((to, _from, next) => {
  if (to.meta?.title) {
    document.title = to.meta.title
  }

  const auth = useAuthStore()

  // Guest-only routes (login, register) redirect to home if already logged in
  if (to.meta?.guestOnly && auth.isAuthenticated) {
    next({ name: 'home' })
    return
  }

  if (to.meta?.requiresAuth && !auth.isAuthenticated) {
    next({ name: 'login' })
    return
  }

  if (to.meta?.requiresSuperAdmin && !auth.isSuperAdmin) {
    next({ name: 'home' })
    return
  }

  next()
})

export default router
