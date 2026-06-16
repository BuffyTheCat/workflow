# Workflow: Investigation

## PRE-FLIGHT GATE

The Pre-Flight Gate (steps A–E), Hard-Case skeleton, anti-regression example, and Autonomous Read-Only Continuation rule are canonical in `AgentOps/Core/AGENT_OS.md`. Execute that order before scope-specific guidance below. Adapter copies live only in `AgentOps/Adapters/{claude,codex}/` per canon §3.2 portable-core+adapters; Workflow files do not duplicate the block.

## Scope

Read-only investigation, diagnosis, or repo forensics.

## Rules

- No edits.
- No commits.
- Live/source repos remain read-only unless explicitly named as the mutation target.
- `AgentOps/Runtime/imports/**` is quarantine/reference, not active canon.

## Context Continuity / Run State

- Before long investigation, compaction/handoff, reporting, or any resumable blocker, capture run state per `AgentOps/Core/CONTEXT_COMPACTION_POLICY.md`.
- Important state must not live only in chat or model memory.
- Preserve at minimum: current task objective, approved mutation target, files inspected, files changed, evidence buckets, active or selected hypothesis, unresolved `UNKNOWN` / `TODO_OPERATOR`, verification status, and next safe action.
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

- T1/T2 investigations may use `COMPACT` mode from `AgentOps/Reports/templates/final-report-template.md`.
- Use `FULL` mode when there is conflict, material `UNKNOWN`, non-trivial residual risk, sensitive/security/data/production impact, operator request, or skeptic verdict `PASS_WITH_RISKS`, `REVISE_REQUIRED`, or `BLOCKED`.
- Compact mode must still include summary, files changed or `None`, evidence, verification, not run/not verified, residual risks, boundary/containment status, commit/push/branch/PR/destructive status, and `Knowledge Delta`.

## Operator Visibility

- Use concise checkpoints from `AgentOps/Core/OPERATOR_VISIBILITY_PROTOCOL.md` at preflight, evidence-gathering, archaeology, blocker, and final-recommendation boundaries.
- If direction changes mid-run, update the objective and resume from the nearest safe checkpoint.

## Task Classification Gate

- Before root-cause summary, final verdict, or mutation recommendation, classify the investigation as `T1`, `T2`, `T3`, or `T4` from evidence.
- Operator wording such as "quick", "simple", "just check", or "take a look" may set initial suspicion but must not override discovered evidence.
- Record selected tier, classification evidence, hard-case triggers found or explicitly absent, whether classification changed during investigation, and why it did or did not escalate.
- Auto-escalate to hard-case T3/T4 unless explicitly disproven when evidence shows reopened/repeated QA return, previous same-ticket fixes, parent/child/related issues, evolving latest comments/media, multi-slice scope, conflict between parent AC and current evidence, frontend/backend split, producer/consumer contract divergence, actor/state/permission matrix divergence, branch/build divergence, stale/current ambiguity, runtime/media closure dependency, or mutation candidates over disjoint evidence slices.
- If hard-case triggers are present but the report lacks the required hard-case skeleton or passes/fallbacks, mark `INVALID_WORKFLOW_RUN`, not `PASS` or `READY_TO_MUTATE`.

## Role Coverage / Agent Activation

- For T3/T4 or specialist-heavy investigations, apply Core Role Coverage / Agent Activation: record whether each materially relevant role used a dedicated visible subagent/pass, was handled inline by Lead, was not needed, was blocked/unavailable, or was skipped as risk.
- Ticket Archivist, Git Historian, Vault Researcher, Media Analyst, and Runtime Reproducer are context-driven, not universal.
- Hard-case T3/T4 investigations include reopened, multi-slice, or comment-heavy tickets, evolving media/expected behavior, related issues/PRs/history, multiple ownership layers, media/runtime/manual closure dependency, or risk of reversing historical intent. When active and supported, prefer at least two materially relevant dedicated visible specialist passes; inline-only handling must justify independence lost, artifacts produced, sources checked, conclusions, unknowns, and verdict impact.
- Hard-case final reports must normalize specialist outputs into evidence matrices and evidence-slice classifications; a narrative summary is incomplete. Parent AC/title/description must be reconciled with latest comments, QA media, related issues, prior fix commits, current code, and branch/build status before scope is considered complete.
- Important hard-case investigation checkpoints require the Three-Agent Consensus Gate from `Core/SKEPTIC_PROTOCOL.md` before `READY_TO_MUTATE` or final closure when the decision is risky. If visible dispatch is unsupported, preserve the three lenses inline and state why dispatch was unavailable, independence lost, what each missing pass would have attacked, verdict impact, and whether `READY_TO_MUTATE` is blocked or allowed.
- Hard-case investigation reports must include a `Field Learning Candidate` or `No reusable learning found` with reason.

## Steps

0. Entrypoint Order
   - Before any narrative summary, root-cause guess, specialist conclusion, or mutation recommendation, emit an initial Task Classification Gate block from intake-level signals; operator wording such as "quick", "simple", "разбери", "глянь", or "хорошенько" cannot lower the tier.
   - If the request references a ticket ID (Linear `SR-`/`ENG-`/etc., Jira, GitHub issue/PR), set the initial classification floor at `T2` and treat hard-case T3/T4 as a live possibility until disproven by evidence.
   - Collect primary evidence under bounded scope (issue body, comments, parent/child/related issues, prior same-ticket fixes, current code, branch/build state, memory/Vault, media when available), then re-emit the Task Classification Gate with hard-case triggers found or explicitly absent.
   - If hard-case T3/T4 is now active, do not produce synthesis or `READY_TO_MUTATE` claim until the hard-case skeleton in `AgentOps/Reports/templates/final-report-template.md` is in place with required specialist passes plus Three-Agent Consensus Gate or explicit fallback. A single ticket read plus narrative is not investigation.
1. Clarify question and success condition.
2. Run preflight relevant to investigation.
3. Gather evidence from code, config, docs, history, tickets, runtime, or media as available.
4. Build hypotheses and eliminate weak ones.
   - For T2+, emit the Agent Dispatch Gate per `AgentOps/Core/AGENT_OS.md` Role Coverage / Agent Activation in `LIVE_STATUS.md` before producing findings or proposing mutation. Read-only investigations still emit the gate so role-coverage gaps (Ticket Archivist, Vault, Code Scout, Media Extractor, Browser/Visual QA, Hypothesis Tester) are visible to the operator. A gate reconstructed only in `FINAL_REPORT.md` post-mutation must be labeled `(POST-HOC)` and capped at `PASS_WITH_RISKS` or worse.
5. Produce findings with confidence.
6. List next safe steps and what remains unknown.
