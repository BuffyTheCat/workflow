# Hypothesis Protocol

## Core Rule

Agents must use falsifiable hypotheses at every task tier. The goal is not to confirm the first plausible story but to eliminate weak explanations.

## By Tier

### Micro Hypotheses for T1

- Use 1-3 short hypotheses.
- Each must map to a specific file, behavior, or command.
- One explicit self-skeptic question is required.

### Standard Hypothesis Matrix for T2

- Use a small matrix before implementation.
- Keep only live candidates with actual evidence.
- The matrix must be emitted as part of the pre-implementation Agent Dispatch Gate per `Core/AGENT_OS.md` Role Coverage / Agent Activation; implementation cannot begin until the matrix names ≥2 candidates with falsifiers and a selection reason.

### Hypothesis Tournament for T3

- Compare multiple plausible causes.
- Include code history, ticket context, and runtime or media evidence when relevant.
- Require at least one disconfirming check for the current leading theory.

### Adversarial Tournament for T4

- Include failure, abuse, and boundary-case scenarios.
- Model what would make the proposed fix unsafe.
- A hypothesis remains unproven until adversarial checks are satisfied.

## Required Matrix Format

| ID | Hypothesis | Evidence For | Evidence Against | How to Falsify | Confidence | Blast Radius | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| H1 | ... | ... | ... | ... | Low/Med/High | Local/Shared/Critical | Open/Rejected/Selected |

For multi-actor / multi-state cases (role × resource × permission, request × handler × store, state × event × subscriber, signer × signed-state × layer, etc.), prefer extending this matrix or the Evidence Slice Classification table (per `Adapters/claude/CLAUDE.md` hard-case skeleton) with explicit per-row actor/state labels and per-cell `FACT` / `INFERENCE` / `UNKNOWN` evidence-class tags from `Core/EVIDENCE_CONTRACT.md`. Per-cell `UNKNOWN` rows must name a fastest falsifier; mutation that touches those cells is gated by `Core/SKEPTIC_PROTOCOL.md` Verdict Gating Rules. Do not introduce a separate dimensional matrix when the existing per-hypothesis or per-slice matrix already pins each actor/state row.

## Rules

- Hypotheses must be falsifiable.
- Agents must actively kill or refute hypotheses, not only support them.
- For non-trivial T2+ work, challenge the selected hypothesis and proposed mutation strategy directly before implementation. Refuting alternatives is insufficient; record what would make the chosen approach wrong.
- If current behavior has historical intent, the selected approach must explain how that intent is preserved or intentionally superseded before mutation.
- Confidence must remain honest if the selected hypothesis is not proven.
- If no hypothesis survives, report `UNKNOWN` and escalate for operator input.

## Candidate Owner File Evidence

Discovery evidence (`find`, `rg`, filename similarity, `git log --stat`, `git show --stat`, path naming, ticket-linked filenames, IDE search) tells the agent which files **might** be implementation owners. It does not tell the agent which files **are** owners. Discovery evidence is `discovery evidence only`; reading the file body in this run is what promotes a file to an implementation target.

- A `Candidate implementation target` file may be listed as such only after the agent has read the file body or the relevant excerpts in this run.
- A file named by discovery evidence alone must be labeled `UNVERIFIED_CANDIDATE_FILE` in `HYPOTHESES.md`, `PLAN.md`, and `FINAL_REPORT.md`.
- Mutation-to-evidence coverage maps may include `UNVERIFIED_CANDIDATE_FILE` rows but must mark them as such; coverage is not credited for slices whose owner files are unread.
- Any implementation plan that names `UNVERIFIED_CANDIDATE_FILE` files as fix targets without first reading them must receive Skeptic verdict `REVISE_REQUIRED` per `Core/SKEPTIC_PROTOCOL.md`.
- For hard-case T2/T3 tickets, the fastest falsifier recorded in the run's Skeptic review must include reading the top candidate owner files. A pilot or investigation that stops before reading file bodies is investigation, not a plan.

This rule scopes to bug, regression, refactor, and visual-bug workflows. Trivial T0 tasks (typo, copy, obvious local fix) are exempt; the file body is implicitly read as part of the edit. Vault-maintenance and PR-review workflows have their own evidence rules and are unaffected.

## Cross-References

- `Core/AGENT_OS.md` Operating Principles bullet on candidate owner file evidence.
- `Core/EVIDENCE_CONTRACT.md` Cross-References — `UNVERIFIED_CANDIDATE_FILE` is discovery-only, not implementation-grade.
- `Core/SKEPTIC_PROTOCOL.md` — Skeptic must downgrade verdicts when plans name `UNVERIFIED_CANDIDATE_FILE` files as targets.
