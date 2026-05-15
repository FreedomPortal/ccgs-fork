---
paths:
  - "src/**"
---

# Baseline Source Rules

> **Coverage note**: This rule applies to ALL `src/` code. Subdirectories with a
> dedicated rule file (`core/`, `gameplay/`, `ai/`, `networking/`, `ui/`, `tools/`)
> also inherit these baselines. If you are writing code in a `src/` subdirectory
> that has NO dedicated rule file, flag it: that subdirectory is coverage-dark and
> needs its own rule added to `.claude/rules/`.

## Baseline Standards (all src/ code)

- All public APIs require doc comments
- Gameplay values must be **data-driven** (external config), never hardcoded constants
- Prefer dependency injection over singletons for testability
- Every new system needs a corresponding ADR in `docs/architecture/`
- Commits must reference the relevant story ID or design document
- Check `docs/engine-reference/` before calling any engine API — do not guess post-cutoff signatures
- Tests live in `tests/` — not co-located with source
