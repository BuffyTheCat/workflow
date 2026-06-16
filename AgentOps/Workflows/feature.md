# Workflow: Feature

## Scope

Use for new behavior or additive changes.

## Context Continuity / Run State

- Before long investigation, implementation after substantial discovery, skeptic handoff, final verification, compaction/handoff, or any resumable blocker, capture run state per `AgentOps/Core/CONTEXT_COMPACTION_POLICY.md`.
- Important state must not live only in chat or model memory.
- Preserve at minimum: current task objective, approved mutation target, intended target paths if writes are planned, files inspected, files changed, evidence buckets, active or selected hypothesis, unresolved `UNKNOWN` / `TODO_OPERATOR`, verification status, and next safe action.
- Preserve source-repository containment in the captured state: live/source repos are read-only unless explicitly named as the mutation target, and `AgentOps/Runtime/imports/**` remains quarantine/reference, not active canon.
- For long-running or resumable work, persist `Run State`, `Evidence Ledger`, and `Decision Log` using `AgentOps/Reports/templates/**`; do not rely on chat/model memory alone.

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

- T1/T2 feature work may use `COMPACT` mode from `AgentOps/Reports/templates/final-report-template.md`.
- Use `FULL` mode when there is conflict, material `UNKNOWN`, non-trivial residual risk, sensitive/security/data/production impact, operator request, or skeptic verdict `PASS_WITH_RISKS`, `REVISE_REQUIRED`, or `BLOCKED`.
- Compact mode must still include summary, files changed, evidence, verification, not run/not verified, residual risks, boundary/containment status, commit/push/branch/PR/destructive status, and `Knowledge Delta`.

## Operator Visibility

- Use concise checkpoints from `AgentOps/Core/OPERATOR_VISIBILITY_PROTOCOL.md` at preflight, constraint scan, first-write, skeptic/verifier handoff, blocker, and final-verification boundaries.
- If direction changes mid-run, update the objective and resume from the nearest safe checkpoint.

## Role Coverage / Agent Activation

- For T3/T4 or specialist-heavy feature work, apply Core Role Coverage / Agent Activation: record whether each materially relevant role used a dedicated visible subagent/pass, was handled inline by Lead, was not needed, was blocked/unavailable, or was skipped as risk.
- Verifier and Skeptic are relevant for behavior-changing work; other specialist roles are added only when task evidence warrants them.

## Steps

1. Requirements
   - Capture explicit user requirements.
   - Mark missing acceptance criteria as `TODO_OPERATOR`.
2. Existing Patterns
   - Find local implementation patterns before inventing structure.
3. MainVault
   - Check project rules, glossary, and architecture notes.
   - For T2+ mutating work, create a compact Pre-code Constraint Pack before the first write per `AgentOps/Core/KNOWLEDGE_VAULT_POLICY.md`; state explicitly if no relevant Vault/project constraints were found.
4. Architecture Boundaries
   - Identify modules, ownership boundaries, and sensitive surfaces.
5. Hypothesis Matrix
   - Model implementation options and blast radius.
   - Before implementation for non-trivial T2+ work, challenge the selected approach; record evidence against it or why it remains acceptable. For T1, use a lightweight check unless risk triggers escalation.
6. Write Boundary Check
   - Print intended target paths before any write.
   - Verify the approved mutation target.
   - Confirm live/source repositories are read-only unless explicitly named as the mutation target in the current task.
   - Confirm `AgentOps/Runtime/imports/**` is quarantine/reference, not active canon.
   - If mutation target, dirty working tree, source ownership, or required external context remains unclear after bounded investigation, stop and mark `UNKNOWN` or `TODO_OPERATOR`.
7. Implementation
   - Prefer the smallest pattern-consistent change.
8. Tests
   - Use verified project commands only.
   - For behavior-changing features, report the Test Delta when feasible: positive / happy path coverage, regression / negative path coverage, existing invariant preservation, and no-test justification when no meaningful test was added or updated.
   - Do not change tests merely to match the new implementation. If tests are updated, state whether they cover changed requirements, a new edge case, obsolete behavior, invariant preservation, or assertion weakening.
   - Snapshot updates are not a fix unless the DOM/visual change is intentional and explained; pair with behavior/assertion coverage when feasible.
   - Propose browser/runtime verification only when it adds unique evidence beyond static/code/unit/type checks.
   - Use browser/runtime tooling only with operator-provided or approved URL, environment, auth, and scenario; otherwise report the browser/runtime status from `AgentOps/Core/MCP_BROWSER_POLICY.md`.
9. Skeptic
   - Challenge scope creep and unsupported assumptions.
10. Final Report
   - Verified outcome, gaps, residual risk.
