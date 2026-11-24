// Page behaviour: preloader, smooth scroll, which 3D layout is showing,
// word reveal, feature index, device gallery, theme, cursor, copy.

import { FEATURES, GROUPS, STORY, GAPS } from './features.js';
import { STATUS } from './layouts.js';

const $ = (s, r = document) => r.querySelector(s);
const html = document.documentElement;
const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
const clamp = (v, a, b) => Math.min(b, Math.max(a, v));
const el = (tag, attrs = {}, kids = []) => {
  const n = Object.assign(document.createElement(tag), attrs);
  n.append(...kids);
  return n;
};

// ---- content ---------------------------------------------------------------
document.querySelectorAll('[data-count="features"]').forEach((n) => { n.textContent = FEATURES.length; });

$('#gaps').append(...GAPS.map(([bad, good]) => el('li', {}, [el('s', { textContent: bad }), el('b', { textContent: good })])));

$('#views').append(...STORY.map((s, i) => el('section', { className: 'step', id: i === 0 ? 'views-start' : '' }, [
  el('div', { className: 'panel' }, [
    el('span', { className: 'big', ariaHidden: 'true', textContent: String(i + 1).padStart(2, '0') }),
    el('p', { className: 'eyebrow', innerHTML: `<span>03.${i + 1}</span> ${s.kicker}` }),
    el('h2', { textContent: s.title }),
    el('p', { className: 'lead', textContent: s.text }),
    el('ul', {}, s.points.map((p) => el('li', { textContent: p }))),
  ]),
])).map((n, i) => { n.dataset.layout = STORY[i].layout; n.dataset.place = 'side'; n.dataset.dim = '1'; return n; }));

// feature marquee (two copies so the loop is seamless)
const names = FEATURES.map((f) => f.t);
$('#marquee').append(...[...names, ...names].map((t) => el('span', { textContent: t })));

// page rail: one dot per major section
const RAIL = [['hero', 'Intro'], ['statement', 'What'], ['why', 'Why'], ['views', 'Views'], ['index', 'Features'], ['screens', 'Screens'], ['stack', 'Stack'], ['start', 'Start']];
$('#rail').append(...RAIL.map(([id, label]) => el('a', { href: `#${id}`, ariaLabel: label }, [el('span', { textContent: label }), el('i')])));

// feature index
let group = 'all';
let query = '';
const groupName = Object.fromEntries(GROUPS.map((g) => [g.id, g.label]));
function renderRows() {
  const q = query.trim().toLowerCase();
  const list = FEATURES.filter((f) => (group === 'all' || f.g === group) && (!q || `${f.t} ${f.d} ${groupName[f.g]}`.toLowerCase().includes(q)));
  $('#rows').replaceChildren(...list.map((f) => {
    const btn = el('button', { type: 'button', ariaExpanded: 'false' }, [
      el('span', { className: 'n', textContent: f.p }),
      el('span', { className: 't', textContent: f.t }),
      el('span', { className: 'g', textContent: groupName[f.g] }),
    ]);
    const li = el('li', { className: 'row' }, [btn, el('p', { className: 'd', textContent: f.d })]);
    btn.addEventListener('click', () => {
      const open = li.classList.toggle('open');
      btn.setAttribute('aria-expanded', String(open));
    });
    return li;
  }));
  $('#none').hidden = list.length > 0;
  $('#index-count').textContent = list.length;
}
$('#chips').append(...[{ id: 'all', label: 'All' }, ...GROUPS].map((g) => {
  const b = el('button', { type: 'button', className: 'chip', textContent: g.label });
  b.setAttribute('aria-pressed', String(g.id === 'all'));
  b.dataset.id = g.id;
  b.addEventListener('click', () => {
    group = g.id;
    $('#chips').querySelectorAll('.chip').forEach((c) => c.setAttribute('aria-pressed', String(c === b)));
    renderRows();
  });
  return b;
}));
$('#q').addEventListener('input', (e) => { query = e.target.value; renderRows(); });
renderRows();

// device gallery
const DEVICES = {
  Web: { kind: 'wide', shots: [['board-light', 'Board'], ['list-light', 'List'], ['task-modal-light', 'Task and comments'], ['board-dark', 'Dark theme'], ['board-fa-rtl', 'Persian, right to left']] },
  macOS: { kind: 'wide', shots: [['macos-home', 'Home'], ['macos-board', 'Board'], ['macos-list', 'List']] },
  iPad: { kind: 'tablet', shots: [['ipad-home', 'Home'], ['ipad-board', 'Board'], ['ipad-task', 'Task and chat'], ['ipad-calendar', 'Calendar'], ['ipad-timeline', 'Timeline']] },
  iPhone: { kind: 'phone', shots: [['ios-home', 'Home'], ['ios-project', 'List'], ['ios-board', 'Board']] },
};
function showDevice(name) {
  const d = DEVICES[name];
  const strip = $('#strip');
  strip.dataset.kind = d.kind;
  strip.scrollLeft = 0;
  strip.replaceChildren(...d.shots.map(([f, cap]) => el('figure', {}, [
    el('img', { src: `img/${f}.png`, alt: `${cap} on ${name}`, loading: 'lazy', decoding: 'async' }),
    el('figcaption', { textContent: cap }),
  ])));
  $('#tabs').querySelectorAll('.chip').forEach((c) => c.setAttribute('aria-selected', String(c.textContent === name)));
}
$('#tabs').append(...Object.keys(DEVICES).map((name) => {
  const b = el('button', { type: 'button', className: 'chip', textContent: name, role: 'tab' });
  b.addEventListener('click', () => showDevice(name));
  return b;
}));
showDevice('Web');

$('#copy').addEventListener('click', async (e) => {
  const btn = e.currentTarget;
  try { await navigator.clipboard.writeText($('#cmd').textContent); btn.textContent = 'Copied'; }
  catch { btn.textContent = 'Press Ctrl+C'; getSelection().selectAllChildren($('#cmd')); }
  setTimeout(() => { btn.textContent = 'Copy'; }, 1800);
});

// ---- word reveal ------------------------------------------------------------
const revealEl = $('[data-reveal]');
const words = revealEl.textContent.trim().split(/\s+/).map((w) => el('span', { textContent: `${w} ` }));
revealEl.replaceChildren(...words);
function updateReveal() {
  const r = revealEl.getBoundingClientRect();
  const p = reduce ? 1 : clamp((innerHeight * 0.78 - r.top) / (innerHeight * 0.4 + r.height), 0, 1);
  const n = Math.round(p * words.length);
  words.forEach((w, i) => w.classList.toggle('on', i < n));
}

// ---- theme --------------------------------------------------------------------
let scene = null;
function applyTheme(t, save) {
  html.dataset.theme = t;
  $('meta[name="theme-color"]').content = t === 'dark' ? '#0E0E0F' : '#F7F7F5';
  if (save) { try { localStorage.setItem('tf-theme', t); } catch { /* private mode */ } }
  scene?.setTheme(t);
}
$('#theme').addEventListener('click', () => applyTheme(html.dataset.theme === 'dark' ? 'light' : 'dark', true));

// ---- which 3D layout is showing -------------------------------------------------
const canvas = $('#scene');
const sections = [...document.querySelectorAll('[data-layout]')];
let current = null;
function syncLayout() {
  const mid = innerHeight * 0.5;
  const s = sections.find((x) => { const r = x.getBoundingClientRect(); return r.top <= mid && r.bottom > mid; });
  if (s && s !== current) {
    current = s;
    scene?.setLayout(s.dataset.layout, s.dataset.place || 'side');
    canvas.style.opacity = s.dataset.dim || '1';
  }
  // rail: the last section whose top has passed the middle of the screen
  let at = 0;
  RAIL.forEach(([id], i) => { const n = document.getElementById(id); if (n && n.getBoundingClientRect().top <= mid) at = i; });
  $('#rail').querySelectorAll('a').forEach((a, i) => a.classList.toggle('on', i === at));
}
function updateProgress() {
  const max = document.documentElement.scrollHeight - innerHeight;
  $('#progress i').style.transform = `scaleX(${max > 0 ? clamp(scrollY / max, 0, 1) : 0})`;
}
let queued = false;
function onScroll() {
  if (queued) return;
  queued = true;
  requestAnimationFrame(() => { queued = false; updateReveal(); syncLayout(); updateProgress(); });
}
addEventListener('scroll', onScroll, { passive: true });
addEventListener('resize', onScroll);

// ---- smooth scroll (Lenis, if it loaded) ----------------------------------------
let lenis = null;
if (window.Lenis && !reduce) {
  lenis = new window.Lenis({ lerp: 0.1 });
  lenis.on('scroll', onScroll);
  const raf = (t) => { lenis.raf(t); requestAnimationFrame(raf); };
  requestAnimationFrame(raf);
}
document.querySelectorAll('a[href^="#"]').forEach((a) => a.addEventListener('click', (e) => {
  const target = $(a.getAttribute('href'));
  if (!target) return;
  e.preventDefault();
  if (lenis) lenis.scrollTo(target, { offset: 0 }); else target.scrollIntoView({ behavior: reduce ? 'auto' : 'smooth' });
}));

// ---- pointer: parallax, hover tooltip, drag, sparks, cursor ring -----------------
const tip = $('#tip');
const ring = $('#cursor');
const isUi = (t) => !!t.closest('a, button, input, label, pre, .panel, .row, .strip, .nav, .chips');
function onHover(card, x, y) {
  if (!card) { tip.hidden = true; ring.classList.remove('big'); return; }
  tip.innerHTML = `<b>${card.id} · ${card.title}</b><span>${STATUS[card.status]}</span>`;
  tip.hidden = false;
  tip.style.left = `${Math.min(x + 16, innerWidth - 280)}px`;
  tip.style.top = `${Math.min(y + 16, innerHeight - 70)}px`;
  ring.classList.add('big');
}

let rx = 0, ry = 0, mx = 0, my = 0, down = false, dragged = false, lx = 0, ly = 0;
addEventListener('pointermove', (e) => {
  if (e.pointerType !== 'mouse') return;
  mx = e.clientX; my = e.clientY;
  ring.classList.add('on');
  const ui = isUi(e.target);
  ring.classList.toggle('big', ui);
  scene?.move(mx, my, !ui);
  if (down) {
    if (Math.abs(e.clientX - lx) + Math.abs(e.clientY - ly) > 2) dragged = true;
    scene?.drag(e.clientX - lx, e.clientY - ly);
    lx = e.clientX; ly = e.clientY;
  }
});
addEventListener('pointerdown', (e) => { if (e.pointerType === 'mouse' && !isUi(e.target)) { down = true; dragged = false; lx = e.clientX; ly = e.clientY; } });
addEventListener('pointerup', () => { if (down && !dragged) scene?.burst(); down = false; });
document.addEventListener('pointerleave', () => { ring.classList.remove('on'); scene?.move(0, 0, false); });
(function follow() {
  rx += (mx - rx) * 0.2; ry += (my - ry) * 0.2;
  ring.style.transform = `translate(${rx}px, ${ry}px)`;
  requestAnimationFrame(follow);
})();

// ---- boot --------------------------------------------------------------------------
async function boot() {
  try {
    const { createScene } = await import('./scene.js');
    scene = createScene(canvas, { reduceMotion: reduce, onHover });
    scene.setTheme(html.dataset.theme);
  } catch (err) {
    console.warn('3D scene unavailable, showing the page without it.', err);
    html.classList.add('no-gl');
  }
  document.addEventListener('visibilitychange', () => (document.hidden ? scene?.stop() : scene?.start()));
  updateReveal(); syncLayout();
  scene?.snap(); // a deep link starts on its layout instead of morphing from the hero
  // the browser jumped to #section before the story steps existed; jump again now
  if (location.hash && $(location.hash)) $(location.hash).scrollIntoView();
  updateReveal(); syncLayout(); updateProgress();
}

const pre = $('#preloader');
const pct = $('#pct');
const started = performance.now();
const MIN_MS = reduce ? 0 : 900;
let ready = false;
let finished = false;
function finish() {
  if (finished) return;
  finished = true;
  pct.textContent = '100%';
  pre.classList.add('done');
  scene?.start();
}
// never leave the page covered, even if animation frames are paused
setTimeout(finish, 6000);
Promise.all([boot(), document.fonts?.ready]).then(() => { ready = true; });
(function tick() {
  if (finished) return;
  const p = clamp((performance.now() - started) / (MIN_MS || 1), 0, 1);
  pct.textContent = `${Math.round((ready ? p : Math.min(p, 0.9)) * 100)}%`;
  if (ready && p >= 1) finish(); else requestAnimationFrame(tick);
})();
