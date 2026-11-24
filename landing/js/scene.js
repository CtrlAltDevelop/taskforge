// The 3D scene: 96 task cards that regroup into list, board, calendar,
// timeline, chart and sphere layouts, a forge anvil with sparks, hover and drag.

import * as THREE from 'three';
import { N, CARDS, LAYOUTS } from './layouts.js';
import { createDust, createSparks } from './particles.js';

// status colours (to do, in progress, in review, done), ember accent, muted tile
const PALETTE = {
  light: ['#9A9A93', '#1D4ED8', '#7C3AED', '#15803D', '#C2410C', '#D9D9D3'],
  dark: ['#6B6B73', '#60A5FA', '#A78BFA', '#4ADE80', '#FB923C', '#2E2E33'],
};
const WIDE = 960; // px: text left, scene right

function roundedRect(w, h, r) {
  const s = new THREE.Shape();
  const x = -w / 2, y = -h / 2;
  s.moveTo(x + r, y);
  s.lineTo(x + w - r, y); s.quadraticCurveTo(x + w, y, x + w, y + r);
  s.lineTo(x + w, y + h - r); s.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
  s.lineTo(x + r, y + h); s.quadraticCurveTo(x, y + h, x, y + h - r);
  s.lineTo(x, y + r); s.quadraticCurveTo(x, y, x + r, y);
  return s;
}

// The brand mark (docs/brand/taskforge-mark.svg) as extruded shapes.
function markShape(points) {
  const s = new THREE.Shape(points.map(([x, y]) => new THREE.Vector2((x - 485) / 110, -(y - 440) / 110)));
  return s;
}
const ANVIL = [[150, 440], [300, 410], [820, 410], [820, 500], [660, 500], [630, 580], [720, 630], [720, 720], [300, 720], [300, 630], [390, 580], [360, 500], [300, 490]];
const SPARK = [[640, 160], [668, 242], [750, 270], [668, 298], [640, 380], [612, 298], [530, 270], [612, 242]];

export function createScene(canvas, { reduceMotion, onHover }) {
  const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true, powerPreference: 'high-performance' });
  renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(38, 1, 0.1, 100);
  camera.position.z = 16;
  scene.add(new THREE.AmbientLight(0xffffff, 1.15));
  const key = new THREE.DirectionalLight(0xffffff, 1.7);
  key.position.set(-4, 6, 8);
  scene.add(key);
  const glow = new THREE.PointLight(0xfb923c, 0, 24);
  glow.position.set(0, 1, 3);
  scene.add(glow);

  const root = new THREE.Group();   // placed and scaled to fit the layout
  const tilt = new THREE.Group();   // pointer parallax
  const ring = new THREE.Group();   // the cards; auto-spin and drag
  const forge = new THREE.Group();  // anvil + sparks, hero only
  root.add(tilt); tilt.add(ring, forge); scene.add(root);

  // ---- cards -------------------------------------------------------------
  const geo = new THREE.ExtrudeGeometry(roundedRect(1, 0.6, 0.07), {
    depth: 0.06, bevelEnabled: true, bevelThickness: 0.015, bevelSize: 0.015, bevelSegments: 2, curveSegments: 6,
  });
  geo.translate(0, 0, -0.03);
  const mesh = new THREE.InstancedMesh(geo, new THREE.MeshStandardMaterial({ roughness: 0.5, metalness: 0.05 }), N);
  mesh.frustumCulled = false;
  mesh.boundingSphere = new THREE.Sphere(new THREE.Vector3(), 200); // cards move; keep raycasts valid
  mesh.instanceMatrix.setUsage(THREE.DynamicDrawUsage);
  for (let i = 0; i < N; i++) mesh.setColorAt(i, new THREE.Color());
  ring.add(mesh);

  const P = new Float32Array(N * 3), PT = new Float32Array(N * 3);
  const S = new Float32Array(N * 2), ST = new Float32Array(N * 2);
  const Q = Array.from({ length: N }, () => new THREE.Quaternion());
  const QT = Array.from({ length: N }, () => new THREE.Quaternion());
  const slot = new Uint8Array(N);
  const colour = Array.from({ length: N }, () => new THREE.Color());
  let palette = PALETTE.dark.map((h) => new THREE.Color(h));

  // ---- forge: anvil, spark star, flying sparks -------------------------------
  const extrude = (pts, depth) => {
    const g = new THREE.ExtrudeGeometry(markShape(pts), { depth, bevelEnabled: true, bevelThickness: 0.06, bevelSize: 0.05, bevelSegments: 2 });
    g.translate(0, 0, -depth / 2);
    return g;
  };
  const anvilMat = new THREE.MeshStandardMaterial({ roughness: 0.45, metalness: 0.15, emissive: 0xfb923c, emissiveIntensity: 0.25 });
  const sparkMat = new THREE.MeshStandardMaterial({ color: 0xffe8cc, emissive: 0xffe8cc, emissiveIntensity: 0.7, roughness: 0.4 });
  const anvil = new THREE.Mesh(extrude(ANVIL, 0.9), anvilMat);
  const star = new THREE.Mesh(extrude(SPARK, 0.5), sparkMat);
  forge.add(anvil, star);

  // sparks live in the anvil's space; dust fills the whole view
  const sparks = createSparks();
  forge.add(sparks.points, sparks.trails);
  const dust = createDust();
  scene.add(dust.points);
  const cursorPlane = new THREE.Plane(new THREE.Vector3(0, 0, 1), 0);
  const cursorWorld = new THREE.Vector3();

  // ---- state -------------------------------------------------------------------
  let theme = 'dark';
  let layout = 'hero';
  let place = 'center';
  let changedAt = 0;
  let forgeTarget = 1, forgeNow = 1;
  const view = { w: 1, h: 1 };
  const rootTo = { s: 1, x: 0, y: 0 };
  const pointer = { x: 0, y: 0, inside: false, ndc: new THREE.Vector2(9, 9) };
  let hover = -1;
  let spinY = 0, spinX = 0, velY = 0, velX = 0;
  const raycaster = new THREE.Raycaster();
  const tmpM = new THREE.Matrix4(), tmpP = new THREE.Vector3(), tmpS = new THREE.Vector3();

  function fit() {
    const [bw, bh] = LAYOUTS[layout].bounds;
    const H = 2 * Math.tan((camera.fov * Math.PI) / 360) * camera.position.z;
    const W = H * camera.aspect;
    const mode = view.w < WIDE ? 'top' : place; // narrow screens: scene above the text
    const area = {
      side: { w: W * 0.56, h: H * 0.86, x: W * 0.21, y: 0 },
      center: { w: W * 0.9, h: H * 0.52, x: 0, y: H * 0.2 },
      top: { w: W * 0.96, h: H * 0.44, x: 0, y: H * 0.24 },
    }[mode];
    Object.assign(rootTo, { s: Math.min(area.w / bw, area.h / bh, 1.25), x: area.x, y: area.y });
  }

  function setTargets() {
    const L = LAYOUTS[layout];
    for (let i = 0; i < N; i++) {
      const t = L.at(i);
      if (!t) { ST[i * 2] = ST[i * 2 + 1] = 0; continue; }
      PT.set(t.p, i * 3); ST.set(t.s, i * 2); QT[i].copy(t.q); slot[i] = t.c;
    }
  }

  function setLayout(name, where = 'side') {
    if (!LAYOUTS[name] || (name === layout && where === place)) return;
    place = where;
    forgeTarget = name === 'hero' && where === 'center' ? 1 : 0;
    if (name === layout) { fit(); if (reduceMotion) snap(); return; } // same arrangement, new position
    layout = name;
    changedAt = performance.now() / 1000;
    if (!reduceMotion) dust.pulse();
    setTargets(); fit();
    if (reduceMotion) snap();
  }

  function snap() {
    P.set(PT); S.set(ST);
    for (let i = 0; i < N; i++) Q[i].copy(QT[i]);
    root.scale.setScalar(rootTo.s); root.position.set(rootTo.x, rootTo.y, 0);
    forgeNow = forgeTarget;
  }

  function setTheme(name) {
    theme = name;
    palette = PALETTE[name].map((h) => new THREE.Color(h));
    const dark = name === 'dark';
    anvilMat.color.set(dark ? 0xfb923c : 0xc2410c);
    anvilMat.emissive.set(dark ? 0xfb923c : 0xc2410c);
    sparkMat.color.set(dark ? 0xffe8cc : 0xf59e0b);
    sparkMat.emissive.set(dark ? 0xffe8cc : 0xf59e0b);
    sparks.setTheme(name);
    dust.setTheme(name);
  }

  function resize() {
    view.w = window.innerWidth; view.h = window.innerHeight;
    renderer.setSize(view.w, view.h, false);
    camera.aspect = view.w / view.h;
    camera.updateProjectionMatrix();
    const pointScale = (renderer.getPixelRatio() * view.h) / (2 * Math.tan((camera.fov * Math.PI) / 360));
    sparks.setScale(pointScale); dust.setScale(pointScale);
    fit();
  }

  function pick() {
    if (!pointer.inside || forgeNow > 0.5) return -1;
    raycaster.setFromCamera(pointer.ndc, camera);
    const hit = raycaster.intersectObject(mesh)[0];
    return hit && hit.instanceId !== undefined && S[hit.instanceId * 2] > 0.2 ? hit.instanceId : -1;
  }

  // ---- frame ----------------------------------------------------------------
  let last = performance.now() / 1000;
  let running = false;
  function frame() {
    if (!running) return;
    requestAnimationFrame(frame);
    const now = performance.now() / 1000;
    const dt = Math.min(now - last, 0.05);
    last = now;
    const k = reduceMotion ? 1 : 1 - Math.exp(-dt * 4.5);

    for (let i = 0; i < N; i++) {
      if (now - changedAt >= CARDS[i].delay) {
        for (let a = 0; a < 3; a++) P[i * 3 + a] += (PT[i * 3 + a] - P[i * 3 + a]) * k;
        S[i * 2] += (ST[i * 2] - S[i * 2]) * k;
        S[i * 2 + 1] += (ST[i * 2 + 1] - S[i * 2 + 1]) * k;
        if (ST[i * 2] === 0 && S[i * 2] < 0.04) S[i * 2] = S[i * 2 + 1] = 0; // finish hiding a card
        Q[i].slerp(QT[i], k);
      }
      const pop = i === hover ? 1.12 : 1;
      tmpP.set(P[i * 3], P[i * 3 + 1], P[i * 3 + 2] + (i === hover ? 0.25 : 0));
      tmpS.set(Math.max(S[i * 2], 0.0001) * pop, Math.max(S[i * 2 + 1], 0.0001) * pop, 1);
      mesh.setMatrixAt(i, tmpM.compose(tmpP, Q[i], tmpS));
      colour[i].lerp(i === hover ? palette[4] : palette[slot[i]], k);
      mesh.setColorAt(i, colour[i]);
    }
    mesh.instanceMatrix.needsUpdate = true;
    mesh.instanceColor.needsUpdate = true;

    // root placement, forge visibility, pointer parallax, spin
    root.scale.setScalar(root.scale.x + (rootTo.s - root.scale.x) * k);
    root.position.x += (rootTo.x - root.position.x) * k;
    root.position.y += (rootTo.y - root.position.y) * k;
    forgeNow += (forgeTarget - forgeNow) * k;
    forge.scale.setScalar(Math.max(forgeNow, 0.0001));
    forge.visible = forgeNow > 0.01;
    glow.intensity = forgeNow * (theme === 'dark' ? 90 : 25) * (1 + sparks.flash * 0.5);
    anvilMat.emissiveIntensity = 0.2 + sparks.flash * 0.3;
    tilt.rotation.y += (pointer.x * 0.22 - tilt.rotation.y) * k * 0.6;
    tilt.rotation.x += (-pointer.y * 0.14 - tilt.rotation.x) * k * 0.6;

    if (!reduceMotion) {
      const spins = LAYOUTS[layout].spin;
      spinY += velY * dt + (spins ? dt * 0.12 : 0);
      spinX += velX * dt;
      velY *= 0.94; velX *= 0.94;
      if (!spins) { const d = Math.exp(-dt * 5); spinY *= d; spinX *= d; }
      ring.rotation.set(Math.max(-0.6, Math.min(0.6, spinX)), spinY, 0);
      let cursor = null;
      if (pointer.inside) { raycaster.setFromCamera(pointer.ndc, camera); cursor = raycaster.ray.intersectPlane(cursorPlane, cursorWorld); }
      dust.points.position.x += (pointer.x * 0.5 - dust.points.position.x) * k * 0.4;
      dust.update(dt, now, cursor);
      sparks.update(dt, now, forgeNow > 0.3);
    }

    const h = pick();
    if (h !== hover) { hover = h; onHover(h < 0 ? null : CARDS[h], pointer.cx, pointer.cy); }
    renderer.render(scene, camera);
  }

  function start() { if (running) return; running = true; last = performance.now() / 1000; frame(); }
  function stop() { running = false; }

  // ---- input (called from main.js) ---------------------------------------------
  function move(cx, cy, over) {
    pointer.cx = cx; pointer.cy = cy; pointer.inside = over;
    pointer.x = (cx / view.w) * 2 - 1; pointer.y = (cy / view.h) * 2 - 1;
    pointer.ndc.set(pointer.x, -pointer.y);
    if (hover >= 0 && over) onHover(CARDS[hover], cx, cy);
  }
  function drag(dx, dy) { velY += dx * 0.06; velX += dy * 0.04; }
  function burst() {
    if (!reduceMotion && forgeNow > 0.3) sparks.burst(70, 1.35);
  }

  setTheme('dark');
  resize();
  setTargets();
  for (let i = 0; i < N; i++) colour[i].copy(palette[slot[i]]);
  snap();
  window.addEventListener('resize', resize);
  return { setLayout, setTheme, snap, move, drag, burst, start, stop, get layout() { return layout; } };
}
