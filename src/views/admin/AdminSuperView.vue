<script setup>
/**
 * AdminSuperView — Super Admin organization registry.
 * Create organizations, verify/suspend them, view all orgs.
 * Only accessible to super admins (route guard enforces this).
 */
import { ref, onMounted } from 'vue'
import {
  fetchAllOrganizations,
  createOrganization,
  updateOrganizationStatus,
} from '../../services/organizationService'
import BaseButton from '../../base/BaseButton.vue'
import BaseCard from '../../base/BaseCard.vue'

const orgs = ref([])
const loading = ref(true)
const error = ref(null)
const showCreateForm = ref(false)
const submitting = ref(false)
const formError = ref(null)

const form = ref({ name: '', type: 'school' })

const statusConfig = {
  pending: { label: 'Menunggu', cls: 'status--warning' },
  verified: { label: 'Terverifikasi', cls: 'status--success' },
  suspended: { label: 'Ditangguhkan', cls: 'status--error' },
}

onMounted(loadOrgs)

async function loadOrgs() {
  loading.value = true
  error.value = null
  try {
    orgs.value = await fetchAllOrganizations()
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

async function handleCreate() {
  submitting.value = true
  formError.value = null
  try {
    await createOrganization({ name: form.value.name, type: form.value.type, status: 'pending' })
    form.value = { name: '', type: 'school' }
    showCreateForm.value = false
    await loadOrgs()
  } catch (err) {
    formError.value = err.message
  } finally {
    submitting.value = false
  }
}

async function handleStatusChange(org, status) {
  try {
    await updateOrganizationStatus(org.id, status)
    await loadOrgs()
  } catch (err) {
    error.value = err.message
  }
}
</script>

<template>
  <div class="super-admin">
    <header class="admin-page-header">
      <div class="admin-page-header__row">
        <div>
          <h1 class="admin-page-title">Registry Organisasi</h1>
          <p class="admin-page-subtitle">Daftarkan dan verifikasi organisasi. Hanya Super Admin.</p>
        </div>
        <BaseButton variant="primary" @click="showCreateForm = !showCreateForm">
          {{ showCreateForm ? 'Batal' : 'Daftarkan Organisasi' }}
        </BaseButton>
      </div>
    </header>

    <Transition name="fade">
      <BaseCard v-if="showCreateForm" padding="lg" shadow="sm" class="super-admin__form-card">
        <h2 class="form-title">Daftarkan Organisasi Baru</h2>
        <form class="admin-form" @submit.prevent="handleCreate">
          <div class="admin-form__field">
            <label for="org-name" class="admin-form__label">Nama Organisasi</label>
            <input id="org-name" v-model="form.name" type="text" class="admin-form__input" placeholder="contoh: SMA Negeri 1 Jakarta" required :disabled="submitting" />
          </div>
          <div class="admin-form__field">
            <label for="org-type" class="admin-form__label">Jenis</label>
            <select id="org-type" v-model="form.type" class="admin-form__select" :disabled="submitting">
              <option value="school">Sekolah</option>
              <option value="campus">Kampus</option>
              <option value="community">Komunitas</option>
              <option value="organization">Organisasi</option>
            </select>
          </div>
          <p v-if="formError" class="admin-form__error" role="alert">{{ formError }}</p>
          <div class="admin-form__actions">
            <BaseButton type="submit" variant="primary" :loading="submitting" :disabled="!form.name.trim()">Daftarkan</BaseButton>
            <BaseButton variant="ghost" @click="showCreateForm = false">Batal</BaseButton>
          </div>
        </form>
      </BaseCard>
    </Transition>

    <p v-if="error" class="page-error">{{ error }}</p>

    <BaseCard padding="none" shadow="sm">
      <div class="table-wrapper">
        <table class="data-table" aria-label="Daftar organisasi">
          <thead>
            <tr>
              <th>Nama</th>
              <th>Jenis</th>
              <th>Status</th>
              <th>Dibuat</th>
              <th>Aksi</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="loading">
              <td colspan="5" class="table-loading">Memuat data...</td>
            </tr>
            <tr v-else-if="orgs.length === 0">
              <td colspan="5" class="table-empty">Belum ada organisasi terdaftar.</td>
            </tr>
            <tr v-for="org in orgs" :key="org.id">
              <td class="td-name">{{ org.name }}</td>
              <td>{{ org.type }}</td>
              <td>
                <span class="status-badge" :class="statusConfig[org.status]?.cls">
                  {{ statusConfig[org.status]?.label ?? org.status }}
                </span>
              </td>
              <td class="td-date">{{ new Date(org.created_at).toLocaleDateString('id-ID') }}</td>
              <td>
                <div class="td-actions">
                  <button v-if="org.status === 'pending'" type="button" class="action-btn action-btn--success" @click="handleStatusChange(org, 'verified')">Verifikasi</button>
                  <button v-if="org.status === 'verified'" type="button" class="action-btn action-btn--danger" @click="handleStatusChange(org, 'suspended')">Tangguhkan</button>
                  <button v-if="org.status === 'suspended'" type="button" class="action-btn action-btn--primary" @click="handleStatusChange(org, 'verified')">Aktifkan Lagi</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </BaseCard>
  </div>
</template>

<style scoped>
.super-admin { padding: var(--space-6); }
.admin-page-header { margin-bottom: var(--space-6); }
.admin-page-header__row { display: flex; justify-content: space-between; align-items: flex-start; gap: var(--space-4); flex-wrap: wrap; }
.admin-page-title { font-size: var(--fs-2xl); font-weight: var(--fw-bold); }
.admin-page-subtitle { color: var(--color-text-secondary); font-size: var(--fs-sm); margin-top: var(--space-1); }
.super-admin__form-card { margin-bottom: var(--space-6); max-width: 560px; }
.form-title { font-size: var(--fs-lg); font-weight: var(--fw-semibold); margin-bottom: var(--space-5); }
.admin-form { display: flex; flex-direction: column; gap: var(--space-4); }
.admin-form__field { display: flex; flex-direction: column; gap: var(--space-2); }
.admin-form__label { font-size: var(--fs-sm); font-weight: var(--fw-medium); color: var(--color-text-primary); }
.admin-form__input, .admin-form__select { min-height: 44px; padding: 0 var(--space-4); font-size: var(--fs-base); border: 1.5px solid var(--color-border); border-radius: var(--radius-md); background: var(--color-surface); color: var(--color-text-primary); transition: border-color var(--transition-fast); }
.admin-form__input:focus, .admin-form__select:focus { border-color: var(--color-primary-500); outline: none; box-shadow: 0 0 0 3px var(--color-primary-100); }
.admin-form__select { appearance: none; background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='none' stroke='%2364748B' stroke-width='2'%3E%3Cpath d='M4 6l4 4 4-4'/%3E%3C/svg%3E"); background-repeat: no-repeat; background-position: right 12px center; padding-right: var(--space-8); }
.admin-form__error { background: var(--color-error-50); color: var(--color-error-700); font-size: var(--fs-sm); padding: var(--space-3); border-radius: var(--radius-md); }
.admin-form__actions { display: flex; gap: var(--space-3); }
.page-error { background: var(--color-error-50); color: var(--color-error-700); font-size: var(--fs-sm); padding: var(--space-3); border-radius: var(--radius-md); margin-bottom: var(--space-4); }
.table-wrapper { overflow-x: auto; }
.data-table { width: 100%; border-collapse: collapse; font-size: var(--fs-sm); }
.data-table th { padding: var(--space-3) var(--space-4); text-align: left; font-weight: var(--fw-semibold); color: var(--color-text-secondary); border-bottom: 1px solid var(--color-border); background: var(--color-neutral-50); font-size: var(--fs-xs); text-transform: uppercase; letter-spacing: 0.05em; }
.data-table td { padding: var(--space-4); border-bottom: 1px solid var(--color-border); color: var(--color-text-primary); vertical-align: middle; }
.data-table tbody tr:last-child td { border-bottom: none; }
.data-table tbody tr:hover td { background: var(--color-surface-hover); }
.td-name { font-weight: var(--fw-medium); max-width: 200px; }
.td-date { color: var(--color-text-secondary); white-space: nowrap; }
.table-loading, .table-empty { text-align: center; padding: var(--space-10) !important; color: var(--color-text-secondary); }
.td-actions { display: flex; gap: var(--space-2); }
.action-btn { padding: var(--space-1) var(--space-3); border-radius: var(--radius-md); font-size: var(--fs-xs); font-weight: var(--fw-semibold); cursor: pointer; transition: all var(--transition-fast); border: none; }
.action-btn--success { background: var(--color-success-50); color: var(--color-success-700); }
.action-btn--success:hover { background: var(--color-success-100); }
.action-btn--danger { background: var(--color-error-50); color: var(--color-error-700); }
.action-btn--danger:hover { background: var(--color-error-100); }
.action-btn--primary { background: var(--color-primary-50); color: var(--color-primary-600); }
.action-btn--primary:hover { background: var(--color-primary-100); }
.status-badge { display: inline-block; padding: 2px var(--space-3); border-radius: var(--radius-full); font-size: var(--fs-xs); font-weight: var(--fw-semibold); }
.status--success { background: var(--color-success-50); color: var(--color-success-700); }
.status--warning { background: var(--color-warning-50); color: var(--color-warning-600); }
.status--error { background: var(--color-error-50); color: var(--color-error-700); }
.fade-enter-active, .fade-leave-active { transition: opacity var(--transition-base); }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>
