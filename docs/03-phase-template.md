# Phase document template

Each `docs/phases/phase-NN-<feature>.md` has these sections, in this order.
**Rule: one phase = one feature.**

1. **Feature** — one sentence.
2. **Why it exists** — the user problem and the Jira/ClickUp weakness it fixes.
3. **How it works (plain words)** — explanation a new teammate can understand.
4. **Scope** — In / Out (what is deliberately left to other phases).
5. **Data model** — tables and key fields.
6. **API surface** — Ninja endpoints, gRPC RPCs, WebSocket events (only those used).
7. **Flutter UI** — screens, widgets, states (loading/empty/error), per platform notes.
8. **Rules and edge cases** — the tricky bits.
9. **Acceptance criteria** — checklist; phase is done when all pass.
10. **Tests** — what must be tested.
11. **Depends on** — earlier phases.
