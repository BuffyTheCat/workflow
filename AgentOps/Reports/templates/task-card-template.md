# Task Card

Captured at intake. One per run. Updated only when scope or tier changes.

## Source

- Operator request:
- Ticket / issue ID:
- Branch / commit / PR:
- Linked tickets / parent / related:

## Task type

bug / regression / feature / refactor / investigation / prod-issue / architecture / vault-maintenance / other:

## Initial tier classification

- T0 / T1 / T2 / T3 / T4:
- Hard-case T2/T3 triggers found at intake: yes / no / pending evidence
- Triggers (if any): reopen / multi-comment / parent-related-issues / multi-slice / parent-AC vs latest-comment conflict / frontend-backend split / producer-consumer contract divergence / actor-state matrix divergence / branch-build divergence / runtime-media closure dependency / prior-fix interaction / other:

## Expected behavior

## Actual behavior

## Affected areas (initial guess; refine in EVIDENCE_LEDGER)

## Required evidence

- code / git / ticket / media / runtime / vault:

## Required tools / MCP

- Linear / Jira / GitHub / browser / ffmpeg / other:

## Capability preflight

If capability preflight is recorded as an artifact, persist it inline in `EVIDENCE_LEDGER.md` (Capability section) or as `RuntimeEvidence/runs/<run-id>/CAPABILITY_PREFLIGHT.md`. No separate template is required; the canonical structure is: MCP availability, browser availability, ffmpeg/media tooling, repo access, ticket access.

## Known unknowns at intake

## Stop conditions

- mutation target unclear:
- destructive action would be required:
- skeptic blocker:
- MCP/auth/media/browser blocker for material capability:
- conflict with Vault canonical rules:
- other:

## Operator-approved scope

- mutation: yes / no / read-only-only
- target paths:
- target repos:
- branches / commits allowed:

## Cross-references

- `AgentOps/Core/AGENT_OS.md` — Task Classification Gate.
- `AgentOps/RuntimeEvidence/runs/README.md` — tier-based artifact requirements.
