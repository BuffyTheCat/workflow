# Workflow: RHO-Lite Harness Retrospection

## Scope

Use this workflow when the operator explicitly asks to apply RHO, retrospective harness optimization, self-improve AgentOps, mine prior runs for workflow improvements, or improve the local agent harness from accumulated `RuntimeEvidence`.

RHO-lite is a local, proposal-first adaptation of Retrospective Harness Optimization. It mines past task artifacts for recurring failure modes and proposes harness improvements, but it does not automatically mutate canon, app code, branches, or external systems.

## Non-Goals

- Do not run autonomous self-editing of `Core/`, `MainVault/`, adapters, skills, tools, or app files.
- Do not promote `RuntimeEvidence` into `MainVault` canon without explicit Vault maintenance approval.
- Do not create branches, worktrees, commits, pushes, PRs, or staged changes unless the operator explicitly approves that exact operation.
- Do not send secrets, ticket media, customer data, signed URLs, credentials, private logs, or raw unredacted trajectories to external services without explicit approval.
- Do not claim benchmark-level validation from local retrospection unless a held-out replay set and verifier actually ran.

## Required Gates

### 1. Boundary Gate

Before any write, state:

- approved mutation target paths;
- paths that are read-only evidence;
- whether the run is proposal-only or mutation-approved;
- whether git/worktree operations are out of scope.

If the operator asked only to "analyze", "recommend", or "try RHO", default to proposal-only.

### 2. Data-Safety Gate

Classify trajectory sources before model calls or persistence:

- `PUBLIC_OR_SYNTHETIC`: safe to process normally.
- `LOCAL_PRIVATE_REDACTED`: allowed if secrets/customer data/media/signed URLs are removed.
- `LOCAL_PRIVATE_RAW`: do not send to external models; process locally or stop for approval.
- `SENSITIVE_BLOCKED`: credentials, secrets, customer data, private ticket media, signed URLs, production logs, or regulated data; requires explicit operator decision.

Record the classification in `EVIDENCE_LEDGER.md`. Prefer summaries and excerpts over raw transcripts.

### 3. Replay Gate

Classify whether prior tasks can be replayed:

- `REPLAYABLE`: deterministic or cleanly resettable task with no external side effects.
- `PARTIAL_REPLAY`: can rerun only a subset such as tests, static checks, or local reproducer.
- `NON_REPLAYABLE`: one-shot, external, destructive, auth-bound, or no longer reproducible.
- `UNKNOWN`: not enough evidence.

Do not rerun tasks with side effects unless separately approved.

### 4. Canonization Gate

All generated changes start as proposals. Canonization requires:

- source evidence;
- scope and exceptions;
- independent skeptic review;
- operator approval for exact target files;
- relevant verification or explicit no-verification rationale.

Use `AgentOps/Workflows/vault-maintenance.md` for MainVault promotion.

## RHO-Lite Stages

### Stage 1: Coreset Selection

Select a small, diverse set of past runs from `AgentOps/RuntimeEvidence/runs/**`.

Start with the read-only closure hygiene audit when available:

```
AgentOps/scripts/audit-runtime-evidence-closure.sh
```

Use its `ISSUE` rows as selection signals, not as automatic retroactive fault. Older runs may predate the current closure contract.

When triaging historical closure drift, prefer:

```
AgentOps/scripts/audit-runtime-evidence-closure.sh --classify
```

Use `TRIAGE` rows to separate `legacy-format`, `needs-close-check`, `needs-skeptic`, and `needs-human-review` before proposing remediation. Do not rewrite historical reports unless the operator explicitly approves that target.

Prefer runs with:

- `PASS_WITH_RISKS`, `REVISE_REQUIRED`, `PARTIAL`, `BLOCKED`, or `INVALID_WORKFLOW_RUN`;
- repeated close-run failures or late workflow violations;
- explicit residual risks;
- missing or degraded browser/media/MCP/tool evidence;
- lessons candidates that were not promoted;
- similar failures across different tickets or modules.

Balance difficulty and diversity. Avoid selecting only one failure family.

### Stage 2: Retrospective Diagnosis

For each selected run, extract:

- task class and workflow used;
- expected gate behavior;
- actual evidence collected;
- where drift, uncertainty, or late correction appeared;
- which rule, skill, helper script, template, or checklist could have prevented the failure;
- whether the issue is reusable or one-off.

Use two lenses:

- Self-validation: Did the run satisfy its own stated AgentOps obligations?
- Self-consistency: Do multiple runs disagree in how they handle the same situation?

### Stage 3: Best-of-N Proposal

Generate 2-3 candidate harness updates when useful. Candidate types:

- proposed MainVault learning;
- workflow rule addition;
- adapter pointer;
- report-template field;
- helper-script check;
- skill/tool proposal;
- no-op with rationale.

Compare candidates against:

- boundary safety;
- data safety;
- evidence strength;
- portability;
- implementation cost;
- risk of overfitting to one task;
- ease of verification.

Select one recommended candidate or return `NO_UPDATE` if evidence is weak.

## Output Contract

For proposal-only runs, produce:

- `LIVE_STATUS.md`;
- `EVIDENCE_LEDGER.md`;
- `SKEPTIC_REVIEW.md`;
- `FINAL_REPORT.md`;
- optional `LESSONS_CANDIDATE.md` or patch suggestion.

`FINAL_REPORT.md` must include:

- selected coreset and why;
- data-safety classification;
- replay classification;
- diagnosis summary;
- candidate proposals considered;
- selected proposal and rejected alternatives;
- canonization target, or `NO_CANONIZATION`;
- verification performed;
- residual risks.

## Skeptic Requirements

Run at least an inline skeptic pass for proposal-only work. Use visible subagents when the change would touch `Core/`, adapters, scripts, or canonical `MainVault`.

Skeptic must check:

- boundary drift;
- data leakage risk;
- overfitting to a single run;
- adapter thickness;
- contradiction with `Core/AGENT_OS.md`, `Workflows/workflow-maintenance.md`, or `Workflows/vault-maintenance.md`.

## Verification

Minimum verification for a workflow-only change:

- file-body review of changed files;
- `rg` check that the workflow is discoverable from adapter or index;
- `close-run.sh <run-dir>` if a run directory was produced.

If executable scripts are added, run the narrowest relevant script test.
