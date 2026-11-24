# Publishing the landing page

`landing/` is a static site. `.github/workflows/pages.yml` deploys it to
https://ctrlaltdevelop.github.io/taskforge/ with GitHub Actions, with no
`gh-pages` branch.

## When it deploys

- on a push to `main` that touches `landing/` or the workflow
- on a pull request into `main` that touches them (same paths)
- by hand: Actions → Pages → Run workflow

There is one Pages site, so the newest deploy is what visitors see. A pull
request deploys its own version of the page; if it is closed without merging,
the site keeps that version until the next deploy (merge, or run the workflow
on `main`).

## One-time repo settings

1. **Settings → Pages → Build and deployment → Source: GitHub Actions.**
2. **Settings → Environments → github-pages → Deployment branches and tags.**
   Allow `main` and add the rule `refs/pull/*/merge` (pull request runs deploy
   from that ref). Delete the old `gh-pages` rule, the branch no longer exists.

Same from the command line:

```bash
gh api -X POST repos/CtrlAltDevelop/taskforge/environments/github-pages/deployment-branch-policies \
  -f name='refs/pull/*/merge' -f type=branch
gh api -X DELETE repos/CtrlAltDevelop/taskforge/environments/github-pages/deployment-branch-policies/<id-of-gh-pages-rule>
```

Pull requests from forks cannot deploy (the workflow gets a read-only token),
which is what you want.
