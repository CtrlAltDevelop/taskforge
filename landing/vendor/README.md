# Vendored scripts

Third-party code the landing page runs, kept here so the page works offline
and does not depend on a CDN.

| File | Package | Version | Licence | Source |
|------|---------|---------|---------|--------|
| `three.module.min.js` | [three](https://github.com/mrdoob/three.js) | 0.170.0 | MIT | `build/three.module.min.js` from the npm package |
| `lenis.min.js` | [lenis](https://github.com/darkroomengineering/lenis) | 1.1.18 | MIT | `dist/lenis.min.js` from the npm package |

To update, download the new build from the same path (for example
`https://cdn.jsdelivr.net/npm/three@<version>/build/three.module.min.js`),
replace the file and change the version here.
