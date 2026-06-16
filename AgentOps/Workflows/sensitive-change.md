# Workflow: Sensitive Change

## Scope

Use for T4 work: auth, billing, permissions, tenant isolation, data integrity, migrations, security, and production config.

## Context Continuity / Run State

- Before long investigation, implementation after substantial discovery, skeptic handoff, final verification, compaction/handoff, or any resumable blocker, capture run state per `AgentOps/Core/CONTEXT_COMPACTION_POLICY.md`.
- Important state must not live only in chat or model memory.
- Preserve at minimum: current task objective, approved mutation target, intended target paths if writes are planned, files inspected, files changed, evidence buckets, active or selected hypothesis, unresolved `UNKNOWN` / `TODO_OPERATOR`, verification status, and next safe action.
- Preserve source-repository containment in the captured state: live/source repos are read-only unless explicitly named as the mutation target, and `AgentOps/Runtime/imports/**` remains quarantine/reference, not active canon.
- Persist `Run State`, `Evidence Ledger`, and `Decision Log` using `AgentOps/Reports/templates/**`; T4 continuity must not rely on chat/model memory alone.

## Vault Hygiene / Knowledge Delta

- Task findings are not canonical project knowledge by default.
- Candidate reusable lessons must go through inline in the run's `FINAL_REPORT.md` Knowledge Delta section per `Core/KNOWLEDGE_VAULT_POLICY.md`.
- Do not write directly to canonical `MainVault` unless the workflow is explicitly vault-maintenance and operator-approved.
- Distinguish canonical, imported, stale, memory-only, conflict, and unknown evidence.
- Memory-only or imported material must not be promoted as fact without direct evidence.
- Conflicts go to conflict/unknown handling, not silent resolution.
- After completion, propose only reusable lessons with clear scope, source, confidence, and expiry or review condition.
- Final report must include `Knowledge Delta`: no update needed / proposal created / blocked by insufficient evidence.

## Final Reporting Mode

- Sensitive-change workflows must use `FULL` mode from `AgentOps/Reports/templates/final-report-template.md`.
- Do not use compact mode for T4, security, auth, permissions, billing, tenant isolation, data integrity, migrations, production config, or public contracts.

## Operator Visibility

- Use concise checkpoints from `AgentOps/Core/OPERATOR_VISIBILITY_PROTOCOL.md` at preflight, sensitive-boundary scan, approval gate, first-write, red-team/skeptic/verifier handoff, blocker, and final-verification boundaries.
- Stop for operator decision when approval, degraded evidence, or risk acceptance is unclear.

## Role Coverage / Agent Activation

- For T4 sensitive changes, apply Core Role Coverage / Agent Activation: record whether each materially relevant role used a dedicated visible subagent/pass, was handled inline by Lead, was not needed, was blocked/unavailable, or was skipped as risk.
- Security Red-Team, Skeptic, and Verifier are normally materially relevant; inline-only handling requires a strong reason and affects confidence.

## Steps

1. Classify as T4
2. Gather evidence
   - Create a compact Pre-code Constraint Pack before first write per `AgentOps/Core/KNOWLEDGE_VAULT_POLICY.md`; for T4 this is mandatory and must include sensitive/security/data/production flags.
3. Require explicit approval before writes
4. Write Boundary Check
   - Print intended target paths before any write.
   - Verify the approved mutation target.
   - Confirm live/source repositories are read-only unless explicitly named as the mutation target in the current task.
   - Confirm `AgentOps/Runtime/imports/**` is quarantine/reference, not active canon.
   - If MCP auth, media access, mutation target, dirty working tree, source ownership, or required runtime target is unclear after bounded investigation, stop and mark `UNKNOWN` or `TODO_OPERATOR`.
5. Build adversarial hypothesis tournament
6. Involve security red-team
7. Define rollback plan
8. Implement only if approval and evidence are sufficient
9. Verify with strongest available checks
10. Report residual risk explicitly

## Hard Rules

- No degraded writes.
- No silent assumptions.
- No agent-only override of blocked skeptic verdicts.
