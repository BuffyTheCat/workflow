# MainVault Index

Status: TEMPLATE
Scope: project-specific knowledge for the repository where this workflow is installed.

`MainVault` is intentionally clean in the shareable workflow package. Fill it with project facts only after verifying them against the target repository, tickets, docs, or runtime evidence.

## Always Loaded

- [01_ALWAYS_READ.md](01_ALWAYS_READ.md) — generic AgentOps always-read rules.

## Suggested Project Files

Create these only when the project has verified evidence for them:

- `01_PROJECT_BRIEF.md`
- `02_ARCHITECTURE_MAP.md`
- `03_DOMAIN_GLOSSARY.md`
- `04_CANONICAL_RULES.md`
- `05_DO_DONT.md`
- `06_COMMON_MISTAKES.md`
- `07_BUSINESS_LOGIC.md`
- `08_UI_UX_RULES.md`
- `09_TESTING_RULES.md`
- `10_KNOWN_REGRESSIONS.md`
- `11_TICKET_DERIVED_LESSONS.md`
- `12_AGENT_LEARNINGS.md`
- `13_RUNTIME_AND_TOOLING.md`
- `14_OPEN_QUESTIONS.md`
- `15_STALE_OR_UNVERIFIED.md`
- `16_AGENT_LEARNINGS_PROPOSED.md`
- `16_CONFLICTS.md`

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
