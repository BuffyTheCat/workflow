# Knowledge Vault Policy

## Purpose

`MainVault` is the project-specific memory layer. It stores evidence-tagged knowledge, canonical project rules, stale or disputed notes, and proposed learnings that are not yet canonical.

## Source Priority

1. Current user request or current ticket
2. Current repository code
3. Current branch diff
4. Recent related commits, PRs, or tickets
5. `MainVault` canonical rules
6. Older mined lessons
7. General model knowledge

## Query Rules

- Read `00_INDEX.md` first.
- Retrieve only relevant entries.
- Do not load the entire vault by default.

## Pre-code Constraint Pack

For T2+ mutating work, before the first write, Lead must ensure a compact Pre-code Constraint Pack exists. The pack may be inline unless the task is long-running, resumable, or handoff-heavy.

The pack is not a Vault dump. Include only:

- relevant Vault/project rules, or an explicit note that none were found;
- current task constraints and acceptance constraints;
- dirty-state and ownership constraints;
- architecture boundaries;
- approved mutation target;
- intended target paths;
- forbidden assumptions;
- evidence gaps and material `UNKNOWN`;
- sensitive, security, data, or production flags if any.

For T1, use a lightweight pack only when shared, business, sensitive, or risky behavior is touched. For T3/T4, the pack is mandatory.

## Canonical Vs Unverified

- Canonical project rules belong in evidence-backed `MainVault` files.
- Uncertain or stale material belongs in `15_STALE_OR_UNVERIFIED.md`.
- Proposed new learnings belong in `16_AGENT_LEARNINGS_PROPOSED.md` until reviewed.
- Task findings are not canonical by default. Reusable lessons must be proposed, then reviewed through `AgentOps/Workflows/vault-maintenance.md` and the Vault Curator role before promotion.
- Hard-case T3/T4 final reports must include a `Field Learning Candidate`: reusable rule or anti-pattern, evidence source, target file if accepted, whether it updates an existing lesson or proposes a new one, verified vs proposed status, safe-to-write status, supporting evidence, and what would make it unsafe or speculative. Prefer `MainVault/16_AGENT_LEARNINGS_PROPOSED.md` for proposed Vault learnings unless a targeted Core/Workflow doc is the better destination. `No reusable learning found` is valid only with a reason. Missing Field Learning Candidate on a hard-case T3/T4 run is one of the items that forces `INVALID_WORKFLOW_RUN` per the Hard-Case Self-Audit Checklist in `AgentOps/Reports/templates/final-report-template.md`.
- Rule 21: when a task exposes workflow friction, stale setup instructions, missing repeatable steps, undocumented local blockers, or repeated workaround patterns, record a Field Learning Candidate or Workflow Improvement Candidate. The target may be a specific `MainVault` runtime note, a workflow file, a report template, or another operator-approved workflow artifact. Do not silently leave recurrent workflow gaps only in chat.

## Conflict Protocol

- If `MainVault` conflicts with live repo code or the current task, report the conflict explicitly.
- Do not silently choose a side.
- Prefer live evidence for implementation decisions unless the operator says otherwise.

## Vault Update Proposal Process

1. Identify candidate knowledge.
2. Attach evidence tags and source references.
3. Classify source quality: canonical, candidate, imported, stale, conflict, memory-only, or unknown.
4. Review via Vault Curator decision: `PROMOTE`, `REJECT`, `STALE`, `ARCHIVE`, or `NEEDS_OPERATOR_DECISION`.
5. Mutate `MainVault` only when the current task explicitly approves Vault maintenance and target paths.
6. For workflow/tooling candidates, identify whether the correct destination is Vault knowledge, Core policy, a Workflow file, a Report/RuntimeEvidence template, or a script. Avoid promoting task-specific hacks into canon without scope and known exceptions.

## Promotion Requirements

Promotion requires direct evidence, reusable value beyond one narrow task, clear scope, explicit source, confidence, freshness or review condition, no unresolved contradiction with live repo/current ticket/current architecture, and known exceptions or `none known`.

`MEMORY_ONLY`, imported, stale, or conflicting material cannot be promoted as fact without direct evidence and operator-approved Vault maintenance scope.

Rejection is valid when a proposal is too task-specific, under-evidenced, stale, conflicted, duplicated by existing canon, or overgeneralized. Stale and archive classifications are useful outcomes, not failures.
