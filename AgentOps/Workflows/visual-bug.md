# Workflow: Visual Bug

## PRE-FLIGHT GATE

The Pre-Flight Gate (steps A–E), Hard-Case skeleton, anti-regression example, and Autonomous Read-Only Continuation rule are canonical in `AgentOps/Core/AGENT_OS.md`. Execute that order before scope-specific guidance below. Adapter copies live only in `AgentOps/Adapters/{claude,codex}/` per canon §3.2 portable-core+adapters; Workflow files do not duplicate the block.

## Scope

Use for layout, rendering, responsive, styling, motion, or visual regression issues.

## Context Continuity / Run State

- Before long investigation, implementation after substantial discovery, skeptic handoff, final verification, compaction/handoff, or any resumable blocker, capture run state per `AgentOps/Core/CONTEXT_COMPACTION_POLICY.md`.
- Important state must not live only in chat or model memory.
- Preserve at minimum: current task objective, approved mutation target, intended target paths if writes are planned, files inspected, files changed, evidence buckets, active or selected hypothesis, unresolved `UNKNOWN` / `TODO_OPERATOR`, verification status, and next safe action.
- Preserve source-repository containment in the captured state: live/source repos are read-only unless explicitly named as the mutation target, and `AgentOps/Runtime/imports/**` remains quarantine/reference, not active canon.
- For long-running or resumable work, persist `Run State`, `Evidence Ledger`, and `Decision Log` using `AgentOps/Reports/templates/**`; do not rely on chat/model memory alone.

## Vault Hygiene / Knowledge Delta

- Task findings are not canonical project knowledge by default.
- Candidate reusable lessons must go through inline in the run's `FINAL_REPORT.md` Knowledge Delta section per `Core/KNOWLEDGE_VAULT_POLICY.md`.
- Do not write directly to canonical `MainVault` unless the workflow is explicitly vault-maintenance and operator-approved.
- Distinguish canonical, imported, stale, memory-only, conflict, and unknown evidence.
- Memory-only or imported material must not be promoted as fact without direct evidence.
- Conflicts go to conflict/unknown handling, not silent resolution.
- After completion, propose only reusable lessons with clear scope, source, confidence, and expiry or review condition.
- Final report must include `Knowledge Delta`: no update needed / proposal created / blocked by insufficient evidence.

## Final Reporting Mode

- T1/T2 visual work may use `COMPACT` mode from `AgentOps/Reports/templates/final-report-template.md` only when visual/runtime evidence is straightforward and residual risk is low.
- Use `FULL` mode when there is conflict, material `UNKNOWN`, non-trivial residual risk, sensitive/security/data/production impact, operator request, missing required visual/runtime evidence, or skeptic verdict `PASS_WITH_RISKS`, `REVISE_REQUIRED`, or `BLOCKED`.
- Compact mode must still include summary, files changed, evidence, verification, not run/not verified, residual risks, boundary/containment status, commit/push/branch/PR/destructive status, and `Knowledge Delta`.

## Operator Visibility

- Use concise checkpoints from `AgentOps/Core/OPERATOR_VISIBILITY_PROTOCOL.md` at preflight, media/browser evidence gathering, first-write, skeptic/verifier handoff, blocker, and final-verification boundaries.
- If media, browser, URL, or runtime capability is missing, offer operator options instead of implying visual certainty.

## Task Classification Gate

- Before root-cause summary, final verdict, or mutation recommendation, classify the visual run as `T1`, `T2`, `T3`, or `T4` from evidence.
- Operator wording such as "quick", "simple", "just check", or "take a look" may set initial suspicion but must not override discovered evidence.
- Record selected tier, classification evidence, hard-case triggers found or explicitly absent, whether classification changed during investigation, and why it did or did not escalate.
- Auto-escalate to hard-case T3/T4 unless explicitly disproven when evidence shows reopened/repeated QA return, previous same-ticket fixes, parent/child/related issues, evolving latest comments/media, multiple symptoms, conflict between parent AC and current evidence, frontend/backend split, renderer/baseline/overlay contract, branch/build divergence, stale/current ambiguity, runtime/media closure dependency, or mutation candidates covering different symptom subsets.
- If hard-case triggers are present but the report lacks the required hard-case skeleton or passes/fallbacks, mark `INVALID_WORKFLOW_RUN`, not `PASS` or `READY_TO_MUTATE`.

## Role Coverage / Agent Activation

- For T3/T4 or specialist-heavy visual runs, apply Core Role Coverage / Agent Activation: record whether each materially relevant role used a dedicated visible subagent/pass, was handled inline by Lead, was not needed, was blocked/unavailable, or was skipped as risk.
- Media Analyst and Runtime Reproducer are relevant only when media or browser/runtime evidence affects confidence.
- Hard-case T3/T4 visual runs include reopened or multi-symptom bugs, multiple/evolving media items or comments, related issues/PRs/history, backend/frontend/runtime ownership splits, manual/runtime closure dependency, or risk of reversing historical visual behavior. When active and supported, prefer at least two materially relevant dedicated visible specialist passes before mutation; inline fallback must explain independence lost and verdict impact.
- Hard-case final reports must reconcile latest visual comments/media against parent AC/title/description, QA media, related issues, prior fix commits, current code, and branch/build status; classify each visual symptom; and map any proposed mutation to symptoms covered/not covered. Specialist outputs must be integrated into the report skeleton, not merely mentioned.
- Important hard-case visual checkpoints require the Three-Agent Consensus Gate from `Core/SKEPTIC_PROTOCOL.md` before `READY_TO_MUTATE`, after material implementation before final verification, and before final closure when visual/runtime confidence is risky. If visible dispatch is unsupported, preserve the three lenses inline; the gate must attack task classification, media/runtime gaps, stale/current assumptions, parent/latest-comment interpretation, branch/build assumptions, mutation coverage, and drift from AgentOps boundaries.
- Hard-case visual reports must include a `Field Learning Candidate` or `No reusable learning found` with reason.

## Inline Media Evidence

- Follow the media access ladder in `AgentOps/Core/MCP_BROWSER_POLICY.md` for formal attachments and inline media links.
- `MEDIA_METADATA_ONLY` covers visible URLs, filenames, sizes, or HTTP `200`/`content-type` without inspected image/frame/media content.
- Do not claim visual facts unless media content was directly inspected; if inline media is visible but content was not inspected, propose the next safe operator action.

## Browser / Runtime Verification

- Follow browser/runtime status vocabulary from `AgentOps/Core/MCP_BROWSER_POLICY.md`.
- Keep media status separate from browser/runtime status: inspected screenshots/video are not the same as reproducing the behavior in a browser/runtime.
- Browser/runtime verification requires operator-provided or approved URL, environment, auth, and scenario. If absent, report `BROWSER_OPERATOR_INPUT_REQUIRED`, `BROWSER_RECOMMENDED_NOT_RUN`, or `BROWSER_BLOCKED` with residual risk.
- End-to-end visual verification requires the actual user journey and acceptance state, not only service readiness, login smoke, a unit test, or a screenshot after unrelated navigation. Define the exact fixture, browser steps, assertions, backend/API evidence, and cleanup criteria before claiming E2E.
- For project-specific visual/runtime workflows, follow the relevant contract in `MainVault/13_RUNTIME_AND_TOOLING.md` when present. If setup paths block before the surface under test, record that blocker and switch to the narrowest approved fixture/reproducer for the accepted scope.

## Runtime Evidence

- When media, browser/runtime, or manual QA evidence affects closure confidence, use `AgentOps/RuntimeEvidence/**` templates for compact task-scoped artifact pointers and residual risk.
- Do not treat Runtime Evidence as `MainVault` canon; any reusable lesson must go through Knowledge Delta / curator flow.
- If Runtime Evidence is missing, state what remains static-only or unproven.

## Steps

0. Entrypoint Order
   - Before any narrative summary, root-cause guess, specialist conclusion, or mutation recommendation, emit an initial Task Classification Gate block from intake-level signals; operator wording such as "quick", "simple", "разбери", "глянь", or "хорошенько" cannot lower the tier.
   - If the request references a ticket ID (Linear `SR-`/`ENG-`/etc., Jira, GitHub issue/PR), set the initial classification floor at `T2` and treat hard-case T3/T4 as a live possibility until disproven by evidence.
   - Collect primary evidence under bounded scope (issue body, comments, parent/child/related issues, prior same-ticket fixes, current code, branch/build state, memory/Vault, inline media metadata or content when available), then re-emit the Task Classification Gate with hard-case triggers found or explicitly absent.
   - If hard-case T3/T4 is now active, do not produce synthesis, mutation candidate, or `READY_TO_MUTATE` claim until the hard-case skeleton in `AgentOps/Reports/templates/final-report-template.md` is in place with required specialist passes plus Three-Agent Consensus Gate or explicit fallback. A single read plus narrative is not investigation.
1. Collect Evidence
   - Get screenshots, video, or design references.
2. Media Extraction
   - Build a manifest of visual evidence.
   - Default first attempt for Linear-tracked tickets: call `mcp__linear-server__extract_images` (or runtime-equivalent image-extraction MCP) on each `[Image]`/screenshot/attachment-bearing markdown body — issue description, every comment body, parent ticket body. The tool returns visual content directly; record extracted observations as `FACT_MEDIA`. If the tool returns 0 images for non-empty markdown, or auth fails, or media is auth-walled, mark Media Extractor `unavailable` with the specific blocker name.
3. Browser Reproduction
   - Reproduce in a browser or runtime environment when possible.
   - Do not trigger browser/runtime tooling only because frontend or UI code changed.
   - Use browser/runtime tooling only when it adds unique evidence and the operator requested or approved the required URL, environment, auth, and scenario.
   - Capture primary state evidence as DOM/API/network assertions. Screenshots are supporting evidence unless the acceptance criterion is purely visual pixels.
   - When saved screenshots are used, record MIME/format (`file <artifact>` or equivalent) and avoid relying on filename extension alone.
4. Context
   - Identify component, stylesheet, asset, and state boundaries.
5. Hypotheses
   - Separate layout, asset, state, and browser-specific candidates.
   - For T2+, emit the Agent Dispatch Gate per `AgentOps/Core/AGENT_OS.md` Role Coverage / Agent Activation in `LIVE_STATUS.md` before any write. Visual workflows fire Media Extractor + Browser/Visual QA defaults from the gate's required-by-tier table; if browser/runtime access is unavailable, mark `unavailable` with residual risk per `Core/MCP_BROWSER_POLICY.md`, do not silently skip. A gate reconstructed only in `FINAL_REPORT.md` post-mutation must be labeled `(POST-HOC)` and capped at `PASS_WITH_RISKS` or worse.
6. Write Boundary Check
   - Print intended target paths before any write.
   - Verify the approved mutation target.
   - Confirm live/source repositories are read-only unless explicitly named as the mutation target in the current task.
   - Confirm `AgentOps/Runtime/imports/**` is quarantine/reference, not active canon.
   - If media access, browser URL, mutation target, source ownership, or visual evidence provenance is unclear after bounded investigation, stop and mark `UNKNOWN` or `TODO_OPERATOR`.
7. Fix
   - Apply the smallest visual change that matches evidence.
8. Before/After Evidence
   - Capture both states when possible.
   - If a runtime attempt is superseded by a later successful attempt, update or explicitly mark the older report as stale before closure.
9. Responsive/Browser Caveats
   - State which breakpoints or browsers were checked.
10. Final Report
   - Include what was visually verified and what remains unverified.
   - If browser/runtime verification was not run, report `Browser/runtime verification: <status>` with reason, residual risk, and operator next action when needed.
   - Never claim visual verification without captured evidence.
   - For runtime/E2E visual work, include cleanup evidence: stopped ports/processes, fixture cleanup, temp-file cleanup, runtime-stub cleanup, and final working-tree status.
