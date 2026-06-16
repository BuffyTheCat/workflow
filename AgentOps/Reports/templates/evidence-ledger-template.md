# Evidence Ledger

Use this to preserve evidence pointers without dumping full files, full chat transcripts, secrets, environment values, tokens, PII, or private chain-of-thought.

## Direct Evidence

| Label | Claim / observation | Source pointer | Last checked | Notes |
| --- | --- | --- | --- | --- |
| `FACT_CODE` |  |  |  |  |
| `FACT_CONFIG` |  |  |  |  |
| `FACT_SCRIPT` |  |  |  |  |
| `FACT_GIT` |  |  |  |  |
| `FACT_TICKET` |  |  |  |  |
| `FACT_MEDIA` |  |  |  |  |
| `FACT_RUNTIME` |  |  |  |  |

## Imported / Vault Evidence

| Label | Claim / observation | Source pointer | Authority / freshness | Notes |
| --- | --- | --- | --- | --- |
| `FACT_VAULT` |  |  |  |  |
| `FACT_DOC` |  |  |  |  |
| `FACT_IMPORTED_CANON` |  |  |  |  |
| `FACT_IMPORTED_DOC` |  |  |  |  |
| `FACT_IMPORTED` |  |  |  |  |

## Inferences

| Label | Inference | Supporting evidence | Confidence | How to falsify |
| --- | --- | --- | --- | --- |
| `INFERENCE` |  |  |  |  |

## Unknowns / Operator Input

| Label | Missing information | Why it matters | Operator action / next check |
| --- | --- | --- | --- |
| `UNKNOWN` |  |  |  |
| `TODO_OPERATOR` |  |  |  |

## Conflicts And Risks

| Label | Item | Sources / trigger | Impact | Next action |
| --- | --- | --- | --- | --- |
| `CONFLICT` |  |  |  |  |
| `RISK` |  |  |  |  |

## Runtime / E2E Evidence

Use this section when the task claims browser/runtime/end-to-end verification.

| Item | Required evidence | Source pointer | Status | Notes |
| --- | --- | --- | --- | --- |
| Stack readiness | backend/frontend ports plus health endpoints |  | pass / fail / n/a | Listening port alone is not enough for backend readiness. |
| Fixture state | ticket-specific fixture IDs and acceptance-relevant data |  | pass / fail / n/a | Existing seeded data must be proven, not assumed. |
| Browser journey | URL, steps, final state |  | pass / fail / n/a | Smoke/login/grid is not full E2E. |
| DOM/API assertions | machine-readable counters or API statuses |  | pass / fail / n/a | Prefer primary assertions over screenshot-only proof. |
| Network/backend linkage | HAR/network log or substitute backend evidence |  | pass / fail / unavailable | If no HAR, disclose substitute evidence. |
| Raw verification logs | test/build command logs and exit codes |  | pass / fail / n/a | Prefer `tee` logs in the run dir. |
| Cleanup | processes, temp files, stubs, generated metadata, fixture rows |  | pass / fail / residual | Record accepted residual rows with owner/rationale. |
