# Final Report

Use evidence labels from `AgentOps/Core/EVIDENCE_CONTRACT.md`.
Do not write `verified`, `confirmed`, `safe`, or `tested` unless backed by the listed evidence.
If a section is empty, write `None` or `Not checked`.

## Reporting Mode

- `COMPACT`: allowed for T1/T2 tasks with no material conflict, no hidden material `UNKNOWN`, no non-trivial residual risk, no sensitive/security/data/production surface, and no operator request for full reporting.
- `FULL`: required for T3/T4, sensitive changes, high uncertainty, conflicts, non-trivial residual risk, operator request, or skeptic verdict `PASS_WITH_RISKS`, `REVISE_REQUIRED`, or `BLOCKED`.
- Compact mode is allowed only when material unknowns are absent or, if low-impact and not blocking, explicitly listed with residual risk; escalate to `FULL` when mutation boundary was complex, dirty overlap existed, MCP/ticket/media/browser context was blocked and material, verification failed or was materially incomplete, sensitive surfaces were touched, or skeptic returned `REVISE_REQUIRED` / `BLOCKED`.

## Compact T1/T2 Report

Use this mode only when allowed above. Keep empty or obvious sections to one line, but do not omit mandatory safety status.

### Summary

### Files Changed

### Evidence

- Direct evidence:
- Inference:
- `UNKNOWN` / `TODO_OPERATOR`:

### Verification

- Run:
- Result:
- Test Delta:
  - Positive / happy path coverage:
  - Regression / negative path coverage:
  - Existing invariant preservation:
  - No-test justification:
- Tests meaningful for changed behavior: yes / partial / no
- Weak assertion concern:
- Snapshot updates, if any:
- Browser/runtime verification: `<BROWSER_NOT_RELEVANT | BROWSER_RECOMMENDED_NOT_RUN | BROWSER_OPERATOR_INPUT_REQUIRED | BROWSER_BLOCKED | BROWSER_STATIC_ONLY | BROWSER_RUN | BROWSER_RUN_WITH_LIMITS>`
- Runtime Evidence artifacts: none / linked / not applicable
- E2E classification: real user journey / smoke-only / static-only / blocked / not applicable
- Fixture source and cleanup status:
- Raw command logs:
- Network/HAR/backend evidence:
- Runtime cleanup status:
- Stale-report sweep:
- Closure confidence: static-only / media-supported / browser-supported / manual-QA-supported / partial / blocked
- Reason:
- Residual risk:
- Operator next action if needed:

### Blast radius

- Directly affected:
- Possibly affected:
- Explicitly out of scope / not affected:

### Rollback note

- What to revert if this fails:
- What behavior returns:
- Data/schema/customer-impact side effects, if any:

### Not Run / Not Verified

### Residual Risks

### Boundary / Containment Status

- Mutation target:
- Source repos touched:
- Pre-existing dirty files: none / present, untouched / present, touched with approval / overlap blocked or needs operator decision / not checked
- Commit/push/branch/PR status:
- Destructive command status:

### Knowledge Delta

- no update needed / proposal created / blocked by insufficient evidence

## Full Report

## Hard-Case Self-Audit Checklist

Required for any run where hard-case T3/T4 triggers were present or could not be explicitly disproven. Mark each item `present`, `fallback recorded with independence impact`, or `missing`. If any item is `missing`, the executive verdict must be `INVALID_WORKFLOW_RUN` (or `PARTIAL` / `REVISE_REQUIRED` when partial usefulness is claimed). Do not finalize as `PASS` or `READY_TO_MUTATE`.

- Initial Task Classification Gate emitted before narrative:
- Ticket-ID-floor applied when applicable:
- Post-evidence Task Classification Gate re-emission with hard-case triggers found or explicitly absent:
- Specialist Pass Ledger with at least two materially relevant dedicated visible passes or explicit fallback per missing pass:
- Three-Agent Consensus Gate after specialist evidence collection, or explicit fallback with independence impact:
- Ticket / Media / Comment Evidence Matrix reconciling parent AC vs latest comments / QA media / related issues / prior fixes / current code / branch-build state:
- Branch / Build / Release Matrix:
- Prior-Fix / History Matrix:
- Evidence Slice Classification table covering every reported / observed slice (visual symptom, API behavior, persistence state, event, permission state, generated artifact, regression step) with evidence / confidence / falsifier / mutation-blocking status / mutation-coverage status:
- Mutation Candidate -> Evidence Coverage Map for every proposed candidate:
- Evidence Gaps / Unknowns split into blocking vs acceptable, with fastest falsifying evidence:
- Field Learning Candidate or explicit `No reusable learning found` with reason:

A run that performs evidence collection and produces narrative synthesis without these items must self-mark `INVALID_WORKFLOW_RUN`. Plausibility of the narrative is not a substitute for the audit.

## Executive Verdict

PASS / PARTIAL / REVISE_REQUIRED / READY_TO_MUTATE / INVALID_WORKFLOW_RUN

## Task

## Tier

## Task Classification Gate

- Selected tier: T1 / T2 / T3 / T4
- Operator wording:
- Evidence used for classification:
- Hard-case triggers found:
- Hard-case triggers explicitly absent:
- Classification changed during investigation: YES / NO
- Escalation rationale:

Classification must be evidence-based, not operator-wording-based. If hard-case triggers exist but required hard-case sections, passes, or fallback explanations are missing, use `INVALID_WORKFLOW_RUN`; list triggers, missing sections/passes, whether the work is still useful as partial investigation, and what must be rerun before mutation.

## Role Coverage / Agent Activation

Post-disclosure of the pre-mutation Agent Dispatch Gate per `Core/AGENT_OS.md` Role Coverage / Agent Activation. For T2+, the gate must have been emitted in `LIVE_STATUS.md` before the first code mutation (file write to target repo / first `implementation_target:` marker). This section is the operator-readable audit copy; it does not by itself prove pre-mutation emission. If the gate was reconstructed after mutation, append `(POST-HOC)` to the heading above and record `Agent Dispatch Gate emitted post-hoc` in `## Residual Risks`; POST-HOC is a workflow violation and caps the executive verdict at `PASS_WITH_RISKS` or worse. Required-by-tier defaults live in the canonical role table in `Core/AGENT_OS.md`; do not duplicate them here.

- Vault Researcher / Context Guardian:
- Ticket Archivist:
- Code Scout:
- Git Historian / Code Archaeologist:
- Media Extractor (Media Analyst):
- Hypothesis Tester / Challenger:
- Skeptic / Critic:
- Browser / Visual QA (Runtime Reproducer):
- Verifier:
- Security Red-Team:
- Other:

Allowed statuses: `dispatched`, `inline`, `skipped` (with reason + residual risk), `unavailable` (with specific blocker + residual risk), `not required` (only when canon defaults do not require it), `not applicable` (when the trigger evidence is absent — e.g., no media in ticket, no visual symptom). For T3/T4, normally dedicated roles handled inline must include why inline was sufficient. Include evidence artifacts, sources checked, conclusions, and unknowns; do not include private chain-of-thought.

Hard-case T3/T4: trigger yes/no; dedicated visible passes used; inline fallback reason; independence lost; verdict impact.

## Specialist Pass Ledger

- Specialist pass:
- Dedicated visible pass: YES / NO
- Scope:
- Evidence artifacts / sources checked:
- Key conclusion:
- Unknowns:
- Independence value:

Hard-case final report: required when hard-case T3/T4 is active. Dedicated specialist outputs must be integrated below, not merely mentioned. A narrative summary without these sections is incomplete.

Hard-case triggers per `Core/AGENT_OS.md` (Role Coverage / Agent Activation): reopened/repeated QA return, prior same-ticket fixes, parent/child/related issues, evolving comments/media, multi-slice scope, parent-AC vs current-evidence conflict, frontend/backend split, producer/consumer contract divergence, actor/state/permission matrix divergence, branch/build/release divergence, stale-vs-current ambiguity, runtime/media closure dependency, or mutation candidates over disjoint evidence slices.

## Ticket / Media / Comment Evidence Matrix

- Parent acceptance criteria / title:
- Parent AC:
- Ticket description:
- Latest comments:
- QA media:
- Media evidence:
- Related issues / PRs:
- Reopen evidence:
- Scope reconciliation:

Parent AC/title/description is not the full scope for hard-case T3/T4 until latest comments, QA media, related issues, prior fixes, current code, and branch/build status are reconciled.

## Branch / Build / Release Matrix

- Branch:
- Build/release:
- Evidence:
- Divergence / unknown:
- Impact on currentness:

## Prior-Fix / History Matrix

- Prior fix / ticket / commit:
- Preserved intent:
- Possible regression interaction:
- Current relevance:

## Hypothesis Tournament

- Candidate:
- Evidence for:
- Evidence against:
- Falsifier:
- Status: selected / rejected / unresolved

## Evidence Slice Classification (slice = visual symptom / API behavior / persistence state / event / permission state / generated artifact / regression step / asset or module-fetch or runtime-load failure — use whichever applies)

| Evidence slice | Evidence | Classification | Confidence | Falsifier | Blocks mutation? | Covered by proposed mutation? |
|---|---|---|---|---|---|---|
|  |  | confirmed current / likely current / stale / possibly fixed by prior work / contradicted / unknown / needs runtime or operator evidence / out of scope / deferred | high / medium / low |  | yes / no / partial | yes / no / partial / n/a |

If a final recommendation proposes mutation, map each mutation candidate to the slices it covers and does not cover. Missing mapping prevents clean `PASS` or `READY_TO_MUTATE`.

## Mutation Candidate -> Evidence Coverage Map

| Mutation candidate | Slices covered | Slices not covered | Required evidence before write | Risk |
|---|---|---|---|---|
|  |  |  |  |  |

## Three-Agent Consensus Gate

- Gate stage: pre-mutation / post-implementation pre-verification / final closure / other
- Visible dispatch supported: YES / NO
- Dispatch prompts included `Start immediately. Do not wait for further instruction.`: YES / NO / N/A
- Prior verdicts withheld from fresh agents: YES / NO / N/A
- Evidence-backed first output checked for each pass: YES / NO / N/A
- Invalid pass reset/rerun used: YES / NO
- Rounds attempted: 1 / 2
- `Skeptic A — BREAK THE RESULT`: dispatched / inline fallback / unavailable / invalid
  - Scope:
  - Minimum 3 break hypotheses:
  - Findings by hypothesis: CONFIRMED_BROKEN / REFUTED_WITH_EVIDENCE
  - P0/P1 objections:
  - P2/P3 follow-ups:
  - Verdict impact:
- `Skeptic B — CLAIMED VS REALITY`: dispatched / inline fallback / unavailable / invalid
  - Scope:
  - External-facing claims checked:
  - Overclaims / hidden assumptions:
  - P0/P1 objections:
  - P2/P3 follow-ups:
  - Verdict impact:
- `Anti-Drift Guardian`: dispatched / inline fallback / unavailable / invalid
  - Scope:
  - Drift findings:
  - Boundary/report/protocol objections:
  - P0/P1 objections:
  - P2/P3 follow-ups:
  - Verdict impact:
- Consensus result: clear / blocked / revise required / operator decision needed
- P0/P1 objections fixed and rechecked by discovering pass:
- Accepted P0/P1 residual risks with owner:
- Verdict downgrade, if any:
- `CHECK_NOT_PERFORMED`, if any:
- Agents closed/terminated after use: YES / NO / N/A
- Fresh agents required for next gate cycle: YES / NO
- If no consensus after two rounds:
  - Stop state:
  - Findings:
  - Operator options:
- If fallback/no dispatch:
  - Reason:
  - `INLINE_ROLE_FALLBACK_USED`:
  - Independence lost:
  - What each missing pass would have attacked:
  - Impact on PASS / READY_TO_MUTATE:

## Evidence Gaps / Unknowns

- Blocking unknowns:
- Acceptable unknowns:
- Missing runtime/media evidence:
- Fastest falsifying evidence:

## Direct Evidence

- `FACT_CODE`:
- `FACT_CONFIG`:
- `FACT_SCRIPT`:
- `FACT_GIT`:
- `FACT_TICKET`:
- `FACT_MEDIA`:
- `FACT_RUNTIME`:

## Imported / Vault Evidence

- `FACT_VAULT`:
- `FACT_DOC`:
- `FACT_IMPORTED_CANON`:
- `FACT_IMPORTED_DOC`:
- `FACT_IMPORTED`:

## Inferences

- `INFERENCE`:
  - Supporting evidence:

## Not Verified / Unknown

- `UNKNOWN`:
- `TODO_OPERATOR`:

## Conflicts

- `CONFLICT`:

## Residual Risks

- `RISK`:
  - Impact:
  - Recommended next action:

## Boundary / Containment Status

- Mutation target:
- Pre-existing dirty files: none / present, untouched / present, touched with approval / overlap blocked or needs operator decision / not checked

## Files Changed

- Source repos touched:
- Commit/push/PR status:

## Blast radius

- Directly affected:
- Possibly affected:
- Explicitly out of scope / not affected:

## Rollback note

- What to revert if this fails:
- What behavior returns:
- Data/schema/customer-impact side effects, if any:

## Knowledge Delta

- Status: no update needed / proposal created / blocked by insufficient evidence
- Reusable lesson summary:
- Target vault file or proposal artifact:
- Evidence basis:
- Confidence:
- Review/expiry condition:

## Skeptic Verdict

- Ladder level used (Level 0 / 1 / 2 / 3 per `Core/SKEPTIC_PROTOCOL.md` Skeptic Strength Ladder):
- Surface audit axes checked (required at Level 2+): list at least 3 checked axes from `Core/SKEPTIC_PROTOCOL.md` UI/backend lists, or write `not applicable — no shared/cross-module surface`
- Second-pass Skeptic triggered: yes / no — reason if yes (first verdict was REVISE_REQUIRED/BLOCKED, scope expanded, verification result changed, fixes applied to address objections)
- Final verdict: see `SKEPTIC_REVIEW.md` canonical verdict line

## Verification Summary

- Tests/checks run:
- Test Delta:
  - Positive / happy path coverage:
  - Regression / negative path coverage:
  - Existing invariant preservation:
  - No-test justification:
- Tests meaningful for changed behavior: yes / partial / no
- Weak assertion concern:
- Snapshot updates, if any:
- Browser/runtime verification: `<BROWSER_NOT_RELEVANT | BROWSER_RECOMMENDED_NOT_RUN | BROWSER_OPERATOR_INPUT_REQUIRED | BROWSER_BLOCKED | BROWSER_STATIC_ONLY | BROWSER_RUN | BROWSER_RUN_WITH_LIMITS>`
- Runtime Evidence artifacts: none / linked / not applicable
- Closure confidence: static-only / media-supported / browser-supported / manual-QA-supported / partial / blocked
- Reason:
- Residual risk:
- Operator next action if needed:

## Operator Follow-Ups

## Workflow Improvement Candidates

- Required when workflow friction, stale local setup docs, missing repeatable steps, repeated workaround paths, or workflow contradictions were encountered.
- Friction point:
- Evidence current workflow was insufficient/stale:
- Workaround used:
- Proposed destination: Vault / Core policy / Workflow doc / Report template / RuntimeEvidence template / product shared tooling / other operator-approved artifact
- Operator decision needed: yes / no
- Recorded artifact: `WORKFLOW_IMPROVEMENT_CANDIDATES.md` / inline only / not applicable

## Field Learning Candidate

- Reusable learning:
- Evidence source:
- Target file:
- Verified or proposed:
- Learning status: updates existing / proposes new / none
- Safe to write now: YES / NO
- Proposed destination: `MainVault/16_AGENT_LEARNINGS_PROPOSED.md` / targeted Core doc / targeted Workflow doc / other
- If no reusable learning: `No reusable learning found`
- Reason if no reusable learning:
- Area: role coverage / media / runtime / hypothesis / skeptic / testing / reporting / vault
- Reusable lesson seed: hard-case tickets fail when specialist findings are not reconciled into a single evidence-slice coverage map.
