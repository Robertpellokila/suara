<script setup>
/**
 * AboutView — explains SUARA's mission, architecture, and security principles.
 */
import { RouterLink } from 'vue-router'
import BaseButton from '../base/BaseButton.vue'
import BaseCard from '../base/BaseCard.vue'

const principles = [
  { num: 1, title: 'One Person, One Vote', desc: 'Setiap pemilih hanya dapat memberikan satu suara per pemilihan.' },
  { num: 2, title: 'One Organization, Isolated Data', desc: 'Data setiap organisasi terisolasi. Tidak ada akses lintas tenant.' },
  { num: 3, title: 'Verified Identity Before Eligibility', desc: 'Identitas diverifikasi sebelum mendapat hak pilih.' },
  { num: 4, title: 'Eligibility Before Voting', desc: 'Backend memastikan eligibility pada setiap operasi.' },
  { num: 5, title: 'Server-Side Authorization Always', desc: 'Frontend tidak dipercaya untuk otorisasi.' },
  { num: 6, title: 'Privacy by Design', desc: 'Pilihan kandidat dan identitas pemilih disimpan terpisah.' },
  { num: 7, title: 'Neutral Candidate Presentation', desc: 'Semua kandidat mendapat visual treatment setara.' },
  { num: 8, title: 'Transparent Election Management', desc: 'Audit log mencatat setiap perubahan administratif.' },
]

const roadmap = [
  { phase: 'P0', title: 'Core Security & Foundation', desc: 'Organization registry, verification, multi-tenant isolation, role & permission, voting integrity, audit logs.' },
  { phase: 'P1', title: 'School Operations', desc: 'Student management, bulk import, class management, election readiness, test mode, participation dashboard.' },
  { phase: 'P2', title: 'Reporting & Experience', desc: 'Result publication, privacy threshold, notifications, multilingual, accessibility, dispute reporting.' },
  { phase: 'P3', title: 'Advanced Security & Scale', desc: 'Security audit, penetration testing, unlinkable voting credentials, backup, disaster recovery.' },
]
</script>

<template>
  <div class="about">
    <!-- Hero -->
    <section class="about__hero">
      <div class="container">
        <span class="about__badge">Tentang SUARA</span>
        <h1 class="about__title">Platform pemilihan digital yang dapat dipercaya</h1>
        <p class="about__lead">
          SUARA bukan sekadar website dengan daftar kandidat dan tombol vote. SUARA adalah
          sistem pemilihan digital dengan pengelolaan organisasi, identitas pemilih, hak pilih,
          integritas suara, privasi, dan pelaporan yang transparan.
        </p>
      </div>
    </section>

    <!-- Principles -->
    <section class="about__section">
      <div class="container">
        <h2 class="section-title">Prinsip Produk</h2>
        <p class="section-subtitle">Setiap keputusan teknis dan desain mengikuti prinsip ini.</p>
        <div class="about__principles">
          <div v-for="p in principles" :key="p.num" class="principle">
            <span class="principle__num">{{ p.num }}</span>
            <h3 class="principle__title">{{ p.title }}</h3>
            <p class="principle__desc">{{ p.desc }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Target -->
    <section class="about__section about__section--alt">
      <div class="container">
        <h2 class="section-title">Untuk Siapa?</h2>
        <p class="section-subtitle">Pilot pertama berfokus pada sekolah, dengan arsitektur yang siap berkembang.</p>
        <div class="about__targets">
          <BaseCard padding="md" shadow="sm" hoverable>
            <h3 class="target__title">Sekolah</h3>
            <p class="target__desc">Ketua OSIS, Ketua Kelas, perwakilan siswa. Pilot pertama.</p>
          </BaseCard>
          <BaseCard padding="md" shadow="sm" hoverable>
            <h3 class="target__title">Kampus</h3>
            <p class="target__desc">BEM, himpunan mahasiswa, organisasi mahasiswa.</p>
          </BaseCard>
          <BaseCard padding="md" shadow="sm" hoverable>
            <h3 class="target__title">Komunitas</h3>
            <p class="target__desc">Pemilihan pengurus komunitas dan organisasi internal.</p>
          </BaseCard>
          <BaseCard padding="md" shadow="sm" hoverable>
            <h3 class="target__title">Organisasi</h3>
            <p class="target__desc">Pemilihan pengurus internal organisasi.</p>
          </BaseCard>
        </div>
      </div>
    </section>

    <!-- Roadmap -->
    <section class="about__section">
      <div class="container">
        <h2 class="section-title">Roadmap Pengembangan</h2>
        <p class="section-subtitle">Implementasi bertahap, bukan sekali jadi.</p>
        <div class="about__roadmap">
          <div v-for="r in roadmap" :key="r.phase" class="roadmap-item">
            <span class="roadmap-item__phase">{{ r.phase }}</span>
            <div class="roadmap-item__body">
              <h3 class="roadmap-item__title">{{ r.title }}</h3>
              <p class="roadmap-item__desc">{{ r.desc }}</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA -->
    <section class="about__cta">
      <div class="container">
        <BaseCard padding="lg" shadow="md">
          <div class="about__cta-inner">
            <h2 class="about__cta-title">Mulai menjelajahi pemilihan</h2>
            <p class="about__cta-desc">Lihat pemilihan yang berhak Anda ikuti.</p>
            <RouterLink :to="{ name: 'explore' }">
              <BaseButton variant="primary">Jelajahi Pemilihan</BaseButton>
            </RouterLink>
          </div>
        </BaseCard>
      </div>
    </section>
  </div>
</template>

<style scoped>
.about__hero {
  background: linear-gradient(135deg, var(--color-primary-50) 0%, var(--color-bg) 100%);
  padding: var(--space-16) 0 var(--space-12);
  text-align: center;
}

.about__badge {
  display: inline-block;
  padding: var(--space-2) var(--space-4);
  background: var(--color-primary-100);
  color: var(--color-primary-600);
  border-radius: var(--radius-full);
  font-size: var(--fs-sm);
  font-weight: var(--fw-semibold);
  margin-bottom: var(--space-4);
}

.about__title {
  font-size: clamp(2rem, 5vw, 3rem);
  font-weight: var(--fw-bold);
  margin-bottom: var(--space-4);
  max-width: 700px;
  margin-inline: auto;
}

.about__lead {
  font-size: var(--fs-lg);
  color: var(--color-text-secondary);
  line-height: var(--lh-base);
  max-width: 640px;
  margin-inline: auto;
}

.about__section {
  padding: var(--space-12) 0;
}

.about__section--alt {
  background: var(--color-neutral-50);
}

.section-title {
  font-size: var(--fs-2xl);
  font-weight: var(--fw-bold);
  text-align: center;
  margin-bottom: var(--space-2);
}

.section-subtitle {
  text-align: center;
  color: var(--color-text-secondary);
  font-size: var(--fs-base);
  margin-bottom: var(--space-8);
}

.about__principles {
  display: grid;
  grid-template-columns: 1fr;
  gap: var(--space-4);
}

@media (min-width: 640px) { .about__principles { grid-template-columns: repeat(2, 1fr); } }
@media (min-width: 1024px) { .about__principles { grid-template-columns: repeat(4, 1fr); } }

.principle {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
  padding: var(--space-5);
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
}

.principle__num {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border-radius: var(--radius-full);
  background: var(--color-primary-50);
  color: var(--color-primary-500);
  font-weight: var(--fw-bold);
  font-size: var(--fs-sm);
  margin-bottom: var(--space-1);
}

.principle__title {
  font-size: var(--fs-base);
  font-weight: var(--fw-semibold);
}

.principle__desc {
  font-size: var(--fs-sm);
  color: var(--color-text-secondary);
  line-height: var(--lh-base);
}

.about__targets {
  display: grid;
  grid-template-columns: 1fr;
  gap: var(--space-4);
}

@media (min-width: 640px) { .about__targets { grid-template-columns: repeat(2, 1fr); } }
@media (min-width: 1024px) { .about__targets { grid-template-columns: repeat(4, 1fr); } }

.target__title {
  font-size: var(--fs-lg);
  font-weight: var(--fw-semibold);
  margin-bottom: var(--space-2);
}

.target__desc {
  font-size: var(--fs-sm);
  color: var(--color-text-secondary);
}

.about__roadmap {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
  max-width: 720px;
  margin-inline: auto;
}

.roadmap-item {
  display: flex;
  gap: var(--space-4);
  padding: var(--space-5);
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
}

.roadmap-item__phase {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  flex-shrink: 0;
  border-radius: var(--radius-md);
  background: var(--color-primary-500);
  color: var(--color-neutral-0);
  font-weight: var(--fw-bold);
  font-size: var(--fs-sm);
}

.roadmap-item__title {
  font-size: var(--fs-base);
  font-weight: var(--fw-semibold);
  margin-bottom: var(--space-1);
}

.roadmap-item__desc {
  font-size: var(--fs-sm);
  color: var(--color-text-secondary);
  line-height: var(--lh-base);
}

.about__cta {
  padding: var(--space-8) 0 var(--space-16);
}

.about__cta-inner {
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-2);
}

.about__cta-title {
  font-size: var(--fs-xl);
  font-weight: var(--fw-bold);
}

.about__cta-desc {
  color: var(--color-text-secondary);
  margin-bottom: var(--space-3);
}
</style>
