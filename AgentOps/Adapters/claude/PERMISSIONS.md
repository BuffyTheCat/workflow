# Claude Permissions

## Purpose

Claude settings may expose tools, shell commands, MCP methods, or allowlist entries. That exposure is capability, not approval.

## Hard Rule

`AgentOps/Core/PERMISSION_MODEL.md` wins over Claude capability settings.

If Claude settings allow:

- `git commit`
- `git push`
- `git merge`
- `gh pr create`
- MCP write operations

the agent must still refuse them unless the current user turn explicitly authorizes the exact action and no stricter safety rule blocks it.

## Capability Vs Approval

- `.claude/settings.json` or `.claude/settings.local.json` may expose commands.
- Exposed commands are not behavioral permission.
- Tool allowlists do not override `AgentOps/Core/**`.
- Live/source repositories remain read-only by default unless explicitly named as the mutation target in the current task.
- `AgentOps/Runtime/imports/**` is quarantine/reference material, not active canon.

## Recommended Posture

Tracked Claude settings should be treated as a capability layer, not a policy source of truth.

Recommended posture:

- keep read-only investigation commands available where useful;
- avoid interpreting write-capable allowlists as standing permission;
- prefer stricter local behavioral policy over broader adapter exposure.

## Local Overrides

Local-only overrides may narrow capability or add convenience, but they must not silently weaken `AgentOps` safety.

Good use of local overrides:

- reduce noisy prompts for read-only commands;
- restrict dangerous commands further;
- configure runtime conveniences that do not expand behavioral authority.

Bad use of local overrides:

- making `git push` effectively implicit;
- treating a tracked allowlist as blanket approval;
- widening write authority without explicit operator review.

## Operational Invariants

- Before any write, print intended target paths and verify they stay inside the approved mutation boundary.
- `git add`, `git commit`, `git push`, branch creation, merge/rebase, PR creation, and destructive commands require explicit single-use current-task approval.
- Browser/runtime tooling is operator-call-only unless the active workflow explicitly requires reproduction evidence.
- Delegates or subagents must have narrow scope and a stop budget.
- If approval, mutation target, or evidence status is unclear, stop and mark `UNKNOWN` or `TODO_OPERATOR`.

## Project-Specific Reconciliation Notes

If a target repository has local Claude settings that technically permit
actions which AgentOps policy restricts, follow the stricter AgentOps rule
unless the operator gives explicit current-task approval. Record
project-specific exceptions in `AgentOps/MainVault/` rather than this portable
adapter file.

## TODO_OPERATOR

- Review whether live `.claude/settings.json` should be narrowed later to better match behavioral policy.
- Do not modify root `CLAUDE.md` in this pass; if later desired, point it at this file explicitly via a separate operator-approved change.
