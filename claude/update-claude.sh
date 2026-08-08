#!/bin/sh
# Update Claude Code config: pull skills repo, re-sync symlinks and local skills.
# Usage: update-claude [--unitial-dir <path>] [--agent-loadout-dir <path>] [--no-pull]
#   SKILLS_DIR         env var or ~/skills (default)
#   UNITIAL_DIR        env var or --unitial-dir flag; if set, also pulls Unitial and re-links CLAUDE.md
#   AGENT_LOADOUT_DIR  env var or --agent-loadout-dir flag; if set, also pulls agent-loadout
#                      (no symlinking — profiles are applied per-project via its own init-project.sh)
#   --no-pull          skip git pull steps (useful in CI where repos are already checked out)

MKDIR="/bin/mkdir"
NO_PULL=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --unitial-dir)       UNITIAL_DIR="$2"; shift 2 ;;
    --agent-loadout-dir) AGENT_LOADOUT_DIR="$2"; shift 2 ;;
    --no-pull)           NO_PULL=1; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done

# Stash local changes (if any), pull --ff-only, then restore the stash.
# Returns non-zero if the pull itself fails; stash pop failures are reported but non-fatal.
pull_with_stash() {
  repo_dir="$1"
  stashed=0
  if [ -n "$(git -C "${repo_dir}" status --porcelain)" ]; then
    git -C "${repo_dir}" stash push -u -m "update-claude autostash" >/dev/null || return 1
    stashed=1
  fi

  git -C "${repo_dir}" pull --ff-only
  pull_status=$?

  if [ "$stashed" -eq 1 ]; then
    git -C "${repo_dir}" stash pop || printf 'WARNING: git stash pop failed in %s; resolve manually\n' "${repo_dir}" >&2
  fi

  return "$pull_status"
}

SKILLS_DIR="${SKILLS_DIR:-${HOME}/skills}"

# 1. Pull skills repo
if [ -d "${SKILLS_DIR}/.git" ]; then
  if [ "$NO_PULL" -eq 0 ]; then
    printf 'Updating skills repo (%s)...\n' "$SKILLS_DIR"
    pull_with_stash "${SKILLS_DIR}" || { printf 'ERROR: git pull failed\n' >&2; exit 1; }
  fi
else
  printf 'ERROR: skills repo not found at %s\n' "${SKILLS_DIR}" >&2
  exit 1
fi

# 2. Re-sync symlinks
${MKDIR} -p ~/.claude
ln -sf "${SKILLS_DIR}/settings.json" ~/.claude/settings.json
rm -rf ~/.claude/commands
ln -sf "${SKILLS_DIR}/commands" ~/.claude/commands
printf 'Symlinks updated.\n'

# 3. Optionally pull Unitial and re-link CLAUDE.md
if [ -n "${UNITIAL_DIR}" ]; then
  if [ "$NO_PULL" -eq 0 ] && [ -d "${UNITIAL_DIR}/.git" ]; then
    printf 'Updating Unitial (%s)...\n' "$UNITIAL_DIR"
    pull_with_stash "${UNITIAL_DIR}" || printf 'WARNING: Unitial git pull failed, skipping\n'
  fi
  ln -sf "${UNITIAL_DIR}/claude/CLAUDE.md" ~/.claude/CLAUDE.md
  printf 'CLAUDE.md re-linked from Unitial.\n'
fi

# 4. Optionally pull agent-loadout (profile templates; applied per-project via its own init-project.sh)
if [ -n "${AGENT_LOADOUT_DIR}" ]; then
  if [ "$NO_PULL" -eq 0 ] && [ -d "${AGENT_LOADOUT_DIR}/.git" ]; then
    printf 'Updating agent-loadout (%s)...\n' "$AGENT_LOADOUT_DIR"
    pull_with_stash "${AGENT_LOADOUT_DIR}" || printf 'WARNING: agent-loadout git pull failed, skipping\n'
  fi
fi

printf '\nClaude Code configuration updated.\n'
