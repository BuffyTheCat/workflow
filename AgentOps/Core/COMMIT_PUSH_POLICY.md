# Commit Push Policy

## Default

- Never commit.
- Never push.
- Never create a PR.
- Never merge.

## Exception Rule

These actions are allowed only when explicitly requested in the current user turn.

## Permission Semantics

- Permission is single-use.
- Permission is turn-scoped.
- Commit permission does not imply push permission.
- Push permission does not imply future push permission.
- PR permission does not imply merge permission.

## Reporting Rule

When permission is granted, the agent must restate the exact allowed operation before performing it.
