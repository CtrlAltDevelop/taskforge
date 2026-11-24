# Publishing the landing page

`landing/` is a static site. `.github/workflows/pages.yml` deploys it to
https://ctrlaltdevelop.github.io/taskforge/ with GitHub Actions, with no
`gh-pages` branch.

## When it deploys

- on a push to `main` that touches `landing/` or the workflow (a merged PR
  counts)
- by hand: Actions → Pages → Run workflow (from `main`)

Pull requests and other branches do not deploy. There is one Pages site, so
the newest deploy is what visitors see.

## Repo settings

1. **Settings → Pages → Build and deployment → Source: GitHub Actions.**
2. **Settings → Environments → github-pages → Deployment branches and tags:**
   `main` only. Anything else cannot deploy, so a manual run from another
   branch fails by design.
