# Runtime Evidence Layer

Runtime Evidence is task-scoped proof for manual QA, browser/runtime validation, and inspected media. It supports closure confidence for a specific task; it is not canonical project knowledge and does not automatically update `MainVault`.

## Rules

- Use these templates when runtime, browser, media, or manual validation materially affects closure confidence.
- Optional for T1/T2 unless the task is visual/runtime-sensitive.
- Expected for T3/T4 when runtime/browser/manual evidence is material and feasible.
- Store compact facts, artifact pointers, hashes or filenames, environment, result, confidence, and residual risk.
- Do not store secrets, tokens, cookies, env dumps, PII, private chain-of-thought, full logs, full ticket archives, or sensitive customer/production payloads.
- Runtime Evidence may support a `Knowledge Delta`, but Vault promotion must go through the existing curator/review flow.
- If runtime evidence is missing, the final report must state what remains static-only or unproven.

## Templates

- `media-evidence-template.md`: inspected screenshots, video frames, or media artifacts.
- `browser-validation-template.md`: browser/runtime scenario validation.
- `manual-qa-template.md`: operator or tester manual validation.
- `evidence-index-template.md`: compact index linking task evidence artifacts and closure confidence.
