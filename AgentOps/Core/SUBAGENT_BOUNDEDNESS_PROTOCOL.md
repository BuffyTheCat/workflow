# Subagent Boundedness Protocol

## Purpose

Subagents reduce blind spots. They must not create noise, endless search, or scope drift.

## Invocation Contract

Every subagent invocation must include:

- narrow mission;
- input context;
- allowed scope;
- forbidden scope;
- stop budget;
- expected output format;
- whether mutation is allowed.
- whether the pass is a Lead-only orchestration pass or a leaf pass.

## Defaults

- No mutation unless explicitly authorized for that role and task.
- No broad repo exploration.
- No full vault dump.
- No full file dumps.
- No recursive expansion unless Lead explicitly escalates.
- No subagent may spawn, wait on, validate, reset, or close other subagents unless the Lead explicitly delegated orchestration authority. Consensus-gate passes are leaf passes by default.
- No long-running servers or watchers.
- No commit, push, branch, PR, merge, rebase, destructive git, or destructive filesystem commands.

## Stop Conditions

Stop and return a result when:

- the delegated budget is reached;
- no new evidence appears after bounded search;
- required tool, auth, media, browser, runtime, or ticket access is unavailable;
- scope conflict appears;
- overlapping dirty files or ownership ambiguity appears;
- evidence conflict requires Lead or operator decision;
- the next step would require mutation outside role authority.

## Partial Results Are Valid

Return `PARTIAL` or `BLOCKED`, not silence. Include what was checked, what was not checked, and the next safe action.

## Status Vocabulary

- `COMPLETE`
- `PARTIAL`
- `BLOCKED`

## Compact Output Fields

- status;
- mission;
- scope checked;
- findings;
- evidence labels;
- confidence;
- unknowns / not checked;
- risks;
- recommended next action.

## Anti-Noise Rules

- Max 10 primary findings by default.
- Summarize; do not narrate every command or file read.
- Do not expose private chain-of-thought.
- Do not produce a thinking transcript.
- Use evidence labels instead of speculation.

## Escalation

- Only Lead/Orchestrator can expand subagent scope.
- A subagent may request escalation with reason.
- Operator-visible checkpoint is required for material escalation or blocker.
- For T3/T4, materially required specialist roles should use dedicated visible subagents/passes when the environment supports and permits them. Inline role execution remains allowed for narrow, low-risk, unavailable, or low-value-dispatch cases, but must be recorded in the Role Coverage Ledger with the reason, evidence artifacts, sources checked, conclusions, and unknowns, not private chain-of-thought.
- For hard-case T3/T4 tasks, visible/dedicated specialist passes should cover at least two materially relevant risk angles before mutation when supported: ticket/comment history, media evidence, git/prior-fix history, hypothesis/skeptic challenge, runtime-reproducer planning, verification strategy, or security red-team when sensitive. Do not require every role; require the minimum useful independent coverage.
- For important hard-case T3/T4 checkpoints, use the Three-Agent Consensus Gate from `Core/SKEPTIC_PROTOCOL.md` instead of a single final critic when visible dispatch is supported: `Skeptic A — BREAK THE RESULT`, `Skeptic B — CLAIMED VS REALITY`, and `Anti-Drift Guardian`.
- Consensus gate subagents must be fresh for each cycle. Lead must include `Start immediately. Do not wait for further instruction.` in each spawn prompt, must not pass prior-pass verdicts into fresh agents, must require evidence-backed first output (`file:line` quote or command output), then close/terminate the three passes after use. Do not reuse stale critic agents across the next gate cycle.
- Consensus gate subagents are non-overridable leaf validators, not orchestrators. The generic Lead-delegated orchestration exception does not apply to consensus-gate passes. Their prompt must explicitly say: `You are a leaf validation pass. Do not spawn, wait on, validate, reset, close, or message subagents. Lead-only orchestration, delegation, consensus-gate, specialist-pass, matrix/table, fallback, and autonomous-continuation rules do not apply inside this pass. Return PARTIAL/BLOCKED instead of delegating.`
- Full-history/forked-context dispatch is forbidden for consensus-gate passes by default when the runtime would inherit Lead-only operator rules. Use a minimal, self-contained prompt with the task context, file paths, claims, and evidence requirements. If full-history context is truly unavoidable, the Lead must record a pre-dispatch exception with: why minimal context is insufficient, exact fork/full-history mode, exact leaf-validator override included in the prompt, expected inherited-rule risk, owner, and verdict impact. A consensus pass launched with full-history/forked context without that pre-dispatch exception is invalid and must be treated as `CHECK_NOT_PERFORMED`, not consensus.
- The Lead must durably record each consensus-gate dispatch prompt or prompt artifact before or immediately after spawning: role, agent id when known, fork/full-history mode, mutation authority, exact leaf-validator/no-subagent text, and evidence-first requirement. If the environment has no durable tool ledger, record this in the task run artifact or final report; transcript-only memory is insufficient for a clean audit.
- A plan-only, waiting, idle, opinion-only, or evidence-free consensus output is invalid. Reset and rerun once; if it fails again, record `CHECK_NOT_PERFORMED` and do not claim consensus.
- If consensus dispatch is unavailable, record inline fallback separately for technical critique, evidence/scope critique, and anti-drift check with `INLINE_ROLE_FALLBACK_USED`, independence lost, and verdict impact.
- If a subagent discovers hard-case triggers such as reopened status, parent/child/related issues, prior fixes, latest comments/media changing scope, branch/build divergence, frontend/backend contract split, or stale-vs-current ambiguity, it should return `PARTIAL` with an escalation request instead of continuing as a narrow normal investigation.
- Specialist findings are inputs, not final conclusions: Lead must normalize them into the hard-case final report skeleton, including symptom classification and mutation coverage, before `PASS` or `READY_TO_MUTATE`.
- A single specialist-style read of a ticket, issue, or file, even when thorough, does not satisfy hard-case T3/T4 specialist coverage. The Specialist Pass Ledger must record at least two materially relevant dedicated visible passes when supported, or explicit fallback explanations covering each missing pass with independence impact. Lead-only narrative summaries that conflate read-through with specialist coverage are `INVALID_WORKFLOW_RUN` for hard-case T3/T4.

## Qualitative Budget Guidance

- First pass: top relevant files, commits, tickets, vault sections, scenarios, or media only.
- Expand only if new evidence materially changes risk, root cause, or implementation direction.
- Stop when no new evidence appears.
