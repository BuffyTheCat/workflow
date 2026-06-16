# Workflow: Vault Maintenance

## Scope

Use for reviewing candidate lessons and deciding whether they become canonical, stale, rejected, archived, or require operator decision.

## Boundary Rules

- No app code edits.
- Do not mutate `MainVault/**` unless the current task explicitly approves Vault maintenance and exact target paths.
- Review-only mode is valid: produce decisions and patch suggestions without writing canon.
- Live/source repos are read-only evidence sources unless explicitly named as mutation targets.
- `AgentOps/Runtime/imports/**` is quarantine/reference, not active canon.
- Print intended Vault target paths before any write.
- Follow `AgentOps/Core/OPERATOR_VISIBILITY_PROTOCOL.md` for preflight status, proposed Vault mutation boundary, conflict/blocker checkpoints, and final report summary.

## Evidence Rules

- Follow `AgentOps/Core/KNOWLEDGE_VAULT_POLICY.md` and `AgentOps/Core/EVIDENCE_CONTRACT.md`.
- Separate canonical, candidate, imported, stale, conflict, memory-only, and unknown material.
- Memory-only or imported material must not be promoted as fact without direct evidence.
- Conflicts must not be silently resolved.

## Promotion Criteria

Promotion requires:

- direct evidence;
- reusable value beyond one narrow task;
- clear scope;
- explicit source;
- confidence;
- freshness or review condition;
- no contradiction with live repo, current ticket, or current architecture;
- known exceptions or `none known`.

## Steps

1. Preflight / Boundary
   - Identify whether the task is review-only or mutation-approved.
   - List approved Vault target paths if mutation is allowed.
2. Proposal Intake
   - Read candidate proposal(s) and source task/run/evidence.
3. Evidence Validation
   - Check live repo, current docs, ticket, commit, run artifacts, or Vault entries only as needed.
4. Classification
   - Decide per proposal: `PROMOTE`, `REJECT`, `STALE`, `ARCHIVE`, or `NEEDS_OPERATOR_DECISION`.
5. Conflict Handling
   - Mark conflicts explicitly and do not choose silently.
6. Optional Mutation
   - Write to `MainVault/**` only with explicit operator-approved Vault maintenance scope and target paths.
7. Final Report
   - Include proposals reviewed, decisions, evidence basis, files changed or no files changed, `Knowledge Delta`, and residual risks.

## Final Report Requirements

- proposals reviewed;
- decision per proposal;
- evidence basis;
- target location or reason not promoted;
- conflicts;
- what was not checked;
- files changed or `NONE`;
- recommended next action.
