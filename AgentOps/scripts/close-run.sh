#!/usr/bin/env bash
# scripts/close-run.sh — MANUAL_CLOSE_CHECK for AgentOps T2+ runs.
#
# Wraps validate-run-report.sh. T2+ runs SHOULD pass this command before
# closure is claimed. Hook-based enforcement is NOT implemented; this is a
# manual-invocation check, not a tool-level interceptor. An agent that
# never invokes this script leaves no disk evidence the check was skipped.
# Do not call this gate "mandatory" in any mechanical sense.
#
# Usage:
#   scripts/close-run.sh <run-dir> [--repo-root <path>]
#
# --repo-root is required when the run contains an `implementation_target:`
# marker and the manifest row has no usable `commit_ref`. The validator
# will produce a concrete error like:
#   "implementation_target '<path>' has no commit_ref and no --repo-root
#    was supplied; cannot validate against actual file. Pass --repo-root
#    <target-repo-path> to close-run.sh"
# Runs that do not declare any `implementation_target:` marker do not
# need --repo-root.
#
# Environment fallback: AGENTOPS_TARGET_REPO is honored by the validator
# when --repo-root is not passed on the command line.
#
# Exit:  0 = run closed; non-zero = NOT closed (validator output printed)

set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RUN=""
REPO_ROOT_ARG=()
while [ $# -gt 0 ]; do
    case "$1" in
        --repo-root)
            shift
            [ $# -gt 0 ] || { echo "Usage: $0 <run-dir> [--repo-root <path>]" >&2; exit 2; }
            REPO_ROOT_ARG=(--repo-root "$1")
            shift
            ;;
        --repo-root=*)
            REPO_ROOT_ARG=(--repo-root "${1#--repo-root=}")
            shift
            ;;
        *)
            if [ -z "$RUN" ]; then RUN="$1"; shift
            else echo "unexpected argument: $1" >&2; exit 2; fi
            ;;
    esac
done

[ -n "$RUN" ] || { echo "Usage: $0 <run-dir> [--repo-root <path>]" >&2; exit 2; }

# Normalize: strip any trailing slash from RUN before it goes into the receipt.
# Receipt's run_dir field is later compared (string-equality) against the
# operator-supplied AGENTOPS_ACTIVE_RUN_DIR by the Stop hook. If close-run.sh
# was invoked with a trailing slash but the operator exports the env var
# without one (or vice versa), the comparison fails and the hook blocks a
# legitimate close. Falsified by cold-falsifier-2 (2026-05-03). The hook also
# normalizes on its side, but normalizing here keeps stored receipts consistent.
RUN="${RUN%/}"
if [ -d "$RUN" ]; then
    RUN="$(cd "$RUN" && pwd)"
fi

VALIDATOR="$HERE/validate-run-report.sh"
[ -x "$VALIDATOR" ] || { echo "MALFORMED: $VALIDATOR not found or not executable" >&2; exit 2; }

if "$VALIDATOR" "$RUN" ${REPO_ROOT_ARG[@]+"${REPO_ROOT_ARG[@]}"}; then
    printf 'CLOSE_OK: %s\n' "$RUN"
    printf '  Run passed MANUAL_CLOSE_CHECK.\n'
    # Write CLOSE_OK as a structured receipt instead of an empty marker.
    # The receipt binds the marker to the run's content + the scripts that
    # produced it via four sha256 hashes (close-run.sh, validate-run-report.sh,
    # SKEPTIC_REVIEW.md, FINAL_REPORT.md). The optional Stop hook
    # Adapters/claude/hooks/enforce-close-run.sh re-computes those hashes at
    # Stop time and refuses to allow stop if any hash differs from the
    # receipt. This raises bypass cost from `touch CLOSE_OK` (one shell
    # command) to "hand-write a receipt whose four hashes match four files
    # the agent must produce." Honest binding ceiling:
    # RECEIPT_HASH_BOUND_NOT_TOOL_BOUND — the hashes prove file content
    # consistency between close time and stop time, not that the agent
    # invoked the Read tool or that the validator was actually run.
    # Idempotent: re-running close-run.sh on a passing run rewrites the
    # receipt with fresh hashes and timestamp.
    if command -v shasum >/dev/null 2>&1; then
        HASHER='shasum -a 256'
    elif command -v sha256sum >/dev/null 2>&1; then
        HASHER='sha256sum'
    else
        printf '  WARNING: no sha256 hasher (shasum/sha256sum) available; CLOSE_OK marker written without receipt; Stop hook receipt verification will fail.\n' >&2
        : > "$RUN/CLOSE_OK"
        exit 0
    fi
    hash_of() { $HASHER "$1" 2>/dev/null | awk '{print $1}'; }
    close_run_hash=$(hash_of "$HERE/close-run.sh")
    validator_hash=$(hash_of "$VALIDATOR")
    skeptic_hash=$(hash_of "$RUN/SKEPTIC_REVIEW.md")
    final_hash=$(hash_of "$RUN/FINAL_REPORT.md")
    timestamp=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
    cat > "$RUN/CLOSE_OK" <<RECEIPT
# CLOSE_OK Receipt
run_dir: $RUN
timestamp: $timestamp
close_run_sha256: $close_run_hash
validator_sha256: $validator_hash
skeptic_sha256: $skeptic_hash
final_sha256: $final_hash
validator_exit_code: 0
RECEIPT
    exit 0
else
    rc=$?
    printf 'CLOSE_BLOCKED: %s (validator exit %d)\n' "$RUN" "$rc" >&2
    printf 'Run is NOT closed. Resolve the violations printed above and re-run close-run.sh before declaring the run complete.\n' >&2
    exit "$rc"
fi
