#!/usr/bin/env bash
# enforce-close-run.sh — OPTIONAL Stop hook for AgentOps MANUAL_CLOSE_CHECK.
#
# NOT auto-enabled. Activation lives in the consuming project's
# .claude/settings.json — see Adapters/claude/hooks/README.md.
#
# Contract:
#   stdin   — Claude Code Stop event JSON payload (consumed and discarded).
#   stdout  — `{}` to allow stop, or
#             `{"decision":"block","reason":"..."}` to block stop.
#   stderr  — operator-facing diagnostic only.
#   exit    — always 0 (decision is conveyed via stdout JSON, not exit code,
#             matching the project's existing PreToolUse hook style).
#
# Behavior table:
#   AGENTOPS_ACTIVE_RUN_DIR unset                        → allow
#   set, but path is not a directory                     → allow + stderr warning
#   set, path exists, no CLOSE_OK file                   → block
#   set, CLOSE_OK exists but lacks receipt header        → block (forged via touch)
#   set, receipt run_dir does not match active run       → block (copy-paste forgery)
#   set, receipt's recorded hashes do not match current  → block (run modified after close)
#   set, receipt valid, all four hashes match            → allow
#
# The active run dir is taken from the env var, not inferred from session
# state. Hash binding is computed against the SKEPTIC_REVIEW.md, FINAL_REPORT.md,
# validate-run-report.sh, and close-run.sh as they exist at Stop time. Honest
# binding ceiling: RECEIPT_HASH_BOUND_NOT_TOOL_BOUND. An adversary that
# hand-writes a receipt with valid hashes must also produce SKEPTIC + FINAL
# files matching those hashes — equivalent to running the actual close-run.sh.

set -u

# Drain stdin (Stop event payload). We do not parse it; the run dir is
# operator-controlled, not session-derived.
cat >/dev/null 2>&1 || true

RUN="${AGENTOPS_ACTIVE_RUN_DIR:-}"

if [ -z "$RUN" ]; then
    echo '{}'
    exit 0
fi

if [ ! -d "$RUN" ]; then
    printf 'enforce-close-run: AGENTOPS_ACTIVE_RUN_DIR=%q is not a directory; not enforcing this turn.\n' "$RUN" >&2
    echo '{}'
    exit 0
fi

CLOSE_OK="$RUN/CLOSE_OK"

emit_block() {
    local reason="$1"
    local escaped_run
    escaped_run=$(printf '%s' "$RUN" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')
    local escaped_reason
    escaped_reason=$(printf '%s' "$reason" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | tr '\n' ' ')
    cat <<EOF
{"decision":"block","reason":"AgentOps active run at $escaped_run: $escaped_reason. Run AgentOps/scripts/close-run.sh '$escaped_run' [--repo-root <path>] to write a fresh receipt. To intentionally bypass, unset AGENTOPS_ACTIVE_RUN_DIR before stopping."}
EOF
}

if [ ! -f "$CLOSE_OK" ]; then
    emit_block "CLOSE_OK marker absent (no validator pass recorded)"
    exit 0
fi

# Pick a sha256 hasher.
if command -v shasum >/dev/null 2>&1; then
    HASHER='shasum -a 256'
elif command -v sha256sum >/dev/null 2>&1; then
    HASHER='sha256sum'
else
    printf 'enforce-close-run: no sha256 hasher (shasum/sha256sum) available; cannot verify receipt; allowing stop.\n' >&2
    echo '{}'
    exit 0
fi

# Receipt schema check: must start with `# CLOSE_OK Receipt`.
first_line=$(head -1 "$CLOSE_OK" 2>/dev/null)
if [ "$first_line" != "# CLOSE_OK Receipt" ]; then
    emit_block "CLOSE_OK is not a structured receipt (forged via 'touch' or written by a pre-receipt close-run.sh; re-run close-run.sh)"
    exit 0
fi

get_field() {
    awk -v key="$1" '
        $0 ~ "^"key": " {
            sub("^"key": ", "", $0)
            print
            exit
        }
    ' "$CLOSE_OK"
}

receipt_run_dir=$(get_field "run_dir")
receipt_close_run_hash=$(get_field "close_run_sha256")
receipt_validator_hash=$(get_field "validator_sha256")
receipt_skeptic_hash=$(get_field "skeptic_sha256")
receipt_final_hash=$(get_field "final_sha256")

# Normalize trailing slashes before comparing. Receipts written by older
# close-run.sh (or close-run.sh invoked with a trailing slash) may store the
# run_dir with a trailing `/`. The operator-supplied AGENTOPS_ACTIVE_RUN_DIR
# typically has no trailing slash. Without normalization, exact-string
# compare would block a legitimate close-run-produced receipt. Falsified by
# cold-falsifier-2 (2026-05-03). Forge protection unaffected: an attacker
# crafting a receipt for a different run still differs by more than just the
# trailing slash, so this normalization does not weaken the copy-paste check.
receipt_run_dir_norm="${receipt_run_dir%/}"
RUN_NORM="${RUN%/}"

# Run-dir consistency: receipt's run_dir must match the env var's run dir
# after trailing-slash normalization.
if [ "$receipt_run_dir_norm" != "$RUN_NORM" ]; then
    emit_block "receipt run_dir '$receipt_run_dir' does not match AGENTOPS_ACTIVE_RUN_DIR '$RUN' (copy-paste forgery)"
    exit 0
fi

# Derive AgentOps root from this hook's location.
HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTOPS_ROOT="$(cd "$HOOK_DIR/../../.." && pwd)"
VALIDATOR_SCRIPT="$AGENTOPS_ROOT/scripts/validate-run-report.sh"
CLOSE_RUN_SCRIPT="$AGENTOPS_ROOT/scripts/close-run.sh"

hash_of() {
    [ -f "$1" ] || { echo ""; return; }
    $HASHER "$1" 2>/dev/null | awk '{print $1}'
}

current_close_run_hash=$(hash_of "$CLOSE_RUN_SCRIPT")
current_validator_hash=$(hash_of "$VALIDATOR_SCRIPT")
current_skeptic_hash=$(hash_of "$RUN/SKEPTIC_REVIEW.md")
current_final_hash=$(hash_of "$RUN/FINAL_REPORT.md")

# Verify each hash. Order: agent-facing files first (most likely cause of
# block in normal use), then script files.
if [ "$receipt_skeptic_hash" != "$current_skeptic_hash" ]; then
    emit_block "SKEPTIC_REVIEW.md hash differs from receipt (file modified after close-run.sh; receipt=${receipt_skeptic_hash:0:16}.. current=${current_skeptic_hash:0:16}..)"
    exit 0
fi
if [ "$receipt_final_hash" != "$current_final_hash" ]; then
    emit_block "FINAL_REPORT.md hash differs from receipt (file modified after close-run.sh; receipt=${receipt_final_hash:0:16}.. current=${current_final_hash:0:16}..)"
    exit 0
fi
if [ "$receipt_validator_hash" != "$current_validator_hash" ]; then
    emit_block "validate-run-report.sh hash differs from receipt (validator updated since close; re-run close-run.sh)"
    exit 0
fi
if [ "$receipt_close_run_hash" != "$current_close_run_hash" ]; then
    emit_block "close-run.sh hash differs from receipt (close-run.sh updated since receipt; re-run close-run.sh)"
    exit 0
fi

# All four hashes match. Final binding: re-run the validator on the run dir
# at Stop time. The 4-hash chain proves SKEPTIC + FINAL + scripts haven't
# changed, but unbound files (NOTES.md, RUN_STATE.md, EVIDENCE_LEDGER.md,
# the actionable-prose deny-list, etc.) could have been tampered after close
# (validator-adversary B-NEW-5 + B-NEW-6). Re-running the validator catches
# any post-close violation against its full deny-list surface. Cost: ~1s
# per Stop event. Honest binding ceiling after this:
# RECEIPT_VALIDATOR_BOUND_NOT_TOOL_LOG_BOUND.
if [ -x "$VALIDATOR_SCRIPT" ]; then
    if ! "$VALIDATOR_SCRIPT" "$RUN" >/dev/null 2>&1; then
        emit_block "validator re-run at Stop time failed (run dir was tampered after close-run.sh succeeded; an unbound file under deny-list now violates a validator rule). Re-run AgentOps/scripts/close-run.sh to write a fresh receipt"
        exit 0
    fi
fi

# Receipt + validator both pass. Allow stop.
echo '{}'
exit 0
