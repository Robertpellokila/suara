<script setup>
/**
 * RegisterView — email/password sign-up using Supabase Auth.
 *
 * On signup, the handle_new_user database trigger automatically creates a
 * profile row. The user is then redirected to the Explore page.
 */
import { ref, computed } from 'vue'
import { useRouter, RouterLink } from 'vue-router'
import { useAuthStore } from '../stores/useAuthStore'
import BaseButton from '../base/BaseButton.vue'
import BaseCard from '../base/BaseCard.vue'

const router = useRouter()
const auth = useAuthStore()

const displayName = ref('')
const email = ref('')
const password = ref('')
const confirmPassword = ref('')
const showPassword = ref(false)
const submitting = ref(false)
const formError = ref(null)

const passwordsMatch = computed(() => password.value === confirmPassword.value)
const isFormValid = computed(() =>
  displayName.value.trim() &&
  email.value.trim() &&
  password.value.length >= 6 &&
  passwordsMatch.value
)

async function handleSubmit() {
  if (!isFormValid.value) return
  submitting.value = true
  formError.value = null

  const { error } = await auth.signUp(email.value.trim(), password.value, displayName.value.trim())

  if (error) {
    formError.value = error.message
    submitting.value = false
  } else {
    router.push({ name: 'explore' })
  }
}
</script>

<template>
  <div class="auth-page">
    <div class="container auth-page__inner">
      <div class="auth-card">
        <BaseCard padding="lg" shadow="md">
          <div class="auth-card__header">
            <svg class="auth-card__logo" viewBox="0 0 32 32" fill="none" aria-hidden="true">
              <rect width="32" height="32" rx="8" fill="var(--color-primary-500)" />
              <path
                d="M10 9h9a3 3 0 0 1 3 3v3a3 3 0 0 1-3 3h-2l3 5h-3l-3-5h-1v5h-3V9z"
                fill="var(--color-neutral-0)"
              />
            </svg>
            <h1 class="auth-card__title">Daftar Akun SUARA</h1>
            <p class="auth-card__subtitle">Buat akun untuk berpartisipasi dalam pemilihan.</p>
          </div>

          <form class="auth-form" @submit.prevent="handleSubmit">
            <div class="auth-form__field">
              <label for="reg-name" class="auth-form__label">Nama Lengkap</label>
              <input
                id="reg-name"
                v-model="displayName"
                type="text"
                class="auth-form__input"
                placeholder="Nama Anda"
                autocomplete="name"
                required
                :disabled="submitting"
              />
            </div>

            <div class="auth-form__field">
              <label for="reg-email" class="auth-form__label">Email</label>
              <input
                id="reg-email"
                v-model="email"
                type="email"
                class="auth-form__input"
                placeholder="nama@email.com"
                autocomplete="email"
                required
                :disabled="submitting"
              />
            </div>

            <div class="auth-form__field">
              <label for="reg-password" class="auth-form__label">Kata Sandi</label>
              <div class="auth-form__password-field">
                <input
                  id="reg-password"
                  v-model="password"
                  :type="showPassword ? 'text' : 'password'"
                  class="auth-form__input"
                  placeholder="Minimal 6 karakter"
                  autocomplete="new-password"
                  required
                  minlength="6"
                  :disabled="submitting"
                />
                <button
                  type="button"
                  class="auth-form__toggle"
                  :aria-label="showPassword ? 'Sembunyikan kata sandi' : 'Tampilkan kata sandi'"
                  @click="showPassword = !showPassword"
                >
                  <svg v-if="showPassword" viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24" /><line x1="1" y1="1" x2="23" y2="23" /></svg>
                  <svg v-else viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" /><circle cx="12" cy="12" r="3" /></svg>
                </button>
              </div>
            </div>

            <div class="auth-form__field">
              <label for="reg-confirm" class="auth-form__label">Konfirmasi Kata Sandi</label>
              <input
                id="reg-confirm"
                v-model="confirmPassword"
                :type="showPassword ? 'text' : 'password'"
                class="auth-form__input"
                :class="{ 'auth-form__input--error': confirmPassword && !passwordsMatch }"
                placeholder="Ulangi kata sandi"
                autocomplete="new-password"
                required
                minlength="6"
                :disabled="submitting"
              />
              <p v-if="confirmPassword && !passwordsMatch" class="auth-form__hint auth-form__hint--error">
                Kata sandi tidak cocok
              </p>
            </div>

            <Transition name="fade">
              <p v-if="formError" class="auth-form__error" role="alert">
                {{ formError }}
              </p>
            </Transition>

            <BaseButton type="submit" variant="primary" full-width :loading="submitting" :disabled="!isFormValid">
              Daftar
            </BaseButton>
          </form>

          <p class="auth-card__footer">
            Sudah punya akun?
            <RouterLink :to="{ name: 'login' }" class="auth-card__link">Masuk di sini</RouterLink>
          </p>
        </BaseCard>
      </div>
    </div>
  </div>
</template>

<style scoped>
.auth-page {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: calc(100vh - 64px);
  padding: var(--space-8) var(--space-4);
  background: linear-gradient(135deg, var(--color-primary-50) 0%, var(--color-bg) 100%);
}

.auth-page__inner {
  display: flex;
  justify-content: center;
  width: 100%;
}

.auth-card {
  width: 100%;
  max-width: 440px;
}

.auth-card__header {
  text-align: center;
  margin-bottom: var(--space-6);
}

.auth-card__logo {
  width: 48px;
  height: 48px;
  border-radius: var(--radius-lg);
  margin: 0 auto var(--space-4);
}

.auth-card__title {
  font-size: var(--fs-2xl);
  font-weight: var(--fw-bold);
  margin-bottom: var(--space-1);
}

.auth-card__subtitle {
  color: var(--color-text-secondary);
  font-size: var(--fs-sm);
}

.auth-form {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.auth-form__field {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.auth-form__label {
  font-size: var(--fs-sm);
  font-weight: var(--fw-medium);
  color: var(--color-text-primary);
}

.auth-form__input {
  width: 100%;
  min-height: 48px;
  padding: 0 var(--space-4);
  font-size: var(--fs-base);
  color: var(--color-text-primary);
  background: var(--color-surface);
  border: 1.5px solid var(--color-border);
  border-radius: var(--radius-lg);
  transition: border-color var(--transition-fast), box-shadow var(--transition-fast);
  appearance: none;
}

.auth-form__input::placeholder {
  color: var(--color-text-secondary);
}

.auth-form__input:focus {
  border-color: var(--color-primary-500);
  box-shadow: 0 0 0 3px var(--color-primary-100);
  outline: none;
}

.auth-form__input--error {
  border-color: var(--color-error-500);
}

.auth-form__hint {
  font-size: var(--fs-xs);
  color: var(--color-text-secondary);
}

.auth-form__hint--error {
  color: var(--color-error-600);
}

.auth-form__password-field {
  position: relative;
}

.auth-form__toggle {
  position: absolute;
  right: var(--space-3);
  top: 50%;
  transform: translateY(-50%);
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

.auth-form__toggle:hover {
  background: var(--color-surface-hover);
  color: var(--color-text-primary);
}

.auth-form__error {
  background: var(--color-error-50);
  color: var(--color-error-700);
  font-size: var(--fs-sm);
  padding: var(--space-3);
  border-radius: var(--radius-md);
  border: 1px solid var(--color-error-100);
}

.auth-card__footer {
  text-align: center;
  margin-top: var(--space-6);
  font-size: var(--fs-sm);
  color: var(--color-text-secondary);
}

.auth-card__link {
  font-weight: var(--fw-semibold);
  color: var(--color-primary-500);
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity var(--transition-fast);
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
