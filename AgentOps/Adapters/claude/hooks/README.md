# Claude Hooks README

Place hard safety hooks here only when there is a clear operational need.

## Rule

Hooks should enforce canonical rules, not replace them.

## Available hooks (NOT auto-enabled)

### `enforce-close-run.sh` — optional Stop hook for `MANUAL_CLOSE_CHECK`

State: created and tested in isolation. **NOT wired into any consuming project's `.claude/settings.json` by AgentOps.** Operator opt-in only.

What it does: when `AGENTOPS_ACTIVE_RUN_DIR` is exported, blocks Claude Code session-stop unless the named run dir contains a `CLOSE_OK` marker (written by `scripts/close-run.sh` on validator success).

Behavior matrix:

| `AGENTOPS_ACTIVE_RUN_DIR` | run dir state | Hook output | Effect |
|---|---|---|---|
| unset | n/a | `{}` | session may stop (hook inert) |
| set, path missing | n/a | `{}` + stderr warning | session may stop (setup error, not closure issue) |
| set + dir exists + `CLOSE_OK` present | closed | `{}` | session may stop |
| set + dir exists + `CLOSE_OK` absent | not closed | `{"decision":"block","reason":"..."}` | session blocked until validator passes |

The hook reads stdin (the Stop event payload), discards it, and decides only from the env var and on-disk marker. Run-dir identification is operator-explicit, not session-inferred — eliminating the ambiguity that prevented earlier hook designs.

### Activation (operator-side, in the consuming project — not AgentOps)

These steps go in your project's `.claude/settings.json`, NOT in any AgentOps source file:

```jsonc
{
  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.agentops-local/AgentOps/Adapters/claude/hooks/enforce-close-run.sh"
          }
        ]
      }
    ]
  }
}
```

(Adjust the path if your AgentOps mirror lives elsewhere; the canonical path under the consuming project is `.agentops-local/AgentOps/Adapters/claude/hooks/enforce-close-run.sh`.)

Then, when starting work on a T2+ run:

```sh
export AGENTOPS_ACTIVE_RUN_DIR="$PWD/AgentOps/RuntimeEvidence/runs/<run-id>"
```

The hook is inert until that env var is set, so unrelated Claude Code sessions in the same project are not blocked.

When the run is complete: `bash AgentOps/scripts/close-run.sh "$AGENTOPS_ACTIVE_RUN_DIR" [--repo-root <repo>]`. On validator pass, `close-run.sh` writes the `CLOSE_OK` marker; the Stop hook then permits session-stop.

To intentionally bypass for a session (without disabling the hook globally): `unset AGENTOPS_ACTIVE_RUN_DIR` before stopping. The hook will exit allow.

### What this hook does NOT do

- Does not detect a run that was never registered (no env var set, no run dir created). An agent that simply doesn't open a run dir at all is unaffected; the hook enforces commitments, not first-time discipline.
- Does not enforce read-tool invocation, snippet authenticity, or any of the validator's content rules — those run inside `validate-run-report.sh`, called by `close-run.sh`.
- Does not run automatically; this directory ships with the hook script but no `.claude/settings.json` entry. Activation requires operator action in the consuming project.
- Does not block PreToolUse, PostToolUse, or any other event. Only Stop.

### When the hook is the wrong tool

- **Trivial T0/T1 work** without a run dir: do not export `AGENTOPS_ACTIVE_RUN_DIR`. The hook stays inert.
- **Multiple concurrent runs** in the same session: not supported by this design. The env var names exactly one active run.
- **Distributed enforcement across agents**: `CLOSE_OK` is a structured receipt
  whose hashes bind `SKEPTIC_REVIEW.md`, `FINAL_REPORT.md`,
  `validate-run-report.sh`, and `close-run.sh` at close time. It is still not
  bound to a specific agent identity or tool-call ledger.
- **Provenance binding**: `touch "$RUN/CLOSE_OK"` is blocked because the Stop
  hook requires the `# CLOSE_OK Receipt` header, matching run dir, matching
  hashes, and a validator re-run at Stop time. Honest ceiling:
  `RECEIPT_VALIDATOR_BOUND_NOT_TOOL_LOG_BOUND`. A malicious agent can still
  bypass by unsetting `AGENTOPS_ACTIVE_RUN_DIR`, by never opening a run dir, or
  by fabricating a fully matching receipt plus matching files. Treat the hook
  as cooperative-runtime enforcement, not adversary-proof security.

### `log-tool-call.sh` — optional PreToolUse hook for tool-invocation ledger

State: created and self-tested in isolation. **NOT wired into any consuming project's `.claude/settings.json` by AgentOps.** Operator opt-in only.

What it does: when `AGENTOPS_ACTIVE_RUN_DIR` is exported, appends one JSONL row per tool invocation to `<run-dir>/TOOL_CALL_LEDGER.jsonl`. The row records timestamp, tool name, sha256 of `tool_input`, cwd, session id, and a small selected-fields struct (issueId / parentId / file_path / command_head / markdown_bytes). Always returns `{}` — observes, never blocks.

Behavior matrix:

| `AGENTOPS_ACTIVE_RUN_DIR` | jq present? | Effect |
|---|---|---|
| unset | n/a | hook inert; returns `{}`; no ledger writes |
| set, path missing | n/a | inert; stderr warning; no ledger writes |
| set, path exists, jq absent | no | inert; stderr warning; no ledger writes |
| set, path exists, jq present | yes | one JSONL row appended per call |
| stdin malformed JSON | yes | one JSONL row with `tool=parse_error` and the input's sha256, so timestamp is preserved |

The hook always returns `{}` — it does not block any tool call. Its purpose is observation, not enforcement. The output ledger lets an operator audit role claims with `grep` + `jq`:

```sh
# Was list_comments called for ABC-12345? Tool names vary by runtime/MCP host.
jq -r 'select(.tool|test("linear.*list_comments")) | .sel.issueId // .sel.id // empty' "$AGENTOPS_ACTIVE_RUN_DIR/TOOL_CALL_LEDGER.jsonl"

# Was extract_images attempted (Media Extractor obligation)?
jq -r 'select(.tool|test("linear.*extract_images")) | .tool' "$AGENTOPS_ACTIVE_RUN_DIR/TOOL_CALL_LEDGER.jsonl"

# Was sibling discovery via parentId attempted?
jq -c 'select(.tool|test("linear.*list_issues")) | .sel.parentId' "$AGENTOPS_ACTIVE_RUN_DIR/TOOL_CALL_LEDGER.jsonl"

# Were owner files read before being named as implementation_target?
grep '"Read"' "$AGENTOPS_ACTIVE_RUN_DIR/TOOL_CALL_LEDGER.jsonl" | jq -r '.sel.file_path'
```

#### Activation (operator-side, in the consuming project)

Adds a `PreToolUse` matcher with wildcard scope to the consuming project's `.claude/settings.json`:

```jsonc
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.agentops-local/AgentOps/Adapters/claude/hooks/log-tool-call.sh"
          }
        ]
      }
    ]
  }
}
```

The matcher is `*` (every tool) because role obligations span Linear MCP, Read, Bash, Edit, Write, chrome-devtools, and others. The hook is cheap (~50 ms wall-clock per call: jq + shasum + jq).

The same `AGENTOPS_ACTIVE_RUN_DIR` env var that gates `enforce-close-run.sh` gates this hook — set both env var and both hook entries together. T0 / T1 work without an exported run dir leaves the hook inert (no ledger writes). T0 chat-only work is unaffected.

#### What this hook does NOT do

- Does not block any tool call. Stop hooks block; PreToolUse hooks here only observe.
- Does not capture `tool_response`. Use a PostToolUse companion if you need response binding (not provided here — adds size + complexity for marginal incremental value when the input args + downstream evidence in the run dir already prove the call happened).
- Does not bind to actual file content. Pair with the snippet contract (`Core/SKEPTIC_PROTOCOL.md` Verdict Gating Rules + `RuntimeEvidence/runs/README.md` Evidence manifest) for file-content binding.
- Does not prove the agent extracted meaningful observations from the response. An agent who calls `list_comments` and ignores the body still leaves a ledger row — the operator must still read the comment-derived facts in `EVIDENCE_LEDGER.md` to audit observation depth.
- Does not run automatically; activation requires the consuming project's `.claude/settings.json` entry above.

#### Honest binding ceiling

`TOOL_INVOCATION_LOGGED_NOT_TOOL_RESPONSE_BOUND_NOT_OBSERVATION_BOUND`.

What this proves:
- which tools were invoked, with what input args (sha256 + selected fields), at what time, in which cwd, in which session;
- absence of a tool: an agent claiming `Ticket Archivist: dispatched` while the ledger has zero `mcp__linear-server__list_comments` rows is operator-detectable in seconds.

What this does NOT prove:
- that the agent extracted meaning from the tool response (response not captured);
- that a Read of an owner file produced anything beyond the file existing — though combined with the snippet contract this becomes mechanically bound;
- that the order of writes truly preceded mutation — mtime is forgeable; only the chronological sequence of *hook-recorded* events is bound.

#### Why this is opt-in, not auto-wired

- `.claude/settings.json` is operator-controlled; AgentOps must not impose it.
- Inline-only / Codex / Cursor runtimes lack hook config; this hook degrades to "absent ledger" in those environments.
- Some operators may want a stricter hook (PreToolUse + PostToolUse + decision: block on certain MCP failures); they are free to extend this script in their consuming project. AgentOps ships a minimal observe-only baseline.

#### When the hook is the wrong tool

- **Pure T0 chat / explain only**: do not export `AGENTOPS_ACTIVE_RUN_DIR`. The hook is inert.
- **Trivial T1 fixes** without a run dir: same — inert.
- **Privacy / secret leakage concerns**: tool_input may contain secret-shaped content (API keys in Bash commands, signed URLs in `extract_images`). The ledger stores `command_head` (200 chars) for `Bash` and `markdown_bytes` count for `extract_images` — designed to avoid full payload retention. Operators with stricter requirements should redact further in their consuming project's wrapper.
- **High-throughput automation**: ~50 ms per call is fine for human-paced sessions; an agent doing 1000 tool calls/min would feel it. Not the AgentOps target use case.
