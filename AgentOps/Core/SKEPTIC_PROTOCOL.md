# Skeptic Protocol

## Purpose

Skeptic attacks assumptions, hidden scope, weak evidence, missed surfaces, and false closure.

## Core Principles

- Every task gets skepticism. The strength varies; the obligation does not.
- Skeptic is a gate, not a decoration. `PASS` is not expected or required; `REVISE_REQUIRED` and `BLOCKED` are valid useful results.
- Lead must answer Skeptic objections with concrete evidence. Rejecting an objection on vibes is not closure; cite the file body, the test output, the git diff, the runtime artifact.
- Any post-Skeptic scope expansion requires a second-pass Skeptic against the **final** diff. See `## Second-Pass Skeptic Trigger` below.
- Operator wording such as "quick", "simple", "just check", "разбери", "глянь", or "хорошенько" cannot lower the Skeptic level. A request that references a tracker/ticket ID (Linear, Jira, GitHub issue/PR) floors the level at Skeptic-Lite (Level 1) and may auto-escalate further by trigger evidence.

## Skeptic Strength Ladder

Strength is selected by tier and by trigger evidence, not by operator wording.

### Level 0 — Inline Self-Skeptic (T0)

- Not a separate role, not a separate file. No `SKEPTIC_REVIEW.md` is required at T0; the run dir itself is optional at T0 per `Core/AGENT_OS.md` Task Tiers.
- Before final, run 3–5 explicit checks: actual task solved? unrelated diff present? obvious adjacent surface missed? verification honestly performed? assumption that wasn't checked?
- Output: a brief inline skepticism note in the response.

### Level 1 — Skeptic-Lite (T1, bounded T2)

- Mandatory for normal tasks with a tracker ID and no Strong-Skeptic trigger.
- May be inline by Lead or dispatched as a subagent depending on runtime support per `Core/SUBAGENT_BOUNDEDNESS_PROTOCOL.md`. Inline must be visibly separated from the implementation narrative.
- Reviews: task fit, diff scope, test coverage of changed behavior, missed nearby surfaces, weak-assertion concerns.
- Must include at least one concrete disconfirming question or regression angle even when the verdict is `PASS`: what would make the fix wrong, which adjacent behavior could regress, which assumption is not directly verified, which prior ticket or Vault rule could conflict.
- Output: compact `SKEPTIC_REVIEW.md` with canonical verdict line; body may be ≤ 1 page.
- T1 with a concrete Strong-Skeptic trigger auto-escalates to Level 2.

### Level 2 — Strong Skeptic (T2 with triggers)

Mandatory whenever any of these is present (any one is enough):

- regression or reopened ticket;
- shared component / shared module / cross-package surface;
- cross-module impact suspected;
- history-sensitive change (prior fix, prior intent, blame chain matters); concrete trigger: any QA comment, branch history, or related ticket text contains `still`, `again`, `not fixed`, `does not reproduce`, `but now`, `partially`, or `another` (the trigger fires from comment text even when Linear `status` is `Not Started`);
- unclear root cause at first-write time;
- visual / media / runtime evidence is part of the closure chain;
- hidden blast-radius suspicion;
- scope expansion after first implementation.

Inputs Lead must hand to Strong Skeptic: task card, evidence ledger, hypothesis matrix, diff (changed files), grep / surface-audit results, verification output.

Strong Skeptic must explicitly attack:

- missed surfaces / raw callsites / parallel implementations bypassing the fixed shared component;
- false confidence from tests passing on the wrong axis;
- scope too narrow (selected fix doesn't cover the reported behavior);
- scope too broad (selected fix touches surfaces not justified by evidence);
- acceptance-criteria substitution (Lead solved a different problem than the one stated);
- history / Vault conflicts (prior fix, prior decision, canonical-rules conflict);
- browser / runtime behavior not proven (static-only closure when behavior closure was needed).

### Level 3 — Strong Skeptic + Red Team (T3, T4, sensitive)

- Strong Skeptic plus the existing Red Team triggers from `Workflows/sensitive-change.md` (security, auth, billing, tenant, data integrity, migrations, prod config, public API contracts).
- Red Team is additive, not a substitute for Skeptic. Each role records its own findings and verdict.
- Verdict gating per `## Verdict Gating Rules` below; agent-only override of `REVISE_REQUIRED` / `BLOCKED` is not allowed at T4.

## Three-Agent Consensus Gate

For important hard-case T3/T4 checkpoints, the default closure gate is three fresh visible passes when the environment supports dispatch. Important checkpoints include the end of specialist evidence collection, before `READY_TO_MUTATE`, after material implementation before final verification, before final closure, and any operator-defined high-risk stage.

- `Skeptic A — BREAK THE RESULT`: assume the result is fake, incomplete, or accidentally working. Produce at least 3 concrete break hypotheses, try to prove each by independently running commands or inspecting files, and mark each `CONFIRMED_BROKEN` or `REFUTED_WITH_EVIDENCE`. Include any new attacks found. Severity: `P0` / `P1` / `P2` / `P3`.
- `Skeptic B — CLAIMED VS REALITY`: compare each external-facing or closure-critical claim against what is actually true in code, diff, ticket/media/history, commands, or artifacts. Hunt overclaiming, hidden assumptions, stale truth, "said vs done" mismatch, and fake verification. Severity: `P0` / `P1` / `P2` / `P3`, with evidence.
- `Anti-Drift Guardian`: verify the stage maps 1:1 to the operator goal and stage definition. Flag scope creep, out-of-scope edits, opportunistic refactors, goal substitution, weakened acceptance criteria, mutation-boundary drift, report-mode drift, and AgentOps protocol drift. Severity: `P0` / `P1` / `P2` / `P3`.

It replaces the old single final critic for those checkpoints; it does not apply to T1/T2 by default unless the operator explicitly requests this gate or the work escalates by evidence. Do not run it after every command or file read.

Consensus is not a vote. Consensus means every `P0` and `P1` finding from all three passes is either fixed and rechecked by the discovering pass, or written as an accepted risk in a decision note with a one-line justification and explicit owner. `P2` / `P3` findings go to follow-up and do not block by default. "Critics found nothing" is not consensus unless the outputs show real break attempts with evidence.

Every dispatch prompt must include the literal instruction: `Start immediately. Do not wait for further instruction.` Do not give fresh passes prior pass verdicts or say the previous round passed; avoid inherited bias. Each pass must start with either a quoted `file:line` observation or output from a command it actually ran. A plan-only, "waiting for instruction", opinion-only, or evidence-free "looks fine" output is not a valid pass. Consensus-gate passes are non-overridable leaf validators: they must not spawn, wait on, validate, reset, close, or message subagents, and inherited Lead-only orchestration, delegation, consensus-gate, specialist-pass, matrix/table, fallback, and autonomous-continuation rules do not apply inside the pass. Use minimal self-contained dispatch context. Full-history/forked context is forbidden by default when it could inherit Lead-only rules; if unavoidable, the Lead must record a pre-dispatch exception with reason, fork mode, exact leaf override, inherited-rule risk, owner, and verdict impact. A full-history/forked consensus pass without that exception is invalid and counts as `CHECK_NOT_PERFORMED`. Preserve an auditable dispatch record for each pass: role, agent id when known, fork/full-history mode, mutation authority, exact leaf-validator/no-subagent text, and evidence-first requirement.

If a pass idles, waits, produces only a plan, or returns no file/command evidence, reset and rerun it once with a stricter mandate. If the rerun also fails, record `CHECK_NOT_PERFORMED` and do not claim consensus. If a round reports zero `P0` / `P1` and lacks proof of real hostile break attempts, treat the check itself as failed and rerun once.

After outputs are recorded, Lead must close/terminate the three passes and use fresh agents on the next consensus cycle; stale critic context must not carry across cycles.

If the stage does not reach consensus after two rounds, stop and return to the operator with current state, findings, options, and blocked criteria. Do not weaken criteria or simulate progress.

If visible dispatch is unavailable, fallback must preserve the three separate lenses inline and record `INLINE_ROLE_FALLBACK_USED`, independence lost, what each pass would have attacked, and verdict impact.

## Surface Audit Obligation

For Strong Skeptic on UI / frontend / shared-component tasks, Skeptic must explicitly check:

- shared-component coverage AND raw HTML elements / direct implementations bypassing the shared component;
- equivalent components in other builds / apps / packages (e.g., second app, story/test-only surface, generated wrapper);
- login / auth / OTP / password-manager opt-outs when autocomplete or input behavior is touched;
- app vs admin / OV / story / test-only surfaces;
- generated or legacy wrappers when aliases or imports suggest cross-stack reuse.

For Strong Skeptic on backend / domain tasks, Skeptic must analogously check:

- direct service callers and indirect callers via DI / events / messaging;
- alternative code paths (legacy v1, v2, beta, feature-flagged branches);
- background jobs and scheduled tasks that touch the same state;
- public API contracts and integration consumers;
- persistence readers AND writers for the touched state;
- permissions / tenant boundaries when the change touches access-controlled data.

The audit is generic; the trigger is "shared surface or cross-module or hidden blast radius", not any specific ticket shape. When the audit returns surfaces the diff does not cover, Skeptic verdict is `REVISE_REQUIRED` until either the diff is extended or the surfaces are explicitly out of scope with evidence.

## Second-Pass Skeptic Trigger

A second Skeptic pass is required when any of the following happens after the first Skeptic verdict:

- first verdict was `REVISE_REQUIRED` or `BLOCKED` and the Lead applied fixes;
- implementation scope expanded (new files, new modules, new surfaces touched);
- verification result changed (passing → failing, or new tests added);
- the agent applied any fix based on a Skeptic objection (even when first verdict was `PASS_WITH_RISKS` and the Lead chose to address the risk).

The second pass:

- reviews the **final** diff, not the pre-fix diff;
- may be smaller than the first pass and focus on the delta;
- produces the final canonical verdict line in `SKEPTIC_REVIEW.md`;
- earlier passes are preserved in the same file as `## Pass N` body sections beneath the canonical verdict line, not as separate files (the validator parses the first column-0 verdict line as the run's verdict, so the final-pass verdict must be at the top). Inside `## Pass N` body sections, do not start any line at column 0 with a canonical bold verdict such as `**`REVISE_REQUIRED`**`; record prior pass verdicts as plain text, e.g. `Pass 1 verdict: REVISE_REQUIRED`, so the validator sees only the final top verdict line.

If unresolved MUST-FIX objections remain after the second pass, the executive verdict is not plain `PASS`; use `PASS_WITH_RISKS`, `PASS_WITH_REQUIRED_FIXES`, `REVISE_REQUIRED`, or `BLOCKED` per the validator allow-list.

This trigger is convention-enforced, not validator-enforced. The validator continues to require one `SKEPTIC_REVIEW.md` with a canonical verdict line; it does not count passes. Operator-visible disclosure of whether a second pass occurred is a field in `Reports/templates/final-report-template.md` `## Skeptic Verdict` so reviewers can audit by reading.

## Anti-Ritual Safeguards

- Do not run Strong Skeptic for trivial typo / copy-only tasks regardless of formal tier; use the lightest Skeptic level that can still name the exact risk and proof.
- Do not spawn separate subagents when runtime lacks subagent support; use inline-but-visibly-separated Skeptic mode and record the fallback per `Core/SUBAGENT_BOUNDEDNESS_PROTOCOL.md`.
- Do not expand to Red Team unless a sensitive trigger fires (`Workflows/sensitive-change.md`).
- Do not require full git/history archaeology for every T1; tournament-depth evidence is for T3/T4.
- Do not produce a long `SKEPTIC_REVIEW.md` body when compact mode suffices; the canonical verdict line plus 5–10 lines of objections / evidence-gap / residual-risk is enough at Skeptic-Lite.
- Skeptic effort scales with tier and blast radius. Ceremony beyond what evidence requires is itself drift.

## Verdict Vocabulary

Operational reports and agent outputs use:

- `PASS`
- `PASS_WITH_RISKS`
- `REVISE_REQUIRED`
- `BLOCKED`

Legacy Core terms remain valid only as semantic aliases: `strong` ⇒ `PASS`, `acceptable` ⇒ `PASS_WITH_RISKS`, `weak` ⇒ `REVISE_REQUIRED`, `blocked` ⇒ `BLOCKED`.

## Rules

- `REVISE_REQUIRED` and `BLOCKED` are valid useful results.
- `REVISE_REQUIRED` is not a skeptic failure; it means the work must be revised, re-investigated, or escalated before finalization.
- `BLOCKED` means no finalization without operator override or resolution of the missing evidence.
- The skeptic must not be forced to approve.
- Lead resolution must address skeptic objections explicitly.
- For T4, `REVISE_REQUIRED` or `BLOCKED` cannot be overridden by the agent alone.
- For T1/T2 lightweight skeptic review, include at least one concrete disconfirming question or regression angle even when the verdict is `PASS`, such as what would make the fix wrong, which adjacent behavior could regress, which assumption is not directly verified, or which previous ticket or Vault rule could conflict.
- Challenge weak test evidence: passing tests are not enough if they do not assert the changed behavior. Test rewrites, weakened assertions, or snapshot-only updates must have explicit justification and may require `PASS_WITH_RISKS` or `REVISE_REQUIRED`.
- Pre-write challenge must attack the selected hypothesis and proposed mutation strategy, not only rejected alternatives. If historical intent explains the current behavior, do not approve a vague direction; require a concrete mutation mechanism with primitive/API, exact scope, state preservation or cleanup, preserved old intent, test seam, and rollback path.
- Wrapper-style fixes that preserve old behavior by adding bounds, clipping, guards, adapters, or cleanup must verify the wrapper boundary against the real behavior boundary. The test plan should distinguish the decision predicate, actual wrapper path use, and cleanup/state restoration; if the concrete primitive cannot be unit-tested cleanly, report residual risk.
- For hard-case T3/T4, the Three-Agent Consensus Gate or its explicit fallback must not summarize the Lead report. It must produce the top 3-7 ways the Lead could be wrong across the two skeptic lenses plus anti-drift lens, identify overconfident findings, split blocking vs acceptable unknowns, judge whether the verdict should be `PASS`, `REVISE_REQUIRED`, `STOP_BEFORE_WRITE`, or `READY_TO_MUTATE`, and name the fastest evidence that would falsify the current plan.
- Hard-case skepticism must explicitly attack task classification, hard-case triggers, symptom classification, stale/current assumptions, branch/build assumptions, parent AC interpretation, latest comments/media interpretation, related issue interpretation, prior-fix interpretation, mutation coverage map, missing runtime/media evidence, confidence levels, whether the Lead is overfitting to a preferred fix, and whether the Lead drifted from AgentOps boundaries.
- If hard-case triggers are present but the final report lacks the required hard-case skeleton, Skeptic must call `INVALID_WORKFLOW_RUN` or equivalent incomplete-run status rather than allowing clean `PASS` / `READY_TO_MUTATE`.
- If the Plan or Final Report names a `Candidate implementation target` file that is still labeled `UNVERIFIED_CANDIDATE_FILE` in `HYPOTHESES.md` (i.e. promoted from `find` / `rg` / `git log --stat` / path naming as discovery evidence only, without the file body being read in this run), Skeptic must downgrade the verdict to `REVISE_REQUIRED`. This rule is canonical in `Core/HYPOTHESIS_PROTOCOL.md` Candidate Owner File Evidence section. The fastest falsifier in such cases is to read the named files; do not allow planning to substitute for reading.

## Verdict Gating Rules

A `REVISE_REQUIRED` or `BLOCKED` verdict from Skeptic mechanically forbids the run from producing any of:

- a `Candidate implementation plan` section (under any heading) in `FINAL_REPORT.md`;
- a multi-phase implementation plan (`Phase A`, `Phase B`, `Candidate scope`, `Recommended sequencing`, etc.) in `PLAN.md`;
- a `READY_FOR_IMPLEMENTATION_PLAN` or `READY_TO_MUTATE` verdict label;
- any prescriptive "minimal change in `<FILE>`" or "route through `<HELPER>`" or "scope auto-populate to `<X>`" directive when the named code is in a file that is `UNVERIFIED_CANDIDATE_FILE`.

When the verdict is `REVISE_REQUIRED` or `BLOCKED`, `PLAN.md` and `FINAL_REPORT.md` may contain only:

- blockers — exactly what evidence is missing;
- fastest falsifiers — the smallest concrete set of file body reads, media inspections, or runtime checks that would unblock;
- next-evidence reads — named files to read in body, named media items to inspect, named git commits whose diff body to view;
- what would be required to plan — concrete preconditions before any plan can be written;
- the verdict itself with its reasoning.

Final-report executive verdict under such a Skeptic verdict must be exactly one of:

- `NO_IMPLEMENTATION_PLAN_AVAILABLE_UNTIL_BODY_READS`
- `BLOCKED_NEEDS_MEDIA`
- `BROWSER_OPERATOR_INPUT_REQUIRED`
- `INSUFFICIENT_EVIDENCE`
- `REVISE_REQUIRED`

Never `READY_FOR_IMPLEMENTATION_PLAN`, `READY_TO_MUTATE`, `READ_ONLY_FINDINGS_ONLY` (the latter has been used in prior runs to launder a candidate plan into a read-only label; this is no longer accepted), or `PASS` / `PASS_WITH_RISKS`.

This rule has teeth: if `PLAN.md` or `FINAL_REPORT.md` violates these constraints despite a `REVISE_REQUIRED` or `BLOCKED` verdict, the run is `INVALID_WORKFLOW_RUN`. Adding `(UNVERIFIED_CANDIDATE_FILE)` annotations to existing prescriptive plan text after-the-fact does NOT satisfy this rule — the prescriptive text itself must be removed or replaced with a "next reads required before plan is allowed" stub. Retroactive label normalization is not compliance.

**Mechanical check**: run `scripts/validate-run-report.sh <run-dir>` before closing any T2+ run. The validator returns non-zero (FAIL) if the run violates the gating rules above or the Inspection-budget verdict cap in `Core/MCP_BROWSER_POLICY.md`. The validator is read-only, has no dependencies beyond `bash`/`grep`/`awk`/`sed`, and finishes in well under one second. A run that passes the validator has not by itself proven good investigation depth — but a run that fails the validator has demonstrated drift and must be revised before closure.

**Structured markers (anti-bypass) + snippet contract + file-snapshot binding**: when a run wants to make an actionable claim about an implementation target, it must use the literal marker `implementation_target: <path>` in `FINAL_REPORT.md` or `PLAN.md`. The validator enforces a snippet-bound + file-snapshot-bound contract (see `RuntimeEvidence/runs/README.md` for full format): a 5-column manifest row (`path<TAB>status<TAB>lines<TAB>evidence_ref<TAB>snippet_hash`), optionally extended to 6 columns with `commit_ref`, plus a structured `BODY_READ_SNIPPET:`/`END_BODY_READ_SNIPPET` block in the referenced evidence file, with matching path/lines/hash and a non-placeholder code excerpt of file-extension-appropriate syntax. The validator (a) computes sha256 of the normalized pasted excerpt and requires manifest `snippet_hash` AND block `snippet_hash` AND computed pasted-excerpt hash to all match; (b) reads the actual file at `<repo-root>/<path>` lines `N..M` (or `git show <commit_ref>:<path>` lines `N..M` when `commit_ref` is set), normalizes it identically, and requires the actual-content hash to also match — and the normalized actual content to equal the pasted excerpt byte-for-byte. Diagnostic messages name the source as `working-tree=<repo-root>` or `commit_ref=<sha>`. Under `REVISE_REQUIRED`/`BLOCKED`/`STOP_BEFORE_WRITE`, any `implementation_target:` marker is itself a violation. The contract collapses the laundering attack from "fabricate excerpt + compute hash" to "tell the truth about file content at those lines". **It still does not prove the Read tool was invoked.** The chain it binds is: manifest ↔ pasted excerpt ↔ actual repository content. The chain it does not bind is: actual repository content ↔ tool invocation log. An agent reading the file via `cat` outside the Read tool can still produce a passing manifest. Tool-log binding requires instrumenting the agent runtime — not in scope for the current contract. Current contract level is `FILE_SNAPSHOT_BOUND_BUT_NOT_TOOL_LOG_BOUND` (5-column working-tree mode) or `COMMIT_SNAPSHOT_BOUND_BUT_NOT_TOOL_LOG_BOUND` (6-column `commit_ref` mode).

**Repo-root requirement**: file-snapshot binding requires a target repo. Pass `scripts/close-run.sh <run-dir> --repo-root <absolute-path>` (or set `AGENTOPS_TARGET_REPO`). Runs without `implementation_target:` markers do not need `--repo-root`. Runs with `implementation_target:` and no `commit_ref` and no `--repo-root` fail with the canonical error: `implementation_target '<path>' has no commit_ref and no --repo-root was supplied; cannot validate against actual file. Pass --repo-root <target-repo-path> to close-run.sh`. Runs that supply `commit_ref` on every row still need `--repo-root` because the validator invokes `git -C <repo-root> show`.

**Actionable-prose loophole closure**: under non-implementation verdicts, `FINAL_REPORT.md` and `PLAN.md` must not contain prose that combines a mutation verb (`change`, `modify`, `update`, `fix`, `edit`, `patch`, `implement in`, `route through`, `target`, `minimal change in`, including their gerund/past-tense/plural forms) with a concrete code-extension path on the same line. Use `next_read:` / `required_falsifier:` instead. Historical citation (`prior fix`, `FACT_GIT`, `git log/show/blame/diff`, etc.) is exempt **only when no obligation token is present on the same line** — a line that says "based on prior fix, update `Foo.tsx`" combines descriptive framing with imperative force and is flagged. Pure descriptive citation ("prior fix d399e65a93 touched `ESignInput.tsx`") remains exempt.

**MANUAL_CLOSE_CHECK**: T2+ runs SHOULD pass `scripts/close-run.sh <run-dir>` before being declared complete. The close check wraps the validator. This is a manual-invocation check, not hook-enforced — an agent that skips it leaves no disk audit trail (a fixture run with `SKEPTIC_REVIEW.md` and `FINAL_REPORT.md` produced without ever invoking `close-run.sh` is indistinguishable on disk from one that ran the check). Do not claim hook enforcement or that the check is mandatory in any mechanical sense; it is observable only when invoked.

## Minimum Output

- claim under review;
- objections;
- evidence gap;
- residual risk;
- verdict.
