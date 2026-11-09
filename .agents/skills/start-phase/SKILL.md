---
name: start-phase
description: Implement one TaskForge phase from its doc in docs/phases/, test-first, one feature only. Use when the user says start/build/implement phase NN (or the next phase).
---

# Start a phase

`AGENTS.md` wins over this file.

1. **Pick the phase** — the number given, else the first unchecked one in
   `docs/02-roadmap.md` whose dependencies are done. Confirm dependencies exist
   in code; if not, stop and say which.
2. **Read** the phase doc fully, plus `docs/01-architecture.md`. Check the
   backend skeleton rules there (reuse existing apps/helpers before writing new).
3. **Plan** in ≤ 8 steps from the doc's Scope/API/UI sections; show it, then go.
   Do not add anything from **Out** — write a new phase doc instead.
4. **Contracts first** — edit `proto/` / Ninja schemas, run `proto-regen`.
5. **TDD** — `test-writer` style: failing test, minimal code, pass. Services
   first, then adapters (Ninja / gRPC / WebSocket), then Flutter.
6. **Verify** — `verifier` agent; then `code-reviewer` on the diff; fix CRITICAL
   and HIGH findings.
7. **Audit** — `phase-auditor` on the phase; close gaps until READY.
8. **Docs** — `docs-sync` if reality differed from the plan; tick the phase in
   `docs/02-roadmap.md`.
9. Commit only when asked (use the `commit` skill).
