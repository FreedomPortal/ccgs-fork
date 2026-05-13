---
name: demo-playtest
description: "Structured playtest protocol for demo builds. Focuses on first impression, onboarding clarity, playthrough completion, and wishlist/purchase conversion intent — the metrics that matter for demos specifically."
argument-hint: "[new|analyze path-to-notes] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Task, AskUserQuestion
---

## Phase 0: Resolve Review Mode

1. If `--review [mode]` was passed → use that
2. Else read `production/review-mode.txt` → use that value
3. Else → default to `lean`

---

## Phase 1: Parse Arguments

- `new` → generate a blank demo playtest report template (Phase 2A)
- `analyze [path]` → read raw notes and fill in the template with structured findings (Phase 2B)

If no argument: default to `new`.

---

## Phase 1b: Read Demo Context

Read the following if they exist:
- `design/demo/demo-scope.md` — included content, target playthrough duration, end state
- `design/gdd/game-concept.md` — core loop, pillars, player fantasy

If `design/demo/demo-scope.md` does not exist:
> "No demo scope found. Run `/demo-scope` first to define the demo before running a playtest."
Stop.

---

## Phase 2A: New Template Mode

Generate this template and show it to the user. The demo template differs from
the generic playtest report — every tester is a first-time player, and the
primary success metrics are completion rate and purchase intent.

```markdown
# Demo Playtest Report

## Session Info
- **Date**: [Date]
- **Build version**: [Version/Commit]
- **Tester**: [Name/ID or "Anonymous"]
- **Platform**: [PC/Console/Mobile]
- **Input method**: [KB+M / Gamepad / Touch]
- **Prior knowledge of game**: [None / Saw announcement / Wishlisted / Followed development]
- **Demo session type**: [Observed / Unobserved / Remote async]

## Playthrough Metrics
- **Completion**: [Reached demo end? Yes / No / Partial — stopped at: ___]
- **Total session time**: [X minutes]
- **Expected duration (from demo-scope.md)**: [Y minutes]
- **Restarts**: [Number of times player restarted from beginning]

## First 2 Minutes (Critical Window)

The demo's hook lives or dies here. Capture everything.

- **Understood what the game is?** [Yes / No / Partially]
- **Understood what to do first?** [Yes / No / Partially — needed: ___]
- **Emotional response at launch**: [Excited / Curious / Confused / Indifferent / Frustrated]
- **First point of confusion**: [What it was, when it happened]
- **First moment of engagement**: [What caused it, when it happened]

## Onboarding Assessment

Each demo tester is a first-time player — there are no returning players in a demo.

| Mechanic / System | Understood without help? | Time to understand | Notes |
|-------------------|--------------------------|-------------------|-------|
| [Core mechanic 1] | Yes / No / Partially | [X min] | |
| [Core mechanic 2] | Yes / No / Partially | [X min] | |
| [Add rows from demo-scope.md included content] | | | |

## Gameplay Flow
### What worked well
- [Observation]

### Pain points (with severity)
- [Issue — Severity: High / Medium / Low]

### Confusion points
- [What confused them and at what point in the playthrough]

### Moments of delight
- [What surprised or engaged the player]

## Demo End State
- **Reached the demo end?** [Yes / No]
- **If yes — reaction to end screen / CTA**: [Description]
- **If no — where did they stop and why**: [Description]

## Conversion Intent (Primary Demo Metric)

These questions determine whether the demo is doing its job.

- **Would you wishlist / buy this game?** [Definitely / Probably / Unsure / Probably not / No]
- **What was the single strongest reason for your answer?**
- **What, if anything, would make you more likely to buy?**
- **How would you describe this game to a friend in one sentence?**
  (Captures whether the demo communicated the game's identity clearly)

## Hook Strength
- **Did you want to keep playing after the demo ended?** [Yes / No / Somewhat]
- **What made you want more (or not)?**
- **Did the demo feel too short, about right, or too long?** [Too short / Right / Too long]

## Bugs Encountered
| # | Description | Severity | Reproducible |
|---|-------------|----------|-------------|

## Overall Assessment
- **Difficulty**: [Too Easy / Just Right / Too Hard]
- **Pacing**: [Too Slow / Good / Too Fast]
- **Demo length vs. expectation**: [Shorter than expected / About right / Longer than expected]

## Top 3 Findings from this session
1. [Most important finding for demo improvement]
2. [Second priority]
3. [Third priority]
```

---

## Phase 2B: Analyze Mode

Read raw notes at the provided path. Read `design/demo/demo-scope.md` and
`design/gdd/game-concept.md` for context. Fill in the template with structured
findings derived from the raw notes. Flag any observations that conflict with
the intended demo experience (from the scope doc).

---

## Phase 3: Finding Categorization

Categorize all findings:

- **Conversion blockers** — reasons a player would NOT wishlist/buy; address before demo release
- **Onboarding failures** — mechanics that were not understood without help
- **Completion failures** — reasons players stopped before reaching the demo end
- **Design feedback** — fun/feel/flow issues that affected the experience
- **Bugs** — reproducible implementation defects
- **Polish items** — friction not blocking conversion, for later

Present the categorized list, then route:

- **Conversion blockers**: These are the highest priority — address before any public release
- **Onboarding failures**: Run `/ux-review` on the affected flow to redesign the tutorial/introduction
- **Completion failures**: Check whether the demo scope's playthrough flow matches actual player paths
- **Design feedback**: "Run `/propagate-design-change [path]` on the affected GDD before making changes."
- **Bugs**: "Use `/bug-report` to formally track these."
- **Polish items**: "Add to the polish backlog — address in `/team-polish` before demo release."

---

## Phase 4: Creative Director Demo Review

**Review mode check** — apply before spawning:
- `solo` → skip. Note: "CD-DEMO-PLAYTEST skipped — Solo mode."
- `lean` → skip. Note: "CD-DEMO-PLAYTEST skipped — Lean mode."
- `full` → spawn as normal.

Spawn `creative-director` via Task:

```
Review a demo playtest report against the game's design pillars.

[paste structured report]

Game pillars (from game-concept.md):
[paste pillars and player fantasy]

Demo scope (from demo-scope.md):
[paste overview and included content]

Assess:
1. Does the demo communicate the game's core identity within the first 2 minutes?
2. Does the conversion intent data suggest the demo is achieving its goal?
3. Are there any findings that indicate the demo experience contradicts the pillars?
4. What is the single most important change to improve demo conversion?

Verdict: APPROVE / CONCERNS / REJECT
One paragraph of reasoning.
```

Present the verdict. If CONCERNS or REJECT, add a `## Creative Director Assessment`
section to the report.

---

## Phase 5: Save Report

Ask: "May I write this demo playtest report to `production/qa/playtests/demo-playtest-[date]-[tester].md`?"

If yes, write the file, creating the directory if needed.

---

## Phase 6: Conversion Tracking (optional)

If this is one of multiple demo playtest sessions, ask:

"Would you like to track this session's conversion data in a summary table?"

If yes, create or append to `production/qa/playtests/demo-conversion-summary.md`:

```markdown
# Demo Playtest Conversion Summary

| Date | Tester | Completed? | Conversion Intent | Top Blocker |
|------|--------|-----------|------------------|-------------|
```

Append one row per session.

---

## Phase 7: Summary

```
Demo Playtest Report — COMPLETE
================================
Output: production/qa/playtests/demo-playtest-[date]-[tester].md
Completion rate: [Yes/No/Partial]
Conversion intent: [Definitely/Probably/Unsure/Probably not/No]
Top finding category: [Conversion blocker / Onboarding failure / Completion failure / ...]

Priority actions:
1. [Highest priority finding]
2. [Second finding]
3. [Third finding]

Next steps:
- Run /demo-playtest again with a fresh tester to build a conversion trend
- If conversion blockers found: address before any public demo release
- When 3+ sessions complete: review demo-conversion-summary.md for patterns
```

---

## Collaborative Protocol

- Never write a report without asking first (Phase 5)
- Conversion intent is the primary metric — always surface it prominently
- Every tester is a first-time player — do not weight feedback from testers who
  already know the game as heavily as truly blind testers
- Track completion rate separately from conversion intent — a player can love the demo
  without finishing it, and vice versa
