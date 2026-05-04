# CCGS Gap Remediation Playbook
*Companion to: `docs/ccgs-capability-analysis-2026-04-10.md`*
*Date: 2026-04-10*

Each entry describes one gap and provides a ready-to-paste prompt. Prompts include enough context to work in a fresh session with no prior conversation history.

---

## Priority Guide

| Priority | Effort | Gaps |
|----------|--------|------|
| P1 — Quick fixes | < 20 min | T2, T7, T10, B4 |
| P2 — New skills | 30–60 min | T1, T3, T4, T8, B1, B5, B6 |
| P3 — Structural | Multi-file, 60+ min | T5, T6, T9, B2, B3 |

---

## Quick Fixes

### T2 — Fix `/export-devlog` Output Path

**Problem:** The skill saves to `review/devlog-N-YYYY-MM-DD.md` instead of `production/publishing/`. This breaks `/publish-check`'s audit trail — it can't find devlogs.

**File:** `.claude/skills/export-devlog/SKILL.md`

**Prompt:**
```
Read .claude/skills/export-devlog/SKILL.md. The skill currently saves its output to
`review/devlog-[N]-[YYYY-MM-DD].md`. This is incorrect — all publishing artifacts
should live in `production/publishing/`. Change the output path to
`production/publishing/devlog-[N]-[YYYY-MM-DD].md`. Show me the diff before writing.
```

---

### T7 — Seed Agent Memory for Key Agents

**Problem:** Only `lead-programmer` has a memory file. `creative-director`, `technical-director`, and `producer` are the most valuable agents for cross-session learning.

**Files:** Three new files in `.claude/agent-memory/`

**Prompt:**
```
Read .claude/agent-memory/lead-programmer/MEMORY.md to understand the format used
for agent memory files in this project.

Then create the following three memory files using the same format:
- .claude/agent-memory/creative-director/MEMORY.md
- .claude/agent-memory/technical-director/MEMORY.md
- .claude/agent-memory/producer/MEMORY.md

Seed each with conventions and patterns already established in the project — check
design/gdd/, docs/architecture/ (if it exists), and .claude/docs/technical-preferences.md.
Each agent's memory should reflect decisions relevant to their domain. Ask before
writing each file.
```

---

### T10 — Add Budget Tracking to Milestone Plans

**Problem:** `/milestone-plan` has no financial fields. Solo developers need to track time and cost alongside delivery targets.

**File:** `.claude/skills/milestone-plan/SKILL.md`

**Prompt:**
```
Read .claude/skills/milestone-plan/SKILL.md and any milestone template in
.claude/docs/templates/.

Add budget tracking fields to the milestone plan output. For a solo indie developer,
the relevant fields are:
- Estimated development hours for the milestone
- Actual hours logged (filled in at /milestone-check time)
- Hard costs (asset store purchases, software licenses, contractor work)
- Running cumulative total vs. overall budget

Add these as optional questions in the skill's Q&A flow. Include them in the
generated milestone document as a "Budget" section. Show me the changes before writing.
```

---

### B4 — Add Conversion Metrics to Community Status

**Problem:** `community-status.md` tracks whether platform accounts are set up (yes/no) but not actual numbers — wishlists, followers, engagement.

**File:** `.claude/skills/community-plan/SKILL.md`

**Prompt:**
```
Read .claude/skills/community-plan/SKILL.md and production/publishing/community-status.md
if it exists.

The community status document tracks account setup but no metrics. Add a metrics
section to the template that includes:
- Steam wishlist count (manually updated)
- Follower count per active platform
- Best-performing post (link + engagement number)
- Weekly posting streak
- Target vs. actual goal (e.g., "500 wishlists before launch — currently 120")

Update the skill to prompt for current metric values when generating or updating
community-status.md. Show me the changes before writing.
```

---

## New Skills

### T1 — Harden `validate-push.sh`

**Problem:** Pushes to main/master are warned about but not blocked. An exit 0 means the hook is advisory only — a force push can still go through.

**File:** `.claude/hooks/validate-push.sh`

**Prompt:**
```
Read .claude/hooks/validate-push.sh and .claude/settings.json.

The current hook warns on pushes to main/master/develop but exits 0 (advisory only).
I want pushes to main and master to be genuinely blocked.

Modify the hook so that:
1. Pushes to `main` or `master` exit with 2 (Claude Code blocking exit code) with
   a clear message explaining why and how to use a feature branch instead
2. Pushes to `develop` remain advisory (exit 0 with warning)
3. Pushes to any other branch pass silently

In Claude Code hooks, exit 2 blocks the operation and shows the message to the user.
Show me the change before writing.
```

---

### T3 — Create `/analytics-setup` Skill

**Problem:** The `analytics-engineer` agent exists but has no entry skill. There is no workflow for designing telemetry or player behavior tracking.

**File:** `.claude/skills/analytics-setup/SKILL.md` (new)

**Prompt:**
```
Read these files to understand skill format and project context:
- .claude/agent-memory/lead-programmer/MEMORY.md (skill authoring conventions)
- .claude/skills/test-setup/SKILL.md (example setup-type skill)
- .claude/docs/technical-preferences.md (engine: Godot 4.6.2, language: GDScript)

Create a new skill at .claude/skills/analytics-setup/SKILL.md. Requirements:
- name: analytics-setup
- user-invocable: true
- Invokes: analytics-engineer agent
- Walks the developer through: what player events to track, what behaviors matter
  for a game like theirs, analytics platform choice (self-hosted vs. third-party),
  and how to implement tracking calls in Godot 4.6.2 GDScript
- Output: docs/analytics/analytics-plan.md
- Asks before writing any file

Show me the full skill content before writing.
```

---

### T4 — Create `/export-build` Skill

**Problem:** No skill invokes Godot's actual export system. All existing `/export-*` skills produce text content — devlogs, store copy, scripts — not game binaries.

**File:** `.claude/skills/export-build/SKILL.md` (new)

**Prompt:**
```
Read these files:
- .claude/agent-memory/lead-programmer/MEMORY.md (skill authoring conventions)
- docs/engine-reference/godot/VERSION.md (Godot 4.6.2)
- .claude/docs/technical-preferences.md
- .claude/skills/gate-check/SKILL.md (understand what "release" stage expects)

Create a new skill at .claude/skills/export-build/SKILL.md. Requirements:
- name: export-build
- Optional argument: platform (windows, linux, mac, web). If omitted, asks the user.
- Invokes godot-specialist to verify export templates are configured before attempting
- Runs: godot --headless --export-release "[preset name]" "[output path]"
- Output path: builds/[version]/[platform]/
- Verifies the export succeeded by checking the output file exists
- Logs the build result (version, platform, timestamp, pass/fail) to production/qa/builds.md

Show me the full skill before writing.
```

---

### T8 — Create `/live-ops-plan` Skill

**Problem:** Only `/live-event` exists for tactical live ops (single event design). No strategic planning skill exists for overall post-launch live service design.

**File:** `.claude/skills/live-ops-plan/SKILL.md` (new)

**Prompt:**
```
Read these files:
- .claude/agent-memory/lead-programmer/MEMORY.md (skill authoring conventions)
- .claude/skills/live-event/SKILL.md (existing tactical skill — do not duplicate it)
- .claude/skills/marketing-plan/SKILL.md (example strategic planning skill)
- design/gdd/game-concept.md (game context)

Create a new skill at .claude/skills/live-ops-plan/SKILL.md. Requirements:
- name: live-ops-plan
- Coordinates: live-ops-designer + producer + economy-designer
- Covers strategic design: post-launch content cadence, seasonal events calendar,
  player retention mechanics, engagement metrics, and economy health monitoring
- Complements /live-event (which handles individual events) — this skill handles
  the overarching plan that /live-event operates within
- Output: production/publishing/live-ops-strategy.md

Show me the full skill before writing.
```

---

### B1 — Create `/monetization-design` Skill

**Problem:** No workflow for revenue model design. `/balance-design` covers in-game economy but not how the game makes money (pricing, DLC, IAP strategy).

**File:** `.claude/skills/monetization-design/SKILL.md` (new)

**Prompt:**
```
Read these files:
- .claude/agent-memory/lead-programmer/MEMORY.md (skill authoring conventions)
- .claude/skills/balance-design/SKILL.md (related in-game economy skill)
- .claude/skills/marketing-plan/SKILL.md (publishing context)
- design/gdd/game-concept.md (game context)

Create a new skill at .claude/skills/monetization-design/SKILL.md. Requirements:
- name: monetization-design
- Coordinates: economy-designer + publishing-manager + game-designer
- Covers: pricing strategy (premium, F2P, buy-once + DLC), post-launch revenue
  streams, pricing for target markets, and player trust alignment
- Must include ethical guardrails — flag pay-to-win patterns, manipulative loot
  box mechanics, and dark patterns as risks to call out explicitly
- Output: design/monetization/monetization-plan.md

Show me the full skill before writing.
```

---

### B5 — Create `/press-outreach` Skill

**Problem:** The press kit exists but there is no workflow for contacting press, journalists, or content creators. A solo developer needs a structured outreach process.

**File:** `.claude/skills/press-outreach/SKILL.md` (new)

**Prompt:**
```
Read these files:
- .claude/agent-memory/lead-programmer/MEMORY.md (skill authoring conventions)
- .claude/skills/export-presskit/SKILL.md (press kit generation — this skill uses its output)
- production/publishing/publishing-roadmap.md (if it exists, for stage context)

Create a new skill at .claude/skills/press-outreach/SKILL.md. Requirements:
- name: press-outreach
- Coordinates: publishing-manager + community-manager
- Helps build a media contact list: journalists, YouTubers, streamers, indie game
  press relevant to the genre
- Drafts outreach email/DM templates tailored to the game
- Creates a tracking document at production/publishing/press-contacts.md with columns:
  Name, Outlet, Contact method, Status (not contacted / sent / replied / coverage), Notes
- Advises on timing relative to release date (e.g., review keys 2–3 weeks before launch)

Show me the full skill before writing.
```

---

### B6 — Create `/post-mortem` Skill

**Problem:** No structured retrospective exists after milestones or at release. Retrospectives are the primary way a solo developer improves process between projects.

**File:** `.claude/skills/post-mortem/SKILL.md` (new)

**Prompt:**
```
Read these files:
- .claude/agent-memory/lead-programmer/MEMORY.md (skill authoring conventions)
- .claude/skills/milestone-check/SKILL.md (this skill typically runs after milestone-check)
- .claude/skills/gate-check/SKILL.md (stage system context)

Create a new skill at .claude/skills/post-mortem/SKILL.md. Requirements:
- name: post-mortem
- Optional argument: milestone or stage name (e.g., `post-mortem pre-production`)
- Coordinates: producer + relevant department leads for what was completed
- Covers: what went well, what went wrong, scope creep analysis, time estimate
  accuracy, technical decisions that paid off or didn't, and one concrete process
  change to implement next milestone
- Output: production/postmortems/[milestone]-[date].md
- Keep it short — no long ceremony for a solo developer. The output should be
  actionable in under 2 pages.

Show me the full skill before writing.
```

---

## Structural Changes

### T5 — Gate Publishing Artifacts at Stage 6

**Problem:** A game can advance to Release (stage 7) without a store page, press kit, or publishing roadmap ever being created. Stage 6 (Polish) gate must verify these exist.

**Files:** `.claude/skills/gate-check/SKILL.md`, `.claude/docs/director-gates.md`

**Prompt:**
```
Read these files:
- .claude/skills/gate-check/SKILL.md (the 7-stage gate system)
- .claude/docs/director-gates.md (the 18 named gate definitions)
- .claude/skills/publish-check/SKILL.md (the publishing audit skill)

I want to add a publishing readiness check to the Stage 6 (Polish/Release Candidate)
gate. Before the gate can PASS, it must verify these files exist:
- production/publishing/publishing-roadmap.md
- production/publishing/community-status.md
- A store page draft (any file in production/publishing/ matching store-page*)
- A press kit (any file in production/publishing/ matching presskit*)

If any artifact is missing, the gate must:
1. List exactly which artifacts are missing
2. Suggest the specific skill to run to create each one
3. Block the PASS verdict until all four are present

Add this as a blocking checklist item in the Stage 6 section of gate-check, and
add a corresponding note in the RM (release-manager) gate in director-gates.md.
Show me all changes before writing.
```

---

### T6 — Include Tooling Work in Sprint Planning

**Problem:** `/sprint-plan` ignores `tools/TOOL_SPEC.md`. If the developer is building a pipeline tool alongside the game, those stories are invisible to the sprint system.

**File:** `.claude/skills/sprint-plan/SKILL.md`

**Prompt:**
```
Read these files:
- .claude/skills/sprint-plan/SKILL.md (the sprint planning skill)
- .claude/skills/setup-tool/SKILL.md (to understand the TOOL_SPEC.md structure)
- tools/TOOL_SPEC.md if it exists

Modify /sprint-plan so that at the start of execution it checks whether
tools/TOOL_SPEC.md exists. If it does:
1. Read the tool spec to understand what pipeline work is in scope
2. Ask the developer how many sprint points to allocate to tooling this sprint
3. Include a "Pipeline Tools" section in the generated sprint document alongside
   the game development sections

If tools/TOOL_SPEC.md does not exist, the skill behaves exactly as it does today.
Show me the changes before writing.
```

---

### T9 — Audit and Fill Rule Coverage Gaps

**Problem:** `.claude/rules/` files only enforce standards when Claude edits paths that match their `paths:` frontmatter. Paths with no matching rule get no automated enforcement — and those gaps are completely silent.

**Files:** `.claude/rules/*.md` (audit + possible new files)

**Prompt:**
```
This is a two-phase audit task.

Phase 1 — Map coverage:
Read every file in .claude/rules/ and note the path pattern in each file's `paths:`
frontmatter. Then list the top-level directories inside src/ to understand what
code directories exist in this project.

Phase 2 — Identify gaps:
For each src/ subdirectory that has NO matching rule, flag it as a gap. Present
the full gap list for my review before creating anything.

Phase 3 — Fill gaps (after I approve the gap list):
For each gap I approve, draft a new rule file. Base the constraints on:
- The type of code in that directory (infer from the directory name and any files present)
- Constraints already established in existing rules (do not contradict them)
- The coding standards in .claude/docs/coding-standards.md

Show me each draft individually before writing. Do not batch-write rules.
```

---

### B2 — Add Solo-Dev Scope Reality Check to Producer Gate

**Problem:** The producer's phase gate has no viability check. An ambitious solo developer can gate-check into Production with a scope that is financially or logistically unrealistic.

**File:** `.claude/docs/director-gates.md`

**Prompt:**
```
Read these files:
- .claude/docs/director-gates.md (all 18 gate definitions)
- .claude/skills/gate-check/SKILL.md (how gates are invoked)
- design/gdd/game-concept.md (game scope context)
- production/publishing/publishing-roadmap.md if it exists

Find the PR-PHASE-GATE definition (the producer's phase gate, used at stages 4 and 5).

Add a "Solo Dev Viability Check" block that the producer agent must evaluate before
the gate can PASS. The check asks three questions:
1. Is the remaining scope achievable by one person before the runway runs out?
2. Does the projected release date align with the marketing calendar?
3. Are there scope creep risks relative to the original concept GDD?

Each question is YES/NO with a required one-sentence justification. A NO does NOT
automatically fail the gate — it creates a flagged risk that the developer must
explicitly acknowledge before the gate advances. Show me the change before writing.
```

---

### B3 — Create `/team-publish` Skill

**Problem:** Publishing has no parallel team execution pattern. `/team-code` and `/team-design` coordinate multiple agents in parallel — publishing needs the same.

**File:** `.claude/skills/team-publish/SKILL.md` (new)

**Prompt:**
```
Read these files:
- .claude/agent-memory/lead-programmer/MEMORY.md (skill authoring conventions)
- .claude/skills/team-design/SKILL.md (example parallel team skill)
- .claude/skills/team-code/SKILL.md (another team skill example)
- .claude/skills/marketing-plan/SKILL.md
- .claude/skills/community-plan/SKILL.md
- .claude/skills/export-devlog/SKILL.md

Create a new skill at .claude/skills/team-publish/SKILL.md. Requirements:
- name: team-publish
- Optional argument for focus: `launch` (pre-launch push), `devlog` (single cycle),
  `full` (comprehensive publishing review). Default: full.
- Coordinates three agents in parallel:
  - publishing-manager: roadmap review, store page status, presskit status
  - community-manager: platform activity, content calendar, metrics update
  - writer: draft any copy needed (devlog, patch notes, store description updates)
- Collates all three outputs into a unified publishing status summary
- Surfaces action items with suggested follow-up skills for each

Show me the full skill before writing.
```

---

## Quick Reference Table

| Gap | File | Est. Effort |
|-----|------|-------------|
| T1 | `.claude/hooks/validate-push.sh` | 15 min |
| T2 | `.claude/skills/export-devlog/SKILL.md` | 5 min |
| T3 | `.claude/skills/analytics-setup/SKILL.md` (new) | 45 min |
| T4 | `.claude/skills/export-build/SKILL.md` (new) | 45 min |
| T5 | `gate-check/SKILL.md` + `director-gates.md` | 60 min |
| T6 | `.claude/skills/sprint-plan/SKILL.md` | 30 min |
| T7 | 3× `.claude/agent-memory/*/MEMORY.md` (new) | 30 min |
| T8 | `.claude/skills/live-ops-plan/SKILL.md` (new) | 45 min |
| T9 | `.claude/rules/*.md` audit + new files | 60 min |
| T10 | `.claude/skills/milestone-plan/SKILL.md` | 20 min |
| B1 | `.claude/skills/monetization-design/SKILL.md` (new) | 45 min |
| B2 | `.claude/docs/director-gates.md` | 30 min |
| B3 | `.claude/skills/team-publish/SKILL.md` (new) | 60 min |
| B4 | `.claude/skills/community-plan/SKILL.md` | 20 min |
| B5 | `.claude/skills/press-outreach/SKILL.md` (new) | 45 min |
| B6 | `.claude/skills/post-mortem/SKILL.md` (new) | 30 min |

*Effort estimates assume a fresh Claude Code session with no prior context.*

---

*Companion to `docs/ccgs-capability-analysis-2026-04-10.md`*
*2026-04-10*
