# Codex Permissions

## Purpose

Codex may have shell access, git available in the environment, and other powerful tools. That is capability, not approval.

## Hard Rule

`AgentOps/Core/PERMISSION_MODEL.md` wins over shell availability or adapter convenience.

If Codex can run:

- `git add`
- `git commit`
- `git push`
- `git checkout -b`
- `git merge`
- `gh pr create`

the agent must still refuse unless the current user turn explicitly authorizes the exact protected action and no stricter safety rule blocks it.

## Capability Vs Approval

- Shell access is not approval.
- Git availability is not approval.
- Existing credentials are not approval.
- Previous turn approval is not approval.
- Live/source repositories remain read-only by default unless explicitly named as the mutation target in the current task.
- `AgentOps/Runtime/imports/**` is quarantine/reference material, not active canon.

## Behavioral Enforcement

Codex environments must enforce permission behaviorally:

- allow read-only git commands for investigation;
- forbid write git commands by default;
- require current-turn single-use approval for protected actions;
- warn before destructive commands;
- keep sensitive-zone writes gated by explicit approval.
- print intended target paths before writes and verify the mutation boundary.
- treat browser/runtime tooling as operator-call-only unless the active workflow explicitly requires reproduction evidence.
- keep delegates or subagents on narrow scope with a stop budget.
- stop and mark `UNKNOWN` or `TODO_OPERATOR` when approval, mutation target, or evidence state is unclear.

## Recommended Posture

- Keep adapter entrypoints thin.
- Keep canonical permission logic in `AgentOps/Core/**`.
- Do not weaken policy to match what the shell happens to permit.

## Project-Specific Reconciliation Notes

If a target repository has local tool settings that technically permit actions
which AgentOps policy restricts, follow the stricter AgentOps rule unless the
operator gives explicit current-task approval. Record project-specific
exceptions in `AgentOps/MainVault/` rather than this portable adapter file.

## TODO_OPERATOR

- Do not modify root `AGENTS.md` in this pass. If a future pass wants a stronger adapter entrypoint, add a separate operator-approved pointer to this file.
