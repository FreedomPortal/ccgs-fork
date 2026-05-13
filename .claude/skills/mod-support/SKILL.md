---
name: mod-support
description: "Design mod support architecture for the game: moddable scope, technical loading approach, authoring tools for modders, distribution strategy, and security constraints. Produces design/modding/mod-support.md and recommends a follow-up /architecture-decision for the mod loading system."
argument-hint: "(no argument needed)"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
---

When this skill is invoked:

## Phase 1: Detect Current State

Read:
- `design/gdd/game-concept.md` — game title, genre, core loop, platforms
- `docs/engine-reference/[engine]/VERSION.md` — engine and version (mod loading capabilities vary significantly by engine)
- `docs/architecture/` — scan for any existing ADRs relevant to asset loading, resource systems, or scripting
- `design/modding/mod-support.md` — load if exists (update vs. create)

If no game concept exists, stop:
> "No game concept found. Run `/brainstorm` first — mod support design requires knowing the genre, core loop, and platform targets."

---

## Phase 2: Determine Mode

If `design/modding/mod-support.md` already exists:
> "A mod support design already exists. What would you like to do?"

Use `AskUserQuestion`:
- Options: "Review and update existing", "Expand the moddable scope", "Start fresh (archive the old one)"

If no design exists: proceed to Phase 3.

---

## Phase 3: Define Modding Philosophy

Use `AskUserQuestion`:
- Prompt: "What level of modding do you want to support?"
- Options:
  - `Data / content only` — modders can replace or add assets and config data; no script access
  - `Full modding` — modders can add new systems, scripts, and content
  - `No modding planned` — document the decision; set architecture constraints now to avoid locking it out later
  - `Undecided — help me think through it`

If "Undecided", present this framing before proceeding:

> **Modding scope trade-offs:**
> - *Data/content only*: Low security risk; lower tooling cost; limits creative modding ceiling
> - *Full modding*: High creative ceiling; significant tooling and security investment; requires sandboxing or trust model
> - *No modding*: Zero additional scope now; document the decision so architecture does not accidentally prevent it post-launch

Use `AskUserQuestion`:
- Prompt: "How do you want mods to be distributed?"
- Options:
  - `Manual file install` — players copy files into a mods folder; lowest dev cost
  - `In-game mod browser` — built-in download and management UI; highest dev cost
  - `Third-party platform` — Steam Workshop, mod.io, or similar; medium dev cost
  - `Undecided`

Use `AskUserQuestion`:
- Prompt: "Is mod support in scope for the MVP, or post-launch?"
- Options:
  - `MVP` — mod support ships with v1.0
  - `Post-launch` — design the architecture now; implement tooling after launch
  - `Not planned` — document as a deliberate decision

---

## Phase 4: Spawn Design Agents

Read `design/gdd/game-concept.md` to extract game title, genre, engine, and platforms.
Read engine VERSION.md for the engine name and version.
Spawn both agents via Task simultaneously.

**Agent 1 — technical-director (runtime architecture and security):**

```
You are the technical director for [GAME TITLE], a [GENRE] game built with [ENGINE VERSION].
Mod support level chosen: [LEVEL FROM PHASE 3]
Distribution method: [METHOD FROM PHASE 3]
Target platforms: [PLATFORMS]

Design the mod loading runtime architecture and security model. Produce:

1. Mod Loading Architecture
   - How mods are loaded at runtime in [ENGINE VERSION] (resource packs, plugin system,
     script injection, or other engine-specific mechanism)
   - Entry points: when and how the game discovers and loads mods
   - Dependency resolution: if mods depend on other mods, how is ordering managed?
   - Hot-reload: are mods loadable without restarting the game? (nice-to-have vs. required)

2. Security Model
   - Can mod code execute arbitrary scripts? What is the attack surface?
   - Save data integrity: how are saves protected from malicious or buggy mods corrupting them?
   - Recommended sandboxing approach for the chosen mod level and engine
   - What the developer is and is not responsible for when mods crash the game

3. Engine-Specific Constraints
   - Capabilities and limitations of [ENGINE VERSION] for runtime mod loading
   - Any APIs or subsystems that are not safely moddable without engine modifications
   - Version compatibility: how are mods versioned against game updates?

4. Architecture Decision Requirements
   - Which aspects of this design should be captured in a formal ADR?
   - What architectural constraints should be registered to prevent future code from
     accidentally breaking mod compatibility?

Format as a structured technical document. Do not write any game code.
```

**Agent 2 — game-pipeline-developer (authoring tools for modders):**

```
You are the game pipeline developer for [GAME TITLE], a [GENRE] game built with [ENGINE VERSION].
Mod support level: [LEVEL FROM PHASE 3]
Distribution method: [METHOD FROM PHASE 3]
Target platforms: [PLATFORMS]

Design the modder-facing tooling pipeline. Produce:

1. Mod Authoring Tools
   - What tools does a modder need to create mods for this game?
   - Which of these can be satisfied by exporting the engine editor vs. requiring custom tools?
   - For data/content mods: what format do modders author in (JSON, YAML, engine resources, etc.)?
   - For full mods: what scripting or SDK access is needed?

2. Asset Pipeline for Modders
   - How do modders package their assets into a distributable mod file?
   - What format does the mod package use (zip, engine-specific pack, folder structure)?
   - Are there asset validation or format conversion steps required?

3. Modder Documentation Requirements
   - What documentation must the developer ship for modders to be productive?
   - Data schema documentation: which game data tables/configs are exposed?
   - API documentation: if scripts are exposed, what is the public API surface?

4. Distribution Tooling
   - For the chosen distribution method ([METHOD]), what tooling does the developer need to build?
   - What does the player-facing install experience look like?

5. Solo Developer Scope Filter
   - Which of the above is essential for a functional mod pipeline vs. nice-to-have?
   - Minimum viable modding toolset for a solo developer to ship

Format as a structured pipeline document. Do not write any game code.
```

After both agents complete, present both outputs to the user for review before writing anything.

---

## Phase 5: Write Mod Support Design

Ask: "May I write the mod support design to `design/modding/mod-support.md`?"

Wait for confirmation before writing. Create `design/modding/` if it does not exist.

Write the file with this structure:

```markdown
# Mod Support Design — [Game Title]
**Last updated:** [date]
**Engine:** [engine + version]
**Mod level:** [data/content only | full modding | none]
**Distribution:** [distribution method]
**Planned for:** [MVP | post-launch | not planned]
**Status:** Draft

---

## Overview

[2–3 sentence summary of the modding philosophy and what modders can do]

---

## Moddable Scope

[What can be modded; what is explicitly off-limits and why]

---

## Runtime Architecture

[From technical-director — mod loading approach, entry points, dependency resolution]

---

## Security Model

[From technical-director — sandboxing, save integrity, attack surface, developer responsibility boundaries]

---

## Modder Tooling

[From game-pipeline-developer — authoring tools, asset pipeline, distribution tooling]

---

## Minimum Viable Mod Pipeline (Solo Dev Slice)

[From game-pipeline-developer — essential tools only, no nice-to-haves]

---

## Documentation Required for Modders

[From game-pipeline-developer — schema docs, API surface, install guide]

---

## Engine-Specific Constraints

[From technical-director — engine capabilities and limitations for this version]

---

## Open Questions

[Unresolved decisions — fill during implementation]

---

## Related ADRs

[To be added when /architecture-decision is run for mod loading implementation]
```

---

## Phase 6: Recommend Architecture Decision

After writing the mod support design, display this note:

> **Next step: formalize the mod loading architecture as an ADR.**
>
> The technical-director identified architectural constraints in this mod design
> that should be registered to prevent future code from accidentally breaking
> mod compatibility.
>
> Run `/architecture-decision mod-loading-system` to create a formal ADR
> for the runtime mod loading architecture. This will register the relevant
> constraints in `docs/registry/architecture.yaml`.
>
> Also run `/security-audit` before shipping mod support — mod loading is an
> active attack surface (arbitrary file execution, save corruption, network
> requests from mod code).

---

## Phase 7: Summary

After writing, output:

```
Mod Support Design — [Game Title]
==================================
Mod level:      [level]
Distribution:   [method]
Planned for:    [MVP / post-launch / not planned]
Output:         design/modding/mod-support.md

Next steps:
1. Run /architecture-decision mod-loading-system to formalize the runtime ADR
2. Run /security-audit before shipping — mod loading is an attack surface
3. Run /create-epics when ready to break modding toolchain into stories

Verdict: COMPLETE — mod support design documented.
```

---

## Collaborative Protocol

- **Never write files without asking** — Phase 5 requires explicit approval before any write
- Both technical-director and game-pipeline-developer produce input — present both for review before writing
- If the developer chooses "No modding planned": still write the document — record the decision and note
  what architectural constraints should be preserved to avoid locking out modding post-launch
- Security implications are non-negotiable: always surface the attack surface analysis from the
  technical-director, even if the developer proceeds with full modding
- Do not recommend a specific mod distribution platform (Steam Workshop, mod.io, etc.) without noting
  their platform policies and revenue share terms — the developer must make an informed choice
- Keep all agent prompts generic — substitute game-specific values at spawn time, never hardcode them
