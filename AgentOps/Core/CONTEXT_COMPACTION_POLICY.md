# Context Compaction Policy

## Goal

Agents must survive context compaction without drifting, re-inventing conclusions, or forgetting constraints.

## Persisted Artifacts

For long-running or resumable work, persist compact state using:

- `AgentOps/Reports/templates/run-state-template.md`: current mission, boundary, current state, blockers, verification status, and next safe action.
- `AgentOps/Reports/templates/evidence-ledger-template.md`: evidence buckets and source pointers.
- Decisions, rejected alternatives, scope boundaries, and operator approvals are recorded inline in `EVIDENCE_LEDGER.md` (Decisions section) or in the run's `FINAL_REPORT.md` (Decisions / Operator Follow-Ups). No separate `DECISION_LOG.md` artifact is required; runs that produced one historically may keep it but new runs should consolidate into the existing artifacts.

Persisted run-state is not a diary. Do not store full chat transcripts, full file dumps, secrets, env values, tokens, PII, or private chain-of-thought.

## Preserve At Minimum

- compact task state;
- current tier;
- user constraints;
- approved mutation target;
- intended target paths;
- source repos touched;
- commit, push, branch, PR, and destructive command status;
- evidence status;
- unresolved questions;
- files changed;
- hypotheses;
- skeptic objections;
- what was not verified.

## Required Capsule Format

```md
# AgentOps Compaction Capsule
## User Request
## Current Tier
## Non-Negotiable Rules
## Repository State
## Files Read
## Files Changed
## Evidence Collected
## Active Hypotheses
## Rejected Hypotheses
## Current Fix Strategy
## Skeptic Objections
## Verification Done
## Not Verified
## Open Questions
## Next Safe Step
```

## Rules

- After compaction, the agent must resume from the capsule.
- The agent must not silently re-invent prior conclusions.
- Missing capsule data must be marked `UNKNOWN`, not guessed.
- Capture persisted run-state before compaction, restart/handoff, long investigation, first write after substantial discovery, skeptic/verifier handoff, final verification, and any resumable blocker.
- Announce meaningful run-state capture as an operator-visible checkpoint under `OPERATOR_VISIBILITY_PROTOCOL.md`.
- Keep detailed evidence in the Evidence Ledger and important decisions in the Decision Log; keep Run State focused on current mission, current state, blockers, and next safe action.
