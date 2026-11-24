// Where each of the 96 task cards sits in every 3D arrangement.
// A layout maps card index -> { p: [x, y, z], q: Quaternion, s: [sx, sy], c: colour slot }
// or null (card hidden). Card geometry is 1 x 0.6; s scales it.

import { Quaternion, Vector3 } from 'three';

export const N = 96;
export const STATUS = ['To do', 'In progress', 'In review', 'Done'];
// Colour slots: 0-3 are statuses, 4 is the ember accent, 5 is a muted tile.
export const ACCENT = 4;
export const MUTED = 5;

function rng(seed) {
  let a = seed;
  return () => {
    a |= 0; a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

const TITLES = [
  'Redesign checkout flow', 'Fix the login redirect', 'Audit the checkout funnel',
  'Write the launch announcement', 'Migrate analytics to the new vendor',
  'Dark mode variants', 'Offline sync indicator', 'Update privacy policy page',
  'Accessibility audit of the homepage', 'Q4 roadmap review', 'Support SSO for enterprise',
  'Set up error monitoring', 'Plan next sprint', 'Cookie banner wording',
  'Board drag drops the card in the wrong column', 'Review onboarding copy',
  'Write API docs for webhooks', 'Fix flaky checkout test', 'Upgrade Flutter to the next minor',
  'Customer case study', 'Newsletter: October roundup', 'Kick-off call',
  'Slow list scroll with 5,000 tasks', 'Tooltip overlaps the close button',
  'Password reset link expires too fast', 'Emails land in spam', 'Month-end invoice run',
  'Design new payment step', 'Hi-fi mockups', 'Implement payment API client',
  'Regression pass on iPhone SE', 'Add a keyboard shortcuts cheat sheet',
];
const KEYS = ['WEB', 'MOB', 'BUG', 'MKT'];

const roll = rng(7);
export const CARDS = Array.from({ length: N }, (_, i) => {
  const r = roll();
  const status = r < 0.3 ? 0 : r < 0.62 ? 1 : r < 0.76 ? 2 : 3;
  return {
    id: `${KEYS[i % 4]}-${i + 1}`,
    title: TITLES[i % TITLES.length],
    status,
    delay: ((i * 37) % 17) / 17 * 0.45,
  };
});

const Q0 = new Quaternion();
const Z = new Vector3(0, 0, 1);
const faceOut = (x, y, z) => new Quaternion().setFromUnitVectors(Z, new Vector3(x, y, z).normalize());
const card = (x, y, z, sx, sy, c, q = Q0) => ({ p: [x, y, z], q, s: [sx, sy], c });

// ---- hero: a helix of cards around the anvil -------------------------------
const hero = (i) => {
  const a = (i / N) * Math.PI * 2 * 3;
  const r = 5.4 + Math.sin(i * 1.7) * 0.5;
  const y = (i / N - 0.5) * 7.4;
  return card(Math.cos(a) * r, y, Math.sin(a) * r, 1, 1, CARDS[i].status, faceOut(Math.cos(a), 0, Math.sin(a)));
};

// ---- list: 32 rows of title bar, status pill, avatar ------------------------
const list = (i) => {
  const row = Math.floor(i / 3);
  const part = i % 3;
  const y = 5.9 - row * 0.38;
  const st = CARDS[row * 3].status;
  if (part === 0) return card(-2.3, y, 0, 5.4, 0.55, st);
  if (part === 1) return card(1.9, y, 0, 1.7, 0.55, st);
  return card(3.4, y, 0, 0.75, 0.55, ACCENT);
};

// ---- board: four status columns ---------------------------------------------
const slots = [0, 1, 2, 3].map((s) =>
  CARDS.map((c, i) => [c, i]).filter(([c, i]) => c.status === s && i < 90).slice(0, 10).map(([, i]) => i),
);
const boardSlot = new Map();
slots.forEach((ids, col) => ids.forEach((id, row) => boardSlot.set(id, [col, row])));
const board = (i) => {
  if (i >= 90 && i <= 93) return card((i - 90 - 1.5) * 3.2, -0.2, -0.25, 3, 12.6, MUTED);
  const at = boardSlot.get(i);
  if (!at) return null;
  return card((at[0] - 1.5) * 3.2, 5 - at[1] * 0.78, 0, 2.7, 1, at[0]);
};

// ---- calendar: 35 day tiles and 24 event bars ---------------------------------
const rc = rng(21);
// Events are packed into lanes per week row so no two bars overlap, and each
// lane sits at its own depth so coplanar faces never fight over a pixel.
const LANES = 3;
const events = [];
{
  const taken = Array.from({ length: 5 }, () => Array.from({ length: LANES }, () => new Set()));
  for (let n = 0; n < 24; n++) {
    const row = Math.floor(rc() * 5);
    const span = 1 + Math.floor(rc() * 4);
    const col = Math.floor(rc() * (8 - span));
    const c = Math.floor(rc() * 4);
    const days = Array.from({ length: span }, (_, d) => col + d);
    const lane = taken[row].findIndex((set) => days.every((d) => !set.has(d)));
    if (lane < 0) { events.push(null); continue; }
    days.forEach((d) => taken[row][lane].add(d));
    events.push({ row, col, span, lane, c });
  }
}
const calendar = (i) => {
  if (i < 35) {
    const c = i % 7, r = Math.floor(i / 7);
    return card((c - 3) * 1.75, (2 - r) * 1.5, 0, 1.65, 2.2, MUTED);
  }
  const e = events[i - 35];
  if (!e) return null;
  const x = (e.col + (e.span - 1) / 2 - 3) * 1.75;
  return card(x, (2 - e.row) * 1.5 + 0.35 - e.lane * 0.3, 0.2 + e.lane * 0.08, e.span * 1.75 - 0.2, 0.42, e.c);
};

// ---- timeline: stair-stepped bars and a "today" line --------------------------
const rt = rng(5);
let prevEnd = 0;
const bars = Array.from({ length: 28 }, (_, row) => {
  const len = 2 + Math.floor(rt() * 7);
  const start = row % 3 === 0 ? Math.floor(rt() * 10) : Math.max(0, prevEnd - 1 - Math.floor(rt() * 2));
  prevEnd = start + len;
  return { start, len };
});
const timeline = (i) => {
  if (i === 94) return card(-0.4, -0.2, 0.3, 0.05, 20, ACCENT);
  const b = bars[i];
  if (!b) return null;
  return card(-6.4 + (b.start + b.len / 2) * 0.5, 5.4 - i * 0.4, 0, b.len * 0.5, 0.55, CARDS[i].status);
};

// ---- chart: twelve stacked columns, coloured by status -------------------------
const heights = [4, 7, 10, 13, 9, 6, 8, 12, 15, 5, 3, 4];
const order = CARDS.map((c, i) => i).sort((a, b) => CARDS[a].status - CARDS[b].status || a - b);
const chartSlot = new Map();
{
  let k = 0;
  heights.forEach((h, col) => { for (let row = 0; row < h; row++) chartSlot.set(order[k++], [col, row]); });
}
const chart = (i) => {
  const at = chartSlot.get(i);
  if (!at) return null;
  return card((at[0] - 5.5) * 1.05, -3.2 + at[1] * 0.42, 0, 0.88, 0.62, CARDS[i].status);
};

// ---- sphere: cards on a Fibonacci sphere ----------------------------------------
const sphere = (i) => {
  const y = 1 - (2 * (i + 0.5)) / N;
  const r = Math.sqrt(1 - y * y);
  const phi = i * Math.PI * (3 - Math.sqrt(5));
  const x = Math.cos(phi) * r, z = Math.sin(phi) * r;
  const R = 4.6;
  return card(x * R, y * R, z * R, 1.15, 1.15, CARDS[i].status, faceOut(x, y, z));
};

// bounds are [width, height] in world units; spin layouts may be dragged round.
export const LAYOUTS = {
  hero: { at: hero, bounds: [13, 9], spin: true },
  list: { at: list, bounds: [10, 12.6], spin: false },
  board: { at: board, bounds: [13, 12.6], spin: false },
  calendar: { at: calendar, bounds: [12.6, 8], spin: false },
  timeline: { at: timeline, bounds: [14, 12.4], spin: false },
  chart: { at: chart, bounds: [13, 8], spin: false },
  sphere: { at: sphere, bounds: [10.4, 10.4], spin: true },
};
