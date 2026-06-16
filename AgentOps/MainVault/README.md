# MainVault

`MainVault` is the project knowledge safe.

This directory is intentionally included in the shareable workflow package. It
should not be empty: the files here define where project knowledge belongs and
how agents should promote lessons without polluting canon.

The templates are clean. They contain no private task artifacts, ticket media,
raw logs, credentials, signed URLs, or project-specific facts from the authoring
repository.

## How To Use

1. Keep `01_ALWAYS_READ.md` as the short generic rule list loaded on every run.
2. Fill the numbered files only with evidence-backed facts from the installed
   project.
3. Label important claims with the taxonomy from
   `AgentOps/Core/EVIDENCE_CONTRACT.md`.
4. Keep task artifacts under `AgentOps/RuntimeEvidence/runs/**`, not here.
5. Put uncertain material in `15_STALE_OR_UNVERIFIED.md`, not canonical files.
6. Put proposed lessons in `16_AGENT_LEARNINGS_PROPOSED.md`.
7. Promote lessons through `AgentOps/Workflows/vault-maintenance.md`.

## What Belongs Here

- Stable architecture facts.
- Project-specific business/domain rules.
- Verified runtime and testing commands.
- Known regressions and recurring mistakes.
- Evidence-backed "do / do not" rules.
- Open questions and conflicts that should block silent assumptions.

## What Does Not Belong Here

- Raw ticket dumps.
- Full chat transcripts.
- Secrets, credentials, tokens, env dumps, customer data, signed URLs.
- One-off task logs.
- Unreviewed guesses.
- Private media or screenshots.

## Rule Of Thumb

If a future agent should rely on it across multiple tasks, it may belong in
`MainVault`.

If it only proves what happened in one task, it belongs in
`RuntimeEvidence/runs/<run-id>/`.
