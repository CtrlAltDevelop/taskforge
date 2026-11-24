// Particles: ember dust that drifts across the whole page and shies from the
// cursor, and forge sparks (glowing heads with streaks) thrown off the anvil.
// Both are plain Points / LineSegments with one small shader, simulated on the CPU.

import * as THREE from 'three';

const VERT = /* glsl */ `
  attribute float aSize; attribute float aLife; attribute float aSeed;
  uniform float uTime; uniform float uScale;
  varying float vLife; varying float vFlick;
  void main() {
    vLife = aLife;
    vFlick = 0.7 + 0.3 * sin(uTime * (2.0 + aSeed * 3.0) + aSeed * 40.0);
    vec4 mv = modelViewMatrix * vec4(position, 1.0);
    gl_PointSize = max(aSize * uScale * vFlick / -mv.z, 0.0);
    gl_Position = projectionMatrix * mv;
  }`;

const FRAG = /* glsl */ `
  uniform vec3 uHot; uniform vec3 uCool; uniform float uAlpha;
  varying float vLife; varying float vFlick;
  void main() {
    float d = length(gl_PointCoord - 0.5);
    if (d > 0.5) discard;
    float soft = smoothstep(0.5, 0.0, d);
    float core = smoothstep(0.2, 0.0, d);
    gl_FragColor = vec4(mix(uCool, uHot, core * vLife), soft * vLife * vFlick * uAlpha);
  }`;

const TRAIL_VERT = /* glsl */ `
  attribute float aLife; varying float vLife;
  void main() { vLife = aLife; gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0); }`;
const TRAIL_FRAG = /* glsl */ `
  uniform vec3 uHot; uniform vec3 uCool; uniform float uAlpha; varying float vLife;
  void main() { gl_FragColor = vec4(mix(uCool, uHot, vLife), vLife * 0.7 * uAlpha); }`;

const LOOKS = {
  dark: { hot: [1.0, 0.91, 0.8], cool: [0.98, 0.57, 0.24], dust: 1.1, spark: 1, blend: THREE.AdditiveBlending },
  light: { hot: [0.96, 0.62, 0.04], cool: [0.76, 0.25, 0.05], dust: 0.5, spark: 0.95, blend: THREE.NormalBlending },
};

function material(vertexShader, fragmentShader) {
  return new THREE.ShaderMaterial({
    vertexShader, fragmentShader, transparent: true, depthWrite: false,
    uniforms: {
      uTime: { value: 0 }, uScale: { value: 600 }, uAlpha: { value: 1 },
      uHot: { value: new THREE.Color() }, uCool: { value: new THREE.Color() },
    },
  });
}
function look(mat, name, alpha) {
  const l = LOOKS[name];
  mat.uniforms.uHot.value.setRGB(...l.hot);
  mat.uniforms.uCool.value.setRGB(...l.cool);
  mat.uniforms.uAlpha.value = alpha(l);
  mat.blending = l.blend;
  mat.needsUpdate = true;
}
const rnd = (a, b) => a + Math.random() * (b - a);

// ---- ember dust ------------------------------------------------------------------
export function createDust(count = 420) {
  const BOX = { x: 15, y: 9, zMin: -8, zMax: 5 };
  const pos = new Float32Array(count * 3), vel = new Float32Array(count * 3), base = new Float32Array(count * 3);
  const size = new Float32Array(count), life = new Float32Array(count), seed = new Float32Array(count);
  for (let i = 0; i < count; i++) {
    pos.set([rnd(-BOX.x, BOX.x), rnd(-BOX.y, BOX.y), rnd(BOX.zMin, BOX.zMax)], i * 3);
    base.set([rnd(-0.06, 0.06), rnd(0.08, 0.32), 0], i * 3);
    vel.set(base.subarray(i * 3, i * 3 + 3), i * 3);
    size[i] = rnd(0.05, 0.15); life[i] = rnd(0.35, 1); seed[i] = Math.random();
  }
  const geometry = new THREE.BufferGeometry();
  geometry.setAttribute('position', new THREE.BufferAttribute(pos, 3));
  geometry.setAttribute('aSize', new THREE.BufferAttribute(size, 1));
  geometry.setAttribute('aLife', new THREE.BufferAttribute(life, 1));
  geometry.setAttribute('aSeed', new THREE.BufferAttribute(seed, 1));
  const mat = material(VERT, FRAG);
  const points = new THREE.Points(geometry, mat);
  points.frustumCulled = false;

  return {
    points,
    setTheme: (name) => look(mat, name, (l) => l.dust),
    setScale: (s) => { mat.uniforms.uScale.value = s; },
    // a ring of force from the middle: dust is thrown outward, then settles
    pulse(power = 1) {
      for (let i = 0; i < count; i++) {
        const x = pos[i * 3], y = pos[i * 3 + 1];
        const d = Math.hypot(x, y) || 1;
        const k = (rnd(1.5, 3.5) * power) / (1 + d * 0.08);
        vel[i * 3] += (x / d) * k; vel[i * 3 + 1] += (y / d) * k;
      }
    },
    update(dt, time, cursor) {
      mat.uniforms.uTime.value = time;
      const settle = Math.min(dt * 1.6, 1);
      for (let i = 0; i < count; i++) {
        const o = i * 3;
        for (let a = 0; a < 3; a++) vel[o + a] += (base[o + a] - vel[o + a]) * settle;
        if (cursor) { // shy away from the pointer
          const dx = pos[o] - cursor.x, dy = pos[o + 1] - cursor.y;
          const d = Math.hypot(dx, dy);
          if (d < 2.8 && d > 0.001) { const f = ((2.8 - d) / 2.8) * 9 * dt; vel[o] += (dx / d) * f; vel[o + 1] += (dy / d) * f; }
        }
        pos[o] += (vel[o] + Math.sin(time * 0.6 + seed[i] * 30) * 0.05) * dt;
        pos[o + 1] += vel[o + 1] * dt;
        pos[o + 2] += vel[o + 2] * dt;
        if (pos[o + 1] > BOX.y) pos[o + 1] = -BOX.y;
        if (pos[o] > BOX.x) pos[o] = -BOX.x; else if (pos[o] < -BOX.x) pos[o] = BOX.x;
      }
      geometry.attributes.position.needsUpdate = true;
    },
  };
}

// ---- forge sparks ------------------------------------------------------------------
// Positions are in the anvil's own space: the top face is at y = 0.27.
export function createSparks(count = 260) {
  const TOP = 0.27;
  const pos = new Float32Array(count * 3).fill(-999), vel = new Float32Array(count * 3);
  const ttl = new Float32Array(count), max = new Float32Array(count).fill(1);
  const size = new Float32Array(count), life = new Float32Array(count), seed = new Float32Array(count);
  const tail = new Float32Array(count * 6).fill(-999), tailLife = new Float32Array(count * 2);
  for (let i = 0; i < count; i++) seed[i] = Math.random();

  const geometry = new THREE.BufferGeometry();
  geometry.setAttribute('position', new THREE.BufferAttribute(pos, 3));
  geometry.setAttribute('aSize', new THREE.BufferAttribute(size, 1));
  geometry.setAttribute('aLife', new THREE.BufferAttribute(life, 1));
  geometry.setAttribute('aSeed', new THREE.BufferAttribute(seed, 1));
  const mat = material(VERT, FRAG);
  const points = new THREE.Points(geometry, mat);
  points.frustumCulled = false;

  const trailGeo = new THREE.BufferGeometry();
  trailGeo.setAttribute('position', new THREE.BufferAttribute(tail, 3));
  trailGeo.setAttribute('aLife', new THREE.BufferAttribute(tailLife, 1));
  const trailMat = material(TRAIL_VERT, TRAIL_FRAG);
  const trails = new THREE.LineSegments(trailGeo, trailMat);
  trails.frustumCulled = false;

  let next = 0.6, cursor = 0;
  const api = {
    points, trails, flash: 0,
    setTheme(name) { look(mat, name, (l) => l.spark); look(trailMat, name, (l) => l.spark); },
    setScale(s) { mat.uniforms.uScale.value = s; },
    burst(n = 22, power = 1) {
      for (let k = 0; k < n; k++) {
        const i = cursor; cursor = (cursor + 1) % count;
        pos.set([rnd(0.4, 2.4), TOP + 0.05, rnd(-0.3, 0.3)], i * 3);
        vel.set([rnd(-1.8, 2.4) * power, rnd(2.4, 6.2) * power, rnd(-1.4, 1.4)], i * 3);
        max[i] = ttl[i] = rnd(0.7, 1.9); size[i] = rnd(0.11, 0.28);
      }
      api.flash = 1;
    },
    // a hammer strike every second or so while the anvil is on screen
    update(dt, time, active) {
      mat.uniforms.uTime.value = time;
      if (active && time > next) { api.burst(Math.round(rnd(16, 28))); next = time + rnd(0.9, 1.9); }
      api.flash *= Math.exp(-dt * 5);
      for (let i = 0; i < count; i++) {
        const o = i * 3;
        if (ttl[i] <= 0) { life[i] = 0; tailLife[i * 2] = tailLife[i * 2 + 1] = 0; continue; }
        ttl[i] -= dt;
        vel[o + 1] -= 4.4 * dt;
        pos[o] += vel[o] * dt; pos[o + 1] += vel[o + 1] * dt; pos[o + 2] += vel[o + 2] * dt;
        if (pos[o + 1] < TOP && vel[o + 1] < 0 && pos[o] > -1.7 && pos[o] < 3.0) { // bounce off the anvil face
          pos[o + 1] = TOP; vel[o + 1] *= -0.36; vel[o] *= 0.8; vel[o + 2] *= 0.8;
        }
        if (ttl[i] <= 0) { pos.fill(-999, o, o + 3); tail.fill(-999, i * 6, i * 6 + 6); life[i] = 0; continue; }
        life[i] = Math.pow(ttl[i] / max[i], 0.8);
        tail.set([pos[o], pos[o + 1], pos[o + 2], pos[o] - vel[o] * 0.055, pos[o + 1] - vel[o + 1] * 0.055, pos[o + 2] - vel[o + 2] * 0.055], i * 6);
        tailLife[i * 2] = life[i]; tailLife[i * 2 + 1] = 0;
      }
      geometry.attributes.position.needsUpdate = true; geometry.attributes.aLife.needsUpdate = true; geometry.attributes.aSize.needsUpdate = true;
      trailGeo.attributes.position.needsUpdate = true; trailGeo.attributes.aLife.needsUpdate = true;
    },
  };
  return api;
}
