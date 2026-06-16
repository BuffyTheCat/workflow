# Progress Beacon Protocol

## Purpose

The operator must be able to see what the agent is doing, why, and what comes next — without reading private chain-of-thought. Beacons are **operational state snapshots**, not internal monologue. They are the concrete artifact behind the abstract "operator-visible checkpoint" described in `Core/OPERATOR_VISIBILITY_PROTOCOL.md`.

## Schema

Every beacon is exactly this shape:

```md
## Progress Beacon
Phase: <intake | preflight | gate | constraint | evidence | re-gate | hypothesis | plan | implement | self-review | skeptic | red-team | verify | report>
Doing now: <one short sentence describing the current focused action>
Why: <one short sentence: what evidence or decision this advances>
Evidence found: <bullet list of new facts since the last beacon, FACT-tagged, or "none new">
Next: <one short sentence describing the planned next action>
Operator can intervene here if: <concrete condition where operator input would change direction>
```

Six fields. No more, no less. No additional headings.

## Cadence

Emit one beacon at every named phase boundary. Specifically:

- after preflight completes;
- after Task Classification Gate emits, and again when re-emitted with hard-case triggers;
- before dispatching subagents or specialist passes;
- when a leading hypothesis is selected;
- before first write or mutation;
- before Skeptic / Contrarian handoff;
- before final verification ladder;
- when degraded mode or a blocker is discovered;
- when a material hypothesis change occurs;
- when the agent is about to expand scope.

Do NOT emit beacons:

- after every grep, file read, or tool call;
- inside a single phase as progress padding;
- for trivial T0 work — one beacon at start, one at end is enough;
- to narrate internal reasoning.

## Persistence

For T1+ runs, beacons are appended to `LIVE_STATUS.md` inside the active run directory:

```
AgentOps/RuntimeEvidence/runs/<run-id>/LIVE_STATUS.md
```

Operator can `tail -f` this file. Each beacon is appended in order — never edit prior beacons, never reorder. Use the template at `AgentOps/Reports/templates/live-status-template.md`.

For T0 trivial work or ad-hoc operations without a run directory, beacons appear inline in the operator-visible response only and are not persisted.

## Operator intervention model

Each beacon's `Operator can intervene here if:` field names a concrete decision the operator can change at this point. After a beacon, the agent waits at most one phase before the next beacon — that is the next safe interruption point.

If the operator interjects mid-phase:

1. Acknowledge the correction in one line.
2. Capture current `RUN_STATE.md` per `Core/CONTEXT_COMPACTION_POLICY.md`.
3. Update objective.
4. Resume from the latest gate, not from the chat.
5. Emit a new beacon noting the change of direction.

Do not silently absorb operator corrections.

## Operational visibility vs hidden reasoning

A beacon describes **what** the agent is doing and **why** in operational terms (which file, which evidence, which decision). It does not contain:

- internal deliberation about which approach to try;
- enumerated alternatives the agent considered and rejected;
- step-by-step reasoning chains;
- raw subagent transcripts.

Those belong in `EVIDENCE_LEDGER.md`, `HYPOTHESES.md`, or the run's `DECISIONS.md` — not in beacons.

## What is NOT a beacon

- "I am thinking."
- "Let me check this file."
- A 200-word summary of internal reasoning.
- A wall of grep output.
- A copy of subagent chain-of-thought.
- A re-statement of the user's request.

## Examples

### Good

```md
## Progress Beacon
Phase: evidence
Doing now: reading Linear <TICKET-ID> comments via MCP
Why: ticket has 7 comments and 8 inline media items spanning 5 weeks; need full timeline before re-emitting Gate
Evidence found:
- FACT_TICKET parent ABC-12300, related ABC-12301
- FACT_TICKET 7 comments 2026-04-03 → 2026-05-01
- FACT_TICKET 5 PNG + 2 MP4 inline media references
Next: download mp4 attachments before signed URLs expire, then run media frame extraction
Operator can intervene here if: ffmpeg is unavailable in this environment, or if signed URL expiry has already occurred
```

### Bad

```md
## Progress Beacon
Phase: thinking
Doing now: I am considering whether to look at the ticket or the code first, both have merits
...
```

(Internal reasoning. Pick one and announce the action.)

## Cross-references

- `AgentOps/Core/OPERATOR_VISIBILITY_PROTOCOL.md` — checkpoint policy and intervention points.
- `AgentOps/Core/CONTEXT_COMPACTION_POLICY.md` — run-state capture before/after intervention.
- `AgentOps/Reports/templates/live-status-template.md` — file template.
- `AgentOps/RuntimeEvidence/runs/README.md` — runs/ directory convention.
