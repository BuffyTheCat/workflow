# MainVault Index

Status: TEMPLATE
Scope: project-specific knowledge for the repository where this workflow is installed.

`MainVault` is the project knowledge safe. This shareable package ships with the
full knowledge structure but no private project facts. Fill the templates only
after verifying facts against the target repository, tickets, docs, git history,
or runtime evidence.

## Always Loaded

- [01_ALWAYS_READ.md](01_ALWAYS_READ.md) — generic AgentOps always-read rules.

## Knowledge Files

These files are included as templates. Keep `Status: TEMPLATE` until the target
project has verified evidence for that topic.

- [01_PROJECT_BRIEF.md](01_PROJECT_BRIEF.md) — project identity and boundaries.
- [02_ARCHITECTURE_MAP.md](02_ARCHITECTURE_MAP.md) — repository structure and ownership map.
- [03_DOMAIN_GLOSSARY.md](03_DOMAIN_GLOSSARY.md) — domain vocabulary.
- [04_CANONICAL_RULES.md](04_CANONICAL_RULES.md) — stable project rules.
- [05_DO_DONT.md](05_DO_DONT.md) — project-specific implementation guardrails.
- [06_COMMON_MISTAKES.md](06_COMMON_MISTAKES.md) — recurring pitfalls.
- [07_BUSINESS_LOGIC.md](07_BUSINESS_LOGIC.md) — domain behavior and invariants.
- [08_UI_UX_RULES.md](08_UI_UX_RULES.md) — UI/UX conventions.
- [09_TESTING_RULES.md](09_TESTING_RULES.md) — verified test commands and strategy.
- [10_KNOWN_REGRESSIONS.md](10_KNOWN_REGRESSIONS.md) — known regression history.
- [11_TICKET_DERIVED_LESSONS.md](11_TICKET_DERIVED_LESSONS.md) — lessons from tickets.
- [12_AGENT_LEARNINGS.md](12_AGENT_LEARNINGS.md) — accepted agent workflow learnings.
- [12_DECISIONS_ADR/](12_DECISIONS_ADR/) — architecture decision records.
- [13_RUNTIME_AND_TOOLING.md](13_RUNTIME_AND_TOOLING.md) — local runtime and tooling.
- [14_OPEN_QUESTIONS.md](14_OPEN_QUESTIONS.md) — unresolved questions.
- [15_STALE_OR_UNVERIFIED.md](15_STALE_OR_UNVERIFIED.md) — material that must not be trusted as canon.
- [16_AGENT_LEARNINGS_PROPOSED.md](16_AGENT_LEARNINGS_PROPOSED.md) — proposed lessons awaiting review.
- [16_CONFLICTS.md](16_CONFLICTS.md) — known conflicts and ambiguity.

## Pre-Code Constraint Pack

For T2+ mutating work, extract only the relevant project constraints before the
first write:

- active rules and do/don't constraints;
- module/domain business rules;
- common mistakes and known pitfalls;
- testing expectations;
- known regressions;
- conflicts, stale/unverified notes, and material `UNKNOWN`s;
- external-content trust warnings if imported notes are used.

Keep the pack short. Do not dump the whole Vault.

## Source Hierarchy

For implementation decisions, prioritize:

1. Operator's current instruction and approved mutation boundary.
2. Live repo/current code.
3. Current ticket / current task acceptance criteria.
4. Current branch diff / dirty state.
5. Recent relevant commits / PRs / tickets.
6. MainVault active/canonical rules.
7. Imported or memory-only Vault notes.
8. General model knowledge.

Rules:

- If MainVault conflicts with live repo/current ticket/current diff, report `CONFLICT`; do not silently choose.
- Old ticket/comment/imported notes are evidence, not law.
- Volatile facts must be rechecked before use.
- Use MainVault to build constraints, not to replace investigation.

## Evidence Labels

Use the taxonomy in `AgentOps/Core/EVIDENCE_CONTRACT.md`. If a project-specific claim is not verified, mark it `UNKNOWN`, `TODO_OPERATOR`, `INFERENCE`, or `RISK` rather than canonizing it.

## Current Template State

No target-project facts are recorded yet. The installed project should populate
these files gradually through normal AgentOps runs and explicit Vault
maintenance.
