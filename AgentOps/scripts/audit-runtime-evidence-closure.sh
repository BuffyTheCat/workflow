#!/usr/bin/env bash
# scripts/audit-runtime-evidence-closure.sh
#
# Read-only hygiene audit for AgentOps RuntimeEvidence run directories.
# It reports closure-shape issues that make later RHO-lite mining unreliable:
# missing CLOSE_OK, missing parseable executive verdict, missing canonical
# bold-backtick verdict label, missing skeptic review for risk-bearing verdicts,
# and stale CLOSE_OK receipts after FINAL_REPORT.md or SKEPTIC_REVIEW.md changed.
#
# Usage:
#   scripts/audit-runtime-evidence-closure.sh [--classify] [runs-root]
#
# Output:
#   SUMMARY<TAB>key<TAB>value
#   ISSUE<TAB>run-name<TAB>issue-code<TAB>detail
#   TRIAGE<TAB>run-name<TAB>class<TAB>reason        (with --classify)
#
# Exit:
#   0 = audit completed, no issues found
#   1 = audit completed, issues found
#   2 = malformed input

set -u

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ROOT="$(cd "$HERE/.." && pwd)/RuntimeEvidence/runs"
CLASSIFY=0
RUNS_ROOT=""

while [ $# -gt 0 ]; do
    case "$1" in
        --classify)
            CLASSIFY=1
            shift
            ;;
        --help|-h)
            printf 'Usage: %s [--classify] [runs-root]\n' "$0"
            exit 0
            ;;
        *)
            if [ -z "$RUNS_ROOT" ]; then
                RUNS_ROOT="$1"
                shift
            else
                printf 'unexpected argument: %s\n' "$1" >&2
                exit 2
            fi
            ;;
    esac
done

RUNS_ROOT="${RUNS_ROOT:-$DEFAULT_ROOT}"

[ -d "$RUNS_ROOT" ] || {
    printf 'MALFORMED: runs root is not a directory: %s\n' "$RUNS_ROOT" >&2
    exit 2
}

hasher() {
    if command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" 2>/dev/null | awk '{print $1}'
    elif command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" 2>/dev/null | awk '{print $1}'
    else
        return 1
    fi
}

mtime() {
    # macOS/BSD stat first, GNU stat second.
    stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null || printf '0'
}

receipt_value() {
    awk -F': ' -v key="$2" '$1 == key { print $2; exit }' "$1" 2>/dev/null
}

canonical_verdict() {
    awk '
        /^## Executive verdict[[:space:]]*$/ { in_ev=1; next }
        in_ev && /^\*\*`[A-Z0-9_]+`\*\*/ {
            line=$0
            sub(/^\*\*`/, "", line)
            sub(/`\*\*.*/, "", line)
            print line
            exit
        }
        in_ev && /^## / { exit }
    ' "$1"
}

is_risk_bearing() {
    case "$1" in
        PASS_WITH_RISKS|PASS_WITH_REQUIRED_FIXES|REVISE_REQUIRED|BLOCKED|STOP_BEFORE_WRITE|INVALID_WORKFLOW_RUN|PARTIAL|NO_IMPLEMENTATION_PLAN_AVAILABLE_UNTIL_BODY_READS|BLOCKED_NEEDS_MEDIA|BLOCKED_NEEDS_BROWSER|BROWSER_OPERATOR_INPUT_REQUIRED|INSUFFICIENT_EVIDENCE)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

has_legacy_verdict_shape() {
    grep -Eq '^## Executive Verdict[[:space:]]*$|^Executive verdict:|^Final verdict:|^## Verdict[[:space:]]*$|^## Result[[:space:]]*$|`(PASS_WITH_RISKS|PASS|REVISE_REQUIRED|BLOCKED|PARTIAL|INVALID_WORKFLOW_RUN)`|PASS_WITH_[A-Z0-9_]+' "$1"
}

has_substantive_report_body() {
    grep -Eq '^## (Summary|Verification|Changes|Changed Files|Implemented|What was verified|Scope|App Changes|Resolution|Files|Evidence|Real Local E2E)' "$1"
}

issue_count=0
run_count=0
final_count=0
triage_count=0

emit_issue() {
    issue_count=$((issue_count + 1))
    printf 'ISSUE\t%s\t%s\t%s\n' "$1" "$2" "$3"
}

emit_triage() {
    triage_count=$((triage_count + 1))
    printf 'TRIAGE\t%s\t%s\t%s\n' "$1" "$2" "$3"
}

while IFS= read -r run_dir; do
    [ -n "$run_dir" ] || continue
    run_count=$((run_count + 1))
    run_name="$(basename "$run_dir")"
    final="$run_dir/FINAL_REPORT.md"
    skeptic="$run_dir/SKEPTIC_REVIEW.md"
    close_ok="$run_dir/CLOSE_OK"

    if [ ! -f "$final" ]; then
        continue
    fi
    final_count=$((final_count + 1))

    missing_close=0
    missing_heading=0
    missing_label=0
    missing_skeptic=0
    stale_close=0
    receipt_problem=0

    if [ ! -f "$close_ok" ]; then
        missing_close=1
        emit_issue "$run_name" "MISSING_CLOSE_OK" "FINAL_REPORT.md exists but CLOSE_OK is absent"
    fi

    if ! grep -q '^## Executive verdict[[:space:]]*$' "$final"; then
        missing_heading=1
        emit_issue "$run_name" "MISSING_EXECUTIVE_VERDICT_HEADING" "FINAL_REPORT.md lacks parseable '## Executive verdict'"
    fi

    verdict="$(canonical_verdict "$final")"
    if [ -z "$verdict" ]; then
        missing_label=1
        emit_issue "$run_name" "MISSING_CANONICAL_VERDICT_LABEL" "FINAL_REPORT.md lacks canonical **\\\`LABEL\\\`** verdict line after executive verdict"
    elif is_risk_bearing "$verdict" && [ ! -f "$skeptic" ]; then
        missing_skeptic=1
        emit_issue "$run_name" "MISSING_SKEPTIC_REVIEW" "risk-bearing verdict '$verdict' has no SKEPTIC_REVIEW.md"
    fi

    if [ -f "$close_ok" ]; then
        if [ -s "$close_ok" ] && ! grep -q '^# CLOSE_OK Receipt' "$close_ok"; then
            receipt_problem=1
            emit_issue "$run_name" "LEGACY_CLOSE_OK_MARKER" "CLOSE_OK exists but is not a receipt"
        fi

        close_mtime="$(mtime "$close_ok")"
        final_mtime="$(mtime "$final")"
        if [ "$final_mtime" -gt "$close_mtime" ] 2>/dev/null; then
            stale_close=1
            emit_issue "$run_name" "STALE_CLOSE_OK_FINAL_REPORT" "FINAL_REPORT.md is newer than CLOSE_OK"
        fi

        if [ -f "$skeptic" ]; then
            skeptic_mtime="$(mtime "$skeptic")"
            if [ "$skeptic_mtime" -gt "$close_mtime" ] 2>/dev/null; then
                stale_close=1
                emit_issue "$run_name" "STALE_CLOSE_OK_SKEPTIC_REVIEW" "SKEPTIC_REVIEW.md is newer than CLOSE_OK"
            fi
        fi

        if grep -q '^# CLOSE_OK Receipt' "$close_ok"; then
            recorded_final_hash="$(receipt_value "$close_ok" final_sha256)"
            current_final_hash="$(hasher "$final" || true)"
            if [ -n "$recorded_final_hash" ] && [ -n "$current_final_hash" ] && [ "$recorded_final_hash" != "$current_final_hash" ]; then
                receipt_problem=1
                emit_issue "$run_name" "CLOSE_OK_FINAL_HASH_MISMATCH" "receipt final hash differs from current FINAL_REPORT.md"
            fi

            if [ -f "$skeptic" ]; then
                recorded_skeptic_hash="$(receipt_value "$close_ok" skeptic_sha256)"
                current_skeptic_hash="$(hasher "$skeptic" || true)"
                if [ -n "$recorded_skeptic_hash" ] && [ -n "$current_skeptic_hash" ] && [ "$recorded_skeptic_hash" != "$current_skeptic_hash" ]; then
                    receipt_problem=1
                    emit_issue "$run_name" "CLOSE_OK_SKEPTIC_HASH_MISMATCH" "receipt skeptic hash differs from current SKEPTIC_REVIEW.md"
                fi
            fi
        fi
    fi

    if [ "$CLASSIFY" -eq 1 ]; then
        if [ "$missing_skeptic" -eq 1 ]; then
            emit_triage "$run_name" "needs-skeptic" "risk-bearing canonical verdict lacks SKEPTIC_REVIEW.md"
        elif [ "$stale_close" -eq 1 ] || [ "$receipt_problem" -eq 1 ]; then
            emit_triage "$run_name" "needs-close-check" "CLOSE_OK exists but receipt is stale, legacy, or hash-mismatched"
        elif [ "$missing_heading" -eq 1 ] || [ "$missing_label" -eq 1 ]; then
            if has_legacy_verdict_shape "$final" && has_substantive_report_body "$final"; then
                emit_triage "$run_name" "legacy-format" "substantive report uses old/non-canonical verdict shape"
            else
                emit_triage "$run_name" "needs-human-review" "missing canonical verdict shape without enough safe legacy-format signal"
            fi
        elif [ "$missing_close" -eq 1 ]; then
            emit_triage "$run_name" "needs-close-check" "canonical verdict shape exists but CLOSE_OK is absent"
        fi
    fi
done < <(find "$RUNS_ROOT" -mindepth 1 -maxdepth 1 -type d | sort)

printf 'SUMMARY\truns_root\t%s\n' "$RUNS_ROOT"
printf 'SUMMARY\trun_dirs\t%d\n' "$run_count"
printf 'SUMMARY\tfinal_reports\t%d\n' "$final_count"
printf 'SUMMARY\tissues\t%d\n' "$issue_count"
if [ "$CLASSIFY" -eq 1 ]; then
    printf 'SUMMARY\ttriage_rows\t%d\n' "$triage_count"
fi

[ "$issue_count" -eq 0 ] || exit 1
