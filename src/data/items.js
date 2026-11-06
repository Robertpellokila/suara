/**
 * Mock election data for Phase 2 frontend foundation.
 *
 * This is placeholder data representing the concept of an "eligible election"
 * that a verified voter would see. In production this list is populated by a
 * backend call that checks identity verification, organization membership, and
 * event eligibility — never a public catalog of all elections.
 *
 * Each item maps to the future elections/{electionId} document structure.
 */

export const electionStatuses = {
  DRAFT: 'draft',
  SCHEDULED: 'scheduled',
  ACTIVE: 'active',
  PAUSED: 'paused',
  COMPLETED: 'completed',
  ARCHIVED: 'archived',
}

export const electionTypes = {
  SCHOOL_WIDE: 'school_wide',
  CLASS_LEVEL: 'class_level',
  GRADE_LEVEL: 'grade_level',
  CUSTOM_GROUP: 'custom_group',
}

/**
 * @typedef {Object} ElectionItem
 * @property {string}  slug        - URL-friendly identifier (navigation only, NOT authorization)
 * @property {string}  title       - Display title
 * @property {string}  description - Short description
 * @property {string}  organization - Organization display name
 * @property {string}  electionType - One of electionTypes
 * @property {string}  status       - One of electionStatuses
 * @property {string}  startAt      - ISO date string
 * @property {string}  endAt        - ISO date string
 * @property {boolean} eligible    - Whether the current user is eligible (mock)
 * @property {string}  image       - Hero image URL from Pexels
 */

/** @type {ElectionItem[]} */
export const items = [
  {
    slug: 'pemilihan-ketua-osis-2026',
    title: 'Pemilihan Ketua OSIS 2026',
    description: 'Pemungutan suara tingkat sekolah untuk memilih Ketua OSIS periode 2026/2027.',
    organization: 'SMA Negeri 1 Jakarta',
    electionType: electionTypes.SCHOOL_WIDE,
    status: electionStatuses.ACTIVE,
    startAt: '2026-11-01T08:00:00+07:00',
    endAt: '2026-11-01T15:00:00+07:00',
    eligible: true,
    image: 'https://images.pexels.com/photos/207692/pexels-photo-207692.jpeg?auto=compress&cs=tinysrgb&w=800',
  },
  {
    slug: 'pemilihan-ketua-kelas-10a',
    title: 'Pemilihan Ketua Kelas 10A',
    description: 'Pemilihan ketua kelas untuk kelas 10A periode 2026/2027.',
    organization: 'SMA Negeri 1 Jakarta',
    electionType: electionTypes.CLASS_LEVEL,
    status: electionStatuses.ACTIVE,
    startAt: '2026-11-01T08:00:00+07:00',
    endAt: '2026-11-01T14:00:00+07:00',
    eligible: true,
    image: 'https://images.pexels.com/photos/256541/pexels-photo-256541.jpeg?auto=compress&cs=tinysrgb&w=800',
  },
  {
    slug: 'pemilihan-wakil-ketua-osis-2026',
    title: 'Pemilihan Wakil Ketua OSIS 2026',
    description: 'Pemungutan suara untuk memilih Wakil Ketua OSIS periode 2026/2027.',
    organization: 'SMA Negeri 1 Jakarta',
    electionType: electionTypes.SCHOOL_WIDE,
    status: electionStatuses.SCHEDULED,
    startAt: '2026-11-05T08:00:00+07:00',
    endAt: '2026-11-05T15:00:00+07:00',
    eligible: true,
    image: 'https://images.pexels.com/photos/159740/books-bookstore-book-reading-159740.jpeg?auto=compress&cs=tinysrgb&w=800',
  },
  {
    slug: 'pemilihan-ketua-kelas-10b',
    title: 'Pemilihan Ketua Kelas 10B',
    description: 'Pemilihan ketua kelas untuk kelas 10B periode 2026/2027.',
    organization: 'SMA Negeri 1 Jakarta',
    electionType: electionTypes.CLASS_LEVEL,
    status: electionStatuses.COMPLETED,
    startAt: '2026-10-28T08:00:00+07:00',
    endAt: '2026-10-28T14:00:00+07:00',
    eligible: false,
    image: 'https://images.pexels.com/photos/207692/pexels-photo-207692.jpeg?auto=compress&cs=tinysrgb&w=800',
  },
  {
    slug: 'pemilihan-bem-fasilkom-2026',
    title: 'Pemilihan BEM Fasilkom 2026',
    description: 'Pemilihan Ketua Badan Eksekutif Mahasiswa Fakultas Ilmu Komputer.',
    organization: 'Universitas Indonesia',
    electionType: electionTypes.SCHOOL_WIDE,
    status: electionStatuses.DRAFT,
    startAt: '2026-11-10T08:00:00+07:00',
    endAt: '2026-11-10T17:00:00+07:00',
    eligible: false,
    image: 'https://images.pexels.com/photos/207692/pexels-photo-207692.jpeg?auto=compress&cs=tinysrgb&w=800',
  },
  {
    slug: 'pemilihan-ketua-komunitas-dev',
    title: 'Pemilihan Ketua Komunitas Developer',
    description: 'Pemilihan ketua komunitas developer untuk periode 2026/2027.',
    organization: 'Komunitas Developer Indonesia',
    electionType: electionTypes.CUSTOM_GROUP,
    status: electionStatuses.ACTIVE,
    startAt: '2026-11-01T09:00:00+07:00',
    endAt: '2026-11-03T20:00:00+07:00',
    eligible: false,
    image: 'https://images.pexels.com/photos/256541/pexels-photo-256541.jpeg?auto=compress&cs=tinysrgb&w=800',
  },
]

/**
 * Returns a single election by slug.
 * @param {string} slug
 * @returns {ElectionItem | undefined}
 */
export function getItemBySlug(slug) {
  return items.find((item) => item.slug === slug)
}

/**
 * Returns only elections the current user is eligible for.
 * In production this is determined by the backend, not the frontend.
 * @returns {ElectionItem[]}
 */
export function getEligibleItems() {
  return items.filter((item) => item.eligible)
}
