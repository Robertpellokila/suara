<script setup>
/**
 * HomeView — landing page for SUARA.
 *
 * Explains the platform, shows the voting flow steps, and links to the Explore
 * page. No election data is shown without eligibility — the "Jelajahi" CTA
 * leads to the eligibility-gated Explore view.
 */
import { RouterLink } from 'vue-router'
import BaseButton from '../base/BaseButton.vue'
import BaseCard from '../base/BaseCard.vue'

const features = [
  {
    icon: 'shield',
    title: 'Verifikasi Identitas',
    desc: 'Identitas pemilih diverifikasi sebelum mendapat hak pilih. Tidak ada yang bisa memilih tanpa proses ini.',
  },
  {
    icon: 'lock',
    title: 'Privasi Suara',
    desc: 'Pilihan kandidat dan identitas pemilih disimpan secara terpisah. Pilihan Anda tidak dapat dilacak.',
  },
  {
    icon: 'check',
    title: 'One Person, One Vote',
    desc: 'Setiap pemilih hanya dapat memberikan satu suara per pemilihan. Sistem mencegah duplikasi.',
  },
  {
    icon: 'building',
    title: 'Isolasi Organisasi',
    desc: 'Setiap sekolah dan organisasi memiliki data terpisah. Tidak ada akses lintas organisasi.',
  },
]

const steps = [
  { num: 1, title: 'Verifikasi', desc: 'Status identitas dan eligibility diperiksa.' },
  { num: 2, title: 'Pilih', desc: 'Lihat kandidat dengan visual treatment setara.' },
  { num: 3, title: 'Konfirmasi', desc: 'Pastikan pilihan Anda sebelum mengirim.' },
  { num: 4, title: 'Selesai', desc: 'Terima tanda terima tanpa membocorkan pilihan.' },
]

const heroImage = 'https://images.pexels.com/photos/1550337/pexels-photo-1550337.jpeg?auto=compress&cs=tinysrgb&w=1200'
</script>

<template>
  <div class="home">
    <!-- Hero -->
    <section class="hero">
      <div class="container hero__inner">
        <div class="hero__content">
          <span class="hero__badge">Platform Pemilihan Digital</span>
          <h1 class="hero__title">
            One Person.<br />
            One Vote.<br />
            <span class="hero__accent">Every Voice Matters.</span>
          </h1>
          <p class="hero__desc">
            SUARA menggantikan pemungutan suara manual dengan sistem digital yang aman,
            terverifikasi, dan terisolasi per organisasi. Dirancang untuk sekolah, kampus,
            komunitas, dan organisasi.
          </p>
          <div class="hero__actions">
            <RouterLink :to="{ name: 'explore' }">
              <BaseButton variant="primary">Jelajahi Pemilihan</BaseButton>
            </RouterLink>
            <RouterLink :to="{ name: 'about' }">
              <BaseButton variant="outline">Pelajari Lebih Lanjut</BaseButton>
            </RouterLink>
          </div>
        </div>
        <div class="hero__image">
          <img :src="heroImage" alt="Tangan memasukkan surat suara ke kotak pilihan — simbol demokrasi" />
        </div>
      </div>
    </section>

    <!-- Features -->
    <section class="features">
      <div class="container">
        <h2 class="section-title">Mengapa SUARA?</h2>
        <p class="section-subtitle">
          Bukan sekadar website voting — sebuah sistem pemilihan digital yang dapat dipercaya.
        </p>
        <div class="features__grid">
          <BaseCard
            v-for="feature in features"
            :key="feature.title"
            padding="md"
            shadow="sm"
            hoverable
          >
            <div class="feature">
              <div class="feature__icon">
                <svg v-if="feature.icon === 'shield'" viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2L3 7v5c0 5 3.5 9.5 9 11 5.5-1.5 9-6 9-11V7l-9-5z" /><path d="M9 12l2 2 4-4" /></svg>
                <svg v-else-if="feature.icon === 'lock'" viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" stroke-width="2"><rect x="5" y="11" width="14" height="10" rx="2" /><path d="M8 11V7a4 4 0 0 1 8 0v4" /></svg>
                <svg v-else-if="feature.icon === 'check'" viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10" /><path d="M8 12l3 3 5-5" /></svg>
                <svg v-else viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 21h18M5 21V7l7-4 7 4v14M9 21V12h6v9" /></svg>
              </div>
              <h3 class="feature__title">{{ feature.title }}</h3>
              <p class="feature__desc">{{ feature.desc }}</p>
            </div>
          </BaseCard>
        </div>
      </div>
    </section>

    <!-- Voting flow -->
    <section class="flow">
      <div class="container">
        <h2 class="section-title">Cara Memilih</h2>
        <p class="section-subtitle">Empat langkah sederhana dan jelas.</p>
        <div class="flow__steps">
          <div v-for="step in steps" :key="step.num" class="flow__step">
            <div class="flow__num">{{ step.num }}</div>
            <h3 class="flow__title">{{ step.title }}</h3>
            <p class="flow__desc">{{ step.desc }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA -->
    <section class="cta">
      <div class="container">
        <BaseCard padding="lg" shadow="md">
          <div class="cta__inner">
            <h2 class="cta__title">Siap memulai pemilihan digital?</h2>
            <p class="cta__desc">
              Lihat pemilihan yang tersedia untuk Anda. Hanya pemilihan yang Anda berhak ikuti yang ditampilkan.
            </p>
            <RouterLink :to="{ name: 'explore' }">
              <BaseButton variant="primary" :full-width="false">Lihat Pemilihan Saya</BaseButton>
            </RouterLink>
          </div>
        </BaseCard>
      </div>
    </section>
  </div>
</template>

<style scoped>
/* Hero */
.hero {
  background: linear-gradient(135deg, var(--color-primary-50) 0%, var(--color-bg) 60%);
  padding: var(--space-16) 0 var(--space-12);
  overflow: hidden;
}

.hero__inner {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-8);
  text-align: center;
}

.hero__content {
  max-width: 600px;
}

.hero__badge {
  display: inline-block;
  padding: var(--space-2) var(--space-4);
  background: var(--color-primary-100);
  color: var(--color-primary-600);
  border-radius: var(--radius-full);
  font-size: var(--fs-sm);
  font-weight: var(--fw-semibold);
  margin-bottom: var(--space-4);
}

.hero__title {
  font-size: clamp(2.25rem, 6vw, 3.75rem);
  line-height: 1.05;
  font-weight: var(--fw-bold);
  color: var(--color-text-primary);
  margin-bottom: var(--space-4);
}

.hero__accent {
  color: var(--color-primary-500);
}

.hero__desc {
  font-size: var(--fs-lg);
  color: var(--color-text-secondary);
  line-height: var(--lh-base);
  margin-bottom: var(--space-6);
}

.hero__actions {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-3);
  justify-content: center;
}

.hero__image {
  width: 100%;
  max-width: 600px;
  border-radius: var(--radius-2xl);
  overflow: hidden;
  box-shadow: var(--shadow-xl);
}

.hero__image img {
  width: 100%;
  height: auto;
  aspect-ratio: 3 / 2;
  object-fit: cover;
}

/* Sections */
.section-title {
  font-size: var(--fs-3xl);
  font-weight: var(--fw-bold);
  text-align: center;
  margin-bottom: var(--space-2);
}

.section-subtitle {
  text-align: center;
  color: var(--color-text-secondary);
  font-size: var(--fs-lg);
  margin-bottom: var(--space-10);
}

/* Features */
.features {
  padding: var(--space-16) 0;
}

.features__grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: var(--space-5);
}

@media (min-width: 640px) {
  .features__grid { grid-template-columns: repeat(2, 1fr); }
}

@media (min-width: 1024px) {
  .features__grid { grid-template-columns: repeat(4, 1fr); }
}

.feature {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
  height: 100%;
}

.feature__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 56px;
  height: 56px;
  border-radius: var(--radius-lg);
  background: var(--color-primary-50);
  color: var(--color-primary-500);
}

.feature__title {
  font-size: var(--fs-lg);
  font-weight: var(--fw-semibold);
}

.feature__desc {
  font-size: var(--fs-sm);
  color: var(--color-text-secondary);
  line-height: var(--lh-base);
}

/* Flow */
.flow {
  padding: var(--space-12) 0 var(--space-16);
  background: var(--color-neutral-50);
}

.flow__steps {
  display: grid;
  grid-template-columns: 1fr;
  gap: var(--space-6);
}

@media (min-width: 640px) {
  .flow__steps { grid-template-columns: repeat(2, 1fr); }
}

@media (min-width: 1024px) {
  .flow__steps { grid-template-columns: repeat(4, 1fr); }
}

.flow__step {
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-2);
}

.flow__num {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 56px;
  height: 56px;
  border-radius: var(--radius-full);
  background: var(--color-primary-500);
  color: var(--color-neutral-0);
  font-size: var(--fs-xl);
  font-weight: var(--fw-bold);
  margin-bottom: var(--space-2);
}

.flow__title {
  font-size: var(--fs-lg);
  font-weight: var(--fw-semibold);
}

.flow__desc {
  font-size: var(--fs-sm);
  color: var(--color-text-secondary);
}

/* CTA */
.cta {
  padding: var(--space-12) 0 var(--space-16);
}

.cta__inner {
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-3);
}

.cta__title {
  font-size: var(--fs-2xl);
  font-weight: var(--fw-bold);
}

.cta__desc {
  font-size: var(--fs-base);
  color: var(--color-text-secondary);
  max-width: 480px;
}

@media (min-width: 768px) {
  .hero {
    padding: var(--space-20) 0 var(--space-16);
  }
  .hero__inner {
    flex-direction: row;
    align-items: center;
    text-align: left;
  }
  .hero__content {
    flex: 1;
  }
  .hero__image {
    flex: 1;
  }
  .hero__actions {
    justify-content: flex-start;
  }
}
</style>
