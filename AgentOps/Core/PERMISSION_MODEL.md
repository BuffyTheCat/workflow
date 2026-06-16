# Permission Model

## Purpose

This file separates technical capability from behavioral authorization. An agent may have a tool, shell, MCP method, or adapter allowlist entry available and still be forbidden to use it.

## Core Distinctions

### Capability

Capability means the environment technically exposes an action:

- shell access;
- git binary availability;
- `gh` CLI availability;
- MCP write tools;
- adapter allowlists such as Claude settings or Codex shell access.

Capability is not approval.

### Behavioral Authorization

Behavioral authorization is the policy decision that the action is allowed in the current turn under current constraints.

Behavioral authorization requires:

- consistency with `AgentOps/Core/AGENT_OS.md`;
- consistency with task tier and risk;
- consistency with user constraints;
- explicit user approval when the action is protected.

### Explicit User Approval

Explicit user approval is a narrow authorization granted in the current user turn.

Rules:

- approval is single-use;
- approval is current-turn scoped;
- approval does not persist to later turns;
- one protected action does not imply another.

Examples:

- `commit this` allows one commit only;
- `push this` allows one push only and does not imply commit rights for future turns;
- `create a PR` allows PR creation only, not merge or push beyond what is necessary and explicitly accepted.

### Hard Safety Stop

Some actions remain blocked unless the user explicitly approves them and the agent also performs a risk warning where required.

Examples:

- destructive git commands;
- force push;
- sensitive-zone writes;
- deletion patterns such as `rm -rf`.

## Default Behavioral Policy

Default means: even if the tool is available, the action is behaviorally forbidden unless the rule below says otherwise.

- Never commit by default.
- Never push by default.
- Never create a branch by default.
- Never create a PR by default.
- Never merge by default.
- Never rebase by default.
- Never perform destructive cleanup by default.
- Never modify application code in sensitive zones without explicit approval.
- Never modify external or live source repositories that are being used only as imported evidence or reference material.

## Source-Repository Containment

When a repository is being used as source material, imported evidence, or live reference for an AgentOps workflow, that original repository is read-only by default.

Rules:

- copied or quarantined materials under `AgentOps/Runtime/imports/**` may be analyzed and transformed;
- the original live/source repository must not be modified unless the operator explicitly names that repository as the mutation target in the current task;
- imported source is evidence, not workspace;
- if there is ambiguity about which repo is the mutation target, stop and ask the operator.

## Adapter Precedence

Precedence order for protected actions:

1. explicit user instruction in the current turn;
2. `AgentOps/Core/PERMISSION_MODEL.md`;
3. other canonical `AgentOps/Core/**` policy files;
4. project-specific `MainVault` rules;
5. adapter/tool settings and allowlists.

If an adapter exposes a command but `AgentOps` forbids it behaviorally, `AgentOps` wins.

## Git Command Classes

### Read-Only Git Commands

Allowed for investigation unless another policy blocks them:

- `git status`
- `git diff`
- `git log`
- `git blame`
- `git show`
- `git branch --show-current`

### Write Git Commands

Forbidden unless the user explicitly approves them in the current turn:

- `git add`
- `git commit`
- `git push`
- `git checkout -b`
- `git switch -c`
- `git merge`
- `git rebase`
- `gh pr create`

### Destructive Commands

Forbidden unless the user explicitly approves them and the agent gives a high-risk warning first:

- `git reset --hard`
- `git clean -fd`
- `rm -rf`
- force push
- discard-style checkout/reset operations

## Sensitive-Zone Write Policy

Sensitive zones include:

- auth
- permissions
- secrets
- billing
- tenant boundaries
- data integrity
- migrations
- security
- public API behavior
- production configuration

Rules:

- no writes in sensitive zones without explicit approval;
- T4 handling applies;
- degraded evidence is not enough;
- when risk is high, the agent must warn before acting even if capability exists.

## Approval Semantics

### Single-use Examples

- User says `commit this`.
  Allowed:
  - one commit that matches the agreed summary.
  Not allowed:
  - push;
  - second commit;
  - PR creation.

- User says `push this`.
  Allowed:
  - one push after summarizing what is being pushed.
  Not allowed:
  - future pushes;
  - merge;
  - unrelated branch creation.

- User says `open a PR`.
  Allowed:
  - one PR creation.
  Not allowed:
  - merge;
  - future PR actions not explicitly requested.

## Required Behavioral Check Before Protected Actions

Before any protected action, the agent must confirm all of the following:

1. the user explicitly asked for the exact protected action in the current turn;
2. the action is within scope of the request;
3. no stricter safety policy blocks it;
4. the action is being consumed as single-use authorization;
5. the agent has restated the action and any risk.

## Allowed / Disallowed Examples

### Allowed

- Running `git status` during investigation.
- Running `git diff` to inspect local edits.
- Reading `git log` and `git blame` for regression archaeology.
- Refusing `git push` even when the adapter allowlist technically permits it.
- Inspecting a live external repository in read-only mode while writing only inside `AgentOps`.

### Disallowed

- Treating Claude `permissions.allow` entries as approval to commit.
- Treating shell availability as approval to create a branch.
- Using a previous turn's `push it` as permission to push again later.
- Performing `git add` and `git commit` because the adapter settings allow them.
- Editing a live source repository after importing its materials into `AgentOps/Runtime/imports/**` unless the operator explicitly retargets the task to that live repo.

## Adapter Guidance

- Adapters may document capability exposure.
- Adapters must not redefine behavioral safety downward.
- Adapter permission files should clarify that tool exposure is not authorization.

## Relationship To Other Core Files

- `AGENT_OS.md` defines the high-level operating contract.
- `COMMIT_PUSH_POLICY.md` states the default no-commit/no-push stance.
- `ANTI_DRIFT_POLICY.md` prevents scope creep and silent weakening.

This file is the canonical bridge between those rules and adapter capability layers.
