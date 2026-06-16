# MainVault

Project-specific memory lives here.

This shareable workflow package ships with a clean `MainVault` scaffold. Do not copy private task artifacts, ticket media, raw logs, credentials, or unverified memory into this directory.

Recommended flow:

1. Keep `01_ALWAYS_READ.md` as the generic always-loaded rule list.
2. Add project files only when evidence exists.
3. Label every important project claim with the evidence taxonomy from `AgentOps/Core/EVIDENCE_CONTRACT.md`.
4. Keep runtime/task artifacts under `AgentOps/RuntimeEvidence/runs/**`, not in `MainVault`.
5. Use `AgentOps/Workflows/vault-maintenance.md` to promote candidate learnings.
