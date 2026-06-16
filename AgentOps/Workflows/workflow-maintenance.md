# Workflow: Workflow Maintenance

## Scope

Changes to `AgentOps` itself.

## Rules

- Preserve portability.
- Do not silently weaken anti-drift, evidence, or permission rules.
- Update adapters from `Core/`, not the reverse.
- Treat live/source repositories as read-only unless the operator explicitly names them as the mutation target.
- Treat `AgentOps/Runtime/imports/**` as quarantine/reference material, not active canon.
- For Vault hygiene changes, task findings are not canonical by default; use the inline Knowledge Delta section in the run's `FINAL_REPORT.md` per `Core/KNOWLEDGE_VAULT_POLICY.md` unless the task is explicitly operator-approved Vault maintenance.
- For candidate lesson promotion, use `AgentOps/Workflows/vault-maintenance.md` and the Vault Curator role; do not silently promote findings into `MainVault`.
- Use concise checkpoints from `AgentOps/Core/OPERATOR_VISIBILITY_PROTOCOL.md` before policy scan, first write, drift-risk discovery, and final verification.
- For specialist-heavy T5 maintenance, apply Core Role Coverage / Agent Activation: record whether Workflow Guardian, Skeptic, or other materially relevant roles used a dedicated visible subagent/pass, were handled inline by Lead, were not needed, were blocked/unavailable, or were skipped as risk.
- For long-running or resumable maintenance, persist `Run State`, `Evidence Ledger`, and `Decision Log` using `AgentOps/Reports/templates/**`; do not rely on chat/model memory alone.
- Final output should follow `AgentOps/Reports/templates/final-report-template.md` shape and include changed files, policy areas affected, validation, boundary checks, and `Knowledge Delta` or vNext candidate observations when applicable.
- When the maintenance request comes from a real task friction point, preserve the trace from friction -> observed evidence -> workaround -> proposed durable rule/script. Do not generalize a one-off workaround without stating scope and exceptions.

## Steps

1. Classify change as T5.
2. Identify canonical files affected.
3. Print intended target paths and confirm every write stays inside the approved mutation boundary.
4. Check whether the change alters guarantees or only wording.
5. Preserve adapter thinness.
6. Preserve compaction continuity, incident history, and existing task-state contracts.
7. Record any rule weakening explicitly in the change report.
8. For each workflow-friction item, choose the narrowest durable destination: runtime Vault note, workflow rule, report template field, helper script, or candidate lesson.
9. Verify internal links and structure.
