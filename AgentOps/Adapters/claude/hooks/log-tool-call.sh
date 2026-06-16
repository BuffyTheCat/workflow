#!/usr/bin/env bash
# log-tool-call.sh — OPTIONAL PreToolUse hook for AgentOps tool-invocation ledger.
#
# NOT auto-enabled. Activation lives in the consuming project's
# .claude/settings.json — see Adapters/claude/hooks/README.md.
#
# Purpose: write a machine-generated JSONL ledger of every tool invocation
# during a T1+ AgentOps run. This converts "agent claim that role was
# dispatched" into "machine record that the role's expected tool calls
# happened". Operator audits become: `grep mcp__linear-server__list_comments
# TOOL_CALL_LEDGER.jsonl` — confirmed or contradicted in seconds.
#
# Contract:
#   stdin   — Claude Code PreToolUse event JSON, e.g.
#             {"hook_event_name":"PreToolUse",
#              "tool_name":"mcp__linear-server__list_comments",
#              "tool_input":{"issueId":"ABC-12345"},
#              "session_id":"...","cwd":"..."}
#   stdout  — always `{}` (we do not block; we observe).
#   stderr  — operator-facing diagnostic only.
#   exit    — always 0.
#
# Behavior table:
#   AGENTOPS_ACTIVE_RUN_DIR unset                          → allow, no log
#   set, path is not a directory                           → allow, stderr warn
#   set, path exists, jq absent                            → allow, stderr warn
#   set, path exists, jq present                           → allow, append JSONL row
#   stdin malformed JSON                                   → allow, append error row
#
# Honest binding ceiling: TOOL_INVOCATION_LOGGED_NOT_TOOL_RESPONSE_BOUND_
#                        NOT_OBSERVATION_BOUND.
# What this proves: which tools were invoked, with which input args, in
# which order, with which cwd. What this does NOT prove: that the agent
# extracted meaningful observations from the response, or that the response
# was non-empty, or that the agent acted on the response. Those remain
# convention-only.

set -u

RUN="${AGENTOPS_ACTIVE_RUN_DIR:-}"
PAYLOAD=$(cat 2>/dev/null || true)

# Always allow — we observe, we do not block.
echo '{}'

if [ -z "$RUN" ]; then
    exit 0
fi

if [ ! -d "$RUN" ]; then
    printf 'log-tool-call: AGENTOPS_ACTIVE_RUN_DIR=%q is not a directory; not logging this turn.\n' "$RUN" >&2
    exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
    printf 'log-tool-call: jq not found; cannot parse PreToolUse payload; not logging this turn.\n' >&2
    exit 0
fi

LEDGER="$RUN/TOOL_CALL_LEDGER.jsonl"
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u)

# Compute sha256 of tool_input for input-content binding (not just tool name).
# An agent that calls list_comments with issueId=ABC-12345 leaves a
# ledger row whose input_hash differs from one for issueId=ABC-12340.
HASHER=""
if command -v shasum >/dev/null 2>&1; then HASHER='shasum -a 256'
elif command -v sha256sum >/dev/null 2>&1; then HASHER='sha256sum'
fi

input_hash="hasher_unavailable"
if [ -n "$HASHER" ]; then
    input_hash=$(printf '%s' "$PAYLOAD" | jq -c '.tool_input // {}' 2>/dev/null | $HASHER 2>/dev/null | awk '{print $1}')
    [ -z "$input_hash" ] && input_hash="parse_error"
fi

# Extract fields. If jq fails on malformed JSON, write an error row so the
# ledger still records that *something* happened at this timestamp.
tool_name=$(printf '%s' "$PAYLOAD" | jq -r '.tool_name // "unknown"' 2>/dev/null || echo "parse_error")
event=$(printf '%s' "$PAYLOAD" | jq -r '.hook_event_name // "PreToolUse"' 2>/dev/null || echo "PreToolUse")
cwd=$(printf '%s' "$PAYLOAD" | jq -r '.cwd // ""' 2>/dev/null || echo "")
session=$(printf '%s' "$PAYLOAD" | jq -r '.session_id // ""' 2>/dev/null || echo "")

# Capture small selected tool_input fields by tool. The full tool_input
# can be huge (e.g., extract_images receives a markdown blob); we keep
# only the structurally-meaningful subset for human grep + the input_hash
# for content binding. Operators wanting the full payload can extend this
# script in their consuming project.
case "$tool_name" in
    mcp__linear-server__list_comments|mcp__linear-server__get_issue|mcp__linear-server__get_user|mcp__linear-server__get_team|mcp__linear-server__get_project|\
    mcp__linear__list_comments|mcp__linear__get_issue|mcp__linear__get_user|mcp__linear__get_team|mcp__linear__get_project|\
    mcp__metamcp__linear__list_comments|mcp__metamcp__linear__get_issue|mcp__metamcp__linear__get_user|mcp__metamcp__linear__get_team|mcp__metamcp__linear__get_project)
        sel=$(printf '%s' "$PAYLOAD" | jq -c '{issueId: .tool_input.issueId, id: .tool_input.id}' 2>/dev/null || echo '{}')
        ;;
    mcp__linear-server__list_issues|mcp__linear__list_issues|mcp__metamcp__linear__list_issues)
        sel=$(printf '%s' "$PAYLOAD" | jq -c '{parentId: .tool_input.parentId, project: .tool_input.project, query: .tool_input.query, assignee: .tool_input.assignee, state: .tool_input.state}' 2>/dev/null || echo '{}')
        ;;
    mcp__linear-server__extract_images|mcp__linear__extract_images|mcp__metamcp__linear__extract_images)
        markdown_bytes=$(printf '%s' "$PAYLOAD" | jq -r '.tool_input.markdown // ""' 2>/dev/null | wc -c | awk '{print $1}')
        sel=$(printf '{"markdown_bytes":%s}' "${markdown_bytes:-0}")
        ;;
    Read)
        sel=$(printf '%s' "$PAYLOAD" | jq -c '{file_path: .tool_input.file_path, offset: .tool_input.offset, limit: .tool_input.limit}' 2>/dev/null || echo '{}')
        ;;
    Write|Edit|NotebookEdit)
        sel=$(printf '%s' "$PAYLOAD" | jq -c '{file_path: .tool_input.file_path}' 2>/dev/null || echo '{}')
        ;;
    Bash)
        # First 200 chars of command for grep + the description if present.
        # Hash binds full content.
        sel=$(printf '%s' "$PAYLOAD" | jq -c '{command_head: (.tool_input.command // "" | .[0:200]), description: .tool_input.description}' 2>/dev/null || echo '{}')
        ;;
    *)
        # Unknown / new tool: store empty struct, hash still binds.
        sel='{}'
        ;;
esac

# Compose the ledger row. JSONL: one compact JSON object per line.
# Use jq to ensure valid JSON (no manual concatenation foot-guns).
row=$(jq -nc \
    --arg ts "$TS" \
    --arg event "$event" \
    --arg tool "$tool_name" \
    --arg input_hash "$input_hash" \
    --arg cwd "$cwd" \
    --arg session "$session" \
    --argjson sel "$sel" \
    '{ts:$ts, event:$event, tool:$tool, input_hash:$input_hash, cwd:$cwd, session:$session, sel:$sel}' \
    2>/dev/null)

if [ -z "$row" ]; then
    # jq composition failed; write a degraded row so operator sees something.
    row=$(printf '{"ts":"%s","event":"%s","tool":"%s","input_hash":"%s","sel":{},"degraded":"jq_compose_failed"}' "$TS" "$event" "$tool_name" "$input_hash")
fi

# Atomic-ish append. JSONL append on local fs is fine for single-writer
# patterns; a real concurrent multi-agent runtime would need flock(1).
printf '%s\n' "$row" >> "$LEDGER" 2>/dev/null || \
    printf 'log-tool-call: failed to append to %s\n' "$LEDGER" >&2

exit 0
