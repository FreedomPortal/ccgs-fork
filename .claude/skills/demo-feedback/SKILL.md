---
name: demo-feedback
description: "Aggregate multiple demo playtest sessions into cross-session patterns, conversion trends, and a prioritized action list with a go/no-go recommendation for public release. Requires 2+ completed demo-playtest reports. Distinct from /demo-playtest which structures a single session."
argument-hint: "[--min-sessions N] [--review full|lean|solo]"
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
- `design/demo/demo-scope.md` — intended experience, goals, acceptance criteria
- `design/gdd/game-concept.md` — pillars and player fantasy
- `production/qa/playtests/demo-conversion-summary.md` — per-session conversion data

If `design/demo/demo-scope.md` does not exist:
> "`design/demo/demo-scope.md` not found. Run `/demo-scope` first."
Stop.

---

## Phase 2: Collect Playtest Reports

Glob `production/qa/playtests/demo-playtest-*.md` to find all demo playtest reports.

Count the reports. Resolve minimum session threshold:
- If `--min-sessions N` was passed → use N
- Else → default minimum is 2

If count < minimum:
> "Found [count] demo playtest report(s) — minimum is [min] for reliable pattern detection.
>
> Options:
> - Run /demo-playtest [N] more times to reach the threshold, then re-run /demo-feedback
> - Proceed anyway with [count] session(s) (findings are preliminary — treat as directional only)"

Use `AskUserQuestion`:
- Prompt: "Proceed with [count] session(s)?"
- Options: `Yes — treat findings as preliminary`, `No — I'll run more playtests first`

If No: stop.

Read all found playtest report files.

---

## Phase 3: Cross-Session Synthesis

Spawn `game-designer` via Task with this prompt:

```
Synthesize multiple demo playtest reports into cross-session patterns.

Demo scope context:
[paste design/demo/demo-scope.md — overview, included content, target playthrough duration,
demo end state, acceptance criteria]

Game pillars and player fantasy:
[paste relevant sections from game-concept.md]

Playtest reports ([N] sessions):
[paste all report content]

Conversion summary table (if present):
[paste demo-conversion-summary.md content]

Produce a cross-session synthesis with these sections:

## Session Overview
Table:
| Session | Date | Tester | Completed? | Conversion Intent | Session Time | vs. Target Duration |
|---------|------|--------|-----------|-----------------|--------------|-------------------|
One row per report. Flag sessions where "Prior knowledge" was not None (less reliable blind data).

## Completion Rate
- % of sessions where the tester reached the demo end state
- Where did non-completers stop? (exact point, if noted)
- Pattern: is there a specific point where testers consistently drop off?

## Conversion Trend
Based on the conversion intent data across all sessions:
- Distribution: Definitely / Probably / Unsure / Probably not / No (count per category)
- Positive conversion rate: (Definitely + Probably) / total sessions
- Most common reason for positive intent
- Most common reason for hesitation or negative intent

## Recurring Issues (appeared in 2+ sessions)
For each recurring issue:
- Description of the issue
- Sessions affected (N/total)
- Category: Conversion Blocker / Onboarding Failure / Completion Failure / Design Feedback / Bug / Polish

## Single-Session Issues
Issues reported in only one session — lower confidence, but note severity.
Group by category (same categories as above).

## Onboarding Pattern
For each core mechanic listed in the demo scope:
- % of sessions where it was understood without help
- Average time-to-understand across sessions
- Any consistent confusion triggers

## First 2 Minutes Aggregate
- % understood what the game is (without help)
- % understood what to do first (without help)
- Most common first point of confusion across sessions
- Most common first moment of engagement across sessions

## Demo End State Assessment
- % of completers who reached the end state
- Aggregate reaction description
- Was the CTA (wishlist/buy prompt) noticed and understood?

## Findings Priority Matrix
| Finding | Sessions | Category | Priority |
|---------|----------|----------|---------|
Rank all findings: Conversion Blockers first (P1), then Onboarding Failures (P2),
Completion Failures (P2), Bugs (P2-P3 by severity), Design Feedback (P3), Polish (P4).

## Top 5 Actions
The 5 highest-impact changes ranked by:
1. Frequency (how many sessions hit this)
2. Category weight (conversion blocker > onboarding failure > other)
3. Implementation effort (prefer low-effort high-impact)

Do not invent findings. If data is insufficient to determine a pattern, say so.
Flag any findings that directly contradict the intended experience in demo-scope.md.
```

Present the synthesis to the user. Discuss before proceeding.

---

## Phase 4: Go / No-Go Assessment

Spawn `producer` via Task:

```
Assess demo readiness for public release based on playtest synthesis.

Demo scope acceptance criteria:
[paste from demo-scope.md]

Playtest synthesis:
[paste Phase 3 synthesis output]

Answer:
1. Is the positive conversion rate (Definitely + Probably) above 60%?
   (If demo-scope.md defines a different threshold, use that.)
2. Are there any unresolved P1 Conversion Blockers?
3. Is the completion rate acceptable (>50% of testers reaching the demo end)?
4. Are there any S1/S2 bugs in the playtest reports?

Verdict: GO / NO-GO / CONDITIONAL GO
- GO: conversion rate met, no P1 blockers, completion rate acceptable, no S1/S2 bugs
- CONDITIONAL GO: conversion rate met but minor blockers remain — list specific conditions
- NO-GO: conversion rate below threshold, P1 blockers present, or S1/S2 bugs present

One paragraph of reasoning. For NO-GO: list the specific blockers that must be resolved.
For CONDITIONAL GO: list the specific conditions and their priority.
```

**Review mode check — creative director:**
- `solo` → skip.
- `lean` → skip.
- `full` → spawn `creative-director` via Task in addition to producer:

```
Review demo playtest synthesis against game pillars.

Game pillars and player fantasy:
[paste from game-concept.md]

Synthesis findings:
[paste Phase 3 synthesis output]

Answer:
1. Does the demo communicate the game's core identity?
2. Are any pillars being violated by the demo experience?
3. Is the single most important change to improve conversion design-level or polish-level?

Verdict: ALIGNED / MINOR CONCERNS / MISALIGNED
One paragraph.
```

If creative-director returns MISALIGNED: add a `## Creative Director Assessment` section to
the output document with their verdict and reasoning before the user proceeds.

---

## Phase 5: Write Feedback Document

Ask: "May I write the demo feedback synthesis to `production/qa/playtests/demo-feedback-[date].md`?"

If yes, write the file. Content:
- Phase 3 synthesis output
- Phase 4 go/no-go verdict (and creative director assessment if full mode)
- Top 5 priority actions clearly marked

---

## Phase 6: Summary and Next Steps

```
Demo Feedback Synthesis — COMPLETE
====================================
Output: production/qa/playtests/demo-feedback-[date].md
Sessions analyzed: [N]
Positive conversion rate: [X]%
Completion rate: [Y]%
P1 blockers: [count]
Verdict: [GO / NO-GO / CONDITIONAL GO]

Priority actions:
1. [P1 item]
2. [P2 item]
3. [P3 item]

[If GO:]
Next steps:
- /demo-polish — run a final polish pass before public release
- /demo-build — export the final demo build

[If CONDITIONAL GO:]
Next steps:
- /demo-iterate [--blocker 1] — resolve P1 items first
- /demo-polish — then run the polish pass
- /demo-build — final build after polish

[If NO-GO:]
Next steps:
- /demo-iterate [--all-blockers] — address all P1 items
- /demo-playtest — run additional sessions after fixes to verify
- Re-run /demo-feedback when conversion blockers are resolved
```

---

## Collaborative Protocol

- Never invent playtest data — only aggregate what is in the report files
- State session count prominently — small N (1–2) is preliminary, not conclusive
- Positive conversion rate threshold defaults to 60% unless demo-scope.md specifies otherwise
- GO verdict requires: threshold met AND no P1 blockers AND completion rate >50% AND no S1/S2 bugs
- Never write to `production/qa/playtests/` without explicit approval
