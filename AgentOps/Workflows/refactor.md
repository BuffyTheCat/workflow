# Workflow: Refactor

## Scope

Use only when refactoring is explicitly requested or strictly required for the target fix.

## Rules

- Refactor requires explicit justification.
- Do not smuggle refactor work into a bugfix unless required.

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

- T1/T2 refactors may use `COMPACT` mode from `AgentOps/Reports/templates/final-report-template.md` only when the blast radius is small and evidence is clean.
- Use `FULL` mode when there is conflict, material `UNKNOWN`, non-trivial residual risk, sensitive/security/data/production impact, operator request, or skeptic verdict `PASS_WITH_RISKS`, `REVISE_REQUIRED`, or `BLOCKED`.
- Compact mode must still include summary, files changed, evidence, verification, not run/not verified, residual risks, boundary/containment status, commit/push/branch/PR/destructive status, and `Knowledge Delta`.

## Operator Visibility

- Use concise checkpoints from `AgentOps/Core/OPERATOR_VISIBILITY_PROTOCOL.md` at preflight, blast-radius scan, first-write, skeptic/verifier handoff, blocker, and final-verification boundaries.
- If direction changes mid-run, update the objective and resume from the nearest safe checkpoint.

## Role Coverage / Agent Activation

- For T3/T4 or specialist-heavy refactors, apply Core Role Coverage / Agent Activation: record whether each materially relevant role used a dedicated visible subagent/pass, was handled inline by Lead, was not needed, was blocked/unavailable, or was skipped as risk.
- Verifier and Skeptic are relevant when behavior or compatibility claims matter; add Git Historian, Vault Researcher, or Security Red-Team only when risk warrants.

## Steps

1. Justification
   - State why refactor is needed.
2. Blast Radius Mapping
   - Identify affected modules, APIs, tests, and migrations.
   - For T2+ mutating work, create a compact Pre-code Constraint Pack before the first write per `AgentOps/Core/KNOWLEDGE_VAULT_POLICY.md`; state explicitly if no relevant Vault/project constraints were found.
3. Compatibility
   - Preserve behavior unless change is explicitly intended.
   - Before implementation for non-trivial T2+ work, challenge the selected refactor approach; record evidence against it or why it remains acceptable. For T1, use a lightweight check unless risk triggers escalation.
4. Write Boundary Check
   - Print intended target paths before any write.
   - Verify the approved mutation target.
   - Confirm live/source repositories are read-only unless explicitly named as the mutation target in the current task.
   - Confirm `AgentOps/Runtime/imports/**` is quarantine/reference, not active canon.
   - If mutation target, ownership boundary, or compatibility evidence remains unclear after bounded investigation, stop and mark `UNKNOWN` or `TODO_OPERATOR`.
5. Implementation
   - Slice into reversible minimal steps.
6. Tests
   - Use verified commands only.
   - For behavior-preserving or behavior-changing refactors, report the Test Delta when feasible: positive / happy path coverage, regression / negative path coverage, existing invariant preservation, and no-test justification when no meaningful test was added or updated.
   - Do not change tests merely to match the new implementation. If tests are updated, state whether they cover changed requirements, a new edge case, obsolete behavior, invariant preservation, or assertion weakening.
   - Snapshot updates are not a fix unless the DOM/visual change is intentional and explained; pair with behavior/assertion coverage when feasible.
7. Skeptic
   - Attack claims of safety and necessity.
8. Final Report
   - Include compatibility risk and what was not verified.
