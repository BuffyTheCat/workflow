#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  bash workflow/install.sh [--project-root /path/to/project] [--no-entrypoints]

Default behavior assumes this package is placed at:
  <project-root>/workflow/

The installer appends managed AgentOps blocks to project-root AGENTS.md,
CLAUDE.md, and .gitignore. It does not touch application code and does not run
git stage/commit/push.
USAGE
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
project_root="$(cd "$script_dir/.." && pwd -P)"
write_entrypoints=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-root)
      if [[ $# -lt 2 ]]; then
        echo "ERROR: --project-root requires a path" >&2
        exit 2
      fi
      project_root="$(cd "$2" && pwd -P)"
      shift 2
      ;;
    --no-entrypoints)
      write_entrypoints=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

agentops_dir="$script_dir/AgentOps"
if [[ ! -d "$agentops_dir/Core" || ! -d "$agentops_dir/Adapters" ]]; then
  echo "ERROR: AgentOps package not found at $agentops_dir" >&2
  exit 1
fi

if [[ "$script_dir" == "$project_root" ]]; then
  workflow_rel="."
elif [[ "$script_dir" == "$project_root/"* ]]; then
  workflow_rel="${script_dir#$project_root/}"
else
  echo "ERROR: this workflow package must live inside the project root." >&2
  echo "Move it under the project, for example: $project_root/workflow/" >&2
  exit 1
fi

mkdir -p "$agentops_dir/Runtime" "$agentops_dir/RuntimeEvidence/runs"

append_managed_block() {
  local target_file="$1"
  local block_name="$2"
  local body="$3"
  local begin_marker="BEGIN AgentOps managed block: $block_name"
  local end_marker="END AgentOps managed block: $block_name"

  if [[ -f "$target_file" ]] && grep -Fq "$begin_marker" "$target_file"; then
    echo "already present: $target_file ($block_name)"
    return 0
  fi

  mkdir -p "$(dirname "$target_file")"
  {
    if [[ -f "$target_file" && -s "$target_file" ]]; then
      printf '\n'
    fi
    printf '<!-- %s -->\n' "$begin_marker"
    printf '%s\n' "$body"
    printf '<!-- %s -->\n' "$end_marker"
  } >> "$target_file"
  echo "updated: $target_file ($block_name)"
}

append_gitignore_block() {
  local target_file="$1"
  local begin_marker="BEGIN AgentOps managed block: runtime-ignore"
  local end_marker="END AgentOps managed block: runtime-ignore"

  if [[ -f "$target_file" ]] && grep -Fq "$begin_marker" "$target_file"; then
    echo "already present: $target_file (runtime-ignore)"
    return 0
  fi

  mkdir -p "$(dirname "$target_file")"
  {
    if [[ -f "$target_file" && -s "$target_file" ]]; then
      printf '\n'
    fi
    printf '# %s\n' "$begin_marker"
    printf '%s/AgentOps/Runtime/*\n' "$workflow_rel"
    printf '!%s/AgentOps/Runtime/.gitkeep\n' "$workflow_rel"
    printf '!%s/AgentOps/Runtime/README.md\n' "$workflow_rel"
    printf '%s/AgentOps/Runtime/imports/**\n' "$workflow_rel"
    printf '%s/AgentOps/Runtime/incidents/**\n' "$workflow_rel"
    printf '%s/AgentOps/RuntimeEvidence/runs/*\n' "$workflow_rel"
    printf '!%s/AgentOps/RuntimeEvidence/runs/README.md\n' "$workflow_rel"
    printf '%s/AgentOps/RuntimeEvidence/**/*.tmp\n' "$workflow_rel"
    printf '%s/AgentOps/RuntimeEvidence/**/*.log\n' "$workflow_rel"
    printf '# %s\n' "$end_marker"
  } >> "$target_file"
  echo "updated: $target_file (runtime-ignore)"
}

if [[ "$write_entrypoints" -eq 1 ]]; then
  append_managed_block \
    "$project_root/AGENTS.md" \
    "codex-entrypoint" \
    "Read \`$workflow_rel/AgentOps/Adapters/codex/AGENTS.md\` and \`$workflow_rel/AgentOps/Core/AGENT_OS.md\` before non-trivial work. Project-specific facts belong in \`$workflow_rel/AgentOps/MainVault/\`."

  append_managed_block \
    "$project_root/CLAUDE.md" \
    "claude-entrypoint" \
    "Read \`$workflow_rel/AgentOps/MainVault/01_ALWAYS_READ.md\`, then \`$workflow_rel/AgentOps/Adapters/claude/CLAUDE.md\` and \`$workflow_rel/AgentOps/Core/AGENT_OS.md\` before non-trivial work. Project-specific facts belong in \`$workflow_rel/AgentOps/MainVault/\`."
else
  echo "skipped: entrypoint files (--no-entrypoints)"
fi

append_gitignore_block "$project_root/.gitignore"

cat <<EOF

AgentOps workflow installed.
- Project root: $project_root
- Workflow path: $workflow_rel
- Next: start the agent from the project root and connect Linear MCP plus Git/GitHub MCP when ticket, PR, or repository-history evidence is needed.
EOF
