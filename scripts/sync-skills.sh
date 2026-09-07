#!/usr/bin/env bash
# Sync canonical skills/ directories into plugins/<name>/skills/<name>/
# This avoids broken symlinks on GitHub web UI and Windows checkouts.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
PLUGINS_DIR="$REPO_ROOT/plugins"

CHECK_MODE=false
if [[ "${1:-}" == "--check" ]]; then
  CHECK_MODE=true
fi

DRIFT_DETECTED=0

for skill_path in "$SKILLS_DIR"/*; do
  if [[ ! -d "$skill_path" ]]; then
    continue
  fi

  skill_name="$(basename "$skill_path")"
  target_dir="$PLUGINS_DIR/$skill_name/skills/$skill_name"

  if [[ "$CHECK_MODE" == true ]]; then
    if [[ ! -d "$target_dir" ]]; then
      echo "Drift: $target_dir does not exist"
      DRIFT_DETECTED=1
    elif ! diff -r "$skill_path" "$target_dir" > /dev/null 2>&1; then
      echo "Drift: $skill_path differs from $target_dir"
      DRIFT_DETECTED=1
    fi
  else
    mkdir -p "$PLUGINS_DIR/$skill_name/skills"
    rm -rf "$target_dir"
    cp -r "$skill_path" "$target_dir"
    echo "Synced: $skill_name -> plugins/$skill_name/skills/$skill_name"
  fi
done

if [[ "$CHECK_MODE" == true ]]; then
  if [[ "$DRIFT_DETECTED" -ne 0 ]]; then
    echo "Error: Skill drift detected. Run ./scripts/sync-skills.sh to sync."
    exit 1
  else
    echo "All plugin skill copies are in sync with skills/."
  fi
fi
