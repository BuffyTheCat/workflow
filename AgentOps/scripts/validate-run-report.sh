#!/usr/bin/env bash
# scripts/validate-run-report.sh
#
# Mechanical validator for AgentOps run directory compliance with:
#   Core/SKEPTIC_PROTOCOL.md           Verdict Gating Rules
#   Core/HYPOTHESIS_PROTOCOL.md        Candidate Owner File Evidence rule
#   Core/MCP_BROWSER_POLICY.md         Inspection budget and verdict cap
#
# Usage:
#   scripts/validate-run-report.sh <run-dir>
#
# Exit codes:
#   0  PASS  (no violations)
#   1  FAIL  (one or more violations)
#   2  MALFORMED  (run dir missing or unreadable)
#
# No dependencies beyond bash, grep, awk, sed. No framework.
# Designed to be runnable inline before closing a run.

set -u

# Argument parsing: <run-dir> [--repo-root <path>]
RUN=""
REPO_ROOT="${AGENTOPS_TARGET_REPO:-}"
while [ $# -gt 0 ]; do
    case "$1" in
        --repo-root)
            shift
            [ $# -gt 0 ] || { echo "--repo-root requires a path argument" >&2; exit 2; }
            REPO_ROOT="$1"
            shift
            ;;
        --repo-root=*)
            REPO_ROOT="${1#--repo-root=}"
            shift
            ;;
        *)
            if [ -z "$RUN" ]; then RUN="$1"; shift; else echo "unexpected argument: $1" >&2; exit 2; fi
            ;;
    esac
done

[ -n "$RUN" ] || { echo "Usage: $0 <run-dir> [--repo-root <path>]" >&2; exit 2; }
[ -d "$RUN" ] || { echo "MALFORMED: $RUN is not a directory" >&2; exit 2; }

VIOLATIONS=()
add_v() { VIOLATIONS+=("$1"); }

skeptic="$RUN/SKEPTIC_REVIEW.md"
final="$RUN/FINAL_REPORT.md"
plan="$RUN/PLAN.md"
hypotheses="$RUN/HYPOTHESES.md"
media="$RUN/MEDIA_PACKET.md"

# --- Detect Skeptic verdict ---------------------------------------------------
# Verdict line must appear at line start as a bold-backtick token, e.g.
#   **`REVISE_REQUIRED`** or **`REVISE_REQUIRED` before any implementation run.**
# Anchor to line start to avoid matching BLOCKED inside BLOCKED_NEEDS_MEDIA prose.
verdict=""
if [ -f "$skeptic" ]; then
    verdict=$(grep -oE '^\*\*`?(REVISE_REQUIRED|BLOCKED|STOP_BEFORE_WRITE|PASS_WITH_RISKS|PASS_WITH_REQUIRED_FIXES|READY_TO_MUTATE|PASS)' "$skeptic" \
              | head -1 \
              | sed -E 's/^\*\*`?//')
    # Verdict-shape bypass closure (validator-adversary B-NEW-7/B-NEW-8):
    # SKEPTIC_REVIEW.md present but no line in canonical `**`<LABEL>`**` form
    # at column zero leaves $verdict empty, which silently disables Rules
    # 1/2/5a/7. Symmetric with the missing-file rule below: convert the
    # silent skip into an explicit "fix the verdict line" failure. Backtick-
    # only (`` `LABEL` ``), blockquote-prefixed (`> **`LABEL`**`), or
    # bullet-prefixed (`- **`LABEL`**`) verdicts all hit this branch.
    if [ -z "$verdict" ]; then
        add_v "SKEPTIC_REVIEW.md present but no canonical verdict line found — verdict line must start at column 0 with **\`<LABEL>\`** (e.g., \`**\\\`REVISE_REQUIRED\\\`**\`); backtick-only, bullet-prefixed, or blockquote-prefixed forms silently disable verdict gating"
    fi
else
    # SKEPTIC_REVIEW.md absent: per Core/SKEPTIC_PROTOCOL.md every T2+ run must
    # carry a Skeptic verdict. Without the file, $verdict stays empty and
    # Rules 1/2/5a/7 silently skip — that was a structural bypass class
    # (validator-adversary case N14). Force the violation so the run cannot
    # close until a Skeptic review is written.
    add_v "SKEPTIC_REVIEW.md is missing — every T2+ run must carry a Skeptic verdict per Core/SKEPTIC_PROTOCOL.md"
fi

# --- Rules 1+2: forbidden plan content under REVISE_REQUIRED or BLOCKED -------
if [ "$verdict" = "REVISE_REQUIRED" ] || [ "$verdict" = "BLOCKED" ] || [ "$verdict" = "STOP_BEFORE_WRITE" ]; then
    if [ -f "$final" ]; then
        if grep -nE '^## Candidate implementation plan' "$final" >/dev/null; then
            line=$(grep -nE '^## Candidate implementation plan' "$final" | head -1 | cut -d: -f1)
            add_v "FINAL_REPORT.md:$line contains '## Candidate implementation plan' heading despite Skeptic $verdict"
        fi
        if grep -nE '^### Phase [ABCD]' "$final" >/dev/null; then
            line=$(grep -nE '^### Phase [ABCD]' "$final" | head -1 | cut -d: -f1)
            add_v "FINAL_REPORT.md:$line contains 'Phase A/B/C/D' heading despite Skeptic $verdict"
        fi
        # Forbidden verdict labels asserted as the report's verdict (line starts with **`LABEL`**)
        if grep -nE '^\*\*`?(READY_TO_MUTATE|READY_FOR_IMPLEMENTATION_PLAN)`?\*\*' "$final" >/dev/null; then
            line=$(grep -nE '^\*\*`?(READY_TO_MUTATE|READY_FOR_IMPLEMENTATION_PLAN)`?\*\*' "$final" | head -1 | cut -d: -f1)
            add_v "FINAL_REPORT.md:$line asserts READY_TO_MUTATE / READY_FOR_IMPLEMENTATION_PLAN despite Skeptic $verdict"
        fi
    fi
    if [ -f "$plan" ]; then
        if grep -nE '^### Phase [ABCD]' "$plan" >/dev/null; then
            line=$(grep -nE '^### Phase [ABCD]' "$plan" | head -1 | cut -d: -f1)
            add_v "PLAN.md:$line contains 'Phase A/B/C/D' heading despite Skeptic $verdict"
        fi
        if grep -nE '^## (Candidate scope|Files likely to touch)' "$plan" >/dev/null; then
            line=$(grep -nE '^## (Candidate scope|Files likely to touch)' "$plan" | head -1 | cut -d: -f1)
            add_v "PLAN.md:$line contains 'Candidate scope' or 'Files likely to touch' heading despite Skeptic $verdict"
        fi
    fi
fi

# --- Rule 3: UNVERIFIED_CANDIDATE_FILE + readiness claim ----------------------
unverified_count=0
for f in "$hypotheses" "$plan"; do
    [ -f "$f" ] || continue
    n=$(grep -c 'UNVERIFIED_CANDIDATE_FILE' "$f" 2>/dev/null || true)
    n=${n:-0}
    unverified_count=$((unverified_count + n))
done
if [ "$unverified_count" -gt 0 ] && [ -f "$final" ]; then
    if grep -nE '^\*\*`?(READY_TO_MUTATE|READY_FOR_IMPLEMENTATION_PLAN)`?\*\*' "$final" >/dev/null; then
        line=$(grep -nE '^\*\*`?(READY_TO_MUTATE|READY_FOR_IMPLEMENTATION_PLAN)`?\*\*' "$final" | head -1 | cut -d: -f1)
        add_v "FINAL_REPORT.md:$line asserts READY_TO_MUTATE / READY_FOR_IMPLEMENTATION_PLAN while UNVERIFIED_CANDIDATE_FILE present ($unverified_count occurrences in HYPOTHESES.md/PLAN.md)"
    fi
fi

# --- Rule 4: SKIPPED_WITH_VERDICT_CAP requires capped executive verdict -------
# Extract executive verdict once (used by Rule 4 and Rule 6).
ev_primary=""
if [ -f "$final" ]; then
    ev_line=$(awk '/^## Executive verdict/{flag=1;next} flag && /^\*\*`/{print; exit}' "$final")
    ev_primary=$(printf '%s' "$ev_line" | sed -E 's/^\*\*`([^`]+)`\*\*.*/\1/')
fi

if [ -f "$media" ] && grep -q 'SKIPPED_WITH_VERDICT_CAP' "$media"; then
    case "$ev_primary" in
        REVISE_REQUIRED|BLOCKED_NEEDS_MEDIA|BLOCKED_NEEDS_BROWSER|BROWSER_OPERATOR_INPUT_REQUIRED|INSUFFICIENT_EVIDENCE|NO_IMPLEMENTATION_PLAN_AVAILABLE_UNTIL_BODY_READS|INVALID_WORKFLOW_RUN)
            : # OK
            ;;
        "")
            add_v "FINAL_REPORT.md has no parseable executive verdict but MEDIA_PACKET.md contains SKIPPED_WITH_VERDICT_CAP"
            ;;
        *)
            add_v "MEDIA_PACKET.md contains SKIPPED_WITH_VERDICT_CAP but FINAL_REPORT.md executive verdict '$ev_primary' is not in the capped set {REVISE_REQUIRED, BLOCKED_NEEDS_MEDIA, BLOCKED_NEEDS_BROWSER, BROWSER_OPERATOR_INPUT_REQUIRED, INSUFFICIENT_EVIDENCE, NO_IMPLEMENTATION_PLAN_AVAILABLE_UNTIL_BODY_READS, INVALID_WORKFLOW_RUN}"
            ;;
    esac
fi

# --- Rule 5: structured markers + manifest -----------------------------------
# Markers are explicit commitments; they trigger validation against the
# evidence manifest. Prose advice does not trigger Rule 5; only the literal
# `implementation_target:` / `next_read:` markers do. This avoids regex
# theater while making the actionable form auditable.
manifest="$RUN/EVIDENCE_MANIFEST.tsv"

# Manifest is tab-separated (5 columns required when an implementation_target
# row is present):
#   path<TAB>status<TAB>lines<TAB>evidence_ref<TAB>snippet_hash
# `lines` must be a non-empty range like `22-24` or a single line like `41`,
# never `unknown`/`n/a`/`?`/`-`. `evidence_ref` must point at an evidence
# artifact inside the same run dir (FILENAME or FILENAME:LINE). The referenced
# file must contain a BODY_READ_SNIPPET:/END_BODY_READ_SNIPPET block whose
# path/lines/snippet_hash all match the manifest row, and whose excerpt is
# non-empty, non-placeholder, and contains code-like syntax for the file
# extension. This is anti-laundering: it raises the cost of laundering from
# one self-attested row to a snippet-bound multi-artifact contract. It does
# NOT prove the Read tool was actually invoked.
body_read_paths=""
if [ -f "$manifest" ]; then
    body_read_paths=$(awk -F'\t' '$2 == "BODY_READ" { print $1 }' "$manifest")
fi

# Helper: fetch the manifest row for a given path (first match wins).
manifest_row_for() {
    awk -F'\t' -v p="$1" '$1 == p { print; exit }' "$manifest"
}

# Helper: extract the BODY_READ_SNIPPET block whose path matches target,
# from the given file. Returns the block body (between BODY_READ_SNIPPET:
# and END_BODY_READ_SNIPPET) or empty.
extract_snippet_block() {
    awk -v target="$2" '
        BEGIN { in_block=0; buf=""; block_path="" }
        /^BODY_READ_SNIPPET:[[:space:]]*$/ { in_block=1; buf=""; block_path=""; next }
        /^END_BODY_READ_SNIPPET[[:space:]]*$/ {
            if (in_block && block_path == target) { printf "%s", buf; exit }
            in_block=0; buf=""; block_path=""; next
        }
        in_block {
            buf = buf $0 "\n"
            if (match($0, /^path:[[:space:]]*/)) {
                p = substr($0, RLENGTH+1)
                gsub(/[[:space:]]+$/, "", p)
                block_path = p
            }
        }
    ' "$1"
}

# Helper: extract a single-line field value from a snippet block.
snippet_field() {
    printf '%s' "$1" | awk -v f="$2" '
        {
            if (match($0, "^" f ":[[:space:]]*")) {
                v = substr($0, RLENGTH+1)
                gsub(/[[:space:]]+$/, "", v)
                print v
                exit
            }
        }
    '
}

# Helper: extract the excerpt section (everything after `excerpt:`).
snippet_excerpt() {
    printf '%s' "$1" | awk '
        BEGIN { capture=0 }
        /^excerpt:[[:space:]]*$/ { capture=1; next }
        capture { print }
    '
}

# Find structured markers in FINAL_REPORT.md and PLAN.md.
collect_markers() {
    local marker="$1"
    local file
    for file in "$final" "$plan"; do
        [ -f "$file" ] || continue
        # Match `implementation_target: <path>` and `next_read: <path>` regardless
        # of bullet prefixing or surrounding markdown. Capture the path token.
        grep -oE "${marker}:[[:space:]]*[^[:space:]]+" "$file" 2>/dev/null \
            | sed -E "s/^${marker}:[[:space:]]*//" \
            | sed -E 's/[[:punct:]]+$//'
    done
}

impl_targets=$(collect_markers 'implementation_target')
next_reads=$(collect_markers 'next_read')

# Rule 5a: under REVISE_REQUIRED / BLOCKED / STOP_BEFORE_WRITE,
# any implementation_target marker is a violation.
if [ "$verdict" = "REVISE_REQUIRED" ] || [ "$verdict" = "BLOCKED" ] || [ "$verdict" = "STOP_BEFORE_WRITE" ]; then
    if [ -n "$impl_targets" ]; then
        while IFS= read -r path; do
            [ -z "$path" ] && continue
            add_v "structured marker 'implementation_target: $path' is forbidden under Skeptic $verdict (Verdict Gating Rules)"
        done <<< "$impl_targets"
    fi
fi

# Rule 5b: every implementation_target path must appear in EVIDENCE_MANIFEST.tsv
# as BODY_READ, with non-empty lines + evidence_ref, AND the referenced
# evidence file must support the claim. Applies under any verdict.
#
# This is anti-laundering, not proof of true reading. The manifest plus the
# referenced evidence artifact form a two-artifact lock: it is no longer
# enough to type `path<TAB>BODY_READ` to satisfy the rule. The agent must
# also produce a separate evidence artifact carrying the path and the line
# anchor. Whether the agent actually read the file is still self-attested —
# this rule only forces a second artifact to carry the claim.
if [ -n "$impl_targets" ]; then
    if [ ! -f "$manifest" ]; then
        add_v "FINAL_REPORT.md / PLAN.md declares implementation_target markers but EVIDENCE_MANIFEST.tsv is absent"
    else
        while IFS= read -r path; do
            [ -z "$path" ] && continue
            # Path-traversal / absolute-path guard. The validator concatenates
            # `<repo-root>/<path>` for working-tree mode and passes <path> to
            # `git show <commit>:<path>`. Forbid any path that could escape the
            # target repo or address files outside it. This applies regardless
            # of whether file-snapshot validation will run, because an
            # unconstrained path is itself a misuse signal.
            normalized_path="${path#./}"
            case "$normalized_path" in
                /*|*/../*|*/..|../*|..)
                    add_v "implementation_target '$path' contains a forbidden path component (absolute path or '..' segment); paths must be repo-root-relative without traversal"
                    continue
                    ;;
            esac
            row=$(manifest_row_for "$path")
            if [ -z "$row" ]; then
                add_v "implementation_target '$path' is not present in EVIDENCE_MANIFEST.tsv"
                continue
            fi
            mstatus=$(printf '%s' "$row" | awk -F'\t' '{print $2}')
            mlines=$(printf '%s' "$row" | awk -F'\t' '{print $3}')
            mref=$(printf '%s' "$row" | awk -F'\t' '{print $4}')

            if [ "$mstatus" != "BODY_READ" ]; then
                add_v "implementation_target '$path' has manifest status '$mstatus', expected BODY_READ"
                continue
            fi
            # lines column must be non-empty and not a placeholder
            case "$mlines" in
                ""|unknown|UNKNOWN|n/a|N/A|"?"|"-")
                    add_v "implementation_target '$path' has invalid manifest lines column '$mlines' (must be a concrete range like '22-24' or single line)"
                    continue
                    ;;
            esac
            # evidence_ref must be non-empty
            if [ -z "$mref" ]; then
                add_v "implementation_target '$path' has empty manifest evidence_ref column (must point at an evidence artifact in the run dir)"
                continue
            fi
            # Parse evidence_ref into FILENAME[:LINE]
            ref_file="${mref%%:*}"
            ref_path="$RUN/$ref_file"
            if [ ! -f "$ref_path" ]; then
                add_v "implementation_target '$path' evidence_ref points at '$ref_file' which does not exist in the run dir"
                continue
            fi
            # The evidence file must contain the path as a literal substring
            if ! grep -Fq "$path" "$ref_path"; then
                add_v "implementation_target '$path' evidence_ref '$ref_file' does not contain the path string — manifest cites this file but the file does not back the claim"
                continue
            fi
            # The evidence file must contain the lines anchor as a literal
            # substring. This is an anchor check, not a semantic check.
            if ! grep -Fq "$mlines" "$ref_path"; then
                add_v "implementation_target '$path' evidence_ref '$ref_file' does not contain the line anchor '$mlines' — manifest cites these lines but the evidence file does not"
                continue
            fi

            # Snippet contract: 5th column required, snippet block required.
            mhash=$(printf '%s' "$row" | awk -F'\t' '{print $5}')
            if [ -z "$mhash" ]; then
                add_v "implementation_target '$path' manifest row missing snippet_hash (5th column required by snippet contract; see RuntimeEvidence/runs/README.md)"
                continue
            fi
            block=$(extract_snippet_block "$ref_path" "$path")
            if [ -z "$block" ]; then
                add_v "implementation_target '$path' has no BODY_READ_SNIPPET block matching path in '$ref_file' (snippet contract requires structured block with matching path/lines/hash and non-placeholder excerpt)"
                continue
            fi
            s_path=$(snippet_field "$block" "path")
            s_lines=$(snippet_field "$block" "lines")
            s_hash=$(snippet_field "$block" "snippet_hash")
            excerpt=$(snippet_excerpt "$block")
            if [ "$s_path" != "$path" ]; then
                add_v "BODY_READ_SNIPPET in '$ref_file' has 'path: $s_path' which does not match implementation_target '$path'"
                continue
            fi
            if [ "$s_lines" != "$mlines" ]; then
                add_v "BODY_READ_SNIPPET in '$ref_file' has 'lines: $s_lines' which does not match manifest lines '$mlines' for '$path'"
                continue
            fi
            if [ "$s_hash" != "$mhash" ]; then
                add_v "BODY_READ_SNIPPET in '$ref_file' has 'snippet_hash: $s_hash' which does not match manifest snippet_hash '$mhash' for '$path'"
                continue
            fi
            trimmed_excerpt=$(printf '%s' "$excerpt" | tr -d '[:space:]')
            if [ -z "$trimmed_excerpt" ]; then
                add_v "BODY_READ_SNIPPET excerpt for '$path' is empty"
                continue
            fi
            if [ "${#trimmed_excerpt}" -lt 10 ]; then
                add_v "BODY_READ_SNIPPET excerpt for '$path' is too short (<10 non-whitespace characters); paste actual code"
                continue
            fi
            lower_excerpt=$(printf '%s' "$excerpt" | tr '[:upper:]' '[:lower:]')
            case "$lower_excerpt" in
                *"code was read here"*|*"placeholder"*|*"snippet goes here"*|*"snippet here"*|*"<excerpt>"*|*"todo: paste"*|*"paste code here"*|*"actual code"*|*"the agent read"*)
                    add_v "BODY_READ_SNIPPET excerpt for '$path' contains placeholder text — paste actual file content"
                    continue
                    ;;
            esac
            ext=$(printf '%s' "$path" | awk -F. '{print tolower($NF)}')
            case "$ext" in
                ts|tsx|js|jsx|mjs|cjs)
                    code_pattern='\b(function|const|let|var|import|export|class|interface|type|return|if|else|switch|case|while|for|async|await|throw)\b|=>|[{}();=]' ;;
                cs|cshtml)
                    code_pattern='\b(using|namespace|class|public|private|protected|internal|static|void|return|if|else|switch|case|while|for|new|var|string|int|bool|double|float)\b|[{}();]' ;;
                py)
                    code_pattern='\b(def|class|import|from|return|if|else|elif|for|while|in|not|and|or|None|True|False|self|raise|try|except|with|as|lambda)\b|[():=]' ;;
                rs)
                    code_pattern='\b(fn|let|pub|use|mod|struct|impl|trait|enum|return|if|else|match|loop|while|for|in|self|mut|const)\b|[{}();]' ;;
                go)
                    code_pattern='\b(func|var|const|type|struct|interface|return|if|else|switch|case|for|range|package|import|defer|go)\b|[{}();]' ;;
                java|kt|kts)
                    code_pattern='\b(public|private|protected|class|interface|void|return|if|else|switch|case|while|for|new|val|var|fun|throws)\b|[{}();]' ;;
                rb)
                    code_pattern='\b(def|class|module|end|return|if|else|elsif|while|for|do|begin|rescue|ensure|require)\b|[():=]' ;;
                swift)
                    code_pattern='\b(func|var|let|class|struct|enum|protocol|extension|return|if|else|switch|case|while|for|in|guard|init)\b|[{}();]' ;;
                *)
                    code_pattern='[{}();]' ;;
            esac
            if ! printf '%s' "$excerpt" | grep -qE "$code_pattern"; then
                add_v "BODY_READ_SNIPPET excerpt for '$path' (.$ext file) does not contain expected code-like syntax — paste real code, not prose"
                continue
            fi

            # Compute sha256 of normalized excerpt and require it to match
            # the manifest snippet_hash. Normalization (canonical):
            #   1. Take the lines printed between `excerpt:` and
            #      `END_BODY_READ_SNIPPET`.
            #   2. Trim exactly one leading blank line if present.
            #   3. Trim exactly one trailing blank line if present.
            #   4. Preserve every other line as-is including indentation.
            #   5. Hash the bytes of the resulting lines joined by `\n`,
            #      WITHOUT a final trailing newline (bash command
            #      substitution semantics — `printf '%s' "$x" | shasum`).
            # An agent computing the hash should reproduce step 5 exactly:
            #   printf '%s' "$normalized" | shasum -a 256
            # where $normalized is the canonical text with no final \n.
            #
            # This binds the manifest hash to the literal excerpt bytes.
            # It does NOT prove the excerpt came from the actual file or
            # the Read tool — only that the agent typed a real sha256 of
            # what they pasted. An adversary can still fabricate an excerpt
            # and compute its hash. See SKEPTIC_PROTOCOL.md and
            # RuntimeEvidence/runs/README.md for the boundary statement.
            if command -v shasum >/dev/null 2>&1; then
                HASHER='shasum -a 256'
            elif command -v sha256sum >/dev/null 2>&1; then
                HASHER='sha256sum'
            else
                add_v "no sha256 hasher (shasum / sha256sum) available; cannot verify snippet hash for '$path' — runtime gap, not validator decision"
                continue
            fi
            normalized=$(printf '%s' "$excerpt" | awk '
                { lines[NR] = $0; nr = NR }
                END {
                    start = 1; end = nr
                    if (start <= end && lines[start] ~ /^[[:space:]]*$/) start++
                    if (end >= start && lines[end] ~ /^[[:space:]]*$/) end--
                    for (i = start; i <= end; i++) print lines[i]
                }
            ')
            computed_hash=$(printf '%s' "$normalized" | $HASHER | awk '{print $1}')
            if [ "$mhash" != "$computed_hash" ]; then
                add_v "BODY_READ_SNIPPET for '$path': manifest snippet_hash '$mhash' does not match sha256 of normalized excerpt (computed '$computed_hash') — excerpt may have been edited after the hash was set, or the hash was not computed from the excerpt"
                continue
            fi

            # File-snapshot binding: compare excerpt against actual repo file
            # at the cited lines. Either:
            #   - manifest commit_ref column (6th) is present → use git show;
            #   - else → require --repo-root and use working tree.
            mcommit=$(printf '%s' "$row" | awk -F'\t' '{print $6}')
            # Accept either N-M range or single line N (treated as N-N).
            if printf '%s' "$mlines" | grep -qE '^[0-9]+-[0-9]+$'; then
                ln_start=$(printf '%s' "$mlines" | cut -d- -f1)
                ln_end=$(printf '%s' "$mlines" | cut -d- -f2)
            elif printf '%s' "$mlines" | grep -qE '^[0-9]+$'; then
                ln_start="$mlines"
                ln_end="$mlines"
            else
                add_v "implementation_target '$path' manifest lines '$mlines' is not numeric (file-snapshot validation requires N-M range or single N)"
                continue
            fi
            if [ "$ln_start" -gt "$ln_end" ]; then
                add_v "implementation_target '$path' manifest lines '$mlines' has start > end"
                continue
            fi

            # Acquire actual file content
            actual_content=""
            actual_source=""
            if [ -n "$mcommit" ]; then
                if [ -z "$REPO_ROOT" ]; then
                    add_v "implementation_target '$path' has commit_ref '$mcommit' but no --repo-root supplied; pass --repo-root <path> to close-run.sh or set AGENTOPS_TARGET_REPO"
                    continue
                fi
                if [ ! -d "$REPO_ROOT/.git" ] && ! git -C "$REPO_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
                    add_v "implementation_target '$path' --repo-root '$REPO_ROOT' is not a git repository for commit_ref '$mcommit' validation"
                    continue
                fi
                if ! actual_content=$(git -C "$REPO_ROOT" show "$mcommit:$path" 2>/dev/null); then
                    add_v "implementation_target '$path' could not resolve 'git show $mcommit:$path' in repo-root '$REPO_ROOT' (commit/path not found at that commit)"
                    continue
                fi
                actual_source="commit_ref=$mcommit"
            else
                if [ -z "$REPO_ROOT" ]; then
                    add_v "implementation_target '$path' has no commit_ref and no --repo-root was supplied; cannot validate against actual file. Pass --repo-root <target-repo-path> to close-run.sh"
                    continue
                fi
                actual_path="$REPO_ROOT/$path"
                if [ ! -f "$actual_path" ]; then
                    add_v "implementation_target '$path' does not exist at '$REPO_ROOT/$path' (file not found in working tree)"
                    continue
                fi
                actual_content=$(cat "$actual_path")
                actual_source="working-tree=$REPO_ROOT"
            fi

            # Bounds check
            total_lines=$(printf '%s\n' "$actual_content" | awk 'END{print NR}')
            if [ "$ln_end" -gt "$total_lines" ]; then
                add_v "implementation_target '$path' line range '$mlines' is out of bounds; file has $total_lines lines (source: $actual_source)"
                continue
            fi

            # Extract lines N..M and normalize the same way as the snippet excerpt
            actual_lines=$(printf '%s\n' "$actual_content" | awk -v s="$ln_start" -v e="$ln_end" 'NR>=s && NR<=e')
            actual_normalized=$(printf '%s' "$actual_lines" | awk '
                { lines[NR] = $0; nr = NR }
                END {
                    start = 1; end = nr
                    if (start <= end && lines[start] ~ /^[[:space:]]*$/) start++
                    if (end >= start && lines[end] ~ /^[[:space:]]*$/) end--
                    for (i = start; i <= end; i++) print lines[i]
                }
            ')
            actual_hash=$(printf '%s' "$actual_normalized" | $HASHER | awk '{print $1}')

            if [ "$actual_hash" != "$mhash" ]; then
                add_v "implementation_target '$path' lines $mlines: actual repo content hash differs from manifest snippet_hash. manifest=$mhash actual=$actual_hash source=$actual_source — pasted excerpt does not match the file at the cited lines"
                continue
            fi
            # String-equality check between snippet excerpt and actual content
            # for clearer diagnostics (would already imply hash match).
            if [ "$actual_normalized" != "$normalized" ]; then
                add_v "implementation_target '$path' lines $mlines: hash matched but normalized excerpt differs from actual repo content — likely whitespace or normalization edge case (source: $actual_source)"
                continue
            fi
        done <<< "$impl_targets"
    fi
fi

# Rule 5c: next_read paths must be disjoint from implementation_target paths.
if [ -n "$next_reads" ] && [ -n "$impl_targets" ]; then
    while IFS= read -r np; do
        [ -z "$np" ] && continue
        if printf '%s\n' "$impl_targets" | grep -Fxq "$np"; then
            add_v "path '$np' appears as both next_read and implementation_target — these must be disjoint"
        fi
    done <<< "$next_reads"
fi

# --- Rule 7: actionable-prose under non-implementation verdicts --------------
# Even without a structured `implementation_target:` marker, a report that
# says "minimal change in `react/src/Form.tsx`" under REVISE_REQUIRED is
# laundering an implementation directive into prose. Catch this by looking
# for a mutation verb followed within ~100 chars (same line) by a path with
# a code-file extension. .md / .txt / .json are excluded so workflow filenames
# don't trigger. Case-insensitive. Same-line only — multi-line context is not
# parsed (false negatives accepted to keep this conservative).
#
# False-positive policy (per addendum): under non-implementation verdicts,
# the report should use `next_read:` markers instead of file-level edit prose.
# A false positive means re-phrasing into a structured marker, which is
# always cheaper than the false-negative case of a laundered plan slipping
# through.
is_blocked=0
case "$verdict" in
    REVISE_REQUIRED|BLOCKED|STOP_BEFORE_WRITE) is_blocked=1 ;;
esac
case "$ev_primary" in
    REVISE_REQUIRED|BLOCKED|BLOCKED_NEEDS_MEDIA|BLOCKED_NEEDS_BROWSER|BROWSER_OPERATOR_INPUT_REQUIRED|INSUFFICIENT_EVIDENCE|NO_IMPLEMENTATION_PLAN_AVAILABLE_UNTIL_BODY_READS|INVALID_WORKFLOW_RUN)
        is_blocked=1 ;;
esac

if [ "$is_blocked" = "1" ]; then
    # Mutation verbs include common verb-form variants (gerund, past tense,
    # plural). Multi-word forms ("implement in", "route through", "minimal
    # change in") still anchored. Path: code-file extensions only; .md /
    # .txt / .json are excluded so workflow artifacts don't trigger.
    PROSE_PATTERN='\b(change|chang(es|ed|ing)|modify|modif(ies|ied|ying)|update|updat(es|ed|ing)|fix|fix(es|ed|ing)|edit|edit(s|ed|ing)|patch|patch(es|ed|ing)|implement[[:space:]]+in|implement(s|ed|ing)|route[[:space:]]+through|rout(es|ed|ing)|target|target(s|ed|ing)|minimal[[:space:]]+change[[:space:]]+in)\b.{0,100}\.(tsx|ts|jsx|js|mjs|cjs|cs|cshtml|py|java|go|rb|swift|kt|kts|scss|css|sass|less|rs|vue|svelte|sql|sh|bash|zsh)\b'

    # Descriptive-context tokens — historical / prior / git-evidence framing
    # that legitimately cites past commits or evidence rather than directing
    # action.
    DESCRIPTIVE_TOKENS='\b(prior[- ]fix|previous[- ]fix|past[- ]fix|earlier[- ]fix|former[- ]fix|old[- ]fix|historical|FACT_GIT|FACT_CODE|FACT_VAULT|FACT_DOC|git[- ](log|show|blame|diff)|prior[- ]commit|previous[- ]commit)\b'

    # Obligation / recommendation / imperative tokens. If a line carries
    # both DESCRIPTIVE_TOKENS and OBLIGATION_TOKENS, it is actionable
    # framing wearing historical clothing — flag it. Pure descriptive lines
    # (no obligation token) remain excluded.
    OBLIGATION_TOKENS='\b(should|must|need[[:space:]]to|needs[[:space:]]to|recommend|recommends|recommendation|recommendations|suggest|suggests|next[[:space:]]step|approach[[:space:]]is|implies[[:space:]]we|indicates[[:space:]]we|propose|proposes|proposal|so[[:space:]]we[[:space:]]should|action[[:space:]]item)\b|(^|[[:space:]])(next:|action:|todo:|recommendation:|recommended[[:space:]]+(correction|approach|fix|change|update|modification|action|step|move):?)'

    # Scan every *.md in the run dir EXCEPT a fixed exclusion list of
    # evidence-side / factual artifacts where descriptive prose citing file
    # paths is normal and not laundering. Earlier versions hard-coded a
    # 6-file ALLOW-list; validator-adversary round 2 (2026-05-03)
    # demonstrated that actionable plan content placed in NOTES.md,
    # MEMO.md, JOURNAL.md, or any other agent-named markdown bypassed the
    # rule. Switching to deny-list closes that bypass class.
    #
    # Excluded files (legitimate factual narrative; broadening the regex
    # to allow their patterns would become regex theater):
    #   SKEPTIC_REVIEW.md  — verdict carrier; objections may cite paths
    #                        under historical-citation framing
    #   EVIDENCE_LEDGER.md — factual ledger; "files touched by prior fix
    #                        include `Foo.tsx`" is legitimate descriptive
    #                        citation, not an actionable directive
    #   MEDIA_PACKET.md    — media catalog; may cite paths in screenshot
    #                        descriptions
    #   HYPOTHESES.md      — hypothesis matrix; descriptive evaluation
    #   TICKET_PACKET.md   — ticket text quoted from external system;
    #                        agent-untrusted content reproduced verbatim
    #
    # All other run-dir markdown (FINAL_REPORT.md, PLAN.md, RUN_STATE.md,
    # TASK_CARD.md, LIVE_STATUS.md, WORKFLOW_RETROSPECTIVE.md, NOTES.md,
    # MEMO.md, etc.) is in-scope. The DESCRIPTIVE_TOKENS / OBLIGATION_TOKENS
    # carve-out still applies per line.
    for f in "$RUN"/*.md; do
        [ -f "$f" ] || continue
        case "$(basename "$f")" in
            SKEPTIC_REVIEW.md|EVIDENCE_LEDGER.md|MEDIA_PACKET.md|HYPOTHESES.md|TICKET_PACKET.md) continue ;;
        esac
        while IFS= read -r line; do
            [ -z "$line" ] && continue
            lineno=$(printf '%s' "$line" | cut -d: -f1)
            content=$(printf '%s' "$line" | cut -d: -f2-)
            # Decide whether this line is purely descriptive (excluded) or
            # actionable (flagged). Descriptive AND no-obligation = excluded.
            has_descriptive=0
            has_obligation=0
            if printf '%s' "$content" | grep -iqE "$DESCRIPTIVE_TOKENS"; then has_descriptive=1; fi
            if printf '%s' "$content" | grep -iqE "$OBLIGATION_TOKENS"; then has_obligation=1; fi
            if [ "$has_descriptive" = "1" ] && [ "$has_obligation" = "0" ]; then
                continue
            fi
            snippet=$(printf '%s' "$content" | tr -d '\r' | head -c 140)
            add_v "$(basename "$f"):$lineno actionable file-level advice under non-implementation verdict (use 'next_read:' or 'required_falsifier:' markers instead): $snippet"
        done < <(grep -niE "$PROSE_PATTERN" "$f" 2>/dev/null || true)
    done
fi

# --- Rule 6: executive verdict must be in known allow-list -------------------
ALLOWED_VERDICTS="REVISE_REQUIRED BLOCKED_NEEDS_MEDIA BLOCKED_NEEDS_BROWSER BROWSER_OPERATOR_INPUT_REQUIRED INSUFFICIENT_EVIDENCE NO_IMPLEMENTATION_PLAN_AVAILABLE_UNTIL_BODY_READS INVALID_WORKFLOW_RUN PASS PASS_WITH_RISKS PASS_WITH_REQUIRED_FIXES READY_TO_MUTATE READY_FOR_IMPLEMENTATION_PLAN"
if [ -f "$final" ]; then
    if [ -z "$ev_primary" ]; then
        add_v "FINAL_REPORT.md has no parseable executive verdict (expected '## Executive verdict' followed by **\`<LABEL>\`** ...)"
    else
        case " $ALLOWED_VERDICTS " in
            *" $ev_primary "*) : ;;
            *) add_v "FINAL_REPORT.md executive verdict '$ev_primary' is not in the known verdict set" ;;
        esac
    fi
fi

# --- Output -------------------------------------------------------------------
if [ "${#VIOLATIONS[@]}" -eq 0 ]; then
    printf 'PASS: %s\n' "$RUN"
    [ -n "$verdict" ] && printf '  Skeptic verdict: %s\n' "$verdict"
    exit 0
else
    printf 'FAIL: %s\n' "$RUN"
    [ -n "$verdict" ] && printf '  Skeptic verdict: %s\n' "$verdict"
    for v in "${VIOLATIONS[@]}"; do printf '  - %s\n' "$v"; done
    exit 1
fi
