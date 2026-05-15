---
name: demo-iterate
description: "Thin orchestrator for targeted demo iteration: pull a specific blocker or all P1 blockers from /demo-feedback output, scope the minimum change, delegate to /dev-story or /bug-report, then chain to /demo-build + /demo-playtest to verify the fix. Logs each iteration to production/qa/demo-iterations.md."
argument-hint: "[--blocker N | --all-blockers] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Task, AskUserQuestion
---

## Phase 0: Resolve Review Mode

1. If `--review [mode]` was passed → use that
2. Else read `production/review-mode.txt` → use that value
3. Else → default to `lean`

---

## Phase 1: Read Prerequisites

Read the following if they exist:
- `design/demo/demo-scope.md` — demo scope and acceptance criteria
- `design/gdd/game-concept.md` — pillars (to catch scope creep)

Glob `production/qa/playtests/demo-feedback-*.md` — read the most recent file.
If no feedback file found, glob `production/qa/playtests/demo-playtest-*.md` and
read all playtest reports instead.

If neither exists:
> "No demo feedback or playtest reports found. Run `/demo-playtest` to generate data
> before iterating — iterate targets known problems, not assumed ones."
Stop.

---

## Phase 2: Select Iteration Target(s)

**If `--blocker N` was passed:** Find item N from the priority list in the feedback document.
Present it to the user and confirm it is the correct target.

**If `--all-blockers` was passed:** Extract all P1 items from the feedback document.
Present the list and ask:
- Prompt: "Address all [N] P1 blockers in this session?"
- Options:
  - `Yes — address all in sequence`
  - `No — let me pick which to tackle now`

If user picks: list P1 items and ask which to include this session.

**If no argument was passed:** Present the full priority list from the feedback document
(P1 first, then P2) and use `AskUserQuestion`:
- Prompt: "Which item(s) should this iteration address?"
- Options: [one per finding, numbered as in the feedback doc, plus "I'll describe a custom target"]

Store the selected item(s) as the iteration scope.

---

## Phase 3: Classify Each Target

For each selected item, determine the correct resolution path:

| Finding category | Resolution path |
|-----------------|----------------|
| Bug (reproducible defect) | `/bug-report` → `/dev-story` |
| Onboarding failure (UX flow) | `/ux-review` on the affected flow, then `/dev-story` |
| Design-level issue | `/propagate-design-change` — NOT handled in this iteration |
| Polish item | `/demo-polish` — redirect there |
| Conversion blocker (implementation) | `/dev-story` directly |
| Conversion blocker (design) | `/propagate-design-change` — NOT handled here |

For any item classified as **Design-level** or **Conversion blocker (design)**:
> "This finding requires a design change, not an implementation fix. To address it:
> 1. Run `/propagate-design-change [relevant GDD]` to scope the design change
> 2. Return to `/demo-iterate` after the GDD is updated
>
> Skipping to the next item."

For any item classified as **Polish item**:
> "This is a polish item, not a blocker. Run `/demo-polish` to address it.
> Skipping to the next item."

Confirm the resolution path with the user before proceeding.

---

## Phase 4: Scope the Minimum Fix

For each remaining target, spawn `lead-programmer` via Task:

```
Scope the minimum change needed to resolve this demo feedback item.

Demo feedback item:
[paste item description and category from feedback doc]

Demo scope context:
[paste design/demo/demo-scope.md — affected area only]

Game concept / pillars:
[paste relevant pillar if the fix touches player experience]

Answer:
1. What is the root cause of this issue?
2. What is the minimum code or content change that resolves it?
3. What files/systems would be touched?
4. What is the verification step — how do we know the fix works?
5. Effort estimate: Low (<2h) / Medium (2–8h) / High (>8h)

Rules:
- Do not add features — only fix the identified issue
- Do not refactor surrounding code
- If the root cause is design-level (the mechanic itself is wrong), say so and flag
  [DESIGN CHANGE NEEDED] — do not attempt to code around a design problem
- If it requires UX redesign (not just tweaks), flag [UX REVIEW NEEDED]
```

Present the scoped fix to the user. Confirm before proceeding.

If lead-programmer flags [DESIGN CHANGE NEEDED] or [UX REVIEW NEEDED]: surface the flag,
skip implementation for this item, and log it as DEFERRED with reason.

---

## Phase 5: Implement

For each target where the fix is scoped and approved:

**Bug path:**
1. If no bug report exists, spawn `qa-tester` via Task to write one
2. Spawn `dev-story` via Task with the scoped fix as the story description
3. dev-story handles the implementation — do not duplicate its work here

**Onboarding / UX path:**
1. Note: "`/ux-review` on [affected flow] is recommended to redesign the UX before implementing."
   Use `AskUserQuestion`:
   - Prompt: "Run /ux-review first, or implement directly from the feedback finding?"
   - Options: `Run /ux-review first`, `Implement directly from finding`
2. If direct: spawn `dev-story` via Task with the scoped fix
3. If ux-review first: stop this phase. User should run `/ux-review` then return to `/demo-iterate`.

**Conversion blocker (implementation) path:**
Spawn `dev-story` via Task with the scoped fix as the story description.

After implementation: confirm with user that the fix is complete before verification.

---

## Phase 6: Verify

For each implemented fix, present the verification step from Phase 4.

Use `AskUserQuestion`:
- Prompt: "Fix implemented for [item]. How would you like to verify it?"
- Options:
  - `Rebuild and run a new playtest session (/demo-build → /demo-playtest)`
  - `Quick smoke check only (run /smoke-check)`
  - `I'll verify manually — mark as pending verification`
  - `Skip verification for now`

If rebuild + playtest selected: provide the chain:
> "To verify:
> 1. Run `/demo-build` to rebuild with the fix applied
> 2. Run `/demo-playtest` focused on the fixed area
> 3. If the issue is resolved across 1–2 sessions, mark it done in the iteration log"

If smoke check selected: run `/smoke-check` against the affected area.

---

## Phase 7: Log Iteration

Ask: "May I log this iteration to `production/qa/demo-iterations.md`?"

If yes, create or append to `production/qa/demo-iterations.md`:

```markdown
# Demo Iteration Log

| Date | Item | Category | Scoped Fix | Status | Verification | Notes |
|------|------|----------|-----------|--------|-------------|-------|
```

For each target processed this session, append one row:
- Status: IMPLEMENTED / DEFERRED / DESIGN-LEVEL (redirected to propagate-design-change) / UX-REVIEW-NEEDED
- Verification: REBUILD+PLAYTEST / SMOKE CHECK / PENDING / SKIPPED

If `production/qa/demo-builds.md` exists and a rebuild was triggered: note the rebuild
reference in the build log as an "iteration rebuild" row.

---

## Phase 8: Summary and Next Steps

```
Demo Iteration — COMPLETE
==========================
Log: production/qa/demo-iterations.md
Items addressed: [N]
  - Implemented: [count]
  - Deferred (design-level): [count]
  - Deferred (UX review needed): [count]
  - Skipped (polish items): [count]

[For each implemented item:]
  [Item description] → [Status] → [Verification approach]

[If design-level items deferred:]
⚠️ Run /propagate-design-change on:
[list items]

[If UX review items deferred:]
⚠️ Run /ux-review on:
[list affected flows]

Next steps:
[If verification is rebuild+playtest:]
- /demo-build — rebuild with fix applied
- /demo-playtest — verify fix with a fresh session
- /demo-feedback — re-synthesize if this was the last P1 blocker

[If all P1 blockers implemented:]
- /demo-feedback — re-run to confirm NO-GO → GO transition
- /demo-polish — final polish pass before public release
- /demo-build — final build after polish
```

---

## Collaborative Protocol

- This skill is a thin orchestrator — it scopes and delegates, never implements directly
- Never attempt to fix design-level issues in code — flag and redirect to /propagate-design-change
- Never expand scope beyond the targeted item — one fix, one verification
- Always confirm the scoped fix before spawning dev-story (Phase 4 gate)
- Never write to `production/qa/` without explicit approval
- Builds triggered by this skill should appear in the existing demo-builds.md log, not a new file
