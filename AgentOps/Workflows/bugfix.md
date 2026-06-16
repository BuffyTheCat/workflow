# Workflow: Bugfix

## PRE-FLIGHT GATE

The Pre-Flight Gate (steps A–E), Hard-Case skeleton, anti-regression example, and Autonomous Read-Only Continuation rule are canonical in `AgentOps/Core/AGENT_OS.md`. Execute that order before scope-specific guidance below. Adapter copies live only in `AgentOps/Adapters/{claude,codex}/` per canon §3.2 portable-core+adapters; Workflow files do not duplicate the block.

## Scope

Use for defects, regressions, broken expected behavior, and runtime mismatches.

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

- T1/T2 bugfixes may use `COMPACT` mode from `AgentOps/Reports/templates/final-report-template.md`.
- Use `FULL` mode when there is conflict, material `UNKNOWN`, non-trivial residual risk, sensitive/security/data/production impact, operator request, or skeptic verdict `PASS_WITH_RISKS`, `REVISE_REQUIRED`, or `BLOCKED`.
- Compact mode must still include summary, files changed, evidence, verification, not run/not verified, residual risks, boundary/containment status, commit/push/branch/PR/destructive status, and `Knowledge Delta`.

## Operator Visibility

- Use concise checkpoints from `AgentOps/Core/OPERATOR_VISIBILITY_PROTOCOL.md` at preflight, evidence-gathering, first-write, skeptic/verifier handoff, blocker, and final-verification boundaries.
- If direction changes mid-run, update the objective and resume from the nearest safe checkpoint.

## Task Classification Gate

- Before root-cause summary, final verdict, or mutation recommendation, classify the bugfix as `T1`, `T2`, `T3`, or `T4` from evidence.
- Operator wording such as "quick", "simple", "just check", or "take a look" may set initial suspicion but must not override discovered evidence.
- Record selected tier, classification evidence, hard-case triggers found or explicitly absent, whether classification changed during investigation, and why it did or did not escalate.
- Auto-escalate to hard-case T3/T4 unless explicitly disproven when evidence shows reopened/repeated QA return, previous same-ticket fixes, parent/child/related issues, evolving latest comments/media, multi-slice scope, conflict between parent AC and current evidence, frontend/backend split, producer/consumer contract divergence, actor/state/permission matrix divergence, branch/build divergence, stale/current ambiguity, runtime/media closure dependency, or mutation candidates over disjoint evidence slices.
- If hard-case triggers are present but the report lacks the required hard-case skeleton or passes/fallbacks, mark `INVALID_WORKFLOW_RUN`, not `PASS` or `READY_TO_MUTATE`.

## Role Coverage / Agent Activation

- For T3/T4 bugfixes, include a compact Role Coverage Ledger in the final report.
- The ledger is context-driven, not universal: Ticket Archivist for ticket-driven bugs, Media Analyst for visual/media bugs, Git Historian for regression/history-sensitive changes, Verifier for behavior-changing implementation, Skeptic for non-trivial hypothesis or mutation risk, Security Red-Team for security/auth/permissions/data integrity, Vault Researcher for Vault-dependent constraints, and Runtime Reproducer when browser/runtime confidence is needed.
- For T3/T4, materially relevant roles are normally `used: dedicated visible subagent/pass` when the environment supports and permits visible specialist execution.
- Inline role execution by Lead is allowed, but mark `used: inline by Lead`, explain why inline was sufficient, and include concrete evidence produced. Mark irrelevant roles `not needed`; mark missing material roles `blocked/unavailable` or `skipped: risk`.
- Hard-case T3/T4 trigger: use the Task Classification Gate trigger list above. When active and supported, use at least two materially relevant dedicated visible specialist passes before mutation unless there is a concrete reason not to. Inline fallback must state independence lost and whether inline-only coverage prevents clean `PASS`.
- Hard-case final report normalization is mandatory: integrate specialist outputs into the hard-case skeleton, not just a narrative summary. Parent AC/title/description is not full scope until latest comments, QA media, related issues, prior fix commits, current code, and branch/build status are reconciled. Classify each evidence slice and map any mutation candidate to covered/not-covered slices before `READY_TO_MUTATE`.
- Important hard-case bugfix checkpoints require the Three-Agent Consensus Gate from `Core/SKEPTIC_PROTOCOL.md` before `READY_TO_MUTATE`, after material implementation before final verification, and before final closure when the decision is risky. If visible dispatch is unsupported, preserve the three lenses inline and report fallback, independence lost, what each missing pass would have attacked, and verdict impact.
- Hard-case bugfix reports must include a `Field Learning Candidate` or `No reusable learning found` with reason; do not mutate `MainVault` unless explicitly approved.

## Steps

0. Entrypoint Order
   - Before any narrative summary, root-cause guess, specialist conclusion, or mutation recommendation, emit an initial Task Classification Gate block from intake-level signals; operator wording such as "quick", "simple", "разбери", "глянь", or "хорошенько" cannot lower the tier.
   - If the request references a ticket ID (Linear `SR-`/`ENG-`/etc., Jira, GitHub issue/PR), set the initial classification floor at `T2` and treat hard-case T3/T4 as a live possibility until disproven by evidence.
   - Collect primary evidence under bounded scope (ticket body, comments, parent/child/related issues, prior same-ticket fixes, current code, branch/build state, memory/Vault, media when available), then re-emit the Task Classification Gate with hard-case triggers found or explicitly absent.
   - If hard-case T3/T4 is now active, do not produce synthesis, mutation candidate, or `READY_TO_MUTATE` claim until the hard-case skeleton in `AgentOps/Reports/templates/final-report-template.md` is in place with the required specialist passes plus Three-Agent Consensus Gate or explicit fallback. A single read plus narrative is not investigation.
1. Intake
   - Restate the symptom, expected behavior, constraints, and user-requested boundaries.
   - Classify tier.
2. Preflight
   - Run capability preflight.
   - Check working tree state.
3. MainVault Scan
   - Read `MainVault/00_INDEX.md`.
   - Pull only relevant notes.
   - For T2+ mutating work, create a compact Pre-code Constraint Pack before the first write per `AgentOps/Core/KNOWLEDGE_VAULT_POLICY.md`; state explicitly if no relevant Vault/project constraints were found.
4. Code Context
   - Map relevant modules, tests, and nearby patterns.
5. Git History
   - Inspect recent commits, blame, and intent around touched logic.
6. Ticket Archaeology
   - If ticket IDs exist or MCP is available, inspect linked context.
7. Media/Runtime
   - Reproduce with browser/runtime/media evidence when relevant.
   - If media, browser/runtime, or manual QA evidence materially affects closure confidence, reference a compact `AgentOps/RuntimeEvidence/**` artifact when available; otherwise state what remains static-only or unproven.
   - For ticket-driven visual bugs with inline media links or attachment references, do not stop at shallow list/search metadata; perform a bounded tool-depth check using full issue fetch, comments, attachment APIs, image extraction, raw body access, browser/media helpers, or operator-provided artifacts before reporting media unavailable.
   - If media status contradicts an earlier report, reconcile the difference before implementation or closure confidence.
   - When media is inspected, classify the visible symptom: overflow outside bounds, duplicate/double-render inside bounds, wrong styling, wrong position, missing value, stale value, or `UNKNOWN`.
   - If the proposed fix only covers one evidence slice (component/renderer type, API endpoint, table column, event handler), require direct evidence for that slice or report `UNPROVEN` / `PARTIAL` with manual/runtime validation required.
   - Do not call a readiness check, login smoke, grid smoke, unit test, or static screenshot "end-to-end". If the operator asks for E2E, define the user journey, fixture state, acceptance assertions, backend/API evidence, cleanup criteria, and residual limitations before closure.
   - For project-specific runtime workflows, use the relevant contract in `MainVault/13_RUNTIME_AND_TOOLING.md` when present. If setup paths fail before the surface under test, record that blocker and switch to the narrowest approved fixture/reproducer for the accepted scope.
   - Do not trigger browser/runtime tooling only because frontend or UI code changed.
   - Propose browser/runtime verification only when it adds unique evidence beyond static/code/unit/type checks.
   - Use browser/runtime tooling only when the operator requested or approved the required URL, environment, auth, and scenario.
8. Hypothesis Matrix/Tournament
   - Build falsifiable candidates.
   - Kill weak theories.
   - For T2+, emit the Agent Dispatch Gate per `AgentOps/Core/AGENT_OS.md` Role Coverage / Agent Activation in `LIVE_STATUS.md` before the first code mutation (file write to target repo / first `implementation_target:` marker). Implementation must not begin until the gate is emitted in `LIVE_STATUS.md`, ticket body / media / hypothesis comparison / Skeptic timing hard stops are satisfied or marked `unavailable` with residual risk, and the Code Scout has read owner file bodies per `Core/HYPOTHESIS_PROTOCOL.md` Candidate Owner File Evidence. A gate reconstructed only in `FINAL_REPORT.md` post-mutation must be labeled `(POST-HOC)` and capped at `PASS_WITH_RISKS` or worse.
9. Fix Plan
   - Choose the minimal change that matches the strongest evidence.
   - Before implementation for non-trivial T2+ work, challenge the selected hypothesis or approach; record evidence against it or why it remains acceptable. For T1, use a lightweight check unless risk triggers escalation.
   - The challenge must attack the proposed mutation strategy itself, not only rejected alternatives.
   - If git, ticket, or code history shows intentional current behavior, require a concrete mutation mechanism before writing: primitive/API, exact scope, state preservation or cleanup, preserved old intent, test seam, and rollback path.
   - If the fix preserves old behavior by adding a bounds, clip, guard, or wrapper mechanism, verify the wrapper boundary matches the real behavior boundary and plan tests for predicate choice, wrapper path use, and cleanup/state restoration where feasible.
10. Write Boundary Check
   - Print intended target paths before any write.
   - Verify the approved mutation target.
   - Confirm live/source repositories are read-only unless explicitly named as the mutation target in the current task.
   - Confirm `AgentOps/Runtime/imports/**` is quarantine/reference, not active canon.
   - If MCP auth, media access, browser URL, mutation target, dirty working tree, or source ownership is unclear after bounded investigation, stop and mark `UNKNOWN` or `TODO_OPERATOR`.
11. Implementation
   - No opportunistic refactor.
12. Verification
   - Run targeted checks, tests, or reproduction.
   - For bugfixes and regressions, report the Test Delta when feasible: positive / happy path coverage, regression / negative path coverage, existing invariant preservation, and no-test justification when no meaningful test was added or updated.
   - Do not change tests merely to match the new implementation. If tests are updated, state whether they cover changed requirements, a new edge case, obsolete behavior, invariant preservation, or assertion weakening.
   - Snapshot updates are not a fix unless the DOM/visual change is intentional and explained; pair with behavior/assertion coverage when feasible.
   - Preserve raw stdout/stderr for material verification commands under the run directory, preferably with `cmd 2>&1 | tee <run-dir>/<command>.log`. Final claims of test/build pass should cite raw logs or rerun output, not only markdown summaries.
   - When a browser E2E claim depends on backend behavior, capture HAR/network logs when the browser tool supports it. If unavailable, explicitly cite the substitute backend evidence: readiness endpoint, backend logs, DB/API result, and exact limitation.
   - Report browser/runtime status using `AgentOps/Core/MCP_BROWSER_POLICY.md`; if not run, include reason, residual risk, and operator next action when needed.
   - Never claim visual verification without captured evidence.
13. Skeptic
   - Require a skeptic pass.
14. Final Report
   - Verified facts.
   - Not verified.
   - Residual risk.
   - Before final closure on runtime/E2E tasks, run a stale-verdict sweep over the run directory for superseded blocker language (for example `LOCAL_E2E_BLOCKED`, `was not completed`, `Blocking P1 remained`) and reconcile any contradiction with the latest evidence.
   - Verify local runtime cleanup when the task started services: expected ports are no longer listening, task-scoped temp files/stubs are removed, generated plugin metadata is removed, and `git status --short --untracked-files=all` is clean or intentionally explained.
