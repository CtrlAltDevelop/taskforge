# Security policy

## Reporting a vulnerability

Please do not open a public issue for a security problem. Use GitHub's private
reporting: **Security → Report a vulnerability** on this repository.

Include what you found, how to reproduce it, and the version (`VERSION`) or commit.
Expect an acknowledgement within a few days.

## Scope

In scope: authentication and sessions, workspace isolation (one workspace reading or
changing another's data), permissions, uploads, webhooks and the public API.

The demo accounts in [docs/demo-guide.md](docs/demo-guide.md) exist only in seeded
development data. They are not a vulnerability; never run `seed_demo` in production.

## Deploying safely

Set your own secrets (`DJANGO_SECRET_KEY`, encryption and signing keys) from
`deploy/.env.production.example`; the development defaults are not safe for production.
