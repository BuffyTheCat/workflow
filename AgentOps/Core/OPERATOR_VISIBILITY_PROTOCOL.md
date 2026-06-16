# Operator Visibility Protocol

## Purpose

Keep the operator able to see, interrupt, and redirect agent work without exposing private chain-of-thought or turning progress into ceremonial reporting.

Operator-visible checkpoints are concise working-state updates. They describe:

- current phase;
- evidence target;
- reason for the check;
- possible blocker or decision point;
- next safe action.

They must not reveal hidden reasoning, private deliberation, or long internal analysis.

## Required Checkpoints

Emit a compact checkpoint at these boundaries when relevant:

- preflight start and result;
- after preflight when dirty state, MCP, browser, media, or mutation constraints matter;
- before Vault or project-constraint scan;
- before git, ticket, MCP, media, or browser archaeology;
- before first write or edit;
- when selecting a leading hypothesis for T2+ work;
- before skeptic or Three-Agent Consensus Gate handoff;
- before verifier handoff or final verification;
- before final verification when tests/checks are expensive or broad;
- when a material hypothesis changes;
- when degraded mode or a blocker appears;
- when uncommitted, dirty, or overlapping user changes are found.
- when skeptic, Three-Agent Consensus Gate, or verifier returns `REVISE_REQUIRED`, `BLOCKED`, or requests revision.
- when the agent encounters workflow friction that requires a workaround, contradicts documented workflow, causes repeated failed attempts, or exposes missing reusable guidance. Emit a compact "workflow improvement candidate" checkpoint with the problem, local workaround, proposed target doc/script, and whether operator approval is needed to record it.

For T1/T2, checkpoints should usually be one or two sentences.

## Heartbeat / Phase-Boundary Rule

For tasks longer than a short local edit, provide compact phase-boundary checkpoints that state what is being checked now, why it matters, what would make the agent stop or escalate, and the next planned action. This is for operator steerability, not ceremony. Do not emit a heartbeat after every grep, file read, or obvious command.

## Intervention Points

These triggers apply at write/mutation, external-action, or expensive-action boundaries — not during read-only investigation continuation. Do not stop a hard-case T3/T4 read-only investigation at one of these triggers; record the concern, continue investigating, and resolve it at the relevant boundary. See `AGENT_OS.md` → Autonomous Read-Only Continuation.

Stop, ask, or offer options at the following boundaries when progress depends on operator input or risk acceptance:

- before a write or mutation, when MCP/auth/media/browser/URL/runtime capability is missing for the write itself;
- before a write or mutation, when task scope, acceptance criteria, mutation target, or ownership boundary is ambiguous (during investigation, record the ambiguity in the relevant matrix and continue);
- when a conflict between Vault/history/current code/ticket/media/runtime evidence requires an operator decision before the write or before declaring the verdict;
- before a write, when overlapping dirty files or pre-existing user changes appear in intended target paths;
- before any high-risk write without an approved mutation target;
- when skeptic or verifier returns `REVISE_REQUIRED` or `BLOCKED`;
- when verification is impossible, unavailable, or not meaningful for a planned write.

Do NOT use these triggers as grounds to stop and ask the operator whether to dispatch required read-only specialist passes, whether to run the Three-Agent Consensus Gate, or whether to fill a required hard-case matrix from already collected evidence.

## Operator Options

When intervention is useful, offer concise choices instead of guessing:

- continue degraded with explicit residual risk;
- provide missing input, auth, media, URL, ticket, or runtime access;
- narrow scope;
- stop;
- escalate tier.

Do not present options when the safe next step is obvious and low risk.

## Rule 21 — Workflow Improvement Candidate Rule

If an agent hits a workflow/documentation/tooling gap that costs material time, requires an undocumented workaround, contradicts current workflow docs, or is likely to recur for future tasks, the agent must surface it to the operator before final closure or at the next safe checkpoint.

The checkpoint should include:

- the friction point;
- the evidence that the current workflow was insufficient or stale;
- the workaround used in this run;
- the proposed workflow/doc/script destination;
- whether the agent is asking to record it now or only proposing a follow-up.

This does not authorize mutating workflow files by itself. Workflow/Vault changes still require the current task to approve the mutation boundary.

## Anti-Noise Rules

- Do not spam checkpoints after every command.
- Do not narrate obvious file reads.
- Do not expose private chain-of-thought.
- Do not turn progress updates into long reports.
- Do not ask lazy questions before bounded investigation.
- For T1/T2, keep updates compact and only emit them at meaningful boundaries.

## Responsiveness Rule

If the operator corrects direction mid-run, the agent must:

1. acknowledge the correction;
2. update the current objective and run-state if applicable;
3. preserve mutation and evidence constraints;
4. resume from the nearest safe checkpoint instead of restarting blindly.

## Evidence And Safety

Operator-visible updates must preserve the existing evidence taxonomy:

- `FACT_*` for direct evidence;
- `INFERENCE` for reasoned conclusions;
- `UNKNOWN` for missing evidence;
- `TODO_OPERATOR` for required operator input;
- `RISK` for residual risk;
- `CONFLICT` for conflicting evidence.

This protocol does not weaken `PERMISSION_MODEL.md`, `COMMIT_PUSH_POLICY.md`, or destructive-command rules.
