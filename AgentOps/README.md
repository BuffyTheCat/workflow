# AgentOps

`AgentOps` is a portable operating system for coding agents. It is designed to help agents investigate before editing, separate verified facts from assumptions, recover original intent from history and tickets, and avoid drift, fake certainty, and unauthorized repo operations.

## How It Is Organized

- `Core/`: portable operating contracts and policies. Reusable across repositories.
- `Workflows/`: step-by-step task playbooks built on `Core/`.
- `Agents/`: role specifications for orchestrated agent work.
- `MainVault/`: project-specific knowledge layer. This is the main repository-local memory surface.
- `Adapters/`: tool-specific entrypoints for Codex, Claude, Cursor, and future tools.
- `Reports/`: reusable report templates.
- `Runtime/`: temporary local artifacts for agent runs.

## Portable Vs Project-Specific

- Portable: `Core/`, `Workflows/`, `Agents/`, `Reports/`, and most of `Adapters/`.
- Project-specific: `MainVault/`.
- Mixed but thin: root `AGENTS.md` and `CLAUDE.md` may point into `AgentOps`, but canonical behavior remains under `Core/`.

## How An Agent Should Start

1. Read `AgentOps/Core/AGENT_OS.md`.
2. Run capability preflight from `AgentOps/Core/CAPABILITY_PREFLIGHT.md`.
3. Classify the task tier.
4. For non-trivial work, consult `AgentOps/MainVault/00_INDEX.md` before making edits.
5. Collect evidence and tag project-specific claims.
6. Build and test hypotheses before changing code.
7. Do not commit, push, or open PRs unless explicitly requested in the current user turn.

## MainVault Rule

`MainVault/` is the only intended home for project-specific knowledge in this system. Facts recorded there must be evidence-tagged and must not be silently promoted from guesses or stale memory.

## Evidence Rule

Project-specific statements should be tagged with one of:

- `FACT_CODE`
- `FACT_DOC`
- `FACT_GIT`
- `FACT_TICKET`
- `FACT_MEDIA`
- `FACT_RUNTIME`
- `FACT_SCRIPT`
- `FACT_CONFIG`
- `FACT_VAULT`
- `INFERENCE`
- `UNKNOWN`
- `TODO_OPERATOR`

## Repo Operation Guardrail

No agent may commit, push, merge, or create a PR without explicit user permission in the current turn. That permission is narrow and does not persist.
