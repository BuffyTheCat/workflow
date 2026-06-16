# Deployment Modes

AgentOps can be deployed into a project in two ways. Pick one explicitly per project. Document the choice. Mixing them silently is a known cause of mirror drift.

## Inline mode

```
project-root/
  AGENTS.md           # 5-line root pointer
  CLAUDE.md           # 5-line root pointer
  AgentOps/           # full tree, committed to git
  .gitignore          # ignores AgentOps/RuntimeEvidence/runs/
```

- AgentOps tree is committed.
- Vault is project-canonical, team-shared.
- All operators see the same rules and templates.
- Vault hygiene applies to the team, not the individual.
- `RuntimeEvidence/runs/` is gitignored; only templates and policies are committed.
- `git status` runs against the project repo and includes AgentOps changes.

Use Inline when: the team agrees on the workflow, vault content is project-specific knowledge, drift across operators is unacceptable, the project has a CI/CD that should lint AgentOps content.

## Overlay mode

```
project-root/
  AGENTS.md → .agentops-local/AGENTS.md     # symlink
  CLAUDE.md → .agentops-local/AGENTS.md     # symlink
  .agentops-local/                           # gitignored via .git/info/exclude
    AGENTS.md
    AgentOps/                                # mirror of an authoring source
```

- AgentOps tree lives under `.agentops-local/` and is not tracked.
- Authoring source lives outside the project (a separate canonical-AgentOps directory).
- Each operator can run their own version.
- Vault is operator-personal, not team-shared.
- `RuntimeEvidence/runs/` lives inside `.agentops-local/` and is automatically gitignored alongside it.
- `git status` runs against the project repo, but ignores `.agentops-local/`.

Use Overlay when: the team has not adopted AgentOps, the operator wants personal workflow without affecting the repo, AgentOps is being piloted, or the operator is testing changes before contributing them upstream.

## Source-of-truth relationship

- **Inline mode**: the project tree IS the authoring source. There is no separate canonical tree.
- **Overlay mode**: the authoring source is a canonical tree outside the project (e.g. `~/Desktop/AgentOpsCanon/AgentOps/`). The project's `.agentops-local/AgentOps/` is a copy. Updates flow authoring → mirror, never the reverse. Use `diff -u` after every authoring change to confirm both trees match.

## Drift risks

| Mode | Drift risk | Mitigation |
|---|---|---|
| Inline | rare; CI/CD can lint AgentOps tree | normal repo review |
| Overlay | high; mirror can fall out of sync silently | `diff -u` per authoring change; `find -newer` audit; ship a sync script if more than two adapters drift |

## Which repo `git status` applies to

The agent runs `git status` against the **project repo**, not the AgentOps tree.

- **Overlay mode**: `.agentops-local/` is excluded by `.git/info/exclude` so a clean `git status` is expected even when AgentOps files change. If the agent sees AgentOps files appear in `git status`, the exclude line is broken — stop and report. Do not attempt to commit.
- **Inline mode**: AgentOps file changes are visible in `git status`. The agent must obey `Core/COMMIT_PUSH_POLICY.md` for them like any other file.

## Where runtime artifacts are stored

| Mode | Runtime artifacts location | Gitignore? |
|---|---|---|
| Inline | `AgentOps/RuntimeEvidence/runs/<run-id>/` inside project repo | yes (project `.gitignore`) |
| Overlay | `.agentops-local/AgentOps/RuntimeEvidence/runs/<run-id>/` | yes (whole `.agentops-local/`) |

In neither mode are runtime artifacts committed.

## When each mode should be used

- Pilot, single operator: **Overlay**.
- Multi-operator team agreement: **Inline**.
- Multi-project authoring with personal preferences: **Overlay** with a single canonical source.
- Compliance-sensitive projects requiring auditable workflow: **Inline**.

## Cross-references

- `AgentOps/Core/COMMIT_PUSH_POLICY.md`
- `AgentOps/Core/CONTEXT_COMPACTION_POLICY.md`
- `AgentOps/RuntimeEvidence/runs/README.md`
