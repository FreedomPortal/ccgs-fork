---
name: publish-check
description: "Audits the current publishing pipeline against development stage. Compares what should have been done by now against what is actually done, and flags overdue, unlocked, and upcoming tasks. Run this at the start of any session or after reaching a development milestone."
argument-hint: "(no argument needed)"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, TodoWrite
---

When this skill is invoked:

## 1. Read Current State

Read all of the following:

- `production/publishing/publishing-roadmap.md` — required.
  If missing, fail with:
  > "No publishing roadmap found. Run `/marketing-plan` first to create one."
- `production/milestones/*.md` — current dev stage
- `production/session-state/active.md` — recent dev activity
- `production/publishing/community-status.md` — community platform status

---

## 2. Determine Current Dev Stage

From the milestone files, identify the current stage:
Pre-Production → MVP Prototype → Vertical Slice → Alpha → Pre-Launch → Launch

Cross-reference against the roadmap's "Current dev stage" field.
If they differ, note the discrepancy and use the milestone file as source of truth.

---

## 3. Run the Audit

For each phase in the roadmap up to and including the current dev stage:

- Tasks marked `not started` or `—` = **check if they should be done by now**
- If a task belongs to a phase the project has already passed: flag 🔴 Overdue
- If a task belongs to the current phase: flag 🟡 Unlocked Now
- If a task belongs to the next phase: flag 🟢 Upcoming (prepare now)

---

## 4. Present Audit Report

Output the report in conversation (do not write to file unless asked):

```
=== PUBLISHING AUDIT — [Game Title] ===
Dev stage: [current stage]
Roadmap last updated: [date]

🔴 OVERDUE ([count] items)
These tasks should have been done by now:
- [task] — [which phase it belongs to] — [suggested action]

🟡 UNLOCKED NOW ([count] items)
Your current dev stage makes these actionable:
- [task] — [why now] — [which export skill to use]

🟢 COMING UP ([count] items)
Start preparing these before the next milestone:
- [task] — [what preparation looks like]

✅ COMPLETED ([count] items)
[brief list]

=== MOST URGENT ACTION ===
[single most important thing to do this session]
[exact skill command to run]
```

---

## 5. Offer to Update Roadmap

Use `AskUserQuestion`:
- "Do you want to update the roadmap with today's audit results?"
  - Options: "Yes, update status and overdue/unlocked sections",
    "No, I'll update it manually", "Mark specific items as complete first"

If yes, update `production/publishing/publishing-roadmap.md`:
- Move completed items to ✅ section
- Update Overdue 🔴 and Unlocked 🟡 sections
- Update "Last updated" date

---

## 6. Offer Next Action

Use `AskUserQuestion`:
- "What do you want to do?"
  - Options:
    - "Work on the most urgent task now"
    - "Update /marketing-plan with new information"
    - "Run /community-plan to check community status"
    - "Skip publishing this session"
