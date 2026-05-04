---
name: dlc-design
description: "Design a DLC content pack: scope, content type, pricing, implementation requirements, and release timing. Produces design/monetization/dlc/[dlc-slug].md. Integrates with /monetization-design and /live-ops-plan."
argument-hint: "[dlc-name]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
---

When this skill is invoked:

## Phase 1: Detect Current State

Read:
- `design/gdd/game-concept.md` — game title, genre, core loop, target audience
- `design/monetization/monetization-plan.md` — revenue model and any DLC strategy already defined
- `production/publishing/publishing-roadmap.md` — current stage, launch window

Scan `design/monetization/dlc/` for existing DLC design files.

If no game concept exists, stop:
> "No game concept found. Run `/brainstorm` first — DLC design depends on knowing the core loop and monetization model."

If no monetization plan exists, stop:
> "No monetization plan found. Run `/monetization-design` first to establish the revenue model before designing individual DLC packs."

---

## Phase 2: Resolve DLC Name

If an argument was passed, use it as the DLC name and proceed to Phase 3.

If no argument was passed:

If existing DLC files were found in Phase 1, use `AskUserQuestion`:
- Prompt: "Which DLC would you like to work on?"
- Options: list existing DLC slugs as "Update: [name]", plus "Create a new DLC"
- If updating: read the existing file and skip Phase 3 except to confirm any scope changes
- If creating new: ask for the name via plain text prompt

If no existing DLC files were found:
- Ask for the DLC name via plain text prompt before proceeding

---

## Phase 3: Define DLC Concept

Use `AskUserQuestion`:
- Prompt: "What type of content is this DLC?"
- Options:
  - `Content pack` — new gameplay items, levels, characters, or systems
  - `Expansion` — a substantial new campaign or feature set that extends the base game
  - `Cosmetic pack` — visual-only content; no gameplay impact
  - `Quality-of-life / utility` — convenience features, tools, or accessibility improvements

Use `AskUserQuestion`:
- Prompt: "When do you plan to release this DLC relative to launch?"
- Options:
  - `Day-one / launch window` — ships with or immediately after the base game
  - `3 months post-launch`
  - `6 months post-launch`
  - `12+ months post-launch`
  - `Undecided`

Use `AskUserQuestion`:
- Prompt: "What is the intended production scope?"
- Options:
  - `Small` — focused addition; minimal new systems (days to 2 weeks of work)
  - `Medium` — meaningful expansion; some new systems (1–2 months of work)
  - `Large` — near-expansion scale; significant new systems (3+ months of work)

---

## Phase 4: Spawn Design Agents

Read `design/gdd/game-concept.md` to extract game title, genre, and target audience.
Read `design/monetization/monetization-plan.md` for revenue model and existing DLC strategy.
Spawn both agents via Task simultaneously.

**Agent 1 — economy-designer:**

```
You are the economy designer for [GAME TITLE], a [GENRE] game targeting [PLATFORMS].
Monetization model: [MODEL]
DLC name: [DLC NAME]
DLC type: [TYPE FROM PHASE 3]
DLC scope: [SCOPE FROM PHASE 3]
Target release timing: [TIMING FROM PHASE 3]

Design this DLC's commercial structure. Produce:

1. Content Scope
   - What content or features should be included given the type and scope
   - What should be excluded to keep it focused and deliverable
   - Whether any base game systems need extension to support this DLC

2. Pricing Recommendation
   - Suggested price and justification (compare to similar DLC in the genre)
   - Whether this DLC should be standalone or require the base game
   - Bundle or discount strategy recommendation (e.g., base + DLC bundle)

3. Scope Warnings
   - Any scope elements risky for a solo developer to deliver at this timing
   - Suggested cut list if scope exceeds realistic solo dev capacity

4. Player Value Statement
   - In 2–3 sentences: what does the player get for their money?
   - Why is this DLC worth buying for someone who already owns the base game?

5. Ethical Check
   - Does this DLC split the player base in a way that harms the base game experience?
   - Does it gate content players would reasonably expect in the base game? (Flag if yes)
   - Does it create pay-to-win dynamics? (Flag as HIGH RISK if yes)

Format as a structured document. Do not write any game code.
```

**Agent 2 — publishing-manager:**

```
You are the publishing manager for [GAME TITLE], a [GENRE] game targeting [PLATFORMS].
Monetization model: [MODEL]
DLC name: [DLC NAME]
DLC type: [TYPE]
DLC scope: [SCOPE]
Target release timing: [TIMING]

Review this DLC from a publishing and market positioning perspective:

1. Market Fit
   - Does this DLC type match what players in this genre expect post-launch?
   - Name 2–3 comparable titles and how they handled similar DLC.

2. Timing Risk
   - Is this release window realistic given the current dev stage?
   - Are there any market timing concerns (e.g., competing launches, seasonal windows)?

3. Community Perception
   - How is this DLC type typically received in this genre's community?
   - What signals make players trust or distrust it?

4. Recommended Messaging
   - How should this DLC be communicated on the store page and in community posts?
   - What framing maximizes player trust?

Report in under 400 words. Do not write any game code.
```

After both agents complete, present both outputs to the user for review before writing anything.

---

## Phase 5: Write DLC Design Document

Derive a slug from the DLC name: lowercase, hyphens for spaces, no special characters.

Ask: "May I write the DLC design to `design/monetization/dlc/[dlc-slug].md`?"

Wait for confirmation before writing. Create `design/monetization/dlc/` if it does not exist.

Write the file with this structure:

```markdown
# DLC Design: [DLC Name] — [Game Title]
**Last updated:** [date]
**Type:** [content type]
**Scope:** [scope]
**Target release:** [timing]
**Status:** Draft

---

## Overview

[2–3 sentence summary of what this DLC is and who it is for]

---

## Content Scope

[From economy-designer — what is included and excluded]

---

## Pricing

[From economy-designer — price, standalone vs. bundle, justification]

---

## Player Value Statement

[From economy-designer — why this DLC is worth buying]

---

## Market Positioning

[From publishing-manager — market fit, community perception, recommended messaging]

---

## Production Notes

[From economy-designer scope warnings — solo dev risks and suggested cuts]

---

## Ethical Review

[From economy-designer — any flags documented here even if proceeding]

---

## Implementation Requirements

[Base game systems that must be complete or extended; new systems required; art pipeline impact]
[Fill in during pre-production for this DLC]

---

## Open Questions

[Unresolved design decisions — fill during development]
```

---

## Phase 6: Summary

After writing, output:

```
DLC Design — [DLC Name]
==================================
Type:       [content type]
Scope:      [scope]
Timing:     [release window]
Output:     design/monetization/dlc/[dlc-slug].md

Next steps:
1. Run /live-ops-plan to place this DLC on the post-launch content calendar
2. Run /create-epics when ready to break DLC implementation into stories
3. Run /scope-check before committing to production to validate solo dev feasibility

Verdict: COMPLETE — DLC design documented.
```

---

## Collaborative Protocol

- **Never write files without asking** — Phase 5 requires explicit approval before any write
- Both economy-designer and publishing-manager produce input — present both for review before writing
- Ethical flags are non-negotiable: document them in the output file even if the developer chooses to proceed
- Do not design DLC that gates content reasonably expected in the base game without surfacing it as an explicit flag
- If no monetization plan exists, stop at Phase 1 — `/monetization-design` must be run first
- Keep all agent prompts generic — substitute game-specific values at spawn time, never hardcode them
