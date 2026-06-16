# Capability Preflight

Run this check before non-trivial work.

## Required Checks

- git status
- available package manager
- existing scripts
- MCP availability
- startup connector check for Linear MCP and Git/GitHub MCP
- browser capability
- `MainVault` availability
- test and build commands
- dirty working tree
- protected or sensitive paths
- browser/runtime verification default
- mutation target
- source repos touched
- commit, push, branch, and PR status
- destructive command status

## Output Statuses

- `AVAILABLE`
- `MISSING`
- `DEGRADED`
- `BLOCKED`
- `OPERATOR_ACTION_REQUIRED`

## Template

```md
# Capability Preflight
- Git: AVAILABLE | details: ...
- Package manager: AVAILABLE | details: ...
- Scripts: AVAILABLE | details: ...
- MCP: MISSING | details: ...
- Browser/runtime: DEGRADED | details: ...
- MainVault: AVAILABLE | details: ...
- Test commands: UNKNOWN | details: ...
- Dirty working tree: AVAILABLE | details: clean/dirty/unknown
- Sensitive paths: UNKNOWN | details: ...
- Browser/runtime verification default: UNKNOWN | details: operator-requested / workflow-required / not checked
- Mutation target: UNKNOWN | details: ...
- Source repos touched: UNKNOWN | details: ...
- Commit/push/branch/PR status: UNKNOWN | details: not requested / approved / blocked / not checked
- Destructive command status: UNKNOWN | details: not requested / approved / blocked / not checked
```

## Startup Connector Check

At the start of a new project session, and before any T1+ work, visibly check
whether Linear MCP and Git/GitHub MCP are connected.

Use this compact surface:

```md
# Connector Check
- Linear MCP: AVAILABLE | MISSING | NOT_CHECKED | NOT_REQUIRED | details: ...
- Git/GitHub MCP: AVAILABLE | MISSING | NOT_CHECKED | NOT_REQUIRED | details: ...
- Action: connect Linear MCP and Git/GitHub MCP now if this task needs ticket, PR, issue, media, related-ticket, or repository-history evidence.
```

Rules:

- If a task references tracker IDs, PRs, issues, comments, ticket media,
  parent/related issues, previous fixes, or repository history, missing or
  unknown connectors are `OPERATOR_ACTION_REQUIRED` unless equivalent evidence
  is explicitly available by another checked route.
- Git CLI availability is not the same thing as Git/GitHub MCP availability.
  Record them separately.
- If the task does not need Linear or Git/GitHub MCP, mark the connector
  `NOT_REQUIRED` and continue.
- Never imply ticket, PR, comment, media, relation, or repository-history
  evidence was checked when the relevant connector was missing or not used.

## Rules

- Do not claim a capability exists unless it was checked.
- Any unchecked field must be explicitly marked as `not checked`, `UNKNOWN`, `DEGRADED`, or `BLOCKED`; silence is not allowed.
- If git is unavailable, mark history-based workflows degraded or blocked.
- If test commands are unknown, do not imply verification coverage that was not achieved.
