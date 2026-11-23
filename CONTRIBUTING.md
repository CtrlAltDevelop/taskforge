# Contributing

Thanks for helping. The full project rules live in [AGENTS.md](AGENTS.md); in short:

- Work on one phase or feature at a time ([docs/02-roadmap.md](docs/02-roadmap.md)).
- Write tests first; new code needs 80%+ coverage.
- Every query is workspace-scoped. Never trust a client-supplied workspace id.
- Change the gRPC service or Ninja schema first, then run `make proto`.
- Use the design system (`app/lib/core/ui/`), not raw colours or icons.
- Commits: `<emoji> <type>(<scope>): <subject>`, see
  [docs/GIT_COMMIT_CONVENTIONS.md](docs/GIT_COMMIT_CONVENTIONS.md).

Set up with `make setup`, then check your change with `make check` and `make test`.
Open a pull request against `develop`.
